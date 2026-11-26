import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obd_engine/obd_engine.dart';
import 'package:obd_protocols/obd_protocols.dart';
import 'package:obd_sim/obd_sim.dart';

import '../state/connection.dart';
import '../state/settings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});
  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  late final TextEditingController _host;
  late final TextEditingController _port;
  ObdProtocol _protocol = ObdProtocol.auto;
  String _scenario = 'healthy_can';
  SimAdapterProfile _profile = SimAdapterProfile.genuineElm;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _host = TextEditingController(text: s.wifiHost);
    _port = TextEditingController(text: '${s.wifiPort}');
  }

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    super.dispose();
  }

  String? _validateHost(String h) {
    final ip = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$').firstMatch(h.trim());
    if (ip != null) {
      final ok = [1, 2, 3, 4].every((i) => int.parse(ip.group(i)!) <= 255);
      return ok ? null : 'Each part of the IP address must be 0 to 255.';
    }
    return RegExp(r'^[A-Za-z0-9.-]{1,253}$').hasMatch(h.trim()) ? null : 'Enter an IP address or host name.';
  }

  Future<void> _connectWifi() async {
    final hostErr = _validateHost(_host.text);
    final port = int.tryParse(_port.text.trim());
    if (hostErr != null || port == null || port < 1 || port > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hostErr ?? 'Port must be 1 to 65535.')));
      return;
    }
    final settings = ref.read(settingsProvider);
    ref.read(settingsProvider.notifier).update(settings.copyWith(wifiHost: _host.text.trim(), wifiPort: port));
    await ref.read(connectionProvider.notifier).connectWifi(_host.text.trim(), port, protocol: _protocol);
  }

  @override
  Widget build(BuildContext context) {
    final conn = ref.watch(connectionProvider);
    final dev = ref.watch(settingsProvider).developerMode;
    final busy = conn.busy;
    return SectionPage(
      title: 'Connect Vehicle',
      simulated: conn.simulated,
      children: [
        _StatusCard(conn),
        InfoCard(
          title: 'Wi-Fi adapter',
          icon: Icons.wifi,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Join the adapter\'s Wi-Fi network first (often named OBDII, WiFi_OBDII or V-LINK), then connect. '
                'Most adapters use 192.168.0.10 port 35000.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
              SizedBox(width: 220, child: TextField(controller: _host, decoration: const InputDecoration(labelText: 'IP address or host'))),
              SizedBox(width: 120, child: TextField(controller: _port, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Port'))),
              SizedBox(
                width: 320,
                child: DropdownButtonFormField<ObdProtocol>(
                  initialValue: _protocol,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Protocol'),
                  items: [for (final p in ObdProtocol.values) DropdownMenuItem(value: p, child: Text(p.label, overflow: TextOverflow.ellipsis))],
                  onChanged: (p) => setState(() => _protocol = p ?? ObdProtocol.auto),
                ),
              ),
              FilledButton.icon(onPressed: busy ? null : _connectWifi, icon: const Icon(Icons.link), label: const Text('Connect')),
            ]),
          ]),
        ),
        const InfoCard(
          title: 'Bluetooth Classic, Bluetooth LE and USB',
          icon: Icons.bluetooth,
          child: Text('Adapter search and connection over Bluetooth Classic, Bluetooth LE and USB serial are being built in Phase 2 '
              'and are not available in this build.', style: TextStyle(color: AppColors.textSecondary)),
        ),
        if (dev)
          InfoCard(
            title: 'Test simulator (developer mode)',
            icon: Icons.science_outlined,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Connects to a simulated adapter and vehicle. All values are synthetic and are marked as simulated on every screen.',
                  style: TextStyle(color: AppColors.simulated)),
              const SizedBox(height: 12),
              Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
                SizedBox(
                  width: 280,
                  child: DropdownButtonFormField<String>(
                    initialValue: _scenario,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Vehicle scenario'),
                    items: [for (final k in Scenarios.all.keys) DropdownMenuItem(value: k, child: Text(Scenarios.all[k]!().name, overflow: TextOverflow.ellipsis))],
                    onChanged: (v) => setState(() => _scenario = v ?? _scenario),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<SimAdapterProfile>(
                    initialValue: _profile,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Adapter behaviour'),
                    items: [for (final p in SimAdapterProfile.all) DropdownMenuItem(value: p, child: Text(p.id))],
                    onChanged: (v) => setState(() => _profile = v ?? _profile),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : () => ref.read(connectionProvider.notifier).connectSimulator(_scenario, _profile),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start simulator'),
                ),
              ]),
            ]),
          ),
      ],
    );
  }
}

class _StatusCard extends ConsumerWidget {
  const _StatusCard(this.c);
  final ConnectionInfo c;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = c.adapter;
    return InfoCard(
      title: 'Connection status',
      icon: Icons.sensors,
      trailing: c.session != null
          ? TextButton.icon(onPressed: () => ref.read(connectionProvider.notifier).disconnect(), icon: const Icon(Icons.link_off), label: const Text('Disconnect'))
          : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (c.busy) const Padding(padding: EdgeInsets.only(bottom: 12), child: LinearProgressIndicator()),
        if (c.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(c.error!, style: const TextStyle(color: AppColors.critical)),
          ),
        KeyValueList([
          ('Status', switch (c.state) {
            SessionState.idle => 'Not connected',
            SessionState.connectingAdapter => 'Connecting to adapter...',
            SessionState.detectingProtocol => 'Searching for vehicle protocol (up to 15 s)...',
            SessionState.ready => 'Connected',
            SessionState.reconnecting => 'Reconnecting...',
            SessionState.closed => 'Closed',
            SessionState.failed => 'Failed',
          }),
          if (c.endpoint != null) ('Connection', c.endpoint.toString()),
          if (a != null) ('Adapter', '${a.manufacturer}, ${a.model}'),
          if (c.isReady) ('Protocol', c.session!.protocol.label),
          if (c.isReady) ('Control modules', c.session!.ecus.join(', ')),
          if (c.quality != null) ('Link quality', '${c.quality!.score}/100, ${c.quality!.average.inMilliseconds} ms average reply'),
        ]),
        if (c.isReady) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            FilledButton.tonal(onPressed: () => context.go('/quick-scan'), child: const Text('Run quick scan')),
            FilledButton.tonal(onPressed: () => context.go('/live'), child: const Text('Live data')),
          ]),
        ],
      ]),
    );
  }
}
