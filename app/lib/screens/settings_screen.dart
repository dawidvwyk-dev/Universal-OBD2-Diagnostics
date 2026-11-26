import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../state/settings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    return SectionPage(title: 'Settings', children: [
      InfoCard(
        title: 'Units',
        icon: Icons.straighten,
        child: SegmentedButton<UnitSystem>(
          segments: const [
            ButtonSegment(value: UnitSystem.metric, label: Text('Metric (°C, km/h, kPa)')),
            ButtonSegment(value: UnitSystem.imperial, label: Text('Imperial (°F, mph, psi)')),
          ],
          selected: {s.units},
          onSelectionChanged: (v) => n.update(s.copyWith(units: v.first)),
        ),
      ),
      InfoCard(
        title: 'Live data refresh interval: ${s.refreshMs} ms',
        icon: Icons.timer_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Slider(
            value: s.refreshMs.toDouble(),
            min: 100,
            max: 2000,
            divisions: 19,
            label: '${s.refreshMs} ms',
            onChanged: (v) => n.update(s.copyWith(refreshMs: v.round())),
          ),
          const Text('Faster refresh needs a fast adapter. Bluetooth adapters typically manage a few readings per second in total.',
              style: TextStyle(color: AppColors.textSecondary)),
        ]),
      ),
      InfoCard(
        title: 'Diagnostic safety',
        icon: Icons.shield_outlined,
        child: const Text('The app runs in read-only mode. Clearing codes and any other action that changes the vehicle asks for '
            'explicit confirmation every time, and is never run automatically.', style: TextStyle(color: AppColors.textSecondary)),
      ),
      InfoCard(
        title: 'Developer mode',
        icon: Icons.science_outlined,
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: s.developerMode,
          onChanged: (v) => n.update(s.copyWith(developerMode: v)),
          title: const Text('Enable the test simulator'),
          subtitle: const Text('Adds a simulated adapter and vehicle on the Connect page. Simulated data is always labelled.'),
        ),
      ),
    ]);
  }
}
