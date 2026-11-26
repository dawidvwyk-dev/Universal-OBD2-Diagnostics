import 'dart:async';
import 'dart:typed_data';

import 'package:obd_transport/obd_transport.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

/// COM ports on Windows: USB OBD cables and paired Bluetooth Classic
/// adapters (Windows creates a "Standard Serial over Bluetooth link" port).
/// Uses the Win32 API directly, so nothing is built for Android.
class WindowsSerial {
  static final _ids = RegExp(r'VID_([0-9A-F]{4}).PID_([0-9A-F]{4})', caseSensitive: false);

  static List<SerialPortInfo> ports() {
    final out = <SerialPortInfo>[];
    final seen = <String>{};
    for (final p in SerialPort.getPortsWithFullMessages()) {
      seen.add(p.portName);
      final m = _ids.firstMatch(p.hardwareID);
      out.add(SerialPortInfo(
        name: p.portName,
        description: p.friendlyName,
        manufacturer: p.manufactureName,
        vendorId: m == null ? null : int.parse(m.group(1)!, radix: 16),
        productId: m == null ? null : int.parse(m.group(2)!, radix: 16),
        bluetooth: p.hardwareID.toUpperCase().startsWith('BTHENUM'),
      ));
    }
    // Ports listed in the registry but not by SetupAPI (some virtual ports).
    for (final name in SerialPort.getAvailablePorts()) {
      if (!seen.contains(name)) out.add(SerialPortInfo(name: name));
    }
    return out;
  }
}

class WindowsSerialLink implements ByteLink {
  WindowsSerialLink(this.portName, this.baud);
  final String portName;
  final int baud;
  SerialPort? _port;
  StreamController<Uint8List>? _ctrl;
  bool _reading = false;

  @override
  int? get maxChunk => null;

  @override
  Stream<Uint8List> get data => _ctrl!.stream;

  @override
  Future<void> open(Duration timeout) async {
    final p = SerialPort(portName, openNow: false, BaudRate: baud);
    try {
      if (!p.isOpened) await p.open();
      p.BaudRate = baud;
    } catch (e) {
      throw StateError('Could not open $portName ($e). Close other programs using the port and check the adapter is plugged in.');
    }
    _port = p;
    final c = StreamController<Uint8List>();
    _ctrl = c;
    _reading = true;
    unawaited(_readLoop(p, c));
  }

  Future<void> _readLoop(SerialPort p, StreamController<Uint8List> c) async {
    while (_reading && !c.isClosed) {
      try {
        final bytes = await p.readBytes(4096, timeout: const Duration(milliseconds: 15), dataPollingInterval: const Duration(milliseconds: 2));
        if (bytes.isNotEmpty && !c.isClosed) c.add(bytes);
      } catch (e) {
        if (_reading && !c.isClosed) {
          c.addError(StateError('Serial port $portName stopped responding: $e'));
          unawaited(c.close());
        }
        return;
      }
    }
  }

  @override
  Future<void> send(Uint8List bytes) async {
    final p = _port;
    if (p == null) throw StateError('port closed');
    if (!await p.writeBytesFromUint8List(bytes, timeout: 1000)) throw StateError('Write to $portName failed');
  }

  @override
  Future<void> close() async {
    _reading = false;
    final c = _ctrl;
    _ctrl = null;
    if (c != null && !c.isClosed) unawaited(c.close()); // done future can wait forever
    final p = _port;
    _port = null;
    if (p != null && p.isOpened) {
      try {
        p.close();
      } catch (_) {}
    }
  }
}
