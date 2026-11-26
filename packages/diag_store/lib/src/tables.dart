import 'package:drift/drift.dart';

/// Saved vehicles.
class Vehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get registration => text().nullable()();
  TextColumn get vin => text().nullable().unique()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get engine => text().nullable()();
  IntColumn get modelYear => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// One diagnostic scan of a vehicle.
class Scans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId => integer().nullable().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get time => dateTime()();

  /// `quick` or `full`.
  TextColumn get kind => text()();

  /// True when the scan came from the simulator. Simulated scans are never
  /// mixed into a real vehicle's history.
  BoolColumn get simulated => boolean().withDefault(const Constant(false))();
  TextColumn get vin => text().nullable()();
  TextColumn get protocol => text().nullable()();
  TextColumn get adapter => text().nullable()();
  RealColumn get batteryVolts => real().nullable()();
  BoolColumn get milOn => boolean().nullable()();

  /// JSON list of steps that failed during the scan.
  TextColumn get errors => text().withDefault(const Constant('[]'))();
}

/// Fault codes found in a scan.
class ScanDtcs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scanId => integer().references(Scans, #id, onDelete: KeyAction.cascade)();
  TextColumn get code => text().withLength(min: 5, max: 5)();

  /// stored, pending, permanent or freezeFrame.
  TextColumn get status => text()();
  TextColumn get ecu => text().nullable()();
}

/// Sensor values captured in a scan (snapshot or freeze frame).
class ScanReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scanId => integer().references(Scans, #id, onDelete: KeyAction.cascade)();

  /// `snapshot` or `freezeFrame`.
  TextColumn get source => text()();
  IntColumn get pid => integer()();
  TextColumn get key => text()();
  TextColumn get name => text()();
  RealColumn get value => real().nullable()();
  TextColumn get unit => text()();
  TextColumn get textValue => text().nullable()();
}

/// Readiness monitor results per scan.
class ScanMonitors extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scanId => integer().references(Scans, #id, onDelete: KeyAction.cascade)();
  TextColumn get key => text()();
  TextColumn get name => text()();

  /// complete or incomplete (unsupported monitors are not stored).
  TextColumn get state => text()();
}

class MaintenanceNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId => integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get time => dateTime().withDefault(currentDateAndTime)();
  TextColumn get body => text().withLength(min: 1, max: 4000)();
}

/// Adapters seen before, so reconnecting can skip the full probe.
class AdapterProfiles extends Table {
  TextColumn get address => text()();
  TextColumn get kind => text()();
  TextColumn get identity => text()();
  TextColumn get manufacturer => text()();

  /// JSON map of capability key to supported.
  TextColumn get capabilities => text()();
  DateTimeColumn get lastSeen => dateTime()();

  @override
  Set<Column> get primaryKey => {address, kind};
}

/// Installed fault-code definition packs (licensed or authored data).
class DtcPacks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get version => text()();

  /// Who supplied the data and under what licence.
  TextColumn get source => text()();

  /// `generic` (SAE) or a manufacturer name.
  TextColumn get scope => text()();
  DateTimeColumn get installedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Fault-code definitions from installed packs. Empty until a pack is
/// installed; the app never invents descriptions.
class DtcDefinitions extends Table {
  TextColumn get packId => text().references(DtcPacks, #id, onDelete: KeyAction.cascade)();
  TextColumn get code => text().withLength(min: 5, max: 5)();

  /// Null for generic definitions; otherwise the manufacturer it applies to.
  TextColumn get manufacturer => text().nullable()();
  TextColumn get description => text()();
  TextColumn get category => text().nullable()();

  /// critical, high, medium, low or informational.
  TextColumn get severity => text().nullable()();

  /// JSON lists.
  TextColumn get causes => text().withDefault(const Constant('[]'))();
  TextColumn get symptoms => text().withDefault(const Constant('[]'))();
  TextColumn get inspection => text().withDefault(const Constant('[]'))();
  TextColumn get repairs => text().withDefault(const Constant('[]'))();
  TextColumn get components => text().withDefault(const Constant('[]'))();

  /// `verified` (manufacturer data) or `generic`.
  TextColumn get confidence => text()();

  @override
  Set<Column> get primaryKey => {packId, code};
}
