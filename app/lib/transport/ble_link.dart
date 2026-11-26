import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:obd_transport/obd_transport.dart';
import 'package:universal_ble/universal_ble.dart';

/// Bluetooth LE scan on Android and Windows.
class BleScanner {
  static Future<String?> availability() async {
    final s = await UniversalBle.getBluetoothAvailabilityState();
    return switch (s) {
      AvailabilityState.poweredOn => null,
      AvailabilityState.poweredOff => 'Bluetooth is switched off.',
      AvailabilityState.unauthorized => 'Bluetooth permission was not granted.',
      AvailabilityState.unsupported => 'This device has no Bluetooth LE support.',
      _ => 'Bluetooth is not ready (${s.name}).',
    };
  }

  static Stream<(TransportEndpoint, bool)> scan() {
    late StreamController<(TransportEndpoint, bool)> c;
    StreamSubscription<BleDevice>? sub;
    c = StreamController(
      onListen: () async {
        sub = UniversalBle.scanStream.listen((d) {
          final name = d.name ?? d.rawName;
          c.add((
            TransportEndpoint(
              kind: TransportKind.bluetoothLe,
              address: d.deviceId,
              name: name == null || name.isEmpty ? d.deviceId : name,
              signalStrength: d.rssi,
            ),
            d.paired == true,
          ));
        });
        try {
          await UniversalBle.startScan(skipDuplicates: false);
        } catch (e) {
          c.addError(e);
        }
      },
      onCancel: () async {
        await sub?.cancel();
        try {
          await UniversalBle.stopScan();
        } catch (_) {}
      },
    );
    return c.stream;
  }
}

/// A BLE adapter's serial stream: one notifying and one writable
/// characteristic, chosen by [selectBleChannel].
class BleByteLink implements ByteLink {
  BleByteLink(this.deviceId);
  final String deviceId;
  BleChannel? channel;
  int _chunk = 20;
  StreamController<Uint8List>? _ctrl;
  final _subs = <StreamSubscription<Object?>>[];

  @override
  int? get maxChunk => _chunk;

  @override
  Stream<Uint8List> get data => _ctrl!.stream;

  @override
  Future<void> open(Duration timeout) async {
    final c = StreamController<Uint8List>();
    _ctrl = c;
    await UniversalBle.connect(deviceId, timeout: timeout);
    final services = await UniversalBle.discoverServices(deviceId);
    final ch = selectBleChannel([
      for (final s in services)
        BleServiceInfo(s.uuid, [
          for (final x in s.characteristics)
            BleCharacteristicInfo(
              x.uuid,
              notify: x.properties.contains(CharacteristicProperty.notify),
              indicate: x.properties.contains(CharacteristicProperty.indicate),
              write: x.properties.contains(CharacteristicProperty.write),
              writeWithoutResponse: x.properties.contains(CharacteristicProperty.writeWithoutResponse),
            ),
        ]),
    ]);
    if (ch == null) {
      await UniversalBle.disconnect(deviceId);
      throw StateError('This Bluetooth LE device has no serial data channel, so it is probably not an OBD adapter.');
    }
    channel = ch;
    if (!kIsWeb && Platform.isAndroid) {
      try {
        _chunk = bleChunkSize(await UniversalBle.requestMtu(deviceId, 247));
      } catch (_) {
        _chunk = 20;
      }
    }
    _subs.add(UniversalBle.characteristicValueStream(deviceId, ch.notify, serviceId: ch.service).listen(c.add));
    _subs.add(UniversalBle.connectionStream(deviceId).listen((connected) {
      if (!connected && !c.isClosed) {
        c.addError(StateError('Bluetooth LE link lost'));
        c.close();
      }
    }));
    final notifyChar = services
        .firstWhere((s) => s.uuid == ch.service)
        .characteristics
        .firstWhere((x) => x.uuid == ch.notify);
    if (notifyChar.properties.contains(CharacteristicProperty.notify)) {
      await UniversalBle.subscribeNotifications(deviceId, ch.service, ch.notify);
    } else {
      await UniversalBle.subscribeIndications(deviceId, ch.service, ch.notify);
    }
  }

  @override
  Future<void> send(Uint8List bytes) {
    final ch = channel!;
    return UniversalBle.write(deviceId, ch.service, ch.write, bytes, withoutResponse: ch.withoutResponse);
  }

  @override
  Future<void> close() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    final c = _ctrl;
    _ctrl = null;
    if (c != null && !c.isClosed) unawaited(c.close()); // done future can wait forever
    try {
      await UniversalBle.disconnect(deviceId);
    } catch (_) {}
  }
}
