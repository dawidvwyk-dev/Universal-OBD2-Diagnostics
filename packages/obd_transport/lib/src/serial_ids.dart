/// USB-to-serial chips used in OBD adapters, and serial port helpers.
library;

class UsbSerialChip {
  const UsbSerialChip(this.vendorId, this.productId, this.name);
  final int vendorId, productId;
  final String name;
}

/// Chips commonly found in USB OBD adapters. OBDLink SX/EX use FTDI parts
/// with their own product strings; ELM327 USB clones use CH340 or PL2303.
const knownUsbSerialChips = [
  UsbSerialChip(0x0403, 0x6001, 'FTDI FT232R'),
  UsbSerialChip(0x0403, 0x6015, 'FTDI FT231X'),
  UsbSerialChip(0x0403, 0x6010, 'FTDI FT2232'),
  UsbSerialChip(0x0403, 0x6014, 'FTDI FT232H'),
  UsbSerialChip(0x1a86, 0x7523, 'WCH CH340'),
  UsbSerialChip(0x1a86, 0x5523, 'WCH CH341'),
  UsbSerialChip(0x1a86, 0x55d4, 'WCH CH9102'),
  UsbSerialChip(0x10c4, 0xea60, 'Silicon Labs CP210x'),
  UsbSerialChip(0x067b, 0x2303, 'Prolific PL2303'),
  UsbSerialChip(0x067b, 0x23a3, 'Prolific PL2303GC'),
];

UsbSerialChip? usbSerialChip(int? vendorId, int? productId) {
  if (vendorId == null || productId == null) return null;
  for (final c in knownUsbSerialChips) {
    if (c.vendorId == vendorId && c.productId == productId) return c;
  }
  return null;
}

/// Baud rates to try, most likely first. ELM327 v1.x USB adapters default to
/// 38400; OBDLink/STN and many v2 clones use 115200; some old units use 9600.
const serialBaudCandidates = [38400, 115200, 9600, 230400, 500000];

/// The usual rate to try first for a known chip/product.
List<int> baudOrderFor({String? product, UsbSerialChip? chip}) {
  final p = (product ?? '').toLowerCase();
  if (p.contains('obdlink') || p.contains('stn')) return const [115200, 38400, 9600, 230400, 500000];
  return serialBaudCandidates;
}

/// A serial port as listed by the platform.
class SerialPortInfo {
  const SerialPortInfo({required this.name, this.description, this.manufacturer, this.vendorId, this.productId, this.bluetooth = false});
  final String name;
  final String? description, manufacturer;
  final int? vendorId, productId;

  /// True for a Windows "Standard Serial over Bluetooth link" port.
  final bool bluetooth;

  UsbSerialChip? get chip => usbSerialChip(vendorId, productId);

  /// Ranks likely adapters first in pickers.
  bool get likelyAdapter =>
      chip != null || bluetooth || RegExp('obd|elm|stn|scantool', caseSensitive: false).hasMatch('${description ?? ''} ${manufacturer ?? ''}');
}
