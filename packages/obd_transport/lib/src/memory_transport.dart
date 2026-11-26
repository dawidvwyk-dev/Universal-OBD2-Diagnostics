import 'dart:async';
import 'dart:typed_data';

import 'transport.dart';

/// A transport whose far end is a Dart callback. Used to connect the engine
/// to the simulator in tests and in the labelled developer mode.
class MemoryTransport extends BaseTransport {
  MemoryTransport({
    required this.endpoint,
    required this.onWrite,
    this.latency = Duration.zero,
    this.chunkSize,
  });

  @override
  final TransportEndpoint endpoint;

  /// Receives bytes the engine writes; replies go through [deliver].
  final void Function(Uint8List bytes, MemoryTransport t) onWrite;

  /// Delay before delivered bytes arrive, to mimic a slow link.
  final Duration latency;

  /// Split deliveries into chunks of this size (mimics BLE notifications).
  final int? chunkSize;

  @override
  Future<void> open({Duration timeout = const Duration(seconds: 10)}) async {
    setState(TransportState.connected);
  }

  @override
  Future<void> write(Uint8List bytes) async {
    requireConnected();
    onWrite(bytes, this);
  }

  /// Sends bytes to the engine side.
  void deliver(List<int> bytes) {
    void push() {
      if (state != TransportState.connected) return;
      final cs = chunkSize;
      if (cs == null) {
        input_.add(Uint8List.fromList(bytes));
      } else {
        for (var i = 0; i < bytes.length; i += cs) {
          input_.add(Uint8List.fromList(
              bytes.sublist(i, i + cs > bytes.length ? bytes.length : i + cs)));
        }
      }
    }

    if (latency == Duration.zero) {
      scheduleMicrotask(push);
    } else {
      Timer(latency, push);
    }
  }

  /// Simulates the link dropping.
  void drop() => setState(TransportState.failed);

  @override
  Future<void> close() async => setState(TransportState.disconnected);
}
