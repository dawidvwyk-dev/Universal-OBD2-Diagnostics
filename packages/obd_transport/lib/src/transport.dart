/// Transport abstraction: a bidirectional byte stream to an OBD adapter.
library;

import 'dart:async';
import 'dart:typed_data';

enum TransportKind { bluetoothClassic, bluetoothLe, wifi, usbSerial, simulator }

extension TransportKindLabel on TransportKind {
  String get label => switch (this) {
        TransportKind.bluetoothClassic => 'Bluetooth Classic',
        TransportKind.bluetoothLe => 'Bluetooth LE',
        TransportKind.wifi => 'Wi-Fi',
        TransportKind.usbSerial => 'USB serial',
        TransportKind.simulator => 'Simulator (test only)',
      };
}

enum TransportState { disconnected, connecting, connected, failed }

/// A discovered or configured adapter endpoint.
class TransportEndpoint {
  const TransportEndpoint({
    required this.kind,
    required this.address,
    required this.name,
    this.port,
    this.baudRate,
    this.signalStrength,
  });

  final TransportKind kind;

  /// MAC address, COM port, IP address or simulator id.
  final String address;
  final String name;

  /// TCP port for Wi-Fi.
  final int? port;

  /// Serial baud rate for USB/COM ports.
  final int? baudRate;

  /// RSSI in dBm when known (Bluetooth).
  final int? signalStrength;

  @override
  String toString() =>
      '${kind.label} $name ($address${port != null ? ':$port' : ''})';
}

class TransportException implements Exception {
  TransportException(this.message, [this.cause]);
  final String message;
  final Object? cause;
  @override
  String toString() =>
      'TransportException: $message${cause != null ? ' ($cause)' : ''}';
}

/// A byte pipe to an adapter. Implementations exist per platform/transport;
/// the engine only uses this interface.
abstract class ObdTransport {
  TransportEndpoint get endpoint;

  TransportState get state;
  Stream<TransportState> get stateChanges;

  /// Bytes received from the adapter.
  Stream<Uint8List> get input;

  Future<void> open({Duration timeout = const Duration(seconds: 10)});
  Future<void> write(Uint8List bytes);
  Future<void> close();

  /// Largest write the link accepts in one call (BLE MTU minus overhead).
  /// Null means unlimited.
  int? get maxWriteSize;
}

/// Shared state handling for implementations.
abstract class BaseTransport implements ObdTransport {
  final _state = StreamController<TransportState>.broadcast();
  final input_ = StreamController<Uint8List>.broadcast();
  TransportState _current = TransportState.disconnected;

  @override
  TransportState get state => _current;

  @override
  Stream<TransportState> get stateChanges => _state.stream;

  @override
  Stream<Uint8List> get input => input_.stream;

  @override
  int? get maxWriteSize => null;

  void setState(TransportState s) {
    if (s == _current) return;
    _current = s;
    _state.add(s);
  }

  void requireConnected() {
    if (_current != TransportState.connected) {
      throw TransportException('Not connected to ${endpoint.name}');
    }
  }
}
