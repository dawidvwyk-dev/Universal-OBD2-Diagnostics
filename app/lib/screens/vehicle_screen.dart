import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obd_decoders/obd_decoders.dart';

import '../state/connection.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class VehicleScreen extends ConsumerWidget {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ref.watch(connectionProvider);
    if (!conn.isReady) {
      return SectionPage(title: 'Vehicle Information', children: [NotConnectedCard(onConnect: () => context.go('/connect'))]);
    }
    final id = conn.identity;
    final s = conn.session!;
    final vin = id?.vin;
    final years = id?.modelYearCandidates ?? const [];
    return SectionPage(
      title: 'Vehicle Information',
      simulated: conn.simulated,
      children: [
        InfoCard(
          title: 'Identification',
          icon: Icons.badge_outlined,
          child: KeyValueList([
            ('VIN', vin ?? 'Not reported by the vehicle (common before 2005 and on some makes)'),
            if (vin != null) ('VIN check digit', isVinCheckDigitValid(vin) ? 'Valid' : 'Does not match (only required in North America)'),
            ('Manufacturer', id?.manufacturer ?? (vin == null ? 'Unknown' : 'Not in the built-in list (WMI ${vin.substring(0, 3)})')),
            if (years.isNotEmpty) ('Model year (from VIN)', years.length == 1 ? '${years.first}' : '${years.join(' or ')} (the VIN code repeats every 30 years)'),
            ('Model and engine', 'Not available over standard OBD2; needs a VIN decoder database (planned)'),
            if (id?.fuelType != null) ('Fuel type', id!.fuelType!),
            if (id?.obdStandard != null) ('OBD standard', id!.obdStandard!),
          ]),
        ),
        InfoCard(
          title: 'Communication',
          icon: Icons.settings_ethernet,
          child: KeyValueList([
            ('Protocol', s.protocol.label),
            ('Control modules answering', s.ecus.join(', ')),
          ]),
        ),
        InfoCard(
          title: 'Control modules',
          icon: Icons.memory,
          child: Column(children: [
            for (final e in s.ecus)
              KeyValueList([
                ('Module $e', id?.ecuNames[e] ?? 'Name not reported'),
                ('Calibration ID', (id?.calibrationIds[e] ?? const ['Not reported']).join(', ')),
                ('Supported sensors', '${s.supportedPids[e]?.where((p) => p % 0x20 != 0).length ?? 0}'),
              ]),
          ]),
        ),
        const Text('Only information the vehicle reports is shown. Nothing is inferred from the make or model.',
            style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}
