import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:obd_transport/obd_transport.dart';

/// COM ports on Windows: USB OBD cables and paired Bluetooth Classic
/// adapters (Windows creates a "Standard Serial over Bluetooth link" port).
class WindowsSerial {
  static List<SerialPortInfo> ports() {
    final out = <SerialPortInfo>[];
    for (final name in SerialPort.availablePorts) {
      final p = SerialPort(name);
      try {
        out.add(SerialPortInfo(
          name: name,
          description: p.description,
          manufacturer: p.manufacturer,
          vendorId: p.transport == SerialPortTransport.usb ? p.vendorId : null,
          productId: p.transport == SerialPortTransport.usb ? p.productId : null,
          bluetooth: p.transport == SerialPortTransport.bluetooth ||
              (p.description ?? '').toLowerCase().contains('bluetooth'),
        ));
      } catch (_) {
        out.add(SerialPortInfo(name: name));
      } finally {
        p.dispose();
      }
    }
    return out;
  }
}

class WindowsSerialLink implements ByteLink {
  WindowsSerialLink(this.portName, this.baud);
  final String portName;
  final int baud;
  SerialPort? _port;
  SerialPortReader? _reader;
  StreamController<Uint8List>? _ctrl;
  StreamSubscription<Uint8List>? _sub;

  @override
  int? get maxChunk => null;

  @override
  Stream<Uint8List> get data => _ctrl!.stream;

  @override
  Future<void> open(Duration timeout) async {
    final p = SerialPort(portName);
    if (!p.openReadWrite()) {
      final err = SerialPort.lastError;
      p.dispose();
      throw StateError('Could not open $portName: ${err?.message ?? 'port busy or missing'}. Close other programs using it.');
    }
    final cfg = SerialPortConfig()
      ..baudRate = baud
      ..bits = 8
      ..parity = SerialPortParity.none
      ..stopBits = 1
      ..setFlowControl(SerialPortFlowControl.none);
    p.config = cfg;
    cfg.dispose();
    _port = p;
    final c = StreamController<Uint8List>();
    _ctrl = c;
    _reader = SerialPortReader(p, timeout: 50);
    _sub = _reader!.stream.listen(c.add, onError: (Object e) {
      if (!c.isClosed) {
        c.addError(e);
        c.close();
      }
    }, onDone: () {
      if (!c.isClosed) c.close();
    });
  }

  @override
  Future<void> send(Uint8List bytes) async {
    final p = _port;
    if (p == null) throw StateError('port closed');
    final n = p.write(bytes, timeout: 1000);
    if (n != bytes.length) throw StateError('Wrote $n of ${bytes.length} bytes to $portName');
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    _sub = null;
    _reader?.close();
    _reader = null;
    final c = _ctrl;
    _ctrl = null;
    if (c != null && !c.isClosed) unawaited(c.close()); // done future can wait forever
    final p = _port;
    _port = null;
    if (p != null) {
      try {
        p.close();
      } catch (_) {}
      p.dispose();
    }
  }
}
