import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obd_engine/obd_engine.dart';

import '../state/connection.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class AdapterScreen extends ConsumerWidget {
  const AdapterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(connectionProvider);
    final a = conn.adapter;
    if (a == null) {
      return SectionPage(title: 'Adapter Manager', children: [NotConnectedCard(onConnect: () => context.go('/connect'))]);
    }
    final q = conn.quality;
    return SectionPage(
      title: 'Adapter Manager',
      simulated: conn.simulated,
      actions: [
        OutlinedButton.icon(
          onPressed: conn.busy || !conn.isReady ? null : () => ref.read(connectionProvider.notifier).retestQuality(),
          icon: const Icon(Icons.network_check),
          label: const Text('Test link'),
        ),
      ],
      children: [
        InfoCard(
          title: 'Adapter',
          icon: Icons.settings_input_component,
          child: KeyValueList([
            ('Connection type', conn.endpoint?.kind.name ?? '-'),
            ('Address', conn.endpoint?.address ?? '-'),
            ('Manufacturer', a.manufacturer),
            ('Model', a.model),
            ('Firmware (reported)', a.identity),
            if (a.stnIdentity != null) ('STN firmware', a.stnIdentity!),
            ('Chip family', switch (a.chip) { ChipFamily.elm327 => 'ELM327 command set', ChipFamily.stn => 'STN (ELM327-compatible plus ST commands)', ChipFamily.unknown => 'Unknown' }),
            ('Clone check', a.likelyClone ? 'Likely a clone: it fails commands a genuine chip of this version supports' : 'No signs of a clone'),
            if (a.voltage != null) ('Voltage at OBD port', '${a.voltage!.toStringAsFixed(1)} V'),
            if (conn.isReady) ('Vehicle protocol', conn.session!.protocol.label),
          ]),
        ),
        if (q != null)
          InfoCard(
            title: 'Link quality',
            icon: Icons.network_check,
            trailing: StatusPill('${q.score}/100', q.score >= 80 ? StatusLevel.ok : (q.score >= 50 ? StatusLevel.warning : StatusLevel.critical)),
            child: KeyValueList([
              ('Answered', '${q.answered} of ${q.sent} test requests'),
              ('Average reply time', '${q.average.inMilliseconds} ms'),
              ('Slowest reply', '${q.worst.inMilliseconds} ms'),
            ]),
          ),
        InfoCard(
          title: 'Supported features',
          icon: Icons.checklist,
          child: Column(children: [
            for (final c in AdapterCapability.values)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(a.supports(c) ? Icons.check_circle : Icons.cancel_outlined,
                    color: a.supports(c) ? AppColors.ok : AppColors.textSecondary),
                title: Text(c.description),
                subtitle: Text('Tested with ${c.probe}'),
              ),
          ]),
        ),
        if (a.limitations.isNotEmpty)
          InfoCard(
            title: 'What this adapter cannot do',
            icon: Icons.warning_amber,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final l in a.limitations) Text(l, style: const TextStyle(color: AppColors.warning)),
              if (!a.supportsEnhanced) ...[
                const SizedBox(height: 8),
                const Text('Enhanced (manufacturer-specific) diagnostics need custom headers and receive filters, so they will not work with this adapter. '
                    'Standard OBD2 functions still work.'),
              ],
            ]),
          ),
        if (conn.session != null)
          InfoCard(
            title: 'Communication log',
            icon: Icons.receipt_long,
            trailing: TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: conn.session!.log.export()));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log copied to the clipboard.')));
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy log'),
            ),
            child: SizedBox(
              height: 220,
              child: ListView(children: [
                for (final e in conn.session!.log.entries.reversed.take(200))
                  Text(e.toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ),
          ),
      ],
    );
  }
}
