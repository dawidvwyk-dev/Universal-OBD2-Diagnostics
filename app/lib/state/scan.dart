import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obd_decoders/obd_decoders.dart';
import 'package:obd_engine/obd_engine.dart';

import 'connection.dart';

class ScanResult {
  ScanResult({
    required this.time,
    required this.full,
    required this.simulated,
    this.identity,
    this.voltage,
    this.readiness,
    this.stored,
    this.pending,
    this.permanent,
    this.freezeDtc,
    this.freezeFrame = const {},
    this.snapshot = const {},
    this.errors = const [],
  });

  final DateTime time;
  final bool full;
  final bool simulated;
  final VehicleIdentity? identity;
  final double? voltage;
  final ReadinessStatus? readiness;
  final DtcReport? stored;
  final DtcReport? pending;
  final DtcReport? permanent;
  final Dtc? freezeDtc;
  final Map<int, List<PidValue>> freezeFrame;

  /// One reading of every supported live PID (full scan only).
  final Map<int, List<PidValue>> snapshot;

  /// Steps that failed, in plain language. A failed step is reported, never
  /// filled with assumed values.
  final List<String> errors;

  int get totalCodes => {...?stored?.all, ...?pending?.all, ...?permanent?.all}.length;
}

class ScanState {
  const ScanState({this.running = false, this.step, this.result, this.progress = 0});
  final bool running;
  final String? step;
  final double progress;
  final ScanResult? result;
}

class ScanController extends Notifier<ScanState> {
  @override
  ScanState build() {
    // A new connection invalidates the previous scan.
    ref.listen(connectionProvider.select((c) => c.session), (prev, next) {
      if (prev != next) state = const ScanState();
    });
    return const ScanState();
  }

  Future<void> run({required bool full}) async {
    final conn = ref.read(connectionProvider);
    final s = conn.session;
    if (s == null || !conn.isReady || state.running) return;
    final errors = <String>[];
    final steps = full ? 8.0 : 6.0;
    var done = 0;

    Future<T?> step<T>(String label, Future<T> Function() f) async {
      state = ScanState(running: true, step: label, progress: done / steps);
      try {
        return await f();
      } catch (e) {
        errors.add('$label: $e');
        return null;
      } finally {
        done++;
      }
    }

    final identity = await step('Reading vehicle identification', s.readIdentity);
    final voltage = await step('Reading battery voltage', s.readBatteryVoltage);
    final readiness = await step('Reading readiness monitors', s.readReadiness);
    final stored = await step('Reading stored codes (Mode 03)', () => s.readDtcs(DtcStatus.stored));
    final pending = await step('Reading pending codes (Mode 07)', () => s.readDtcs(DtcStatus.pending));
    final permanent = await step('Reading permanent codes (Mode 0A)', () => s.readDtcs(DtcStatus.permanent));
    Dtc? ffDtc;
    var ff = <int, List<PidValue>>{};
    var snapshot = <int, List<PidValue>>{};
    if (full) {
      final r = await step('Reading freeze frame (Mode 02)', s.readFreezeFrame);
      if (r != null) {
        ffDtc = r.$1;
        ff = r.$2;
      }
      final live = s.supportedPids.values.expand((e) => e).where((p) => p % 0x20 != 0 && mode01Pids[p]?.isLiveValue == true).toSet().toList()..sort();
      snapshot = await step('Reading all supported sensors', () => s.readPids(live)) ?? {};
    }
    state = ScanState(
      result: ScanResult(
        time: DateTime.now(),
        full: full,
        simulated: conn.simulated,
        identity: identity,
        voltage: voltage,
        readiness: readiness,
        stored: stored,
        pending: pending,
        permanent: permanent,
        freezeDtc: ffDtc,
        freezeFrame: ff,
        snapshot: snapshot,
        errors: errors,
      ),
      progress: 1,
    );
  }

  void clear() => state = const ScanState();
}

final scanProvider = NotifierProvider<ScanController, ScanState>(ScanController.new);
