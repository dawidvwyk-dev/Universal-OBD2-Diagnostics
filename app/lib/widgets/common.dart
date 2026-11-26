import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Page scaffold used by every section: title, optional actions, padded body
/// that scrolls, and the simulated-data banner when relevant.
class SectionPage extends StatelessWidget {
  const SectionPage({super.key, required this.title, required this.children, this.actions = const [], this.simulated = false});
  final String title;
  final List<Widget> children;
  final List<Widget> actions;
  final bool simulated;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (simulated) const SimulatedBanner(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Row(children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600))),
                ...actions,
              ]),
              const SizedBox(height: 16),
              for (final c in children) ...[c, const SizedBox(height: 12)],
            ],
          ),
        ),
      ],
    );
  }
}

class SimulatedBanner extends StatelessWidget {
  const SimulatedBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.simulated.withValues(alpha: 0.18),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Row(children: [
          Icon(Icons.science_outlined, color: AppColors.simulated, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text('SIMULATED DATA: connected to the built-in test simulator, not a real vehicle.',
                style: TextStyle(color: AppColors.simulated, fontWeight: FontWeight.w600)),
          ),
        ]),
      );
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.child, this.icon, this.trailing});
  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (icon != null) ...[Icon(icon, size: 20, color: AppColors.accent), const SizedBox(width: 8)],
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
              ?trailing,
            ]),
            const SizedBox(height: 12),
            child,
          ]),
        ),
      );
}

/// Label/value rows.
class KeyValueList extends StatelessWidget {
  const KeyValueList(this.rows, {super.key});
  final List<(String, String)> rows;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (final (k, v) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(width: 180, child: Text(k, style: const TextStyle(color: AppColors.textSecondary))),
                Expanded(child: SelectableText(v)),
              ]),
            ),
        ],
      );
}

enum StatusLevel { ok, warning, critical, info, idle }

Color statusColor(StatusLevel l) => switch (l) {
      StatusLevel.ok => AppColors.ok,
      StatusLevel.warning => AppColors.warning,
      StatusLevel.critical => AppColors.critical,
      StatusLevel.info => AppColors.accent,
      StatusLevel.idle => AppColors.textSecondary,
    };

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, this.level, {super.key});
  final String label;
  final StatusLevel level;
  @override
  Widget build(BuildContext context) {
    final c = statusColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.6)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12)),
      ]),
    );
  }
}

/// Shown instead of vehicle data when no vehicle is connected.
class NotConnectedCard extends StatelessWidget {
  const NotConnectedCard({super.key, required this.onConnect});
  final VoidCallback onConnect;
  @override
  Widget build(BuildContext context) => InfoCard(
        title: 'No vehicle connected',
        icon: Icons.link_off,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Connect an adapter and switch the ignition on to read this information.',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: onConnect, icon: const Icon(Icons.cable), label: const Text('Connect vehicle')),
        ]),
      );
}

/// Honest status for sections scheduled in a later phase.
class PlannedFeatureCard extends StatelessWidget {
  const PlannedFeatureCard({super.key, required this.phase, required this.items});
  final String phase;
  final List<String> items;
  @override
  Widget build(BuildContext context) => InfoCard(
        title: 'Not built yet: scheduled for $phase',
        icon: Icons.construction,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('This section is not available in this build. It will provide:',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          for (final i in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('•  '),
                Expanded(child: Text(i)),
              ]),
            ),
        ]),
      );
}
