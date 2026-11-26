/// Diagnostic trouble code decoding (SAE J2012 / ISO 15031-6 bit layout).
library;

/// The system letter of a DTC.
enum DtcSystem {
  powertrain('P'),
  chassis('C'),
  body('B'),
  network('U');

  const DtcSystem(this.letter);
  final String letter;

  static DtcSystem fromLetter(String letter) =>
      DtcSystem.values.firstWhere((s) => s.letter == letter.toUpperCase(),
          orElse: () => throw FormatException('Unknown DTC system: $letter'));
}

/// Where a code came from on the vehicle.
enum DtcStatus {
  /// Mode 03: confirmed/stored.
  stored,

  /// Mode 07: pending (detected on the current or last drive cycle).
  pending,

  /// Mode 0A: permanent (cannot be cleared by a scan tool).
  permanent,

  /// Mode 02: the code that triggered a freeze frame.
  freezeFrame,
}

/// Whether the code number is defined by SAE (generic) or by the manufacturer.
enum DtcOrigin { generic, manufacturer }

/// A five-character diagnostic trouble code such as `P0171`.
class Dtc implements Comparable<Dtc> {
  Dtc._(this.code);

  /// Builds a DTC from its two raw bytes.
  factory Dtc.fromBytes(int a, int b) {
    if (a < 0 || a > 0xFF || b < 0 || b > 0xFF) {
      throw RangeError('DTC bytes must be 0..255');
    }
    const letters = ['P', 'C', 'B', 'U'];
    final letter = letters[(a >> 6) & 0x03];
    final d1 = (a >> 4) & 0x03;
    final d2 = (a & 0x0F).toRadixString(16);
    final d3 = ((b >> 4) & 0x0F).toRadixString(16);
    final d4 = (b & 0x0F).toRadixString(16);
    return Dtc._('$letter$d1$d2$d3$d4'.toUpperCase());
  }

  /// Parses a textual code such as `p0171` or `U0100`.
  factory Dtc.parse(String text) {
    final t = text.trim().toUpperCase();
    if (!_pattern.hasMatch(t)) {
      throw FormatException('Not a valid DTC: "$text"');
    }
    return Dtc._(t);
  }

  static final _pattern = RegExp(r'^[PCBU][0-3][0-9A-F]{3}$');

  /// Returns true if [text] is a syntactically valid DTC.
  static bool isValid(String text) =>
      _pattern.hasMatch(text.trim().toUpperCase());

  final String code;

  DtcSystem get system => DtcSystem.fromLetter(code[0]);

  /// Second character, 0..3.
  int get groupDigit => int.parse(code[1]);

  /// SAE J2012 assignment of generic vs manufacturer-controlled ranges.
  ///
  /// P0xxx, P2xxx, P34xx-P39xx, B0/C0/U0, U3 are SAE controlled.
  /// P1xxx, P30xx-P33xx, B1/B2, C1/C2, U1/U2 are manufacturer controlled.
  DtcOrigin get origin {
    switch (system) {
      case DtcSystem.powertrain:
        if (groupDigit == 1) return DtcOrigin.manufacturer;
        if (groupDigit == 3) {
          final third = int.parse(code[2], radix: 16);
          return third <= 3 ? DtcOrigin.manufacturer : DtcOrigin.generic;
        }
        return DtcOrigin.generic;
      case DtcSystem.chassis:
      case DtcSystem.body:
        return (groupDigit == 0 || groupDigit == 3)
            ? DtcOrigin.generic
            : DtcOrigin.manufacturer;
      case DtcSystem.network:
        return (groupDigit == 0 || groupDigit == 3)
            ? DtcOrigin.generic
            : DtcOrigin.manufacturer;
    }
  }

  /// Raw two-byte encoding.
  List<int> toBytes() {
    final sys = const {'P': 0, 'C': 1, 'B': 2, 'U': 3}[code[0]]!;
    final a = (sys << 6) | (groupDigit << 4) | int.parse(code[2], radix: 16);
    final b = int.parse(code.substring(3), radix: 16);
    return [a, b];
  }

  @override
  int compareTo(Dtc other) => code.compareTo(other.code);

  @override
  bool operator ==(Object other) => other is Dtc && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => code;
}

/// Decodes the DTC payload of a Mode 03/07/0A response.
///
/// [data] is the response payload after the mode byte (0x43/0x47/0x4A).
/// On CAN (ISO 15765-4) the first byte is the number of codes; on legacy
/// protocols there is no count byte and each frame carries three code slots
/// padded with 0x0000. Set [hasCountByte] accordingly.
///
/// `P0000` slots are padding and are dropped. Duplicates are removed while
/// keeping the ECU's order.
List<Dtc> decodeDtcPayload(List<int> data, {required bool hasCountByte}) {
  var bytes = data;
  int? declared;
  if (hasCountByte) {
    if (bytes.isEmpty) return const [];
    declared = bytes.first;
    bytes = bytes.sublist(1);
  }
  final result = <Dtc>[];
  for (var i = 0; i + 1 < bytes.length; i += 2) {
    if (bytes[i] == 0 && bytes[i + 1] == 0) continue;
    final dtc = Dtc.fromBytes(bytes[i], bytes[i + 1]);
    if (!result.contains(dtc)) result.add(dtc);
  }
  if (declared != null && result.length > declared) {
    return result.sublist(0, declared);
  }
  return result;
}
