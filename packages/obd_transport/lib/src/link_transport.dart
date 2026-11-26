import 'dart:async';
import 'dart:typed_data';

import 'transport.dart';

/// A platform byte link (Bluetooth socket, BLE characteristics, serial port).
/// Platform code implements this small interface; [LinkTransport] turns it
/// into an [ObdTransport] with consistent state handling, so the platform
/// glue stays thin and the behaviour is testable without hardware.
abstract class ByteLink {
  /// Opens the link. Throws on failure.
  Future<void> open(Duration timeout);

  /// Bytes from the adapter. Must be valid after [open] completes. A stream
  /// error or done event means the link was lost.
  Stream<Uint8List> get data;

  Future<void> send(Uint8List bytes);

  Future<void> close();

  /// Largest single write, or null for unlimited.
  int? get maxChunk;
}

class LinkTransport extends BaseTransport {
  LinkTransport(this.endpoint, this.link);

  @override
  final TransportEndpoint endpoint;
  final ByteLink link;
  StreamSubscription<Uint8List>? _sub;
  bool _closing = false;

  @override
  int? get maxWriteSize => link.maxChunk;

  @override
  Future<void> open({Duration timeout = const Duration(seconds: 10)}) async {
    if (state == TransportState.connected) return;
    _closing = false;
    setState(TransportState.connecting);
    try {
      await link.open(timeout).timeout(timeout + const Duration(seconds: 1));
      _sub = link.data.listen(input_.add, onError: (Object e) => _lost(), onDone: _lost, cancelOnError: true);
      setState(TransportState.connected);
    } on Object catch (e) {
      setState(TransportState.failed);
      try {
        await link.close();
      } catch (_) {}
      throw TransportException('Could not open ${endpoint.kind.label} link to ${endpoint.name}', e);
    }
  }

  void _lost() {
    _sub = null;
    if (!_closing && state == TransportState.connected) setState(TransportState.failed);
  }

  @override
  Future<void> write(Uint8List bytes) async {
    requireConnected();
    try {
      await link.send(bytes);
    } on Object catch (e) {
      _lost();
      throw TransportException('Write to ${endpoint.name} failed', e);
    }
  }

  @override
  Future<void> close() async {
    _closing = true;
    setState(TransportState.disconnected);
    final s = _sub;
    _sub = null;
    await s?.cancel();
    try {
      await link.close();
    } catch (_) {}
  }
}
