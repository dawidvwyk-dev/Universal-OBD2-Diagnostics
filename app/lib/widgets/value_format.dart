import 'package:obd_decoders/obd_decoders.dart';

import '../state/settings.dart';

/// Converts a decoded value to the user's unit system for display.
(String, String) formatValue(PidValue v, UnitSystem units) {
  if (v.text != null) return (v.text!, '');
  final raw = v.value;
  if (raw == null) return ('not used', '');
  var unit = v.unit;
  var value = raw;
  if (units == UnitSystem.imperial) {
    final target = switch (unit) {
      ObdUnit.celsius => ObdUnit.fahrenheit,
      ObdUnit.kpa => ObdUnit.psi,
      ObdUnit.kmh => ObdUnit.mph,
      ObdUnit.km => ObdUnit.miles,
      ObdUnit.gramsPerSecond => ObdUnit.poundsPerMinute,
      ObdUnit.litresPerHour => ObdUnit.gallonsPerHour,
      _ => unit,
    };
    final c = convert(raw, unit, target);
    if (c != null) {
      value = c;
      unit = target;
    }
  }
  final digits = value == value.roundToDouble() || value.abs() >= 1000 ? 0 : (value.abs() >= 100 ? 1 : 2);
  return (value.toStringAsFixed(digits), unit.symbol);
}
