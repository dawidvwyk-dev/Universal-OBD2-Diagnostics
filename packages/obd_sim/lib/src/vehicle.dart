/// Virtual vehicles for the simulator. TEST USE ONLY: values here are
/// synthetic and must never be shown as real vehicle readings.
library;

import 'dart:math' as math;

import 'package:obd_decoders/obd_decoders.dart';

/// Protocols a virtual vehicle can speak (ELM numbering).
enum SimProtocol {
  j1850Pwm(1, false, false),
  j1850Vpw(2, false, false),
  iso9141(3, false, false),
  kwp5Baud(4, false, false),
  kwpFast(5, false, false),
  can11b500(6, true, false),
  can29b500(7, true, true),
  can11b250(8, true, false),
  can29b250(9, true, true);

  const SimProtocol(this.elmNumber, this.isCan, this.is29Bit);
  final int elmNumber;
  final bool isCan;
  final bool is29Bit;
}

/// Produces the raw data bytes of a PID at simulated time [t] seconds.
typedef PidSource = List<int> Function(double t);

class VirtualEcu {
  VirtualEcu({
    required this.canId,
    required this.legacyAddress,
    required this.name,
    Map<int, PidSource>? pids,
    List<String>? storedDtcs,
    List<String>? pendingDtcs,
    List<String>? permanentDtcs,
    this.vin,
    this.calibrationId,
    this.cvn,
    this.freezeFrameDtc,
    Map<int, List<int>>? freezeFrame,
  })  : pids = pids ?? {},
        storedDtcs = [...?storedDtcs],
        pendingDtcs = [...?pendingDtcs],
        permanentDtcs = [...?permanentDtcs],
        freezeFrame = freezeFrame ?? {};

  /// Response CAN id for 11-bit (e.g. 0x7E8). 29-bit uses 18DAF1xx where
  /// xx is [legacyAddress].
  final int canId;

  /// Source address used in legacy headers and 29-bit ids (e.g. 0x10).
  final int legacyAddress;
  final String name;
  final Map<int, PidSource> pids;
  final List<String> storedDtcs;
  final List<String> pendingDtcs;
  final List<String> permanentDtcs;
  final String? vin;
  final String? calibrationId;
  final List<int>? cvn;
  String? freezeFrameDtc;
  final Map<int, List<int>> freezeFrame;

  /// Builds the 4-byte supported-PID bitmap for [base] from [pids].
  List<int> supportedBitmap(int base) {
    final out = [0, 0, 0, 0];
    final all = {...pids.keys, 0x01};
    // A "supported" PID for the next range is set when any higher PID exists.
    for (final p in all) {
      if (p > base && p <= base + 0x20) {
        final i = p - base - 1;
        out[i ~/ 8] |= 0x80 >> (i % 8);
      }
    }
    if (all.any((p) => p > base + 0x20)) out[3] |= 0x01;
    return out;
  }
}

class VirtualVehicle {
  VirtualVehicle({
    required this.name,
    required this.protocol,
    required this.ecus,
    this.batteryVolts = 12.6,
    this.ignitionOn = true,
  });

  final String name;
  final SimProtocol protocol;
  final List<VirtualEcu> ecus;
  double batteryVolts;
  bool ignitionOn;

  VirtualEcu get engine => ecus.first;
}

// ---- encoders (inverse of SAE J1979 formulas) ----
int _clamp8(num v) => v.round().clamp(0, 255);
List<int> _u16(num v) {
  final x = v.round().clamp(0, 65535);
  return [x >> 8, x & 0xFF];
}

List<int> encTemp(double c) => [_clamp8(c + 40)];
List<int> encPct(double p) => [_clamp8(p * 255 / 100)];
List<int> encTrim(double p) => [_clamp8(p * 128 / 100 + 128)];
List<int> encRpm(double rpm) => _u16(rpm * 4);
List<int> encMaf(double gs) => _u16(gs * 100);
List<int> encVolts(double v) => _u16(v * 1000);

double _wave(double t, double period, double amp) =>
    amp * math.sin(2 * math.pi * t / period);

/// Ready-made scenarios used by tests and the developer simulator.
class Scenarios {
  static const testVin = '1M8GDM9AXKP042788';

  static Map<int, PidSource> _gasolinePids({
    double stft = 0,
    double ltft = 0,
    double coolant = 90,
    double rpmBase = 780,
    double volts = 14.2,
  }) =>
      {
        0x01: (t) => [0x00, 0x07, 0x65, 0x00],
        0x03: (t) => [0x02, 0x00],
        0x04: (t) => encPct(22 + _wave(t, 7, 3)),
        0x05: (t) => encTemp(coolant),
        0x06: (t) => encTrim(stft + _wave(t, 3, 2)),
        0x07: (t) => encTrim(ltft),
        0x0B: (t) => [_clamp8(33 + _wave(t, 5, 2))],
        0x0C: (t) => encRpm(rpmBase + _wave(t, 4, 25)),
        0x0D: (t) => [0],
        0x0E: (t) => [_clamp8((12 + 64) * 2)],
        0x0F: (t) => encTemp(28),
        0x10: (t) => encMaf(3.6 + _wave(t, 4, 0.2)),
        0x11: (t) => encPct(14.5),
        0x13: (t) => [0x03],
        0x14: (t) => [_clamp8((0.45 + _wave(t, 1.2, 0.35)) * 200), encTrim(stft)[0]],
        0x15: (t) => [_clamp8(0.65 * 200), 0xFF],
        0x1C: (t) => [0x06],
        0x1F: (t) => _u16(t),
        0x21: (t) => _u16(0),
        0x2F: (t) => encPct(61),
        0x30: (t) => [12],
        0x31: (t) => _u16(845),
        0x33: (t) => [101],
        0x42: (t) => encVolts(volts),
        0x46: (t) => encTemp(18),
        0x51: (t) => [0x01],
      };

