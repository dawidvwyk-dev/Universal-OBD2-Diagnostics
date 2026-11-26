/// SAE J1979 Mode 01 / Mode 02 parameter IDs and their decoders.
///
/// Formulas follow SAE J1979 (ISO 15031-5). Each decoder receives exactly
/// the data bytes after the PID byte (for Mode 02, after the frame number).
library;

import 'units.dart';

/// UI grouping for live data.
enum PidCategory { engine, fuel, emissions, oxygen, vehicle, status }

/// One decoded value. A PID can yield several values (e.g. O2 voltage + trim).
class PidValue {
  const PidValue({
    required this.key,
    required this.name,
    required this.value,
    required this.unit,
    this.text,
  });

  /// Stable identifier, e.g. `rpm` or `o2_b1s1_voltage`.
  final String key;
  final String name;

  /// Numeric value in [unit]; null when the value is not numeric or the
  /// sensor reported "not used" (e.g. O2 trim 0xFF).
  final double? value;
  final ObdUnit unit;

  /// Text form for enumerations (fuel system status, fuel type, ...).
  final String? text;

  @override
  String toString() =>
      '$name: ${text ?? value?.toStringAsFixed(2) ?? 'n/a'} ${unit.symbol}'
          .trim();
}

typedef PidDecoder = List<PidValue> Function(List<int> d);

class PidDefinition {
  const PidDefinition({
    required this.pid,
    required this.name,
    required this.bytes,
    required this.category,
    required this.decode,
    this.min,
    this.max,
    this.isLiveValue = true,
  });

  final int pid;
  final String name;

  /// Number of data bytes the ECU returns for this PID.
  final int bytes;
  final PidCategory category;
  final PidDecoder decode;

  /// Physical range of the encoding (used for gauge scales).
  final double? min;
  final double? max;

  /// False for bitfield/status PIDs that are not gauge material.
  final bool isLiveValue;

  String get hex => pid.toRadixString(16).padLeft(2, '0').toUpperCase();
}

int _u16(List<int> d, [int i = 0]) => (d[i] << 8) | d[i + 1];

PidDecoder _single(String key, String name, ObdUnit unit,
        double Function(List<int> d) f) =>
    (d) => [PidValue(key: key, name: name, value: f(d), unit: unit)];

double _pct(int a) => a * 100 / 255;
double _trim(int a) => (a - 128) * 100 / 128;

const _fuelSystemStatus = {
  0x00: 'Not reported',
  0x01: 'Open loop: insufficient temperature',
  0x02: 'Closed loop: using oxygen sensor',
  0x04: 'Open loop: engine load or deceleration',
  0x08: 'Open loop: system failure',
  0x10: 'Closed loop: fault in feedback system',
};

const fuelTypes = {
  0x00: 'Not available',
  0x01: 'Gasoline',
  0x02: 'Methanol',
  0x03: 'Ethanol',
  0x04: 'Diesel',
  0x05: 'LPG',
  0x06: 'CNG',
  0x07: 'Propane',
  0x08: 'Electric',
  0x09: 'Bifuel: gasoline',
  0x0A: 'Bifuel: methanol',
  0x0B: 'Bifuel: ethanol',
  0x0C: 'Bifuel: LPG',
  0x0D: 'Bifuel: CNG',
  0x0E: 'Bifuel: propane',
  0x0F: 'Bifuel: electricity',
  0x10: 'Bifuel: electric and combustion',
  0x11: 'Hybrid gasoline',
  0x12: 'Hybrid ethanol',
  0x13: 'Hybrid diesel',
  0x14: 'Hybrid electric',
  0x15: 'Hybrid electric and combustion',
  0x16: 'Hybrid regenerative',
  0x17: 'Bifuel: diesel',
};

