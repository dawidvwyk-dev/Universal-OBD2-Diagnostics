import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obd_decoders/obd_decoders.dart';

import 'connection.dart';
import 'settings.dart';

class SensorTrace {
  SensorTrace(this.pid, this.value);
  final int pid;
  PidValue value;
  final List<double> history = [];
  double? min;
  double? max;

  void add(PidValue v) {
    value = v;
    final x = v.value;
    if (x == null) return;
    history.add(x);
    if (history.length > 240) history.removeAt(0);
    min = min == null || x < min! ? x : min;
    max = max == null || x > max! ? x : max;
  }
}

class LiveState {
  const LiveState({this.selected = const [], this.traces = const {}, this.running = false, this.error, this.updatesPerSecond = 0});
  final List<int> selected;
  final Map<String, SensorTrace> traces;
  final bool running;
  final String? error;
  final double updatesPerSecond;
}

class LiveController extends Notifier<LiveState> {
  Timer? _timer;
  bool _polling = false;
  final _stamps = <DateTime>[];

  @override
  LiveState build() {
    ref.onDispose(() => _timer?.cancel());
    ref.listen(connectionProvider.select((c) => c.session), (a, b) {
      if (a != b) stop(clear: true);
    });
    return const LiveState(selected: [0x0C, 0x0D, 0x05, 0x04, 0x11, 0x42]);
  }

  void toggle(int pid) {
    final s = [...state.selected];
    s.contains(pid) ? s.remove(pid) : s.add(pid);
    state = LiveState(selected: s, traces: state.traces, running: state.running, updatesPerSecond: state.updatesPerSecond);
  }

  void start() {
    _timer?.cancel();
    final ms = ref.read(settingsProvider).refreshMs;
    state = LiveState(selected: state.selected, traces: state.traces, running: true);
    _timer = Timer.periodic(Duration(milliseconds: ms), (_) => _poll());
    _poll();
  }

  void stop({bool clear = false}) {
    _timer?.cancel();
    _timer = null;
    state = LiveState(selected: state.selected, traces: clear ? const {} : state.traces, running: false);
  }

  Future<void> _poll() async {
    if (_polling) return; // a slow link skips ticks instead of queueing them
    final s = ref.read(connectionProvider).session;
    if (s == null) return stop();
    _polling = true;
    try {
      final values = await s.readPids(state.selected);
      final traces = Map<String, SensorTrace>.from(state.traces);
      for (final e in values.entries) {
        for (final v in e.value) {
          (traces[v.key] ??= SensorTrace(e.key, v)).add(v);
        }
      }
      final now = DateTime.now();
      _stamps.add(now);
      _stamps.removeWhere((t) => now.difference(t) > const Duration(seconds: 5));
      state = LiveState(selected: state.selected, traces: traces, running: _timer != null, updatesPerSecond: _stamps.length / 5);
    } catch (e) {
      state = LiveState(selected: state.selected, traces: state.traces, running: _timer != null, error: '$e');
    } finally {
      _polling = false;
    }
  }
}

final liveProvider = NotifierProvider<LiveController, LiveState>(LiveController.new);
