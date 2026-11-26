import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obd_transport/obd_transport.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ble_link.dart';
import 'bt_classic_android.dart';
import 'serial_windows.dart';
import 'usb_android.dart';

/// One adapter found by a scan or a port listing.
class DiscoveredAdapter {
  const DiscoveredAdapter(this.endpoint, {this.paired = false, this.detail, this.likelyObd = false});
  final TransportEndpoint endpoint;
  final bool paired;

  /// Extra information such as the USB chip or "Bluetooth COM port".
  final String? detail;

  /// Name or chip suggests an OBD adapter. Used for sorting and a badge only.
  final bool likelyObd;
}

/// Platform adapter discovery and transport creation. Tests replace this.
abstract class AdapterDiscovery {
  /// Transport kinds this platform supports, in the order shown.
  List<TransportKind> get kinds;

  /// Short help shown above a transport's device list.
  String help(TransportKind kind);

  /// Requests the runtime permissions [kind] needs. Returns a message for the
  /// user when something is missing, else null.
  Future<String?> prepare(TransportKind kind);

  /// Devices for [kind]. Bluetooth scans keep emitting until cancelled or
  /// the scan time ends; wired lists emit once.
  Stream<List<DiscoveredAdapter>> discover(TransportKind kind);

  /// A transport for [endpoint]. Serial endpoints need a baud rate.
  ObdTransport transportFor(TransportEndpoint endpoint);
}

class PlatformAdapterDiscovery implements AdapterDiscovery {
  bool get _android => !kIsWeb && Platform.isAndroid;
  bool get _windows => !kIsWeb && Platform.isWindows;

  @override
  List<TransportKind> get kinds => [
        if (_android) TransportKind.bluetoothClassic,
        if (_android || _windows) TransportKind.bluetoothLe,
        if (_android || _windows) TransportKind.usbSerial,
      ];

  @override
  String help(TransportKind kind) => switch (kind) {
        TransportKind.bluetoothClassic =>
          'Most ELM327 Bluetooth adapters. Pair the adapter in Android Bluetooth settings first (PIN is usually 1234 or 0000), '
              'then pick it here. Unpaired adapters appear after a search.',
        TransportKind.bluetoothLe =>
          'Bluetooth LE adapters (for example vLinker, OBDLink CX, Veepeak BLE). Do not pair them in system settings; just search and connect.',
        TransportKind.usbSerial => _windows
            ? 'USB cables and paired Bluetooth Classic adapters both appear as COM ports. For a Bluetooth adapter, pair it in Windows '
                'Settings first, then use its outgoing COM port. The baud rate is detected automatically.'
            : 'USB OBD cables through a USB OTG adapter. Android asks for permission the first time. The baud rate is detected automatically.',
        _ => '',
      };

  @override
  Future<String?> prepare(TransportKind kind) async {
    if (!_android) return null;
    if (kind == TransportKind.usbSerial) return null;
    final perms = [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.locationWhenInUse];
    final res = await perms.request();
    final scan = res[Permission.bluetoothScan]!;
    final connect = res[Permission.bluetoothConnect]!;
    final location = res[Permission.locationWhenInUse]!;
    // Android 12+ uses the Bluetooth permissions; older versions need location.
    final ok = (scan.isGranted && connect.isGranted) || location.isGranted;
    if (!ok) {
      if (scan.isPermanentlyDenied || connect.isPermanentlyDenied) {
        return 'Bluetooth permission is blocked. Allow "Nearby devices" for this app in Android settings.';
      }
      return 'Bluetooth permission is needed to find and connect to adapters.';
    }
    if (kind == TransportKind.bluetoothClassic && !await AndroidBtClassic.isEnabled()) return 'Bluetooth is switched off.';
    if (kind == TransportKind.bluetoothLe) return BleScanner.availability();
    return null;
  }

