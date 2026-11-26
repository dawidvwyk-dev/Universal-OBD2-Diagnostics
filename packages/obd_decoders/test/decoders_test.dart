import 'package:obd_decoders/obd_decoders.dart';
import 'package:test/test.dart';

void main() {
  group('Dtc', () {
    test('decodes the four systems from raw bytes', () {
      expect(Dtc.fromBytes(0x01, 0x71).code, 'P0171');
      expect(Dtc.fromBytes(0x43, 0x00).code, 'C0300');
      expect(Dtc.fromBytes(0x80, 0x01).code, 'B0001');
      expect(Dtc.fromBytes(0xC1, 0x00).code, 'U0100');
      expect(Dtc.fromBytes(0x3F, 0xFF).code, 'P3FFF');
    });

    test('round-trips through bytes', () {
      for (final c in ['P0171', 'P2BAF', 'C1234', 'B2AAA', 'U3000']) {
        final b = Dtc.parse(c).toBytes();
        expect(Dtc.fromBytes(b[0], b[1]).code, c);
      }
    });

    test('rejects malformed codes', () {
      expect(() => Dtc.parse('P4000'), throwsFormatException);
      expect(() => Dtc.parse('X0100'), throwsFormatException);
      expect(Dtc.isValid('p0300'), isTrue);
    });

    test('classifies generic and manufacturer ranges', () {
      expect(Dtc.parse('P0171').origin, DtcOrigin.generic);
      expect(Dtc.parse('P1234').origin, DtcOrigin.manufacturer);
      expect(Dtc.parse('P2096').origin, DtcOrigin.generic);
      expect(Dtc.parse('P3000').origin, DtcOrigin.manufacturer);
      expect(Dtc.parse('P3400').origin, DtcOrigin.generic);
      expect(Dtc.parse('U0100').origin, DtcOrigin.generic);
      expect(Dtc.parse('U1100').origin, DtcOrigin.manufacturer);
      expect(Dtc.parse('B1000').origin, DtcOrigin.manufacturer);
    });

    test('decodes CAN payload with count byte', () {
      final codes = decodeDtcPayload([0x02, 0x01, 0x71, 0x03, 0x00],
          hasCountByte: true);
      expect(codes.map((c) => c.code), ['P0171', 'P0300']);
    });

    test('decodes legacy payload and drops padding', () {
      final codes = decodeDtcPayload([0x01, 0x71, 0x00, 0x00, 0x00, 0x00],
          hasCountByte: false);
      expect(codes.map((c) => c.code), ['P0171']);
    });

    test('no codes on CAN', () {
      expect(decodeDtcPayload([0x00], hasCountByte: true), isEmpty);
    });
  });

  group('PIDs', () {
    test('engine speed', () {
      expect(decodePid(0x0C, [0x1A, 0xF8])!.single.value, 1726);
    });
    test('coolant and IAT offset by 40', () {
      expect(decodePid(0x05, [0x7B])!.single.value, 83);
      expect(decodePid(0x0F, [0x00])!.single.value, -40);
    });
    test('fuel trims are signed percentages', () {
      expect(decodePid(0x06, [0x80])!.single.value, 0);
      expect(decodePid(0x07, [0x00])!.single.value, -100);
      expect(decodePid(0x06, [0x8A])!.single.value, closeTo(7.8125, 1e-9));
    });
    test('MAF and module voltage', () {
      expect(decodePid(0x10, [0x01, 0xF4])!.single.value, 5.0);
      expect(decodePid(0x42, [0x37, 0x6E])!.single.value, closeTo(14.19, 1e-9));
    });
    test('narrow O2 sensor yields voltage and trim, 0xFF trim unused', () {
      final v = decodePid(0x14, [0x5A, 0xFF])!;
      expect(v[0].value, 0.45);
      expect(v[1].value, isNull);
    });
    test('evap pressure is signed', () {
      expect(decodePid(0x32, [0xFF, 0xFC])!.single.value, -1);
    });
    test('catalyst temperature', () {
      expect(decodePid(0x3C, [0x11, 0x94])!.single.value, closeTo(410.0, 1e-9));
      expect(mode01Pids[0x3D]!.name, contains('B2S1'));
    });
    test('unknown PID and short payload return null', () {
      expect(decodePid(0x12, [0x00]), isNull);
      expect(decodePid(0x0C, [0x1A]), isNull);
    });
    test('fuel type enumeration', () {
      expect(decodePid(0x51, [0x04])!.single.text, 'Diesel');
    });
    test('supported bitmap', () {
      expect(decodeSupportedBitmap(0x00, [0xBE, 0x1F, 0xA8, 0x13]), [
        0x01, 0x03, 0x04, 0x05, 0x06, 0x07, 0x0C, 0x0D, 0x0E, 0x0F, 0x10,
        0x11, 0x13, 0x15, 0x1C, 0x1F, 0x20,
      ]);
      expect(decodeSupportedBitmap(0x20, [0x80, 0, 0, 0x01]), [0x21, 0x40]);
    });
  });

  group('Readiness', () {
    test('spark ignition', () {
      final r = decodeReadiness([0x81, 0x07, 0x65, 0x04]);
      expect(r.milOn, isTrue);
      expect(r.dtcCount, 1);
      expect(r.compressionIgnition, isFalse);
      expect(r.supported.map((m) => m.key), [
        'misfire', 'fuel_system', 'components', 'catalyst', 'evap',
        'o2_sensor', 'o2_heater',
      ]);
      expect(r.incomplete.map((m) => m.key), ['evap']);
    });
    test('compression ignition uses diesel monitors', () {
      final r = decodeReadiness([0x00, 0x0F, 0xC0, 0x40]);
      expect(r.compressionIgnition, isTrue);
      expect(r.supported.map((m) => m.key),
          containsAll(['pm_filter', 'egr_vvt']));
      expect(r.incomplete.single.key, 'pm_filter');
    });
  });

  group('VIN', () {
    test('check digit', () {
      expect(isVinCheckDigitValid('1M8GDM9AXKP042788'), isTrue);
      expect(isVinCheckDigitValid('1M8GDM9A1KP042788'), isFalse);
    });
    test('extracts from CAN payload with count byte', () {
      final vin = 'WVWZZZ1KZAW123456';
      expect(extractVin([0x01, ...vin.codeUnits]), vin);
    });
    test('extracts from legacy 5-message payload with padding', () {
      final vin = '1M8GDM9AXKP042788';
      final padded = [0, 0, 0, ...vin.codeUnits];
      final payload = <int>[];
      for (var i = 0; i < 5; i++) {
        payload
          ..add(i + 1)
          ..addAll(padded.sublist(i * 4, i * 4 + 4));
      }
      expect(extractVin(payload), vin);
    });
    test('rejects too-short data', () {
      expect(extractVin('ABC'.codeUnits), isNull);
    });
    test('model year candidates', () {
      expect(vinModelYearCandidates('1M8GDM9AXKP042788', maxYear: 2026),
          [2019, 1989]);
    });
    test('manufacturer lookup never guesses', () {
      expect(manufacturerFromVin('WVWZZZ1KZAW123456'), 'Volkswagen');
      expect(manufacturerFromVin('XXX00000000000000'), isNull);
    });
  });

  group('Units', () {
    test('conversions', () {
      expect(convert(100, ObdUnit.celsius, ObdUnit.fahrenheit), 212);
      expect(convert(100, ObdUnit.kmh, ObdUnit.mph), closeTo(62.137, 1e-3));
      expect(convert(1, ObdUnit.volts, ObdUnit.kpa), isNull);
    });
  });
}
