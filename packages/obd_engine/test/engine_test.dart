
import 'package:obd_decoders/obd_decoders.dart';
import 'package:obd_engine/obd_engine.dart';
import 'package:obd_protocols/obd_protocols.dart';
import 'package:obd_sim/obd_sim.dart';
import 'package:obd_transport/obd_transport.dart';
import 'package:test/test.dart';

double _t = 0;
ElmEmulator emu(VirtualVehicle v, [SimAdapterProfile p = SimAdapterProfile.genuineElm]) =>
    ElmEmulator(vehicle: v, profile: p, clock: () => _t);

Future<ObdSession> connected(ElmEmulator e, {int? chunk, ObdProtocol protocol = ObdProtocol.auto}) async {
  final s = ObdSession(simulatorTransport(e, chunkSize: chunk));
  await s.connect(protocol: protocol);
  return s;
}

void main() {
  group('adapter probing', () {
    test('genuine ELM supports everything but STN', () async {
      final s = await connected(emu(Scenarios.healthyCan()));
      final a = s.adapter!;
      expect(a.chip, ChipFamily.elm327);
      expect(a.claimedVersion, '2.3');
      expect(a.likelyClone, isFalse);
      expect(a.supportsEnhanced, isTrue);
      expect(a.supports(AdapterCapability.stnExtensions), isFalse);
      expect(a.voltage, 12.6);
    });

    test('v1.5 clone is detected and its gaps explained', () async {
      final s = await connected(emu(Scenarios.healthyCan(), SimAdapterProfile.cloneV15));
      final a = s.adapter!;
      expect(a.likelyClone, isTrue);
      expect(a.supportsEnhanced, isFalse);
      expect(a.limitations, contains(contains('CAN receive address filter')));
      expect(a.manufacturer, contains('clone'));
    });

    test('v2.1 clone without ATDPN still finds the protocol', () async {
      final s = await connected(emu(Scenarios.healthyCan(), SimAdapterProfile.cloneV21));
      expect(s.adapter!.supports(AdapterCapability.describeProtocol), isFalse);
      expect(s.protocol, ObdProtocol.can11b500);
      expect(s.ecus, ['7E8', '7E9']);
    });

    test('OBDLink STN identified', () async {
      final s = await connected(emu(Scenarios.healthyCan(), SimAdapterProfile.obdLinkStn));
      expect(s.adapter!.chip, ChipFamily.stn);
      expect(s.adapter!.manufacturer, contains('OBDLink'));
    });

    test('link quality burst', () async {
      final s = await connected(emu(Scenarios.healthyCan()));
      final q = await measureLinkQuality(s.link, count: 5);
      expect(q.answered, 5);
      expect(q.successRate, 1.0);
    });
  });

  group('protocol detection', () {
    test('auto-detects CAN 11-bit and both ECUs', () async {
      final s = await connected(emu(Scenarios.healthyCan()));
      expect(s.protocol, ObdProtocol.can11b500);
      expect(s.ecus, ['7E8', '7E9']);
      expect(s.isSupported(0x0C), isTrue);
      expect(s.isSupported(0x5C), isFalse);
    });

    test('auto-detects 29-bit CAN', () async {
      final s = await connected(emu(Scenarios.diesel29Bit()));
      expect(s.protocol, ObdProtocol.can29b500);
      expect(s.ecus.single, '18DAF110');
    });

    test('auto-detects legacy ISO 9141-2', () async {
      final s = await connected(emu(Scenarios.legacyIso9141()));
      expect(s.protocol, ObdProtocol.iso9141);
      expect(s.ecus.single, '10');
    });

    test('manual protocol that does not match fails clearly', () async {
      final v = Scenarios.healthyCan();
      final s = ObdSession(simulatorTransport(emu(v)));
      await expectLater(s.connect(protocol: ObdProtocol.iso9141),
          throwsA(isA<ObdException>().having((e) => e.elmError, 'error', ElmError.busInitError)));
      expect(s.state, SessionState.failed);
    });

    test('ignition off: unable to connect', () async {
      final v = Scenarios.healthyCan()..ignitionOn = false;
      final s = ObdSession(simulatorTransport(emu(v)));
      await expectLater(s.connect(),
          throwsA(isA<ObdException>().having((e) => e.elmError, 'error', ElmError.unableToConnect)));
    });
  });

  group('reading data', () {
    test('live PIDs batched on CAN', () async {
      final e = emu(Scenarios.healthyCan());
      final s = await connected(e);
      final before = e.requestCount;
      final v = await s.readPids([0x0C, 0x05, 0x0D, 0x42, 0x0F, 0x10, 0x11]);
      expect(e.requestCount - before, 2); // 6 + 1
      expect(v[0x05]!.single.value, 90);
      expect(v[0x0C]!.single.value, closeTo(780, 30));
      expect(v[0x42]!.single.value, closeTo(14.2, 0.01));
    });

    test('unsupported PIDs are skipped, not invented', () async {
      final s = await connected(emu(Scenarios.healthyCan()));
      final v = await s.readPids([0x5C, 0x0C]);
      expect(v.keys, [0x0C]);
    });

    test('legacy protocol reads singly and over chunked BLE-like link', () async {
      final s = await connected(emu(Scenarios.legacyIso9141()), chunk: 20);
      final v = await s.readPids([0x0C, 0x05]);
      expect(v[0x05]!.single.value, 90);
    });

    test('stored, pending and permanent DTCs on CAN', () async {
      final s = await connected(emu(Scenarios.misfire()));
      expect((await s.readDtcs(DtcStatus.stored)).all.map((d) => d.code), ['P0300', 'P0302']);
      expect((await s.readDtcs(DtcStatus.pending)).all.single.code, 'P0304');
      expect((await s.readDtcs(DtcStatus.permanent)).all, isEmpty);
    });

    test('legacy DTCs over two frames', () async {
      final s = await connected(emu(Scenarios.legacyIso9141()));
      final r = await s.readDtcs(DtcStatus.stored);
      expect(r.all.map((d) => d.code), ['P0133', 'P0420', 'P0441', 'P0455']);
    });

    test('readiness', () async {
      final s = await connected(emu(Scenarios.misfire()));
      final r = (await s.readReadiness())!;
      expect(r.milOn, isTrue);
      expect(r.incomplete.single.key, 'catalyst');
    });

    test('freeze frame', () async {
      final s = await connected(emu(Scenarios.leanBank1()));
      final (dtc, values) = await s.readFreezeFrame();
      expect(dtc!.code, 'P0171');
      expect(values[0x0C]!.single.value, 2150);
      expect(values[0x07]!.single.value, closeTo(19, 1));
    });

    test('vehicle identity on CAN', () async {
      final s = await connected(emu(Scenarios.healthyCan()));
      final id = await s.readIdentity();
      expect(id.vin, Scenarios.testVin);
      expect(id.calibrationIds['7E8'], ['SIMCAL0001']);
      expect(id.ecuNames['7E8'], 'ECM-EngineControl');
      expect(id.obdStandard, 'EOBD (Europe)');
      expect(id.fuelType, 'Gasoline');
    });

    test('vehicle identity on legacy (5-frame VIN)', () async {
      final s = await connected(emu(Scenarios.legacyIso9141()));
      expect((await s.readIdentity()).vin, 'WVWZZZ1JZ3W386752');
    });

    test('VIN on 29-bit CAN', () async {
      final s = await connected(emu(Scenarios.diesel29Bit()));
      final id = await s.readIdentity();
      expect(id.vin, 'WF0XXXTTGXKA12345');
      expect(id.manufacturer, 'Ford (Germany)');
    });

    test('battery voltage from ATRV, falls back to PID 42 on clones', () async {
      var s = await connected(emu(Scenarios.weakCharging()));
      expect(await s.readBatteryVoltage(), 11.9);
      s = await connected(emu(Scenarios.weakCharging(), SimAdapterProfile.cloneV21));
      expect(await s.readBatteryVoltage(), closeTo(12.1, 0.01));
    });
  });

  group('safety gate', () {
    test('clearing codes is blocked without a permit', () async {
      final s = await connected(emu(Scenarios.misfire()));
      await expectLater(s.request(const ObdRequest(0x04)), throwsA(isA<SafetyException>()));
      expect((await s.readDtcs(DtcStatus.stored)).all, isNotEmpty);
    });

    test('permit needs confirmation and is single use', () async {
      final s = await connected(emu(Scenarios.misfire()));
      expect(() => s.gate.authorize(WriteAction.clearDtcs, vin: null, userConfirmed: false),
          throwsA(isA<SafetyException>()));
      final p = s.gate.authorize(WriteAction.clearDtcs, vin: null, userConfirmed: true);
      expect(await s.clearDtcs(p), isTrue);
      expect((await s.readDtcs(DtcStatus.stored)).all, isEmpty);
      await expectLater(s.clearDtcs(p), throwsA(isA<SafetyException>()));
    });

    test('permit for another vehicle is rejected', () async {
      final s = await connected(emu(Scenarios.misfire()));
      await s.readIdentity();
      final p = s.gate.authorize(WriteAction.clearDtcs, vin: 'WVWZZZ1JZ3W386752', userConfirmed: true);
      await expectLater(s.clearDtcs(p), throwsA(isA<SafetyException>()));
    });

    test('permanent codes survive a clear', () async {
      final s = await connected(emu(Scenarios.leanBank1()));
      await s.clearDtcs(s.gate.authorize(WriteAction.clearDtcs, vin: null, userConfirmed: true));
      expect((await s.readDtcs(DtcStatus.permanent)).all.single.code, 'P0171');
    });
  });

  group('faults and recovery', () {
    test('timeout when adapter goes silent', () async {
      final t = MemoryTransport(
        endpoint: const TransportEndpoint(kind: TransportKind.simulator, address: 'mute', name: 'mute'),
        onWrite: (_, __) {},
      );
      await t.open();
      final link = ElmLink(t);
      await expectLater(link.send('ATI', timeout: const Duration(milliseconds: 50)),
          throwsA(isA<ElmTimeoutException>()));
      expect(link.timeouts, 1);
    });

    test('adapter errors are mapped to messages', () async {
      final e = emu(Scenarios.healthyCan());
      final s = await connected(e);
      e.forcedReply = 'CAN ERROR';
      await expectLater(s.readPids([0x0C]),
          throwsA(isA<ObdException>().having((x) => x.message, 'msg', contains('CAN bus'))));
    });

    test('pending request fails fast when the link drops', () async {
      final e = emu(Scenarios.healthyCan());
      final transport = simulatorTransport(e, latency: const Duration(milliseconds: 200));
      final s = ObdSession(transport);
      await s.connect();
      final f = s.readPids([0x0C]);
      transport.drop();
      await expectLater(f, throwsA(isA<LinkClosedException>()));
    });

    test('reconnect restores protocol', () async {
      final e = emu(Scenarios.healthyCan());
      final transport = simulatorTransport(e);
      final s = ObdSession(transport);
      await s.connect();
      transport.drop();
      expect(await s.reconnect(firstDelay: const Duration(milliseconds: 1)), isTrue);
      expect(s.state, SessionState.ready);
      expect((await s.readPids([0x05]))[0x05]!.single.value, 90);
    });

    test('communication log records traffic', () async {
      final s = await connected(emu(Scenarios.healthyCan()));
      expect(s.log.export(), contains('>> 0100'));
    });
  });

  group('TCP transport against simulator server', () {
    test('full session over a real socket', () async {
      final server = SimulatorServer(vehicleFactory: Scenarios.leanBank1);
      await server.start(port: 0);
      addTearDown(server.stop);
      final s = ObdSession(TcpTransport(TransportEndpoint(
          kind: TransportKind.wifi, address: '127.0.0.1', name: 'sim', port: server.port)));
      await s.connect();
      expect((await s.readDtcs(DtcStatus.stored)).all.single.code, 'P0171');
      await s.close();
    });

    test('connection refused is a TransportException', () async {
      final s = ObdSession(TcpTransport(const TransportEndpoint(
          kind: TransportKind.wifi, address: '127.0.0.1', name: 'none', port: 1)));
      await expectLater(s.connect(), throwsA(isA<TransportException>()));
    });
  });

}
