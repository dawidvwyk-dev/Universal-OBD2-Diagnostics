import 'package:material_ui/material_ui.dart';

import '../widgets/common.dart';

class AdvancedScreen extends StatelessWidget {
  const AdvancedScreen({super.key});
  @override
  Widget build(BuildContext context) => const SectionPage(title: 'Advanced Diagnostics', children: [
        PlannedFeatureCard(phase: 'Phase 4', items: [
          'Mode 06 on-board monitor test results',
          'Oxygen sensor tests (Mode 05) and fuel trim analysis',
          'ECU communication tests per module',
          'Enhanced manufacturer-specific diagnostics (UDS) for ABS, SRS and transmission, where a manufacturer profile exists',
        ]),
      ]);
}

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});
  @override
  Widget build(BuildContext context) => const SectionPage(title: 'Vehicle Health', children: [
        PlannedFeatureCard(phase: 'Phase 5', items: [
          'Fault correlation and sensor range checks, each showing the readings it used',
          'Severity: critical, high, medium, low, informational',
          'Guidance on whether the vehicle can be driven to a repair facility',
          'Overall health assessment, labelled as a suggestion and not a confirmed fault',
        ]),
      ]);
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => const SectionPage(title: 'Diagnostic Reports', children: [
        PlannedFeatureCard(phase: 'Phase 6', items: [
          'Professional PDF health reports',
          'Save, print and share',
          'Export to PDF, CSV and JSON',
          'Compare reports between scans',
        ]),
      ]);
}