const obdStandards = {
  0x01: 'OBD-II (CARB)',
  0x02: 'OBD (EPA)',
  0x03: 'OBD and OBD-II',
  0x04: 'OBD-I',
  0x05: 'Not OBD compliant',
  0x06: 'EOBD (Europe)',
  0x07: 'EOBD and OBD-II',
  0x08: 'EOBD and OBD',
  0x09: 'EOBD, OBD and OBD-II',
  0x0A: 'JOBD (Japan)',
  0x0B: 'JOBD and OBD-II',
  0x0C: 'JOBD and EOBD',
  0x0D: 'JOBD, EOBD and OBD-II',
  0x11: 'Engine Manufacturer Diagnostics (EMD)',
  0x12: 'EMD+',
  0x13: 'Heavy Duty OBD (Child/Partial)',
  0x14: 'Heavy Duty OBD',
  0x15: 'World Wide Harmonized OBD',
  0x17: 'Heavy Duty Euro OBD Stage I without NOx control',
  0x18: 'Heavy Duty Euro OBD Stage I with NOx control',
  0x19: 'Heavy Duty Euro OBD Stage II without NOx control',
  0x1A: 'Heavy Duty Euro OBD Stage II with NOx control',
  0x1C: 'Brazil OBD Phase 1',
  0x1D: 'Brazil OBD Phase 2',
  0x1E: 'Korean OBD',
  0x1F: 'India OBD I',
  0x20: 'India OBD II',
  0x21: 'Heavy Duty Euro OBD Stage VI',
};

List<PidValue> _fuelSystem(List<int> d) {
  String txt(int v) => _fuelSystemStatus[v] ?? 'Unknown (0x${v.toRadixString(16)})';
  return [
    PidValue(key: 'fuel_system_1', name: 'Fuel system 1 status', value: d[0].toDouble(), unit: ObdUnit.none, text: txt(d[0])),
    PidValue(key: 'fuel_system_2', name: 'Fuel system 2 status', value: d[1].toDouble(), unit: ObdUnit.none, text: txt(d[1])),
  ];
}

/// O2 sensor location names for PIDs 0x14..0x1B (PID 0x13 layout).
const _o2Locations = [
  'B1S1', 'B1S2', 'B1S3', 'B1S4', 'B2S1', 'B2S2', 'B2S3', 'B2S4',
];

PidDecoder _o2Narrow(int index) => (d) {
      final loc = _o2Locations[index];
      return [
        PidValue(key: 'o2_${loc.toLowerCase()}_voltage', name: 'O2 sensor $loc voltage', value: d[0] / 200, unit: ObdUnit.volts),
        PidValue(key: 'o2_${loc.toLowerCase()}_trim', name: 'O2 sensor $loc short-term trim', value: d[1] == 0xFF ? null : _trim(d[1]), unit: ObdUnit.percent),
      ];
    };

PidDecoder _o2WideVoltage(int index) => (d) {
      final loc = 'S${index + 1}';
      return [
        PidValue(key: 'o2w_${loc.toLowerCase()}_lambda', name: 'O2 sensor $loc equivalence ratio', value: _u16(d) * 2 / 65536, unit: ObdUnit.ratio),
        PidValue(key: 'o2w_${loc.toLowerCase()}_voltage', name: 'O2 sensor $loc voltage', value: _u16(d, 2) * 8 / 65536, unit: ObdUnit.volts),
      ];
    };

PidDecoder _o2WideCurrent(int index) => (d) {
      final loc = 'S${index + 1}';
      return [
        PidValue(key: 'o2w_${loc.toLowerCase()}_lambda', name: 'O2 sensor $loc equivalence ratio', value: _u16(d) * 2 / 65536, unit: ObdUnit.ratio),
        PidValue(key: 'o2w_${loc.toLowerCase()}_current', name: 'O2 sensor $loc current', value: _u16(d, 2) / 256 - 128, unit: ObdUnit.milliamps),
      ];
    };

