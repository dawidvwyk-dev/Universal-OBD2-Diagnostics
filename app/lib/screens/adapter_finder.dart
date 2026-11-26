import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obd_transport/obd_transport.dart';

import '../state/connection.dart';
import '../state/settings.dart';
import '../theme/app_theme.dart';
import '../transport/discovery.dart';
import '../widgets/common.dart';

IconData kindIcon(TransportKind k) => switch (k) {
      TransportKind.bluetoothClassic => Icons.bluetooth,
      TransportKind.bluetoothLe => Icons.bluetooth_searching,
      TransportKind.usbSerial => Icons.usb,
      TransportKind.wifi => Icons.wifi,
      TransportKind.simulator => Icons.science_outlined,
    };

/// Remembered adapter with reconnect and the auto-connect switch.
class LastAdapterCard extends ConsumerWidget {
  const LastAdapterCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final conn = ref.watch(connectionProvider);
    final last = s.lastAdapter;
    if (last == null) return const SizedBox.shrink();
    return InfoCard(
      title: 'Last adapter',
      icon: Icons.history_toggle_off,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Icon(kindIcon(last.kind), color: AppColors.accent),
          Text(last.toString()),
          if (last.baudRate != null) Text('${last.baudRate} baud', style: const TextStyle(color: AppColors.textSecondary)),
          FilledButton.tonalIcon(
            onPressed: conn.busy || conn.session != null ? null : () => ref.read(connectionProvider.notifier).connectLast(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reconnect'),
          ),
          TextButton(
            onPressed: () => ref.read(settingsProvider.notifier).update(s.copyWith(clearLastAdapter: true)),
            child: const Text('Forget'),
          ),
        ]),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: s.autoConnect,
          onChanged: (v) => ref.read(settingsProvider.notifier).update(s.copyWith(autoConnect: v)),
          title: const Text('Connect to this adapter when the app starts'),
        ),
      ]),
    );
  }
}

/// Bluetooth Classic, Bluetooth LE and USB/COM adapter search.
class AdapterFinderCard extends ConsumerStatefulWidget {
  const AdapterFinderCard({super.key});
  @override
  ConsumerState<AdapterFinderCard> createState() => _AdapterFinderCardState();
}

class _AdapterFinderCardState extends ConsumerState<AdapterFinderCard> {
  TransportKind? _kind;
  StreamSubscription<List<DiscoveredAdapter>>? _sub;
  List<DiscoveredAdapter> _found = const [];
  bool _searching = false;
  bool _searched = false;
  String? _error;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _search() async {
    final d = ref.read(adapterDiscoveryProvider);
    final kind = _kind!;
    unawaited(_sub?.cancel());
    _sub = null;
    setState(() {
      _searching = true;
      _searched = true;
      _found = const [];
      _error = null;
    });
    final err = await d.prepare(kind);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _error = err;
        _searching = false;
      });
      return;
    }
    _sub = d.discover(kind).listen(
          (l) => setState(() => _found = l),
          onError: (Object e) => setState(() => _error = 'Search failed: $e'),
          onDone: () {
            _sub = null;
            if (mounted) setState(() => _searching = false);
          },
        );
  }

  Future<void> _stop() async {
    final s = _sub;
    _sub = null;
    // Not awaited: a finished scan's cancel future may never complete.
    unawaited(s?.cancel());
    setState(() => _searching = false);
  }

  Future<void> _connect(DiscoveredAdapter a) async {
    await _stop();
    await ref.read(connectionProvider.notifier).connectEndpoint(a.endpoint);
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(adapterDiscoveryProvider);
    final busy = ref.watch(connectionProvider).busy;
    final kinds = d.kinds;
    if (kinds.isEmpty) {
      return const InfoCard(
        title: 'Bluetooth and USB adapters',
        icon: Icons.bluetooth,
        child: Text('Bluetooth and USB adapters are supported in the Windows and Android apps.',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    final kind = _kind ??= kinds.first;
    return InfoCard(
      title: 'Bluetooth and USB adapters',
      icon: kindIcon(kind),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<TransportKind>(
            segments: [for (final k in kinds) ButtonSegment(value: k, label: Text(k.label), icon: Icon(kindIcon(k)))],
            selected: {kind},
            onSelectionChanged: (s) async {
              await _stop();
              setState(() {
                _kind = s.first;
                _found = const [];
                _searched = false;
                _error = null;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(d.help(kind), style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Row(children: [
          FilledButton.icon(
            key: const Key('adapter-search'),
            onPressed: _searching || busy ? null : _search,
            icon: const Icon(Icons.search),
            label: Text(kind == TransportKind.usbSerial ? 'List ports' : 'Search'),
          ),
          if (_searching) ...[
            const SizedBox(width: 12),
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 8),
            TextButton(onPressed: _stop, child: const Text('Stop')),
          ],
        ]),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: AppColors.critical))),
        if (_searched && !_searching && _found.isEmpty && _error == null)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Nothing found. Check the adapter is plugged into the car, the ignition is on, and it is in range.',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        for (final a in _found)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(kindIcon(a.endpoint.kind), color: a.likelyObd ? AppColors.accent : AppColors.textSecondary),
            title: Text(a.endpoint.name),
            subtitle: Text([
              a.endpoint.address,
              if (a.detail != null && a.detail!.isNotEmpty) a.detail!,
              if (a.endpoint.signalStrength != null) '${a.endpoint.signalStrength} dBm',
            ].join(' · ')),
            trailing: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
              if (a.likelyObd) const StatusPill('likely OBD adapter', StatusLevel.info),
              OutlinedButton(onPressed: busy ? null : () => _connect(a), child: const Text('Connect')),
            ]),
          ),
      ]),
    );
  }
}
