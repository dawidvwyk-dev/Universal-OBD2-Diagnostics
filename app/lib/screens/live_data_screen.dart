import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obd_decoders/obd_decoders.dart';

import '../state/connection.dart';
import '../state/live.dart';
import '../state/settings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/gauges.dart';
import '../widgets/value_format.dart';

class LiveDataScreen extends ConsumerStatefulWidget {
  const LiveDataScreen({super.key});
  @override
  ConsumerState<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends ConsumerState<LiveDataScreen> {
  bool _gauges = false;

  @override
  Widget build(BuildContext context) {
    final conn = ref.watch(connectionProvider);
    final live = ref.watch(liveProvider);
    final settings = ref.watch(settingsProvider);
    if (!conn.isReady) {
      return SectionPage(title: 'Live Data', children: [NotConnectedCard(onConnect: () => context.go('/connect'))]);
    }
    final s = conn.session!;
    final available = s.supportedPids.values.expand((e) => e).toSet().where((p) => mode01Pids[p]?.isLiveValue ?? false).toList()..sort();
    final ctl = ref.read(liveProvider.notifier);
    return SectionPage(
      title: 'Live Data',
      simulated: conn.simulated,
      actions: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, icon: Icon(Icons.pin_outlined), label: Text('Digital')),
            ButtonSegment(value: true, icon: Icon(Icons.speed), label: Text('Gauges')),
          ],
          selected: {_gauges},
          onSelectionChanged: (v) => setState(() => _gauges = v.first),
        ),
        const SizedBox(width: 8),
        live.running
            ? FilledButton.icon(onPressed: ctl.stop, icon: const Icon(Icons.pause), label: const Text('Pause'))
            : FilledButton.icon(onPressed: ctl.start, icon: const Icon(Icons.play_arrow), label: const Text('Start')),
      ],
      children: [
        InfoCard(
          title: 'Sensors this vehicle supports (${available.length})',
          icon: Icons.tune,
          trailing: Text(live.running ? '${live.updatesPerSecond.toStringAsFixed(1)} updates/s · every ${settings.refreshMs} ms' : 'Paused',
              style: const TextStyle(color: AppColors.textSecondary)),
          child: Wrap(spacing: 6, runSpacing: 6, children: [
            for (final p in available)
              FilterChip(
                label: Text(mode01Pids[p]!.name),
                selected: live.selected.contains(p),
                onSelected: (_) => ctl.toggle(p),
              ),
          ]),
        ),
        if (live.error != null) Text(live.error!, style: const TextStyle(color: AppColors.critical)),
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth > 1100 ? 4 : (c.maxWidth > 760 ? 3 : (c.maxWidth > 480 ? 2 : 1));
          final w = (c.maxWidth - (cols - 1) * 12) / cols;
          final traces = live.traces.values.where((t) => live.selected.contains(t.pid)).toList();
          if (traces.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Choose sensors above and press Start.', style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return Wrap(spacing: 12, runSpacing: 12, children: [
            for (final t in traces) SizedBox(width: w, child: _SensorTile(t, settings.units, _gauges)),
          ]);
        }),
      ],
    );
  }
}

class _SensorTile extends StatelessWidget {
  const _SensorTile(this.t, this.units, this.gauge);
  final SensorTrace t;
  final UnitSystem units;
  final bool gauge;

  @override
  Widget build(BuildContext context) {
    final (value, unit) = formatValue(t.value, units);
    String fmt(double? x) {
      if (x == null) return '-';
      return formatValue(PidValue(key: '', name: '', value: x, unit: t.value.unit), units).$1;
    }

    final def = mode01Pids[t.pid]!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.value.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          if (gauge && def.min != null && def.max != null && t.value.value != null)
            SizedBox(
              height: 150,
              child: ArcGauge(value: t.value.value, min: def.min!, max: def.max!, label: value, unit: unit),
            )
          else
            Text.rich(TextSpan(children: [
              TextSpan(text: value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              TextSpan(text: ' $unit', style: const TextStyle(color: AppColors.textSecondary)),
            ])),
          const SizedBox(height: 6),
          Sparkline(t.history),
          const SizedBox(height: 4),
          Text('min ${fmt(t.min)} · max ${fmt(t.max)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ]),
      ),
    );
  }
}
