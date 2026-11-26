/// Transport layer: one interface for Bluetooth, BLE, Wi-Fi, USB and the
/// simulator. Platform-specific implementations live in the app's plugins.
library;

export 'src/memory_transport.dart';
export 'src/tcp_transport.dart';
export 'src/transport.dart';
