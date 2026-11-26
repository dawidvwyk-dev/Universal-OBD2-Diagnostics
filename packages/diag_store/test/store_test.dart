import 'dart:io';

import 'package:diag_store/diag_store.dart';
import 'package:drift/drift.dart' show Value;
import 'package:obd_decoders/obd_decoders.dart';
import 'package:test/test.dart';

const vin = '1M8GDM9AXKP042788';

ScanRecord scan(DateTime t, List<String> codes, {int? vehicleId, bool simulated = false, double rpm = 800}) => ScanRecord(
      vehicleId: vehicleId,
      time: t,
      full: true,
      simulated: simulated,
      vin: vin,
      protocol: 'ISO 15765-4 CAN (11 bit, 500 kbaud)',
      adapter: 'ELM327 v2.3',
      batteryVolts: 12.6,
      milOn: codes.isNotEmpty,
      dtcs: [for (final c in codes) (Dtc.parse(c), DtcStatus.stored, '7E8')],
      snapshot: {
        0x0C: [PidValue(key: 'rpm', name: 'Engine speed', value: rpm, unit: ObdUnit.rpm)],
        0x51: [const PidValue(key: 'fuel_type', name: 'Fuel type', value: 1, unit: ObdUnit.none, text: 'Gasoline')],
      },
      freezeFrame: {
        0x05: [const PidValue(key: 'coolant_temp', name: 'Coolant', value: 88, unit: ObdUnit.celsius)],
      },
      monitors: const [
        ReadinessMonitor('catalyst', 'Catalyst', MonitorState.incomplete),
        ReadinessMonitor('evap', 'Evaporative system', MonitorState.notSupported),
      ],
      errors: const ['Reading freeze frame: timeout'],
    );

