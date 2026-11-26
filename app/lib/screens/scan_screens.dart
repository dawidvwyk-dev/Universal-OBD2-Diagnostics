import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obd_decoders/obd_decoders.dart';

import '../state/connection.dart';
import '../state/storage.dart';
import '../state/scan.dart';
import '../state/settings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/dtc_details.dart';
import '../widgets/value_format.dart';

class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key, required this.full});
  final bool full;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(connectionProvider);
    final scan = ref.watch(scanProvider);
    final result = scan.result;
    final title = full ? 'Full Diagnostic Scan' : 'Quick Scan';
    if (!conn.isReady) {
      return SectionPage(title: title, children: [NotConnectedCard(onConnect: () => context.go('/connect'))]);
    }
    return SectionPage(
      title: title,
      simulated: conn.simulated,
      actions: [
        FilledButton.icon(
          onPressed: scan.running ? null : () => ref.read(scanProvider.notifier).run(full: full),
          icon: const Icon(Icons.play_arrow),
          label: Text(result == null ? 'Start scan' : 'Scan again'),
        ),
      ],
      children: [
        InfoCard(
          title: full ? 'What a full scan reads' : 'What a quick scan reads',
          icon: Icons.info_outline,
          child: Text(
            full
                ? 'Identification, battery voltage, readiness monitors, stored, pending and permanent codes from every module that answers, '
                    'the freeze frame, and one reading of every sensor the vehicle supports. Read-only: nothing on the vehicle is changed.'
                : 'Identification, battery voltage, readiness monitors and stored, pending and permanent codes. Read-only: nothing on the vehicle is changed.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        if (scan.running)
          InfoCard(
            title: scan.step ?? 'Scanning',
            icon: Icons.hourglass_top,
            child: LinearProgressIndicator(value: scan.progress),
          ),
        if (result != null && result.full == full) ScanResultView(result),
        if (result != null && scan.savedId != null)
          Text(result.simulated ? 'Saved to history as a simulated scan.' : 'Saved to vehicle history.',
              style: const TextStyle(color: AppColors.textSecondary)),
        if (scan.saveError != null) Text(scan.saveError!, style: const TextStyle(color: AppColors.warning)),
        if (result != null && result.full != full)
          Text('The last scan was a ${result.full ? 'full' : 'quick'} scan. Its results are shown on the Fault Codes page.',
              style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

class ScanResultView extends ConsumerWidget {
  const ScanResultView(this.r, {super.key});
  final ScanResult r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(settingsProvider).units;
    final rd = r.readiness;
    final codes = r.totalCodes;
    final volt = r.voltage;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      InfoCard(
        title: 'Summary',
        icon: Icons.fact_check_outlined,
        trailing: Text(_time(r.time), style: const TextStyle(color: AppColors.textSecondary)),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          StatusPill(codes == 0 ? 'No fault codes' : '$codes fault code${codes == 1 ? '' : 's'}', codes == 0 ? StatusLevel.ok : StatusLevel.critical),
          if (rd != null) StatusPill(rd.milOn ? 'Check engine light ON' : 'Check engine light off', rd.milOn ? StatusLevel.critical : StatusLevel.ok),
          if (rd != null)
            StatusPill(rd.allComplete ? 'All monitors complete' : '${rd.incomplete.length} monitor${rd.incomplete.length == 1 ? '' : 's'} incomplete',
                rd.allComplete ? StatusLevel.ok : StatusLevel.warning),
          if (volt != null) StatusPill('Battery ${volt.toStringAsFixed(1)} V', volt < 12.2 ? StatusLevel.warning : StatusLevel.ok),
        ]),
      ),
      const SizedBox(height: 12),
      if (r.errors.isNotEmpty) ...[
        InfoCard(
          title: 'Steps that could not be completed',
          icon: Icons.error_outline,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final e in r.errors) Text(e, style: const TextStyle(color: AppColors.warning)),
          ]),
        ),
        const SizedBox(height: 12),
      ],
      DtcListCard(title: 'Stored codes (Mode 03)', status: DtcStatus.stored, codes: r.stored?.all),
      const SizedBox(height: 12),
      DtcListCard(title: 'Pending codes (Mode 07)', status: DtcStatus.pending, codes: r.pending?.all),
      const SizedBox(height: 12),
      DtcListCard(title: 'Permanent codes (Mode 0A)', status: DtcStatus.permanent, codes: r.permanent?.all),
      if (rd != null) ...[
        const SizedBox(height: 12),
        ReadinessCard(rd),
      ],
      if (r.full) ...[
        const SizedBox(height: 12),
        InfoCard(
          title: r.freezeDtc == null ? 'Freeze frame: none stored' : 'Freeze frame for ${r.freezeDtc}',
          icon: Icons.ac_unit,
          child: r.freezeFrame.isEmpty
              ? const Text('The vehicle has no freeze frame stored.', style: TextStyle(color: AppColors.textSecondary))
              : KeyValueList([
                  for (final vs in r.freezeFrame.values)
                    for (final v in vs) (v.name, '${formatValue(v, units).$1} ${formatValue(v, units).$2}'.trim()),
                ]),
        ),
        if (r.snapshot.isNotEmpty) ...[
          const SizedBox(height: 12),
          InfoCard(
            title: 'Sensor snapshot (${r.snapshot.length} supported sensors)',
            icon: Icons.sensors,
            child: KeyValueList([
              for (final vs in r.snapshot.values)
                for (final v in vs) (v.name, '${formatValue(v, units).$1} ${formatValue(v, units).$2}'.trim()),
            ]),
          ),
        ],
      ],
    ]);
  }

  static String _time(DateTime t) =>
      '${t.year}-${_two(t.month)}-${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}';
  static String _two(int v) => v.toString().padLeft(2, '0');
}

