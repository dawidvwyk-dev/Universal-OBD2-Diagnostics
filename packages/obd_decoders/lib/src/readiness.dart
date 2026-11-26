/// Readiness monitor decoding for Mode 01 PID 01 (monitor status since DTCs
/// cleared) and PID 41 (monitor status this drive cycle) per SAE J1979.
library;

enum MonitorState {
  /// The vehicle does not have this monitor.
  notSupported,

  /// Supported and has run to completion.
  complete,

  /// Supported but has not yet completed.
  incomplete,
}

class ReadinessMonitor {
  const ReadinessMonitor(this.key, this.name, this.state);
  final String key;
  final String name;
  final MonitorState state;

  @override
  String toString() => '$name: ${state.name}';
}

class ReadinessStatus {
  const ReadinessStatus({
    required this.milOn,
    required this.dtcCount,
    required this.compressionIgnition,
    required this.monitors,
  });

  final bool milOn;
  final int dtcCount;

  /// True for diesel (compression ignition) monitor layout.
  final bool compressionIgnition;
  final List<ReadinessMonitor> monitors;

  Iterable<ReadinessMonitor> get supported =>
      monitors.where((m) => m.state != MonitorState.notSupported);

  Iterable<ReadinessMonitor> get incomplete =>
      monitors.where((m) => m.state == MonitorState.incomplete);

  bool get allComplete => incomplete.isEmpty;
}

const _continuous = [
  ('misfire', 'Misfire'),
  ('fuel_system', 'Fuel system'),
  ('components', 'Comprehensive components'),
];

const _spark = [
  ('catalyst', 'Catalyst'),
  ('heated_catalyst', 'Heated catalyst'),
  ('evap', 'Evaporative system'),
  ('secondary_air', 'Secondary air system'),
  ('ac_refrigerant', 'A/C refrigerant'),
  ('o2_sensor', 'Oxygen sensor'),
  ('o2_heater', 'Oxygen sensor heater'),
  ('egr_vvt', 'EGR and/or VVT system'),
];

const _compression = [
  ('nmhc_catalyst', 'NMHC catalyst'),
  ('nox_scr', 'NOx/SCR aftertreatment'),
  (null, null),
  ('boost_pressure', 'Boost pressure'),
  (null, null),
  ('exhaust_gas_sensor', 'Exhaust gas sensor'),
  ('pm_filter', 'Particulate filter (DPF)'),
  ('egr_vvt', 'EGR and/or VVT system'),
];

/// Decodes the 4 data bytes of PID 01.
ReadinessStatus decodeReadiness(List<int> d) {
  if (d.length < 4) {
    throw ArgumentError('PID 01 needs 4 bytes, got ${d.length}');
  }
  final a = d[0], b = d[1], c = d[2], dd = d[3];
  final ci = (b & 0x08) != 0;
  final monitors = <ReadinessMonitor>[];

  MonitorState state(bool supported, bool incomplete) => !supported
      ? MonitorState.notSupported
      : (incomplete ? MonitorState.incomplete : MonitorState.complete);

  for (var i = 0; i < 3; i++) {
    final (key, name) = _continuous[i];
    monitors.add(ReadinessMonitor(key, name,
        state((b >> i) & 1 == 1, (b >> (i + 4)) & 1 == 1)));
  }
  final table = ci ? _compression : _spark;
  for (var i = 0; i < 8; i++) {
    final (key, name) = table[i];
    if (key == null || name == null) continue;
    monitors.add(ReadinessMonitor(
        key, name, state((c >> i) & 1 == 1, (dd >> i) & 1 == 1)));
  }
  return ReadinessStatus(
    milOn: (a & 0x80) != 0,
    dtcCount: a & 0x7F,
    compressionIgnition: ci,
    monitors: monitors,
  );
}
