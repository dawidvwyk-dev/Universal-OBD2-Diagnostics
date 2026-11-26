/// OBD2 protocols as numbered by the ELM327 `ATSP`/`ATDPN` commands.
enum ObdProtocol {
  auto(0, 'Automatic', ProtocolFamily.unknown, 0),
  j1850Pwm(1, 'SAE J1850 PWM (41.6 kbaud)', ProtocolFamily.legacy, 3),
  j1850Vpw(2, 'SAE J1850 VPW (10.4 kbaud)', ProtocolFamily.legacy, 3),
  iso9141(3, 'ISO 9141-2 (5 baud init)', ProtocolFamily.legacy, 3),
  kwp5Baud(4, 'ISO 14230-4 KWP2000 (5 baud init)', ProtocolFamily.legacy, 3),
  kwpFast(5, 'ISO 14230-4 KWP2000 (fast init)', ProtocolFamily.legacy, 3),
  can11b500(6, 'ISO 15765-4 CAN (11 bit, 500 kbaud)', ProtocolFamily.can, 3),
  can29b500(7, 'ISO 15765-4 CAN (29 bit, 500 kbaud)', ProtocolFamily.can, 8),
  can11b250(8, 'ISO 15765-4 CAN (11 bit, 250 kbaud)', ProtocolFamily.can, 3),
  can29b250(9, 'ISO 15765-4 CAN (29 bit, 250 kbaud)', ProtocolFamily.can, 8),
  j1939(10, 'SAE J1939 CAN (29 bit, 250 kbaud)', ProtocolFamily.can, 8),
  userCan1(11, 'User CAN 1 (ISO 11898)', ProtocolFamily.can, 3),
  userCan2(12, 'User CAN 2 (ISO 11898)', ProtocolFamily.can, 3);

  const ObdProtocol(this.elmNumber, this.label, this.family, this.headerHexChars);

  /// Number used with `ATSPn`/`ATTPn` (hex digit 0..C).
  final int elmNumber;
  final String label;
  final ProtocolFamily family;

  /// CAN header length in hex characters when headers are shown (`ATH1`):
  /// 3 for 11-bit, 8 for 29-bit. Legacy protocols always use 3 header bytes.
  final int headerHexChars;

  bool get isCan => family == ProtocolFamily.can;
  bool get is29Bit => headerHexChars == 8;

  String get elmCode => elmNumber.toRadixString(16).toUpperCase();

  static ObdProtocol fromElmNumber(int n) => ObdProtocol.values
      .firstWhere((p) => p.elmNumber == n, orElse: () => ObdProtocol.auto);

  /// Parses the reply of `ATDPN`, e.g. `A6` (automatic, found 6) or `3`.
  static ObdProtocol fromDpn(String reply) {
    var r = reply.trim().toUpperCase();
    if (r.length == 2 && r.startsWith('A')) r = r.substring(1);
    final n = int.tryParse(r, radix: 16);
    return n == null ? ObdProtocol.auto : fromElmNumber(n);
  }
}

enum ProtocolFamily { unknown, legacy, can }
