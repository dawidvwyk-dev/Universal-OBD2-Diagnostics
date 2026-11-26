import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../state/connection.dart';
import '../state/scan.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(connectionProvider);
    final scan = ref.watch(scanProvider).result;
    final id = conn.identity;
    return SectionPage(
      title: 'Dashboard',
      simulated: conn.simulated,
      children: [
        if (!conn.isReady) NotConnectedCard(onConnect: () => context.go('/connect')),
        if (conn.isReady)
          InfoCard(
            title: 'Vehicle',
            icon: Icons.directions_car,
            child: KeyValueList([
              ('VIN', id?.vin ?? 'Not reported by the vehicle'),
              if (id?.manufacturer != null) ('Manufacturer (from VIN)', id!.manufacturer!),
              ('Protocol', conn.session!.protocol.label),
              ('Adapter', conn.adapter == null ? '-' : '${conn.adapter!.manufacturer}, ${conn.adapter!.model}'),
            ]),
          ),
        if (conn.isReady)
          InfoCard(
            title: 'Last scan',
            icon: Icons.fact_check_outlined,
            child: scan == null
                ? Row(children: [
                    const Expanded(child: Text('No scan yet in this session.', style: TextStyle(color: AppColors.textSecondary))),
                    FilledButton(onPressed: () => context.go('/quick-scan'), child: const Text('Quick scan')),
                  ])
                : Wrap(spacing: 8, runSpacing: 8, children: [
                    StatusPill(scan.totalCodes == 0 ? 'No fault codes' : '${scan.totalCodes} fault codes',
                        scan.totalCodes == 0 ? StatusLevel.ok : StatusLevel.critical),
                    if (scan.readiness != null)
                      StatusPill(scan.readiness!.milOn ? 'Check engine light ON' : 'Check engine light off',
                          scan.readiness!.milOn ? StatusLevel.critical : StatusLevel.ok),
                    if (scan.voltage != null)
                      StatusPill('Battery ${scan.voltage!.toStringAsFixed(1)} V', scan.voltage! < 12.2 ? StatusLevel.warning : StatusLevel.ok),
                  ]),
          ),
        Wrap(spacing: 12, runSpacing: 12, children: [
          for (final (label, icon, path) in [
            ('Quick scan', Icons.bolt, '/quick-scan'),
            ('Fault codes', Icons.report_problem_outlined, '/codes'),
            ('Live data', Icons.show_chart, '/live'),
            ('Adapter', Icons.settings_input_component, '/adapter'),
          ])
            SizedBox(
              width: 200,
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.go(path),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(children: [
                      Icon(icon, color: AppColors.accent),
                      const SizedBox(width: 12),
                      Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                ),
              ),
            ),
        ]),
      ],
    );
  }
}
