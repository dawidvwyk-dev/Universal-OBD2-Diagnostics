import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:obd_decoders/obd_decoders.dart';

import 'database.dart';
import 'pack_format.dart';

/// A scan as stored and loaded. Built from decoder types so this package
/// does not depend on the communication engine.
class ScanRecord {
  ScanRecord({
    this.id,
    this.vehicleId,
    required this.time,
    required this.full,
    required this.simulated,
    this.vin,
    this.protocol,
    this.adapter,
    this.batteryVolts,
    this.milOn,
    this.dtcs = const [],
    this.snapshot = const {},
    this.freezeFrame = const {},
    this.monitors = const [],
    this.errors = const [],
  });

  final int? id;
  final int? vehicleId;
  final DateTime time;
  final bool full;
  final bool simulated;
  final String? vin;
  final String? protocol;
  final String? adapter;
  final double? batteryVolts;
  final bool? milOn;
  final List<(Dtc, DtcStatus, String?)> dtcs;
  final Map<int, List<PidValue>> snapshot;
  final Map<int, List<PidValue>> freezeFrame;
  final List<ReadinessMonitor> monitors;
  final List<String> errors;

  Set<String> codesWith(DtcStatus s) => {for (final (d, st, _) in dtcs) if (st == s) d.code};
  Set<String> get allCodes => {for (final (d, _, _) in dtcs) d.code};
}

class ScanComparison {
  ScanComparison(this.older, this.newer);
  final ScanRecord older;
  final ScanRecord newer;

  Set<String> get newCodes => newer.allCodes.difference(older.allCodes);
  Set<String> get resolvedCodes => older.allCodes.difference(newer.allCodes);
  Set<String> get persistingCodes => older.allCodes.intersection(newer.allCodes);

  /// Readings present in both scans' snapshots, keyed by value key:
  /// (older, newer).
  Map<String, (PidValue, PidValue)> get readingChanges {
    final a = {for (final vs in older.snapshot.values) for (final v in vs) v.key: v};
    final out = <String, (PidValue, PidValue)>{};
    for (final vs in newer.snapshot.values) {
      for (final v in vs) {
        final o = a[v.key];
        if (o != null) out[v.key] = (o, v);
      }
    }
    return out;
  }
}

class DtcPackInput {
  DtcPackInput({required this.id, required this.title, required this.version, required this.source, required this.scope});
  final String id, title, version, source, scope;
}

class DtcDefinitionInput {
  DtcDefinitionInput({
    required this.code,
    required this.description,
    required this.confidence,
    this.manufacturer,
    this.category,
    this.severity,
    this.causes = const [],
    this.symptoms = const [],
    this.inspection = const [],
    this.repairs = const [],
    this.components = const [],
  });
  final String code, description, confidence;
  final String? manufacturer, category, severity;
  final List<String> causes, symptoms, inspection, repairs, components;
}

const _severities = {'critical', 'high', 'medium', 'low', 'informational'};

class DiagRepository {
  DiagRepository(this.db);
  final DiagDatabase db;

  // ---- vehicles ----

  Future<int> addVehicle(VehiclesCompanion v) {
    final vin = v.vin.present ? v.vin.value : null;
    if (vin != null && !isVinSyntaxValid(vin)) {
      throw ArgumentError('Invalid VIN: $vin');
    }
    return db.into(db.vehicles).insert(v);
  }

  Future<void> updateVehicle(Vehicle v) => db.update(db.vehicles).replace(v);

  Future<void> deleteVehicle(int id) => (db.delete(db.vehicles)..where((t) => t.id.equals(id))).go();

