import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:obd_transport/obd_transport.dart';

/// Result of probing one serial rate.
class BaudAttempt {
  BaudAttempt(this.baud, this.ok, this.detail);
  final int baud;
  final bool ok;
  final String detail;
}

/// Finds the serial rate an ELM327/STN adapter answers at.
///
/// For each rate it opens a fresh transport from [create], sends a carriage
/// return then `ATI`, and accepts the rate when a readable reply ending in the
/// `>` prompt arrives. Wrong rates give silence or unreadable bytes. The
/// transport is always closed again; open a new one at the returned rate.
Future<(int?, List<BaudAttempt>)> detectBaudRate(
  List<int> candidates,
  ObdTransport Function(int baud) create, {
  Duration perTry = const Duration(milliseconds: 1500),
}) async {
  final attempts = <BaudAttempt>[];
  for (final baud in candidates) {
    final t = create(baud);
    final buf = BytesBuilder();
    StreamSubscription<Uint8List>? sub;
    try {
      await t.open(timeout: const Duration(seconds: 3));
      sub = t.input.listen(buf.add);
      await t.write(Uint8List.fromList([13]));
      await Future<void>.delayed(const Duration(milliseconds: 150));
      buf.clear();
      await t.write(Uint8List.fromList(latin1.encode('ATI\r')));
      for (var waited = 0; waited < perTry.inMilliseconds; waited += 40) {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        if (buf.toBytes().contains(0x3e)) break;
      }
      final bytes = buf.toBytes();
      final printable = bytes.where((b) => b == 10 || b == 13 || (b >= 0x20 && b < 0x7f)).length;
      final readable = bytes.isNotEmpty && printable / bytes.length > 0.9;
      final text = latin1.decode(bytes, allowInvalid: true).replaceAll(RegExp(r'[\r\n>]+'), ' ').trim();
      if (bytes.contains(0x3e) && readable) {
        attempts.add(BaudAttempt(baud, true, text));
        return (baud, attempts);
      }
      attempts.add(BaudAttempt(baud, false, bytes.isEmpty ? 'no reply' : 'unreadable reply (${bytes.length} bytes)'));
    } on Object catch (e) {
      attempts.add(BaudAttempt(baud, false, 'could not open: $e'));
    } finally {
      await sub?.cancel();
      try {
        await t.close();
      } catch (_) {}
    }
  }
  return (null, attempts);
}