  /// A healthy petrol car on 11-bit CAN with engine and transmission ECUs.
  static VirtualVehicle healthyCan() => VirtualVehicle(
        name: 'Healthy petrol, CAN 11-bit 500k',
        protocol: SimProtocol.can11b500,
        ecus: [
          VirtualEcu(
            canId: 0x7E8,
            legacyAddress: 0x10,
            name: 'ECM-EngineControl',
            vin: testVin,
            calibrationId: 'SIMCAL0001',
            cvn: [0x12, 0x34, 0xAB, 0xCD],
            pids: _gasolinePids(),
          ),
          VirtualEcu(
            canId: 0x7E9,
            legacyAddress: 0x18,
            name: 'TCM-TransmissionCtl',
            pids: {0x01: (t) => [0x00, 0x04, 0x00, 0x00]},
          ),
        ],
      );

  /// P0171 lean bank 1 with high positive trims and a freeze frame.
  static VirtualVehicle leanBank1() {
    final v = healthyCan();
    final e = v.engine;
    e.pids
      ..addAll(_gasolinePids(stft: 9, ltft: 18))
      ..[0x01] = (t) => [0x81, 0x07, 0x65, 0x00];
    e.storedDtcs.add('P0171');
    e.permanentDtcs.add('P0171');
    e.freezeFrameDtc = 'P0171';
    e.freezeFrame.addAll({
      0x04: encPct(31), 0x05: encTemp(88), 0x06: encTrim(12),
      0x07: encTrim(19), 0x0C: encRpm(2150), 0x0D: [62],
    });
    return VirtualVehicle(name: 'Lean bank 1 (P0171), CAN 11-bit', protocol: v.protocol, ecus: v.ecus);
  }

  /// Random misfire with a pending code and incomplete catalyst monitor.
  static VirtualVehicle misfire() {
    final v = healthyCan();
    v.engine.pids[0x01] = (t) => [0x81, 0x07, 0x65, 0x01];
    v.engine.storedDtcs.addAll(['P0300', 'P0302']);
    v.engine.pendingDtcs.add('P0304');
    return VirtualVehicle(name: 'Misfire (P0300/P0302), CAN 11-bit', protocol: v.protocol, ecus: v.ecus);
  }

  /// An older car on ISO 9141-2, single ECU, legacy framing.
  static VirtualVehicle legacyIso9141() => VirtualVehicle(
        name: 'Legacy petrol, ISO 9141-2',
        protocol: SimProtocol.iso9141,
        ecus: [
          VirtualEcu(
            canId: 0x7E8,
            legacyAddress: 0x10,
            name: 'ECM',
            vin: 'WVWZZZ1JZ3W386752',
            pids: _gasolinePids(),
            storedDtcs: ['P0420', 'P0133', 'P0441', 'P0455'],
          ),
        ],
      );

  /// Weak charging: low module voltage, no codes.
  static VirtualVehicle weakCharging() {
    final v = healthyCan();
    v.engine.pids.addAll(_gasolinePids(volts: 12.1));
    v.batteryVolts = 11.9;
    return VirtualVehicle(name: 'Weak charging system, CAN 11-bit', protocol: v.protocol, ecus: v.ecus, batteryVolts: 11.9);
  }

  /// A diesel on 29-bit CAN with DPF monitor incomplete.
  static VirtualVehicle diesel29Bit() => VirtualVehicle(
        name: 'Diesel, CAN 29-bit 500k',
        protocol: SimProtocol.can29b500,
        ecus: [
          VirtualEcu(
            canId: 0x7E8,
            legacyAddress: 0x10,
            name: 'ECM-EngineControl',
            vin: 'WF0XXXTTGXKA12345',
            pids: {
              ..._gasolinePids(rpmBase: 820),
              0x01: (t) => [0x00, 0x0F, 0xC9, 0x40],
              0x51: (t) => [0x04],
            },
          ),
        ],
      );

  static final Map<String, VirtualVehicle Function()> all = {
    'healthy_can': healthyCan,
    'lean_bank1': leanBank1,
    'misfire': misfire,
    'legacy_iso9141': legacyIso9141,
    'weak_charging': weakCharging,
    'diesel_29bit': diesel29Bit,
  };
}

/// Encodes a textual DTC to its two bytes.
List<int> dtcBytes(String code) => Dtc.parse(code).toBytes();
