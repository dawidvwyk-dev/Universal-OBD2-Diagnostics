import 'package:obd_engine/obd_engine.dart';
import 'package:obd_sim/obd_sim.dart';
import 'package:obd_transport/obd_transport.dart';
import 'package:test/test.dart';

const _ble = TransportEndpoint(kind: TransportKind.bluetoothLe, address: 'AA:BB:CC', name: 'OBDII');
const _usb = TransportEndpoint(kind: TransportKind.usbSerial, address: 'COM5', name: 'USB adapter');

ElmEmulator _emu([SimAdapterProfile? p]) => ElmEmulator(vehicle: Scenarios.healthyCan(), profile: p ?? SimAdapterProfile.cloneV21);

void main() {
  test('BLE-style link: 20-byte writes and fragmented notifications', () async {
    final link = SimByteLink(_emu(), maxChunk: 20, replyChunk: 7, latency: const Duration(milliseconds: 2));
    final s = ObdSession(LinkTransport(_ble, link));
    await s.connect();
    expect(s.state, SessionState.ready);
    final v = await s.readPids([0x0C, 0x05, 0x0D, 0x42, 0x0F, 0x10, 0x11]);
    expect(v[0x05]!.single.value, isNotNull);
    expect(link.writeSizes.every((n) => n <= 20), isTrue);
    final id = await s.readIdentity();
    expect(id.vin, Scenarios.testVin);
    await s.close();
  });

  test('reconnects after the link drops and retries a failed open', () async {
    final link = SimByteLink(_emu());
    final t = LinkTransport(_ble, link);
    final s = ObdSession(t);
    await s.connect();
    link.drop();
    await Future<void>.delayed(Duration.zero);
    expect(t.state, TransportState.failed);
    link.failOpens = 1;
    final ok = await s.reconnect(firstDelay: const Duration(milliseconds: 10));
    expect(ok, isTrue);
    expect(link.opens, 3);
    expect((await s.readPids([0x0C]))[0x0C], isNotNull);
    await s.close();
  });

  test('detects the serial baud rate', () async {
    final emu = _emu(SimAdapterProfile.genuineElm);
    final (baud, attempts) = await detectBaudRate(
      [9600, 38400, 115200],
      (b) => LinkTransport(_usb, SimByteLink(emu, answersAtBaud: 38400, baud: b)),
      perTry: const Duration(milliseconds: 300),
    );
    expect(baud, 38400);
    expect(attempts.first.ok, isFalse);
    expect(attempts.first.detail, contains('unreadable'));
    expect(attempts.last.detail, contains('ELM327'));
  });

  test('baud detection reports no adapter', () async {
    final (baud, attempts) = await detectBaudRate(
      [9600],
      (b) => LinkTransport(_usb, SimByteLink(_emu(), failOpens: 1)),
      perTry: const Duration(milliseconds: 100),
    );
    expect(baud, isNull);
    expect(attempts.single.detail, contains('could not open'));
  });
}
