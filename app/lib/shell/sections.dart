import 'package:material_ui/material_ui.dart';

class Section {
  const Section(this.path, this.label, this.icon);
  final String path;
  final String label;
  final IconData icon;
}

const sections = [
  Section('/dashboard', 'Dashboard', Icons.speed),
  Section('/connect', 'Connect Vehicle', Icons.cable),
  Section('/vehicle', 'Vehicle Information', Icons.directions_car),
  Section('/quick-scan', 'Quick Scan', Icons.bolt),
  Section('/full-scan', 'Full Diagnostic Scan', Icons.manage_search),
  Section('/codes', 'Fault Codes', Icons.report_problem_outlined),
  Section('/live', 'Live Data', Icons.show_chart),
  Section('/advanced', 'Advanced Diagnostics', Icons.biotech_outlined),
  Section('/health', 'Vehicle Health', Icons.monitor_heart_outlined),
  Section('/reports', 'Diagnostic Reports', Icons.picture_as_pdf_outlined),
  Section('/history', 'Vehicle History', Icons.history),
  Section('/adapter', 'Adapter Manager', Icons.settings_input_component),
  Section('/settings', 'Settings', Icons.settings_outlined),
];
