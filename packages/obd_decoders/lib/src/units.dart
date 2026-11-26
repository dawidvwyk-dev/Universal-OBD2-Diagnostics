/// Units used by decoded values. All decoders produce SI/metric base units;
/// conversion for display is done with [convert].
enum ObdUnit {
  none(''),
  percent('%'),
  celsius('°C'),
  fahrenheit('°F'),
  kpa('kPa'),
  psi('psi'),
  bar('bar'),
  rpm('rpm'),
  kmh('km/h'),
  mph('mph'),
  degrees('°'),
  gramsPerSecond('g/s'),
  poundsPerMinute('lb/min'),
  seconds('s'),
  minutes('min'),
  km('km'),
  miles('mi'),
  volts('V'),
  milliamps('mA'),
  ratio('λ'),
  litresPerHour('L/h'),
  gallonsPerHour('gal/h'),
  pascal('Pa'),
  count('');

  const ObdUnit(this.symbol);
  final String symbol;
}

/// Converts [value] from [from] to [to]. Returns null when the units are not
/// convertible.
double? convert(double value, ObdUnit from, ObdUnit to) {
  if (from == to) return value;
  switch ((from, to)) {
    case (ObdUnit.celsius, ObdUnit.fahrenheit):
      return value * 9 / 5 + 32;
    case (ObdUnit.fahrenheit, ObdUnit.celsius):
      return (value - 32) * 5 / 9;
    case (ObdUnit.kpa, ObdUnit.psi):
      return value * 0.1450377377;
    case (ObdUnit.psi, ObdUnit.kpa):
      return value / 0.1450377377;
    case (ObdUnit.kpa, ObdUnit.bar):
      return value / 100;
    case (ObdUnit.bar, ObdUnit.kpa):
      return value * 100;
    case (ObdUnit.kmh, ObdUnit.mph):
      return value * 0.6213711922;
    case (ObdUnit.mph, ObdUnit.kmh):
      return value / 0.6213711922;
    case (ObdUnit.km, ObdUnit.miles):
      return value * 0.6213711922;
    case (ObdUnit.miles, ObdUnit.km):
      return value / 0.6213711922;
    case (ObdUnit.gramsPerSecond, ObdUnit.poundsPerMinute):
      return value * 0.1322773573;
    case (ObdUnit.poundsPerMinute, ObdUnit.gramsPerSecond):
      return value / 0.1322773573;
    case (ObdUnit.litresPerHour, ObdUnit.gallonsPerHour):
      return value * 0.2641720524;
    case (ObdUnit.gallonsPerHour, ObdUnit.litresPerHour):
      return value / 0.2641720524;
    case (ObdUnit.seconds, ObdUnit.minutes):
      return value / 60;
    case (ObdUnit.minutes, ObdUnit.seconds):
      return value * 60;
    default:
      return null;
  }
}