class DtcListCard extends StatelessWidget {
  const DtcListCard({super.key, required this.title, required this.status, required this.codes});
  final String title;
  final DtcStatus status;
  final List<Dtc>? codes;

  @override
  Widget build(BuildContext context) {
    final list = codes;
    return InfoCard(
      title: title,
      icon: Icons.report_problem_outlined,
      child: list == null
          ? const Text('Could not be read.', style: TextStyle(color: AppColors.warning))
          : list.isEmpty
              ? const Text('None.', style: TextStyle(color: AppColors.ok))
              : Column(children: [for (final d in list) DtcTile(d, status)]),
    );
  }
}

class DtcTile extends ConsumerWidget {
  const DtcTile(this.dtc, this.status, {super.key});
  final Dtc dtc;
  final DtcStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final make = ref.watch(connectionProvider).identity?.manufacturer;
    final def = ref.watch(dtcDefinitionProvider((dtc.code, make))).value;
    final system = switch (dtc.system) {
      DtcSystem.powertrain => 'Powertrain',
      DtcSystem.chassis => 'Chassis',
      DtcSystem.body => 'Body',
      DtcSystem.network => 'Network / communication',
    };
    final origin = dtc.origin == DtcOrigin.generic ? 'Generic (SAE) code number' : 'Manufacturer-specific code number';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: def == null ? null : () => showDtcDetails(context, def),
      trailing: def == null ? null : SeverityPill(def.severity),
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.critical.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.critical.withValues(alpha: 0.5)),
        ),
        child: Text(dtc.code, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700)),
      ),
      title: def == null
          ? const Text('Unknown code: no installed fault-code database defines it',
              style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic))
          : Text(def.description),
      subtitle: Text([
        system,
        origin,
        status.name,
        if (def != null) def.confidence == 'verified' ? 'verified ${def.manufacturer ?? ''} definition'.replaceAll('  ', ' ') : 'generic interpretation',
      ].join(' · ')),
    );
  }
}

class ReadinessCard extends StatelessWidget {
  const ReadinessCard(this.r, {super.key});
  final ReadinessStatus r;

  @override
  Widget build(BuildContext context) => InfoCard(
        title: 'Readiness monitors (${r.compressionIgnition ? 'diesel' : 'petrol'} layout)',
        icon: Icons.checklist,
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          for (final m in r.supported)
            StatusPill('${m.name}: ${m.state == MonitorState.complete ? 'complete' : 'incomplete'}',
                m.state == MonitorState.complete ? StatusLevel.ok : StatusLevel.warning),
        ]),
      );
}
