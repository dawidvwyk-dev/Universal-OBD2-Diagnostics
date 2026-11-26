import 'dart:async';
import 'dart:typed_data';

import 'package:obd_transport/obd_transport.dart';
import 'package:test/test.dart';

class FakeLink implements ByteLink {
  FakeLink({this.failOpen = false});
  bool failOpen;
  StreamController<Uint8List>? ctrl;
  final sent = <Uint8List>[];
  bool closed = false;
  @override
  int? get maxChunk => 20;
  @override
  Stream<Uint8List> get data => ctrl!.stream;
  @override
  Future<void> open(Duration timeout) async {
    if (failOpen) throw StateError('nope');
    ctrl = StreamController<Uint8List>();
    closed = false;
  }

  @override
  Future<void> send(Uint8List bytes) async => sent.add(bytes);
  @override
  Future<void> close() async {
    closed = true;
    await ctrl?.close();
  }
}

const ep = TransportEndpoint(kind: TransportKind.bluetoothLe, address: 'AA:BB', name: 'OBDII');

void main() {
  group('LinkTransport', () {
    test('opens, passes data, reports chunk size and closes', () async {
      final link = FakeLink();
      final t = LinkTransport(ep, link);
      final states = <TransportState>[];
      t.stateChanges.listen(states.add);
      await t.open();
      expect(t.state, TransportState.connected);
      expect(t.maxWriteSize, 20);
      final got = <int>[];
      t.input.listen(got.addAll);
      link.ctrl!.add(Uint8List.fromList([0x3e]));
      await t.write(Uint8List.fromList([65, 13]));
      await Future<void>.delayed(Duration.zero);
      expect(got, [0x3e]);
      expect(link.sent.single, [65, 13]);
      await t.close();
      expect(link.closed, isTrue);
      expect(states, [TransportState.connecting, TransportState.connected, TransportState.disconnected]);
    });

    test('open failure becomes failed state and TransportException', () async {
      final t = LinkTransport(ep, FakeLink(failOpen: true));
      await expectLater(t.open(), throwsA(isA<TransportException>()));
      expect(t.state, TransportState.failed);
    });

    test('lost link is reported as failed, user close is not', () async {
      final link = FakeLink();
      final t = LinkTransport(ep, link);
      await t.open();
      link.ctrl!.addError(StateError('gone'));
      await Future<void>.delayed(Duration.zero);
      expect(t.state, TransportState.failed);
      expect(() => t.write(Uint8List(1)), throwsA(isA<TransportException>()));
      // Can be reopened.
      await t.close();
      await t.open();
      expect(t.state, TransportState.connected);
      await t.close();
      expect(t.state, TransportState.disconnected);
    });
  });

  group('BLE channel selection', () {
    test('known FFF0 layout', () {
      final ch = selectBleChannel(const [
        BleServiceInfo('1800', [BleCharacteristicInfo('2a00')]),
        BleServiceInfo('0000fff0-0000-1000-8000-00805f9b34fb', [
          BleCharacteristicInfo('0000fff1-0000-1000-8000-00805f9b34fb', notify: true),
          BleCharacteristicInfo('0000fff2-0000-1000-8000-00805f9b34fb', write: true, writeWithoutResponse: true),
        ]),
      ]);
      expect(ch!.profile, contains('FFF0'));
      expect(ch.notify, endsWith('fff1-0000-1000-8000-00805f9b34fb'));
      expect(ch.withoutResponse, isTrue);
    });

    test('FFE0 uses one characteristic both ways', () {
      final ch = selectBleChannel(const [
        BleServiceInfo('FFE0', [BleCharacteristicInfo('FFE1', notify: true, writeWithoutResponse: true)]),
      ]);
      expect(ch!.notify, 'FFE1');
      expect(ch.write, 'FFE1');
    });

    test('Vgate custom service', () {
      final ch = selectBleChannel(const [
        BleServiceInfo('E7810A71-73AE-499D-8C15-FAA9AEF0C3F2',
            [BleCharacteristicInfo('BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F', notify: true, write: true)]),
      ]);
      expect(ch!.profile, contains('Vgate'));
      expect(ch.withoutResponse, isFalse);
    });

    test('generic fallback skips standard services', () {
      final ch = selectBleChannel(const [
        BleServiceInfo('180A', [BleCharacteristicInfo('2a29', notify: true, write: true)]),
        BleServiceInfo('12345678-1234-1234-1234-1234567890ab', [
          BleCharacteristicInfo('aaaa', notify: true),
          BleCharacteristicInfo('bbbb', write: true),
        ]),
      ]);
      expect(ch!.profile, 'generic');
      expect(ch.write, 'bbbb');
    });

    test('nothing usable', () {
      expect(selectBleChannel(const [BleServiceInfo('1800', [BleCharacteristicInfo('2a00', notify: true, write: true)])]), isNull);
      expect(selectBleChannel(const [BleServiceInfo('fff0', [BleCharacteristicInfo('fff1', notify: true)])]), isNull);
    });

    test('helpers', () {
      expect(fullUuid('FFF0'), '0000fff0-0000-1000-8000-00805f9b34fb');
      expect(bleChunkSize(null), 20);
      expect(bleChunkSize(185), 182);
      expect(looksLikeObdAdapter('OBDII'), isTrue);
      expect(looksLikeObdAdapter('vLinker MC-Android'), isTrue);
      expect(looksLikeObdAdapter('IOS-Vlink'), isTrue);
      expect(looksLikeObdAdapter('Galaxy Buds'), isFalse);
    });
  });

  group('serial ids', () {
    test('chips and port ranking', () {
      expect(usbSerialChip(0x1a86, 0x7523)!.name, contains('CH340'));
      expect(usbSerialChip(0x1234, 0x5678), isNull);
      expect(const SerialPortInfo(name: 'COM3', vendorId: 0x0403, productId: 0x6015).likelyAdapter, isTrue);
      expect(const SerialPortInfo(name: 'COM1', description: 'Communications Port').likelyAdapter, isFalse);
      expect(const SerialPortInfo(name: 'COM7', bluetooth: true).likelyAdapter, isTrue);
      expect(baudOrderFor(product: 'OBDLink SX').first, 115200);
      expect(baudOrderFor().first, 38400);
    });
  });
}