void main() {
  late DiagDatabase db;
  late DiagRepository repo;
  setUp(() {
    db = DiagDatabase.memory();
    repo = DiagRepository(db);
  });
  tearDown(() => db.close());

  group('vehicles', () {
    test('create from VIN once', () async {
      final a = await repo.vehicleForVin(vin, manufacturer: 'Test', modelYear: 2019);
      final b = await repo.vehicleForVin(vin);
      expect(a, b);
      final v = (await repo.watchVehicles().first).single;
      expect(v.modelYear, 2019);
      expect(v.name, 'Test ($vin)');
    });

    test('rejects invalid VIN', () {
      expect(() => repo.addVehicle(VehiclesCompanion.insert(name: 'x', vin: const Value('BADVIN'))), throwsArgumentError);
    });

    test('notes and cascade delete', () async {
      final id = await repo.vehicleForVin(vin);
      await repo.addNote(id, 'Replaced front O2 sensor');
      await repo.saveScan(scan(DateTime(2026, 1, 1), ['P0171'], vehicleId: id));
      expect((await repo.watchNotes(id).first).single.body, 'Replaced front O2 sensor');
      await repo.deleteVehicle(id);
      expect(await repo.watchScans().first, isEmpty);
    });
  });

  group('scans', () {
    test('round trip keeps codes, readings, monitors and errors', () async {
      final id = await repo.saveScan(scan(DateTime(2026, 3, 4, 10), ['P0171', 'P0300']));
      final r = (await repo.loadScan(id))!;
      expect(r.allCodes, {'P0171', 'P0300'});
      expect(r.snapshot[0x0C]!.single.value, 800);
      expect(r.snapshot[0x51]!.single.text, 'Gasoline');
      expect(r.freezeFrame[0x05]!.single.unit, ObdUnit.celsius);
      expect(r.monitors.single.key, 'catalyst'); // unsupported monitors not stored
      expect(r.errors.single, contains('timeout'));
      expect(r.full, isTrue);
    });

    test('simulated scans are hidden from history by default', () async {
      await repo.saveScan(scan(DateTime(2026, 1, 1), [], simulated: true));
      await repo.saveScan(scan(DateTime(2026, 1, 2), []));
      expect((await repo.watchScans().first).length, 1);
      expect((await repo.watchScans(includeSimulated: true).first).length, 2);
    });

    test('compare scans', () async {
      final a = await repo.saveScan(scan(DateTime(2026, 1, 1), ['P0171', 'P0420'], rpm: 800));
      final b = await repo.saveScan(scan(DateTime(2026, 2, 1), ['P0420', 'P0300'], rpm: 760));
      final c = (await repo.compare(b, a))!; // order-independent
      expect(c.newCodes, {'P0300'});
      expect(c.resolvedCodes, {'P0171'});
      expect(c.persistingCodes, {'P0420'});
      expect(c.readingChanges['rpm']!.$2.value, 760);
    });
  });

  group('DTC packs', () {
    final pack = DtcPackInput(id: 'test-generic', title: 'Test pack', version: '1', source: 'Unit test fixture', scope: 'generic');

    test('no pack: unknown code returns null', () async {
      expect(await repo.lookupDtc('P0171'), isNull);
    });

    test('manufacturer definition wins over generic', () async {
      await repo.installPack(pack, [
        DtcDefinitionInput(code: 'P1234', description: 'Generic text', confidence: 'generic'),
      ]);
      await repo.installPack(
        DtcPackInput(id: 'test-vw', title: 'VW', version: '1', source: 'fixture', scope: 'Volkswagen'),
        [DtcDefinitionInput(code: 'P1234', description: 'VW text', manufacturer: 'Volkswagen', confidence: 'verified', severity: 'medium')],
      );
      expect((await repo.lookupDtc('p1234', manufacturer: 'volkswagen'))!.description, 'VW text');
      expect((await repo.lookupDtc('P1234', manufacturer: 'Ford'))!.description, 'Generic text');
      expect((await repo.searchDtcs('vw')).single.code, 'P1234');
    });

    test('invalid pack rejected whole', () async {
      expect(
        () => repo.installPack(pack, [
          DtcDefinitionInput(code: 'P0171', description: 'ok', confidence: 'generic'),
          DtcDefinitionInput(code: 'P0172', description: 'x', confidence: 'generic', severity: 'scary'),
        ]),
        throwsArgumentError,
      );
      expect(await repo.lookupDtc('P0171'), isNull);
    });

    test('reinstalling a pack replaces it', () async {
      await repo.installPack(pack, [DtcDefinitionInput(code: 'P0171', description: 'v1', confidence: 'generic')]);
      await repo.installPack(pack, [DtcDefinitionInput(code: 'P0171', description: 'v2', confidence: 'generic')]);
      expect((await repo.lookupDtc('P0171'))!.description, 'v2');
    });
  });

  group('encryption', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('diag_store'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('linked SQLite supports encryption', () {
      expect(encryptionAvailable(), isTrue);
    });

    test('data on disk is not readable, wrong key fails', () async {
      final f = File('${dir.path}/diag.db');
      final key = 'k' * 32;
      final enc = DiagDatabase.openEncrypted(f, key);
      await DiagRepository(enc).vehicleForVin(vin, manufacturer: 'PlaintextMarker');
      await enc.close();

      final raw = f.readAsBytesSync();
      expect(String.fromCharCodes(raw).contains('PlaintextMarker'), isFalse);
      expect(String.fromCharCodes(raw.sublist(0, 15)) == 'SQLite format 3', isFalse);

      final again = DiagDatabase.openEncrypted(f, key);
      expect((await again.select(again.vehicles).get()).single.vin, vin);
      await again.close();

      final wrong = DiagDatabase.openEncrypted(f, 'x' * 32);
      await expectLater(wrong.select(wrong.vehicles).get(), throwsA(anything));
      await wrong.close();
    });

    test('short key rejected', () {
      expect(() => DiagDatabase.openEncrypted(File('${dir.path}/x.db'), 'short'), throwsA(isA<DatabaseKeyException>()));
    });
  });
}
