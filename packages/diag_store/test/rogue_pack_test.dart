import 'dart:io';

import 'package:diag_store/diag_store.dart';
import 'package:obd_decoders/obd_decoders.dart';
import 'package:test/test.dart';

/// Checks the built-in fault-code pack shipped with the app.
void main() {
  final file = File('../../app/assets/dtc/rogue_generic.json');
  late DtcPackFile pack;

  setUpAll(() => pack = parseDtcPackJson(file.readAsStringSync()));

  test('pack metadata', () {
    expect(pack.pack.id, 'rogue-generic');
    expect(pack.pack.scope, 'generic');
    expect(pack.definitions.length, greaterThan(200));
  });

  test('every entry is a valid generic code with complete guidance', () {
    final seen = <String>{};
    for (final d in pack.definitions) {
      expect(Dtc.isValid(d.code), isTrue, reason: d.code);
      expect(Dtc.parse(d.code).origin, DtcOrigin.generic, reason: '${d.code} is not a generic code number');
      expect(seen.add(d.code), isTrue, reason: 'duplicate ${d.code}');
      expect(d.confidence, 'generic', reason: d.code);
      expect(d.manufacturer, isNull, reason: d.code);
      expect(d.description.trim(), isNotEmpty);
      expect(d.category, isNotNull);
      expect({'critical', 'high', 'medium', 'low', 'informational'}, contains(d.severity));
      for (final l in [d.causes, d.symptoms, d.inspection, d.repairs, d.components]) {
        expect(l, isNotEmpty, reason: d.code);
        expect(l.every((s) => s.trim().isNotEmpty), isTrue, reason: d.code);
      }
    }
  });

  test('installs once and looks codes up', () async {
    final db = DiagDatabase.memory();
    addTearDown(db.close);
    final repo = DiagRepository(db);
    expect(await repo.ensurePack(pack), isTrue);
    expect(await repo.ensurePack(pack), isFalse, reason: 'same version is not reinstalled');
    expect(await repo.definitionCount(), pack.definitions.length);
    final p0171 = await repo.lookupDtc('P0171');
    expect(p0171!.description, contains('lean'));
    expect(p0171.confidence, 'generic');
    expect(await repo.lookupDtc('P1234'), isNull, reason: 'manufacturer codes stay unknown');
    expect((await repo.searchDtcs('misfire')).length, greaterThan(5));
  });

  test('rejects malformed packs', () {
    expect(() => parseDtcPackJson('{}'), throwsFormatException);
    expect(() => parseDtcPackJson('{"pack":{"id":"x"},"definitions":[]}'), throwsFormatException);
  });
}
