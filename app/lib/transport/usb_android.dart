import 'dart:async';
import 'dart:typed_data';

import 'package:obd_transport/obd_transport.dart';
import 'package:usb_serial/usb_serial.dart';

/// USB OBD cables on Android (USB OTG). Supports FTDI, CH34x, CP210x,
/// PL2303 and CDC-ACM chips.
class AndroidUsb {
  static Future<List<(SerialPortInfo, UsbDevice)>> devices() async => [
        for (final d in await UsbSerial.listDevices())
          (
            SerialPortInfo(
              name: '${d.deviceId}',
              description: d.productName,
              manufacturer: d.manufacturerName,
              vendorId: d.vid,
              productId: d.pid,
            ),
            d,
          ),
      ];
}

class AndroidUsbLink implements ByteLink {
  AndroidUsbLink(this.deviceId, this.baud);
  final String deviceId;
  final int baud;
  UsbPort? _port;
  StreamController<Uint8List>? _ctrl;
  final _subs = <StreamSubscription<Object?>>[];

  @override
  int? get maxChunk => null;

  @override
  Stream<Uint8List> get data => _ctrl!.stream;

  @override
  Future<void> open(Duration timeout) async {
    final devs = await UsbSerial.listDevices();
    final d = devs.where((x) => '${x.deviceId}' == deviceId).firstOrNull;
    if (d == null) throw StateError('The USB adapter is no longer connected.');
    // Android shows a permission prompt for the device here.
    final p = await d.create();
    if (p == null) throw StateError('This USB device is not a supported serial adapter.');
    if (!await p.open()) throw StateError('USB permission was refused or the device is busy.');
    await p.setDTR(true);
    await p.setRTS(true);
    await p.setPortParameters(baud, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    _port = p;
    final c = StreamController<Uint8List>();
    _ctrl = c;
    _subs.add(p.inputStream!.listen(c.add, onError: c.addError, onDone: () {
      if (!c.isClosed) c.close();
    }));
    _subs.add(UsbSerial.usbEventStream!.listen((e) {
      if (e.event == UsbEvent.ACTION_USB_DETACHED && '${e.device?.deviceId}' == deviceId && !c.isClosed) {
        c.addError(StateError('USB adapter unplugged'));
        c.close();
      }
    }));
  }

  @override
  Future<void> send(Uint8List bytes) async {
    final p = _port;
    if (p == null) throw StateError('port closed');
    await p.write(bytes);
  }

  @override
  Future<void> close() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    final c = _ctrl;
    _ctrl = null;
    if (c != null && !c.isClosed) unawaited(c.close()); // done future can wait forever
    await _port?.close();
    _port = null;
  }
}
