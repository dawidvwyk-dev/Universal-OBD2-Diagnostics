import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:diag_store/diag_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

const _keyName = 'diag_db_key_v1';

/// Returns the database key from the platform's secure storage (Windows
/// Credential Manager/DPAPI, Android Keystore), creating one on first run.
Future<String> _databaseKey() async {
  const storage = FlutterSecureStorage();
  final existing = await storage.read(key: _keyName);
  if (existing != null && existing.length >= 32) return existing;
  final r = Random.secure();
  final key = base64UrlEncode(List<int>.generate(32, (_) => r.nextInt(256)));
  await storage.write(key: _keyName, value: key);
  return key;
}

/// The encrypted on-device database. Tests override this provider.
final databaseProvider = FutureProvider<DiagDatabase>((ref) async {
  final dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  final db = DiagDatabase.openEncrypted(File('${dir.path}${Platform.pathSeparator}diagnostics.db'), await _databaseKey());
  ref.onDispose(db.close);
  return db;
});

final repositoryProvider = FutureProvider<DiagRepository>((ref) async => DiagRepository(await ref.watch(databaseProvider.future)));

const builtInDtcPackAsset = 'assets/dtc/rogue_generic.json';

/// Installs the built-in fault-code descriptions (written for this app) on
/// first run or when the bundled pack version changes. Resolves to the number
/// of definitions available for lookups.
final dtcLibraryProvider = FutureProvider<int>((ref) async {
  final repo = await ref.watch(repositoryProvider.future);
  final pack = parseDtcPackJson(await rootBundle.loadString(builtInDtcPackAsset));
  await repo.ensurePack(pack);
  return repo.definitionCount();
});

/// Looks a code up, preferring a verified manufacturer definition.
final dtcDefinitionProvider = FutureProvider.family<DtcDefinition?, (String, String?)>((ref, arg) async {
  await ref.watch(dtcLibraryProvider.future);
  final repo = await ref.watch(repositoryProvider.future);
  return repo.lookupDtc(arg.$1, manufacturer: arg.$2);
});

final dtcSearchProvider = FutureProvider.family<List<DtcDefinition>, String>((ref, query) async {
  await ref.watch(dtcLibraryProvider.future);
  final repo = await ref.watch(repositoryProvider.future);
  return repo.searchDtcs(query, limit: 40);
});
