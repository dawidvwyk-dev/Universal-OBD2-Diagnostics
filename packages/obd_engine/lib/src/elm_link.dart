/// Command/response link to an ELM327-compatible adapter over any transport.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:obd_transport/obd_transport.dart';

import 'comm_log.dart';

class ElmTimeoutException implements Exception {
  ElmTimeoutException(this.command, this.timeout, this.partial);
  final String command;
  final Duration timeout;
  final String partial;
  @override
  String toString() =>
      'No reply to "$command" within ${timeout.inMilliseconds} ms';
}

class LinkClosedException implements Exception {
  LinkClosedException(this.reason);
  final String reason;
  @override
  String toString() => 'Adapter link closed: $reason';
}

/// Sends one command at a time and returns the text before the `>` prompt.
/// Requests are queued, so callers can issue them concurrently.
class ElmLink {
  ElmLink(this.transport, {CommLog? log}) : log = log ?? CommLog() {
    _sub = transport.input.listen(_onData);
    _stateSub = transport.stateChanges.listen((s) {
      if (s != TransportState.connected) {
        _failPending(LinkClosedException(s.name));
      }
    });
  }

  final ObdTransport transport;
  final CommLog log;
  late final StreamSubscription<Uint8List> _sub;
  late final StreamSubscription<TransportState> _stateSub;

  final _buffer = StringBuffer();
  Completer<String>? _pending;
  Future<void> _queue = Future.value();

  /// Round-trip times of recent successful commands, newest last.
  final List<Duration> recentRtt = [];
  int timeouts = 0;
  int completed = 0;

  void _onData(Uint8List data) {
    final text = latin1.decode(data, allowInvalid: true);
    _buffer.write(text);
    final s = _buffer.toString();
    final idx = s.indexOf('>');
    if (idx >= 0) {
      final reply = s.substring(0, idx);
      _buffer.clear();
      if (idx + 1 < s.length) _buffer.write(s.substring(idx + 1));
      final p = _pending;
      _pending = null;
      if (p != null && !p.isCompleted) p.complete(reply);
    }
  }

  void _failPending(Object error) {
    final p = _pending;
    _pending = null;
    if (p != null && !p.isCompleted) p.completeError(error);
  }

  /// Sends [command] (without CR) and returns the cleaned reply: echo
  /// removed, CR/LF normalised to `\n`, trimmed.
  Future<String> send(String command,
      {Duration timeout = const Duration(seconds: 2)}) {
    final result = Completer<String>();
    _queue = _queue.then((_) async {
      try {
        result.complete(await _sendNow(command, timeout));
      } catch (e, st) {
        result.completeError(e, st);
      }
    });
    return result.future;
  }

  Future<String> _sendNow(String command, Duration timeout) async {
    if (transport.state != TransportState.connected) {
      throw LinkClosedException('transport not connected');
    }
    _buffer.clear();
    final c = Completer<String>();
    _pending = c;
    final sw = Stopwatch()..start();
    log.add(LogDirection.tx, command);
    final bytes = Uint8List.fromList(latin1.encode('$command\r'));
    final max = transport.maxWriteSize;
    if (max == null || bytes.length <= max) {
      await transport.write(bytes);
    } else {
      for (var i = 0; i < bytes.length; i += max) {
        await transport.write(Uint8List.sublistView(
            bytes, i, i + max > bytes.length ? bytes.length : i + max));
      }
    }
    try {
      final raw = await c.future.timeout(timeout);
      sw.stop();
      completed++;
      recentRtt.add(sw.elapsed);
      if (recentRtt.length > 50) recentRtt.removeAt(0);
      final cleaned = _clean(raw, command);
      log.add(LogDirection.rx, cleaned);
      return cleaned;
    } on TimeoutException {
      timeouts++;
      _pending = null;
      final partial = _buffer.toString();
      log.add(LogDirection.error, 'timeout after ${timeout.inMilliseconds} ms: $partial');
      throw ElmTimeoutException(command, timeout, partial);
    }
  }

  static String _clean(String raw, String command) {
    final lines = raw
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    // Strip echo (ATE1 or clones that ignore ATE0).
    if (lines.isNotEmpty &&
        lines.first.replaceAll(' ', '').toUpperCase() ==
            command.replaceAll(' ', '').toUpperCase()) {
      lines.removeAt(0);
    }
    // Some clones send stray NUL bytes.
    return lines.map((l) => l.replaceAll('\u0000', '')).join('\n').trim();
  }

  Duration? get averageRtt {
    if (recentRtt.isEmpty) return null;
    final us = recentRtt.fold<int>(0, (a, d) => a + d.inMicroseconds);
    return Duration(microseconds: us ~/ recentRtt.length);
  }

  Future<void> dispose() async {
    _failPending(LinkClosedException('disposed'));
    await _sub.cancel();
    await _stateSub.cancel();
  }
}