  Stream<List<Vehicle>> watchVehicles() =>
      (db.select(db.vehicles)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<Vehicle?> vehicleByVin(String vin) =>
      (db.select(db.vehicles)..where((t) => t.vin.equals(vin))).getSingleOrNull();

  /// Finds the vehicle with [vin] or creates a profile for it.
  Future<int> vehicleForVin(String vin, {String? manufacturer, int? modelYear}) async {
    final existing = await vehicleByVin(vin);
    if (existing != null) return existing.id;
    return addVehicle(VehiclesCompanion.insert(
      name: manufacturer == null ? 'Vehicle $vin' : '$manufacturer ($vin)',
      vin: Value(vin),
      manufacturer: Value(manufacturer),
      modelYear: Value(modelYear),
    ));
  }

  // ---- scans ----

  Future<int> saveScan(ScanRecord r) => db.transaction(() async {
        final id = await db.into(db.scans).insert(ScansCompanion.insert(
              vehicleId: Value(r.vehicleId),
              time: r.time,
              kind: r.full ? 'full' : 'quick',
              simulated: Value(r.simulated),
              vin: Value(r.vin),
              protocol: Value(r.protocol),
              adapter: Value(r.adapter),
              batteryVolts: Value(r.batteryVolts),
              milOn: Value(r.milOn),
              errors: Value(jsonEncode(r.errors)),
            ));
        await db.batch((b) {
          b.insertAll(db.scanDtcs, [
            for (final (d, s, ecu) in r.dtcs)
              ScanDtcsCompanion.insert(scanId: id, code: d.code, status: s.name, ecu: Value(ecu)),
          ]);
          for (final (source, map) in [('snapshot', r.snapshot), ('freezeFrame', r.freezeFrame)]) {
            b.insertAll(db.scanReadings, [
              for (final e in map.entries)
                for (final v in e.value)
                  ScanReadingsCompanion.insert(
                    scanId: id,
                    source: source,
                    pid: e.key,
                    key: v.key,
                    name: v.name,
                    value: Value(v.value),
                    unit: v.unit.name,
                    textValue: Value(v.text),
                  ),
            ]);
          }
          b.insertAll(db.scanMonitors, [
            for (final m in r.monitors)
              if (m.state != MonitorState.notSupported)
                ScanMonitorsCompanion.insert(scanId: id, key: m.key, name: m.name, state: m.state.name),
          ]);
        });
        return id;
      });

  Stream<List<Scan>> watchScans({int? vehicleId, bool includeSimulated = false}) {
    final q = db.select(db.scans)..orderBy([(t) => OrderingTerm.desc(t.time)]);
    if (vehicleId != null) q.where((t) => t.vehicleId.equals(vehicleId));
    if (!includeSimulated) q.where((t) => t.simulated.equals(false));
    return q.watch();
  }

  Future<ScanRecord?> loadScan(int id) async {
    final s = await (db.select(db.scans)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (s == null) return null;
    final dtcs = await (db.select(db.scanDtcs)..where((t) => t.scanId.equals(id))).get();
    final readings = await (db.select(db.scanReadings)..where((t) => t.scanId.equals(id))).get();
    final monitors = await (db.select(db.scanMonitors)..where((t) => t.scanId.equals(id))).get();
    Map<int, List<PidValue>> group(String source) {
      final out = <int, List<PidValue>>{};
      for (final r in readings.where((r) => r.source == source)) {
        out.putIfAbsent(r.pid, () => []).add(PidValue(
              key: r.key,
              name: r.name,
              value: r.value,
              unit: ObdUnit.values.firstWhere((u) => u.name == r.unit, orElse: () => ObdUnit.none),
              text: r.textValue,
            ));
      }
      return out;
    }

    return ScanRecord(
      id: s.id,
      vehicleId: s.vehicleId,
      time: s.time,
      full: s.kind == 'full',
      simulated: s.simulated,
      vin: s.vin,
      protocol: s.protocol,
      adapter: s.adapter,
      batteryVolts: s.batteryVolts,
      milOn: s.milOn,
      dtcs: [
        for (final d in dtcs) (Dtc.parse(d.code), DtcStatus.values.byName(d.status), d.ecu),
      ],
      snapshot: group('snapshot'),
      freezeFrame: group('freezeFrame'),
      monitors: [
        for (final m in monitors) ReadinessMonitor(m.key, m.name, MonitorState.values.byName(m.state)),
      ],
      errors: (jsonDecode(s.errors) as List).cast<String>(),
    );
  }

  Future<ScanComparison?> compare(int olderId, int newerId) async {
    final a = await loadScan(olderId);
    final b = await loadScan(newerId);
    if (a == null || b == null) return null;
    return a.time.isAfter(b.time) ? ScanComparison(b, a) : ScanComparison(a, b);
  }

  // ---- notes ----

  Future<int> addNote(int vehicleId, String body) =>
      db.into(db.maintenanceNotes).insert(MaintenanceNotesCompanion.insert(vehicleId: vehicleId, body: body.trim()));

  Stream<List<MaintenanceNote>> watchNotes(int vehicleId) => (db.select(db.maintenanceNotes)
        ..where((t) => t.vehicleId.equals(vehicleId))
        ..orderBy([(t) => OrderingTerm.desc(t.time)]))
      .watch();

  // ---- adapters ----

  Future<void> saveAdapter({
    required String address,
    required String kind,
    required String identity,
    required String manufacturer,
    required Map<String, bool> capabilities,
  }) =>
      db.into(db.adapterProfiles).insertOnConflictUpdate(AdapterProfilesCompanion.insert(
            address: address,
            kind: kind,
            identity: identity,
            manufacturer: manufacturer,
            capabilities: jsonEncode(capabilities),
            lastSeen: DateTime.now(),
          ));

  Future<AdapterProfile?> adapter(String address, String kind) => (db.select(db.adapterProfiles)
        ..where((t) => t.address.equals(address) & t.kind.equals(kind)))
      .getSingleOrNull();

  // ---- DTC definitions ----

  /// Installs a definition pack. Every row is validated; an invalid pack is
  /// rejected whole.
  Future<void> installPack(DtcPackInput pack, List<DtcDefinitionInput> defs) async {
    for (final d in defs) {
      if (!Dtc.isValid(d.code)) throw ArgumentError('Invalid code in pack: ${d.code}');
      if (d.description.trim().isEmpty) throw ArgumentError('Empty description for ${d.code}');
      if (d.severity != null && !_severities.contains(d.severity)) {
        throw ArgumentError('Unknown severity "${d.severity}" for ${d.code}');
      }
      if (d.confidence != 'verified' && d.confidence != 'generic') {
        throw ArgumentError('Confidence must be verified or generic for ${d.code}');
      }
    }
    await db.transaction(() async {
      await (db.delete(db.dtcPacks)..where((t) => t.id.equals(pack.id))).go();
      await db.into(db.dtcPacks).insert(DtcPacksCompanion.insert(
          id: pack.id, title: pack.title, version: pack.version, source: pack.source, scope: pack.scope));
      await db.batch((b) => b.insertAll(db.dtcDefinitions, [
            for (final d in defs)
              DtcDefinitionsCompanion.insert(
                packId: pack.id,
                code: d.code.toUpperCase(),
                manufacturer: Value(d.manufacturer),
                description: d.description.trim(),
                category: Value(d.category),
                severity: Value(d.severity),
                causes: Value(jsonEncode(d.causes)),
                symptoms: Value(jsonEncode(d.symptoms)),
                inspection: Value(jsonEncode(d.inspection)),
                repairs: Value(jsonEncode(d.repairs)),
                components: Value(jsonEncode(d.components)),
                confidence: d.confidence,
              ),
          ]));
    });
  }

  /// Looks up [code]. A manufacturer-specific definition for [manufacturer]
  /// wins over a generic one. Returns null when no installed pack defines
  /// the code; callers must then show the code as unknown.
  /// Version of an installed pack, or null when it is not installed.
  Future<String?> packVersion(String id) async =>
      (await (db.select(db.dtcPacks)..where((t) => t.id.equals(id))).getSingleOrNull())?.version;

  /// Installs [file] unless the same pack version is already installed.
  /// Returns true when it was (re)installed.
  Future<bool> ensurePack(DtcPackFile file) async {
    if (await packVersion(file.pack.id) == file.pack.version) return false;
    await installPack(file.pack, file.definitions);
    return true;
  }

  Future<int> definitionCount() async {
    final c = db.dtcDefinitions.code.count();
    return (await (db.selectOnly(db.dtcDefinitions)..addColumns([c])).getSingle()).read(c) ?? 0;
  }

  Future<DtcDefinition?> lookupDtc(String code, {String? manufacturer}) async {
    final rows = await (db.select(db.dtcDefinitions)..where((t) => t.code.equals(code.toUpperCase()))).get();
    if (rows.isEmpty) return null;
    if (manufacturer != null) {
      final m = rows.where((r) => r.manufacturer?.toLowerCase() == manufacturer.toLowerCase());
      if (m.isNotEmpty) return m.first;
    }
    final generic = rows.where((r) => r.manufacturer == null);
    return generic.isEmpty ? null : generic.first;
  }

  Future<List<DtcDefinition>> searchDtcs(String query, {int limit = 50}) {
    final q = query.trim().toUpperCase();
    return (db.select(db.dtcDefinitions)
          ..where((t) => t.code.like('$q%') | t.description.upper().like('%$q%'))
          ..limit(limit))
        .get();
  }
}
