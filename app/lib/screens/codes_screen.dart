import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obd_decoders/obd_decoders.dart';
import 'package:obd_engine/obd_engine.dart';

import '../state/connection.dart';
import '../state/scan.dart';
import '../state/storage.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/dtc_details.dart';
import 'scan_screens.dart';

class CodesScreen extends ConsumerWidget {
  const CodesScreen({super.key});

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final conn = ref.read(connectionProvider);
    final s = conn.session;
    if (s == null) return;
    final vin = conn.identity?.vin;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ClearDialog(vin: vin),
    );
    if (confirmed != true) return;
    try {
      final permit = s.gate.authorize(WriteAction.clearDtcs, vin: vin, userConfirmed: true);
      final ok = await s.clearDtcs(permit);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Codes cleared. Permanent codes remain until the vehicle confirms the repair.' : 'The vehicle did not confirm the clear.')));
      await ref.read(scanProvider.notifier).run(full: false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Codes were not cleared: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(connectionProvider);
    final scan = ref.watch(scanProvider);
    if (!conn.isReady) {
      return SectionPage(title: 'Fault Codes', children: [
        NotConnectedCard(onConnect: () => context.go('/connect')),
        const CodeLibrary(),
      ]);
    }
    final r = scan.result;
    return SectionPage(
      title: 'Fault Codes',
      simulated: conn.simulated,
      actions: [
        OutlinedButton.icon(
          onPressed: scan.running ? null : () => ref.read(scanProvider.notifier).run(full: false),
          icon: const Icon(Icons.refresh),
          label: const Text('Read codes'),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: AppColors.critical),
          onPressed: scan.running ? null : () => _clear(context, ref),
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Clear codes...'),
        ),
      ],
      children: [
        if (scan.running) LinearProgressIndicator(value: scan.progress),
        if (r == null && !scan.running)
          const Text('Press Read codes to read stored, pending and permanent codes.', style: TextStyle(color: AppColors.textSecondary)),
        if (r != null) ...[
          DtcListCard(title: 'Stored codes (Mode 03)', status: DtcStatus.stored, codes: r.stored?.all),
          DtcListCard(title: 'Pending codes (Mode 07)', status: DtcStatus.pending, codes: r.pending?.all),
          DtcListCard(title: 'Permanent codes (Mode 0A)', status: DtcStatus.permanent, codes: r.permanent?.all),
        ],
        const CodeLibrary(),
      ],
    );
  }
}

/// The searchable code library, backed by the installed description packs.
class CodeLibrary extends ConsumerWidget {
  const CodeLibrary({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(dtcLibraryProvider);
    if (lib.hasError) {
      return InfoCard(
          title: 'Code library',
          icon: Icons.menu_book_outlined,
          child: Text('The fault-code library could not be loaded: ${lib.error}', style: const TextStyle(color: AppColors.critical)));
    }
    return DtcLibraryCard(count: lib.value, search: (q) => _SearchResults(q));
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults(this.query);
  final String query;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(dtcSearchProvider(query));
    return res.when(
      loading: () => const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
      error: (e, _) => Text('Search failed: $e'),
      data: (rows) => rows.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                  Dtc.isValid(query)
                      ? '${query.toUpperCase()} is not in the library. It may be manufacturer-specific; no meaning is guessed.'
                      : 'No codes match "$query".',
                  style: const TextStyle(color: AppColors.textSecondary)))
          : Column(children: [
              for (final d in rows)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(d.code, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700)),
                  title: Text(d.description),
                  trailing: SeverityPill(d.severity),
                  onTap: () => showDtcDetails(context, d),
                ),
            ]),
    );
  }
}

class _ClearDialog extends StatefulWidget {
  const _ClearDialog({required this.vin});
  final String? vin;
  @override
  State<_ClearDialog> createState() => _ClearDialogState();
}

class _ClearDialogState extends State<_ClearDialog> {
  bool _ack = false;
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Clear diagnostic trouble codes?'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(WriteAction.clearDtcs.warning),
          const SizedBox(height: 8),
          const Text('Clearing codes does not fix the fault. Record the codes first. Switch the engine off with the ignition on.'),
          if (widget.vin != null) ...[const SizedBox(height: 8), Text('Vehicle: ${widget.vin}')],
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _ack,
            onChanged: (v) => setState(() => _ack = v ?? false),
            title: const Text('I understand and want to clear the codes on this vehicle'),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.critical),
            onPressed: _ack ? () => Navigator.pop(context, true) : null,
            child: const Text('Clear codes'),
          ),
        ],
      );
}
