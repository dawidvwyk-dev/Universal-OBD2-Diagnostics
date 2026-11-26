/// VIN extraction and validation (ISO 3779 / 49 CFR 565).
library;

/// Extracts a VIN from the raw Mode 09 PID 02 payload (all bytes after the
/// `49 02` header, possibly including the CAN item count byte or the legacy
/// per-message sequence bytes). Returns null if no 17-character VIN is found.
String? extractVin(List<int> payload) {
  final chars = StringBuffer();
  for (final b in payload) {
    if (b >= 0x30 && b <= 0x39 || b >= 0x41 && b <= 0x5A) {
      chars.writeCharCode(b);
    }
  }
  final s = chars.toString();
  if (s.length < 17) return null;
  final vin = s.substring(s.length - 17);
  return isVinSyntaxValid(vin) ? vin : null;
}

final _vinPattern = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');

/// 17 characters, digits and capital letters except I, O and Q.
bool isVinSyntaxValid(String vin) => _vinPattern.hasMatch(vin);

const _translit = {
  'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8,
  'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'P': 7, 'R': 9,
  'S': 2, 'T': 3, 'U': 4, 'V': 5, 'W': 6, 'X': 7, 'Y': 8, 'Z': 9,
};
const _weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];

/// North American check digit (position 9). Other regions do not require
/// it, so a mismatch outside North America is not an error.
bool isVinCheckDigitValid(String vin) {
  if (!isVinSyntaxValid(vin)) return false;
  var sum = 0;
  for (var i = 0; i < 17; i++) {
    final ch = vin[i];
    final v = int.tryParse(ch) ?? _translit[ch]!;
    sum += v * _weights[i];
  }
  final r = sum % 11;
  final expected = r == 10 ? 'X' : '$r';
  return vin[8] == expected;
}

const _yearCodes = 'ABCDEFGHJKLMNPRSTVWXY123456789';

/// Possible model years for the VIN's 10th character. The code repeats every
/// 30 years, so up to two candidates are returned, newest first, never later
/// than [maxYear].
List<int> vinModelYearCandidates(String vin, {int? maxYear}) {
  if (!isVinSyntaxValid(vin)) return const [];
  final idx = _yearCodes.indexOf(vin[9]);
  if (idx < 0) return const [];
  final limit = maxYear ?? DateTime.now().year + 1;
  final out = <int>[];
  for (var y = 1980 + idx; y <= limit; y += 30) {
    out.add(y);
  }
  return out.reversed.toList();
}

/// World manufacturer identifiers for widely sold brands. Unknown WMIs return
/// null; the app then shows the WMI itself rather than guessing a brand.
const Map<String, String> knownWmi = {
  'WVW': 'Volkswagen', 'WV1': 'Volkswagen Commercial', 'WV2': 'Volkswagen Commercial',
  '3VW': 'Volkswagen (Mexico)', '1VW': 'Volkswagen (USA)',
  'WAU': 'Audi', 'TRU': 'Audi (Hungary)', 'WBA': 'BMW', 'WBS': 'BMW M',
  'WDB': 'Mercedes-Benz', 'WDD': 'Mercedes-Benz', 'WDC': 'Mercedes-Benz',
  'W1K': 'Mercedes-Benz', 'WP0': 'Porsche', 'WP1': 'Porsche',
  'W0L': 'Opel/Vauxhall', 'WF0': 'Ford (Germany)', 'TMB': 'Škoda', 'VSS': 'SEAT',
  'VF1': 'Renault', 'VF3': 'Peugeot', 'VF7': 'Citroën', 'ZFA': 'Fiat',
  'ZAR': 'Alfa Romeo', 'SAL': 'Land Rover', 'SAJ': 'Jaguar', 'YV1': 'Volvo',
  'JHM': 'Honda', '1HG': 'Honda (USA)', 'JTD': 'Toyota', 'JTE': 'Toyota',
  'JT2': 'Toyota', 'SB1': 'Toyota (UK)', '2T1': 'Toyota (Canada)',
  '4T1': 'Toyota (USA)', 'JN1': 'Nissan', 'JM1': 'Mazda', 'JF1': 'Subaru',
  'JMB': 'Mitsubishi', 'KMH': 'Hyundai', 'KNA': 'Kia', '1FA': 'Ford (USA)',
  '1FT': 'Ford Truck (USA)', '1G1': 'Chevrolet (USA)', '5YJ': 'Tesla',
};

String? manufacturerFromVin(String vin) =>
    vin.length >= 3 ? knownWmi[vin.substring(0, 3)] : null;
