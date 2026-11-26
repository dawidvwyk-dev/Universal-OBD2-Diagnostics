import 'dart:async';
import 'dart:typed_data';

import 'package:obd_transport/obd_transport.dart';

import 'elm_emulator.dart';

/// A [ByteLink] backed by the emulator, for testing the Bluetooth, BLE and
/// serial code paths without hardware. TEST USE ONLY.
class SimByteLink implements ByteLink {
  SimByteLink(this.emulator, {this.maxChunk, this.replyChunk, this.latency = Duration.zero, this.failOpens = 0, this.answersAtBaud, this.baud});

  final ElmEmulator emulator;
  @override
  final int? maxChunk;

  /// Split replies into notifications of this size (BLE delivers ~20 bytes).
  final int? replyChunk;
  final Duration latency;

  /// Number of upcoming [open] calls that fail (adapter out of range).
  int failOpens;

  /// When both are set and differ, replies are garbled like a wrong baud rate.
  final int? answersAtBaud;
  final int? baud;

  StreamController<Uint8List>? _ctrl;
  final List<int> _pending = [];
  int opens = 0;
  final List<int> writeSizes = [];

  @override
  Stream<Uint8List> get data => _ctrl!.stream;

  @override
  Future<void> open(Duration timeout) async {
    opens++;
    if (failOpens > 0) {
      failOpens--;
      throw StateError('simulated: adapter not reachable');
    }
    _ctrl = StreamController<Uint8List>();
  }

  @override
  Future<void> send(Uint8List bytes) async {
    final c = _ctrl;
    if (c == null || c.isClosed) throw StateError('link closed');
    if (maxChunk != null && bytes.length > maxChunk!) throw StateError('write of ${bytes.length} bytes exceeds $maxChunk');
    writeSizes.add(bytes.length);
    _pending.addAll(bytes);
    if (!_pending.contains(13)) return;
    final reply = Uint8List.fromList(emulator.receive(_pending));
    _pending.clear();
    if (reply.isEmpty) return;
    final Uint8List out = answersAtBaud != null && baud != null && answersAtBaud != baud
        ? Uint8List.fromList([for (final b in reply) b | 0x80])
        : reply;
    Future<void>.delayed(latency, () {
      if (c.isClosed) return;
      final n = replyChunk ?? out.length;
      for (var i = 0; i < out.length; i += n) {
        c.add(Uint8List.sublistView(out, i, i + n > out.length ? out.length : i + n));
      }
    });
  }

  /// Simulates the adapter disappearing (power cut, out of range).
  void drop() {
    final c = _ctrl;
    if (c != null && !c.isClosed) {
      c.addError(StateError('simulated: link lost'));
      c.close();
    }
  }

  @override
  Future<void> close() async {
    final c = _ctrl;
    _ctrl = null;
    if (c != null && !c.isClosed) unawaited(c.close()); // done future can wait forever
  }
}
