import 'dart:convert';

import 'repository.dart';

/// A fault-code pack as stored in a JSON asset.
class DtcPackFile {
  DtcPackFile(this.pack, this.definitions);
  final DtcPackInput pack;
  final List<DtcDefinitionInput> definitions;
}

List<String> _list(Object? v) => v == null ? const [] : [for (final e in v as List) e as String];

/// Parses a pack file of the form `{"pack": {...}, "definitions": [...]}`.
/// Throws [FormatException] when required fields are missing.
DtcPackFile parseDtcPackJson(String source) {
  final root = jsonDecode(source);
  if (root is! Map<String, dynamic>) throw const FormatException('Pack root must be an object');
  final p = root['pack'];
  final defs = root['definitions'];
  if (p is! Map<String, dynamic> || defs is! List) throw const FormatException('Pack needs "pack" and "definitions"');
  String req(Map<String, dynamic> m, String k) {
    final v = m[k];
    if (v is! String || v.isEmpty) throw FormatException('Missing "$k"');
    return v;
  }

  return DtcPackFile(
    DtcPackInput(id: req(p, 'id'), title: req(p, 'title'), version: req(p, 'version'), source: req(p, 'source'), scope: req(p, 'scope')),
    [
      for (final d in defs.cast<Map<String, dynamic>>())
        DtcDefinitionInput(
          code: req(d, 'code'),
          description: req(d, 'description'),
          confidence: req(d, 'confidence'),
          manufacturer: d['manufacturer'] as String?,
          category: d['category'] as String?,
          severity: d['severity'] as String?,
          causes: _list(d['causes']),
          symptoms: _list(d['symptoms']),
          inspection: _list(d['inspection']),
          repairs: _list(d['repairs']),
          components: _list(d['components']),
        ),
    ],
  );
}
