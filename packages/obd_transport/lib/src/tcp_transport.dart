import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'transport.dart';

/// Wi-Fi adapters: a raw TCP socket, usually 192.168.0.10:35000.
class TcpTransport extends BaseTransport {
  TcpTransport(this.endpoint);

  static const defaultHost = '192.168.0.10';
  static const defaultPort = 35000;

  @override
  final TransportEndpoint endpoint;

  Socket? _socket;
  StreamSubscription<Uint8List>? _sub;

  @override
  Future<void> open({Duration timeout = const Duration(seconds: 10)}) async {
    if (state == TransportState.connected) return;
    setState(TransportState.connecting);
    try {
      final s = await Socket.connect(endpoint.address,
          endpoint.port ?? defaultPort,
          timeout: timeout);
      s.setOption(SocketOption.tcpNoDelay, true);
      _socket = s;
      _sub = s.listen(input_.add,
          onError: (Object e) => _lost(e),
          onDone: () => _lost(null),
          cancelOnError: true);
      setState(TransportState.connected);
    } on Object catch (e) {
      setState(TransportState.failed);
      throw TransportException(
          'Could not reach ${endpoint.address}:${endpoint.port ?? defaultPort}', e);
    }
  }

  void _lost(Object? e) {
    _socket = null;
    if (state != TransportState.disconnected) setState(TransportState.failed);
  }

  @override
  Future<void> write(Uint8List bytes) async {
    requireConnected();
    _socket!.add(bytes);
    await _socket!.flush();
  }

  @override
  Future<void> close() async {
    setState(TransportState.disconnected);
    await _sub?.cancel();
    await _socket?.close();
    _socket?.destroy();
    _socket = null;
  }
}