PidDefinition _supported(int pid) => PidDefinition(
      pid: pid,
      name: 'PIDs supported ${(pid + 1).toRadixString(16).toUpperCase().padLeft(2, '0')}-${(pid + 0x20).toRadixString(16).toUpperCase().padLeft(2, '0')}',
      bytes: 4,
      category: PidCategory.status,
      isLiveValue: false,
      decode: (d) => [
        PidValue(key: 'supported_${pid.toRadixString(16)}', name: 'Supported PIDs', value: null, unit: ObdUnit.none, text: decodeSupportedBitmap(pid, d).map((p) => p.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ')),
      ],
    );

/// Decodes a 4-byte "PIDs supported" bitmap returned for [basePid]
/// (0x00, 0x20, 0x40, ...). Bit 7 of the first byte is basePid+1.
List<int> decodeSupportedBitmap(int basePid, List<int> d) {
  final out = <int>[];
  for (var byte = 0; byte < 4; byte++) {
    for (var bit = 0; bit < 8; bit++) {
      if ((d[byte] >> (7 - bit)) & 1 == 1) {
        out.add(basePid + byte * 8 + bit + 1);
      }
    }
  }
  return out;
}

/// All Mode 01 PIDs this decoder knows. PIDs not in this table are shown as
/// raw bytes and never given an invented meaning.
final Map<int, PidDefinition> mode01Pids = {
  for (final p in _definitions) p.pid: p,
};

final List<PidDefinition> _definitions = [
  _supported(0x00),
  PidDefinition(pid: 0x01, name: 'Monitor status since DTCs cleared', bytes: 4, category: PidCategory.status, isLiveValue: false, decode: (d) => [
        PidValue(key: 'mil_on', name: 'MIL (check engine light)', value: (d[0] & 0x80) != 0 ? 1 : 0, unit: ObdUnit.none, text: (d[0] & 0x80) != 0 ? 'On' : 'Off'),
        PidValue(key: 'dtc_count', name: 'Stored DTC count', value: (d[0] & 0x7F).toDouble(), unit: ObdUnit.count),
      ]),
  PidDefinition(pid: 0x03, name: 'Fuel system status', bytes: 2, category: PidCategory.fuel, isLiveValue: false, decode: _fuelSystem),
  PidDefinition(pid: 0x04, name: 'Calculated engine load', bytes: 1, category: PidCategory.engine, min: 0, max: 100, decode: _single('engine_load', 'Calculated engine load', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x05, name: 'Engine coolant temperature', bytes: 1, category: PidCategory.engine, min: -40, max: 215, decode: _single('coolant_temp', 'Engine coolant temperature', ObdUnit.celsius, (d) => d[0] - 40.0)),
  PidDefinition(pid: 0x06, name: 'Short-term fuel trim bank 1', bytes: 1, category: PidCategory.fuel, min: -100, max: 99.2, decode: _single('stft_b1', 'Short-term fuel trim bank 1', ObdUnit.percent, (d) => _trim(d[0]))),
  PidDefinition(pid: 0x07, name: 'Long-term fuel trim bank 1', bytes: 1, category: PidCategory.fuel, min: -100, max: 99.2, decode: _single('ltft_b1', 'Long-term fuel trim bank 1', ObdUnit.percent, (d) => _trim(d[0]))),
  PidDefinition(pid: 0x08, name: 'Short-term fuel trim bank 2', bytes: 1, category: PidCategory.fuel, min: -100, max: 99.2, decode: _single('stft_b2', 'Short-term fuel trim bank 2', ObdUnit.percent, (d) => _trim(d[0]))),
  PidDefinition(pid: 0x09, name: 'Long-term fuel trim bank 2', bytes: 1, category: PidCategory.fuel, min: -100, max: 99.2, decode: _single('ltft_b2', 'Long-term fuel trim bank 2', ObdUnit.percent, (d) => _trim(d[0]))),
  PidDefinition(pid: 0x0A, name: 'Fuel pressure (gauge)', bytes: 1, category: PidCategory.fuel, min: 0, max: 765, decode: _single('fuel_pressure', 'Fuel pressure', ObdUnit.kpa, (d) => d[0] * 3.0)),
  PidDefinition(pid: 0x0B, name: 'Intake manifold absolute pressure', bytes: 1, category: PidCategory.engine, min: 0, max: 255, decode: _single('map', 'Intake manifold absolute pressure', ObdUnit.kpa, (d) => d[0].toDouble())),
  PidDefinition(pid: 0x0C, name: 'Engine speed', bytes: 2, category: PidCategory.engine, min: 0, max: 16383.75, decode: _single('rpm', 'Engine speed', ObdUnit.rpm, (d) => _u16(d) / 4)),
  PidDefinition(pid: 0x0D, name: 'Vehicle speed', bytes: 1, category: PidCategory.vehicle, min: 0, max: 255, decode: _single('speed', 'Vehicle speed', ObdUnit.kmh, (d) => d[0].toDouble())),
  PidDefinition(pid: 0x0E, name: 'Timing advance', bytes: 1, category: PidCategory.engine, min: -64, max: 63.5, decode: _single('timing_advance', 'Timing advance', ObdUnit.degrees, (d) => d[0] / 2 - 64)),
  PidDefinition(pid: 0x0F, name: 'Intake air temperature', bytes: 1, category: PidCategory.engine, min: -40, max: 215, decode: _single('iat', 'Intake air temperature', ObdUnit.celsius, (d) => d[0] - 40.0)),
  PidDefinition(pid: 0x10, name: 'Mass air flow rate', bytes: 2, category: PidCategory.engine, min: 0, max: 655.35, decode: _single('maf', 'Mass air flow rate', ObdUnit.gramsPerSecond, (d) => _u16(d) / 100)),
  PidDefinition(pid: 0x11, name: 'Throttle position', bytes: 1, category: PidCategory.engine, min: 0, max: 100, decode: _single('throttle', 'Throttle position', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x13, name: 'Oxygen sensors present (2 banks)', bytes: 1, category: PidCategory.oxygen, isLiveValue: false, decode: (d) => [
        PidValue(key: 'o2_present', name: 'Oxygen sensors present', value: d[0].toDouble(), unit: ObdUnit.none, text: [for (var i = 0; i < 8; i++) if ((d[0] >> i) & 1 == 1) _o2Locations[i]].join(', ')),
      ]),
  for (var i = 0; i < 8; i++)
    PidDefinition(pid: 0x14 + i, name: 'O2 sensor ${_o2Locations[i]}', bytes: 2, category: PidCategory.oxygen, min: 0, max: 1.275, decode: _o2Narrow(i)),
  PidDefinition(pid: 0x1C, name: 'OBD standard', bytes: 1, category: PidCategory.status, isLiveValue: false, decode: (d) => [
        PidValue(key: 'obd_standard', name: 'OBD standard', value: d[0].toDouble(), unit: ObdUnit.none, text: obdStandards[d[0]] ?? 'Reserved (0x${d[0].toRadixString(16)})'),
      ]),
  PidDefinition(pid: 0x1F, name: 'Run time since engine start', bytes: 2, category: PidCategory.vehicle, min: 0, max: 65535, decode: _single('runtime', 'Run time since engine start', ObdUnit.seconds, (d) => _u16(d).toDouble())),
  _supported(0x20),
  PidDefinition(pid: 0x21, name: 'Distance travelled with MIL on', bytes: 2, category: PidCategory.vehicle, min: 0, max: 65535, decode: _single('distance_mil', 'Distance with MIL on', ObdUnit.km, (d) => _u16(d).toDouble())),
  PidDefinition(pid: 0x22, name: 'Fuel rail pressure (relative to manifold)', bytes: 2, category: PidCategory.fuel, min: 0, max: 5177.265, decode: _single('fuel_rail_pressure_rel', 'Fuel rail pressure (relative)', ObdUnit.kpa, (d) => _u16(d) * 0.079)),
  PidDefinition(pid: 0x23, name: 'Fuel rail gauge pressure', bytes: 2, category: PidCategory.fuel, min: 0, max: 655350, decode: _single('fuel_rail_pressure', 'Fuel rail pressure', ObdUnit.kpa, (d) => _u16(d) * 10.0)),
  for (var i = 0; i < 8; i++)
    PidDefinition(pid: 0x24 + i, name: 'O2 sensor S${i + 1} (wide range, voltage)', bytes: 4, category: PidCategory.oxygen, min: 0, max: 2, decode: _o2WideVoltage(i)),
  PidDefinition(pid: 0x2C, name: 'Commanded EGR', bytes: 1, category: PidCategory.emissions, min: 0, max: 100, decode: _single('egr_commanded', 'Commanded EGR', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x2D, name: 'EGR error', bytes: 1, category: PidCategory.emissions, min: -100, max: 99.2, decode: _single('egr_error', 'EGR error', ObdUnit.percent, (d) => _trim(d[0]))),
  PidDefinition(pid: 0x2E, name: 'Commanded evaporative purge', bytes: 1, category: PidCategory.emissions, min: 0, max: 100, decode: _single('evap_purge', 'Commanded evaporative purge', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x2F, name: 'Fuel tank level input', bytes: 1, category: PidCategory.fuel, min: 0, max: 100, decode: _single('fuel_level', 'Fuel tank level', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x30, name: 'Warm-ups since codes cleared', bytes: 1, category: PidCategory.vehicle, min: 0, max: 255, decode: _single('warmups', 'Warm-ups since codes cleared', ObdUnit.count, (d) => d[0].toDouble())),
  PidDefinition(pid: 0x31, name: 'Distance since codes cleared', bytes: 2, category: PidCategory.vehicle, min: 0, max: 65535, decode: _single('distance_cleared', 'Distance since codes cleared', ObdUnit.km, (d) => _u16(d).toDouble())),
  PidDefinition(pid: 0x32, name: 'Evap system vapour pressure', bytes: 2, category: PidCategory.emissions, min: -8192, max: 8191.75, decode: _single('evap_vapor_pressure', 'Evap system vapour pressure', ObdUnit.pascal, (d) => _u16(d).toSigned(16) / 4)),
  PidDefinition(pid: 0x33, name: 'Absolute barometric pressure', bytes: 1, category: PidCategory.vehicle, min: 0, max: 255, decode: _single('baro', 'Barometric pressure', ObdUnit.kpa, (d) => d[0].toDouble())),
  for (var i = 0; i < 8; i++)
    PidDefinition(pid: 0x34 + i, name: 'O2 sensor S${i + 1} (wide range, current)', bytes: 4, category: PidCategory.oxygen, min: 0, max: 2, decode: _o2WideCurrent(i)),
  for (var i = 0; i < 4; i++)
    PidDefinition(pid: 0x3C + i, name: 'Catalyst temperature B${i % 2 + 1}S${i ~/ 2 + 1}', bytes: 2, category: PidCategory.emissions, min: -40, max: 6513.5, decode: _single('cat_temp_b${i % 2 + 1}s${i ~/ 2 + 1}', 'Catalyst temperature B${i % 2 + 1}S${i ~/ 2 + 1}', ObdUnit.celsius, (d) => _u16(d) / 10 - 40)),
  _supported(0x40),
  PidDefinition(pid: 0x42, name: 'Control module voltage', bytes: 2, category: PidCategory.vehicle, min: 0, max: 65.535, decode: _single('module_voltage', 'Control module voltage', ObdUnit.volts, (d) => _u16(d) / 1000)),
  PidDefinition(pid: 0x43, name: 'Absolute load value', bytes: 2, category: PidCategory.engine, min: 0, max: 25700, decode: _single('absolute_load', 'Absolute load value', ObdUnit.percent, (d) => _u16(d) * 100 / 255)),
  PidDefinition(pid: 0x44, name: 'Commanded air-fuel equivalence ratio', bytes: 2, category: PidCategory.fuel, min: 0, max: 2, decode: _single('commanded_lambda', 'Commanded equivalence ratio', ObdUnit.ratio, (d) => _u16(d) * 2 / 65536)),
  PidDefinition(pid: 0x45, name: 'Relative throttle position', bytes: 1, category: PidCategory.engine, min: 0, max: 100, decode: _single('throttle_relative', 'Relative throttle position', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x46, name: 'Ambient air temperature', bytes: 1, category: PidCategory.vehicle, min: -40, max: 215, decode: _single('ambient_temp', 'Ambient air temperature', ObdUnit.celsius, (d) => d[0] - 40.0)),
  PidDefinition(pid: 0x47, name: 'Absolute throttle position B', bytes: 1, category: PidCategory.engine, min: 0, max: 100, decode: _single('throttle_b', 'Absolute throttle position B', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x48, name: 'Absolute throttle position C', bytes: 1, category: PidCategory.engine, min: 0, max: 100, decode: _single('throttle_c', 'Absolute throttle position C', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x49, name: 'Accelerator pedal position D', bytes: 1, category: PidCategory.engine, min: 0, max: 100, decode: _single('pedal_d', 'Accelerator pedal position D', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x4A, name: 'Accelerator pedal position E', bytes: 1, category: PidCategory.engine, min: 0, max: 100, decode: _single('pedal_e', 'Accelerator pedal position E', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x4B, name: 'Accelerator pedal position F', bytes: 1, category: PidCategory.engine, min: 0, max: 100, decode: _single('pedal_f', 'Accelerator pedal position F', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x4C, name: 'Commanded throttle actuator', bytes: 1, category: PidCategory.engine, min: 0, max: 100, decode: _single('throttle_commanded', 'Commanded throttle actuator', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x4D, name: 'Time run with MIL on', bytes: 2, category: PidCategory.vehicle, min: 0, max: 65535, decode: _single('time_mil', 'Time run with MIL on', ObdUnit.minutes, (d) => _u16(d).toDouble())),
  PidDefinition(pid: 0x4E, name: 'Time since codes cleared', bytes: 2, category: PidCategory.vehicle, min: 0, max: 65535, decode: _single('time_cleared', 'Time since codes cleared', ObdUnit.minutes, (d) => _u16(d).toDouble())),
  PidDefinition(pid: 0x51, name: 'Fuel type', bytes: 1, category: PidCategory.fuel, isLiveValue: false, decode: (d) => [
        PidValue(key: 'fuel_type', name: 'Fuel type', value: d[0].toDouble(), unit: ObdUnit.none, text: fuelTypes[d[0]] ?? 'Reserved (0x${d[0].toRadixString(16)})'),
      ]),
  PidDefinition(pid: 0x52, name: 'Ethanol fuel percentage', bytes: 1, category: PidCategory.fuel, min: 0, max: 100, decode: _single('ethanol', 'Ethanol fuel percentage', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x59, name: 'Fuel rail absolute pressure', bytes: 2, category: PidCategory.fuel, min: 0, max: 655350, decode: _single('fuel_rail_abs', 'Fuel rail absolute pressure', ObdUnit.kpa, (d) => _u16(d) * 10.0)),
  PidDefinition(pid: 0x5A, name: 'Relative accelerator pedal position', bytes: 1, category: PidCategory.engine, min: 0, max: 100, decode: _single('pedal_relative', 'Relative accelerator pedal position', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x5B, name: 'Hybrid battery pack remaining life', bytes: 1, category: PidCategory.vehicle, min: 0, max: 100, decode: _single('hybrid_battery', 'Hybrid battery remaining life', ObdUnit.percent, (d) => _pct(d[0]))),
  PidDefinition(pid: 0x5C, name: 'Engine oil temperature', bytes: 1, category: PidCategory.engine, min: -40, max: 210, decode: _single('oil_temp', 'Engine oil temperature', ObdUnit.celsius, (d) => d[0] - 40.0)),
  PidDefinition(pid: 0x5D, name: 'Fuel injection timing', bytes: 2, category: PidCategory.fuel, min: -210, max: 301.992, decode: _single('injection_timing', 'Fuel injection timing', ObdUnit.degrees, (d) => _u16(d) / 128 - 210)),
  PidDefinition(pid: 0x5E, name: 'Engine fuel rate', bytes: 2, category: PidCategory.fuel, min: 0, max: 3212.75, decode: _single('fuel_rate', 'Engine fuel rate', ObdUnit.litresPerHour, (d) => _u16(d) / 20)),
  _supported(0x60),
  _supported(0x80),
  _supported(0xA0),
  _supported(0xC0),
];

/// Decodes a Mode 01 (or Mode 02 after removing the frame byte) payload for
/// [pid]. Returns null for unknown PIDs or short payloads; callers must show
/// unknown PIDs as raw data rather than guessing.
List<PidValue>? decodePid(int pid, List<int> data) {
  final def = mode01Pids[pid];
  if (def == null || data.length < def.bytes) return null;
  return def.decode(data.sublist(0, def.bytes));
}
