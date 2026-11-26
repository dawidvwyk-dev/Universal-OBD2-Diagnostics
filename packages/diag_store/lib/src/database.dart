import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

import 'tables.dart';

part 'database.g.dart';

class DatabaseKeyException implements Exception {
  DatabaseKeyException(this.message);
  final String message;
  @override
  String toString() => message;
}

@DriftDatabase(tables: [
  Vehicles,
  Scans,
  ScanDtcs,
  ScanReadings,
  ScanMonitors,
  MaintenanceNotes,
  AdapterProfiles,
  DtcPacks,
  DtcDefinitions,
])
class DiagDatabase extends _$DiagDatabase {
  DiagDatabase(super.e);

  /// Opens (or creates) the encrypted database at [file] with [key].
  ///
  /// [key] is a random secret kept in the platform's secure storage
  /// (Windows DPAPI / Android Keystore). A wrong key fails on open rather
  /// than returning garbage.
  factory DiagDatabase.openEncrypted(File file, String key) {
    if (key.length < 16) {
      throw DatabaseKeyException('Database key is too short.');
    }
    final quoted = key.replaceAll("'", "''");
    return DiagDatabase(NativeDatabase.createInBackground(
      file,
      setup: (Database db) {
        db.execute("PRAGMA key = '$quoted';");
        // Fails with SQLITE_NOTADB if the key is wrong.
        db.select('SELECT count(*) FROM sqlite_master;');
        db.execute('PRAGMA foreign_keys = ON;');
      },
    ));
  }

  /// Unencrypted in-memory database for tests.
  factory DiagDatabase.memory() => DiagDatabase(NativeDatabase.memory(
        setup: (db) => db.execute('PRAGMA foreign_keys = ON;'),
      ));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// True when the linked SQLite build supports encryption.
bool encryptionAvailable() {
  try {
    final db = sqlite3.openInMemory();
    final r = db.select("SELECT sqlite3mc_version() AS v;");
    db.close();
    return r.isNotEmpty;
  } catch (_) {
    return false;
  }
}