  @override
  Stream<List<DiscoveredAdapter>> discover(TransportKind kind) {
    switch (kind) {
      case TransportKind.bluetoothClassic:
        return _accumulate(() async* {
          for (final (e, b) in await AndroidBtClassic.bonded()) {
            yield (e, b);
          }
          yield* AndroidBtClassic.discover();
        }(), const Duration(seconds: 14));
      case TransportKind.bluetoothLe:
        return _accumulate(BleScanner.scan(), const Duration(seconds: 12));
      case TransportKind.usbSerial:
        return Stream.fromFuture(_serial());
      default:
        return const Stream.empty();
    }
  }

  Future<List<DiscoveredAdapter>> _serial() async {
    final ports = _windows ? WindowsSerial.ports() : [for (final (p, _) in await AndroidUsb.devices()) p];
    final list = [
      for (final p in ports)
        DiscoveredAdapter(
          TransportEndpoint(
            kind: TransportKind.usbSerial,
            address: p.name,
            name: _windows ? '${p.name}${p.description != null ? ' (${p.description})' : ''}' : (p.description ?? 'USB device ${p.name}'),
          ),
          detail: [
            if (p.bluetooth) 'Bluetooth COM port',
            if (p.chip != null) p.chip!.name,
            if (p.manufacturer != null) p.manufacturer!,
          ].join(' · '),
          likelyObd: p.likelyAdapter,
        ),
    ];
    list.sort((a, b) => (b.likelyObd ? 1 : 0) - (a.likelyObd ? 1 : 0));
    return list;
  }

  /// Merges scan results by address, keeps the list sorted (likely adapters
  /// and strongest signal first) and stops after [limit].
  Stream<List<DiscoveredAdapter>> _accumulate(Stream<(TransportEndpoint, bool)> source, Duration limit) {
    final found = <String, DiscoveredAdapter>{};
    late StreamController<List<DiscoveredAdapter>> c;
    StreamSubscription<(TransportEndpoint, bool)>? sub;
    Timer? timer;
    void emit() {
      final l = found.values.toList()
        ..sort((a, b) {
          final o = (b.likelyObd ? 1 : 0) - (a.likelyObd ? 1 : 0);
          if (o != 0) return o;
          final p = (b.paired ? 1 : 0) - (a.paired ? 1 : 0);
          if (p != 0) return p;
          return (b.endpoint.signalStrength ?? -999) - (a.endpoint.signalStrength ?? -999);
        });
      c.add(l);
    }

    Future<void> stop() async {
      timer?.cancel();
      await sub?.cancel();
      sub = null;
      if (!c.isClosed) unawaited(c.close());
    }

    c = StreamController(
      onListen: () {
        emit();
        sub = source.listen((r) {
          final (e, paired) = r;
          final old = found[e.address];
          found[e.address] = DiscoveredAdapter(e,
              paired: paired || (old?.paired ?? false), likelyObd: looksLikeObdAdapter(e.name), detail: paired ? 'Paired' : null);
          emit();
        }, onError: c.addError, onDone: stop);
        timer = Timer(limit, stop);
      },
      onCancel: stop,
    );
    return c.stream;
  }

  @override
  ObdTransport transportFor(TransportEndpoint e) => switch (e.kind) {
        TransportKind.bluetoothClassic => LinkTransport(e, AndroidBtClassicLink(e.address)),
        TransportKind.bluetoothLe => LinkTransport(e, BleByteLink(e.address)),
        TransportKind.usbSerial => LinkTransport(
            e, _windows ? WindowsSerialLink(e.address, e.baudRate ?? 38400) : AndroidUsbLink(e.address, e.baudRate ?? 38400)),
        TransportKind.wifi => TcpTransport(e),
        TransportKind.simulator => throw ArgumentError('Simulator transports are created by the simulator'),
      };
}

final adapterDiscoveryProvider = Provider<AdapterDiscovery>((ref) => PlatformAdapterDiscovery());
