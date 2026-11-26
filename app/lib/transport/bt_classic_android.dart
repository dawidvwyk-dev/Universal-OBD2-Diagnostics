import 'dart:async';

import 'package:flutter/services.dart';
import 'package:obd_transport/obd_transport.dart';

const _methods = MethodChannel('rogue/bt_classic');
const _discovery = EventChannel('rogue/bt_classic/discovery');
const _data = EventChannel('rogue/bt_classic/data');

TransportEndpoint _endpoint(Map<Object?, Object?> m) => TransportEndpoint(
      kind: TransportKind.bluetoothClassic,
      address: m['address']! as String,
      name: (m['name'] as String?)?.isNotEmpty == true ? m['name']! as String : m['address']! as String,
      signalStrength: m['rssi'] as int?,
    );

/// Android Bluetooth Classic (SPP), backed by BluetoothClassicChannel.kt.
class AndroidBtClassic {
  static Future<bool> isEnabled() async => await _methods.invokeMethod<bool>('isEnabled') ?? false;

  /// Paired devices. Most Bluetooth Classic adapters must be paired in
  /// Android settings first (PIN usually 1234 or 0000).
  static Future<List<(TransportEndpoint, bool)>> bonded() async {
    final list = await _methods.invokeListMethod<Map<Object?, Object?>>('bondedDevices') ?? const [];
    return [for (final m in list) (_endpoint(m), true)];
  }

  /// Nearby devices found by a discovery scan (about 12 seconds).
  static Stream<(TransportEndpoint, bool)> discover() {
    late StreamController<(TransportEndpoint, bool)> c;
    StreamSubscription<Object?>? sub;
    c = StreamController(
      onListen: () async {
        sub = _discovery.receiveBroadcastStream().listen((e) {
          final m = e! as Map<Object?, Object?>;
          c.add((_endpoint(m), m['bonded'] == true));
        }, onError: c.addError);
        try {
          await _methods.invokeMethod<bool>('startDiscovery');
        } catch (e) {
          c.addError(e);
        }
      },
      onCancel: () async {
        await sub?.cancel();
        await _methods.invokeMethod<void>('cancelDiscovery');
      },
    );
    return c.stream;
  }
}

class AndroidBtClassicLink implements ByteLink {
  AndroidBtClassicLink(this.address);
  final String address;
  StreamController<Uint8List>? _ctrl;
  StreamSubscription<Object?>? _sub;

  @override
  int? get maxChunk => null;

  @override
  Stream<Uint8List> get data => _ctrl!.stream;

  @override
  Future<void> open(Duration timeout) async {
    final c = StreamController<Uint8List>();
    _ctrl = c;
    _sub = _data.receiveBroadcastStream().listen(
          (e) => c.add(e! as Uint8List),
          onError: (Object e) {
            if (!c.isClosed) {
              c.addError(e);
              c.close();
            }
          },
        );
    await _methods.invokeMethod<void>('connect', {'address': address}).timeout(timeout);
  }

  @override
  Future<void> send(Uint8List bytes) => _methods.invokeMethod<void>('write', {'data': bytes});

  @override
  Future<void> close() async {
    await _sub?.cancel();
    _sub = null;
    final c = _ctrl;
    _ctrl = null;
    if (c != null && !c.isClosed) unawaited(c.close()); // done future can wait forever
    try {
      await _methods.invokeMethod<void>('disconnect');
    } catch (_) {}
  }
}
