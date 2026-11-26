import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obd_engine/obd_engine.dart';

import '../state/connection.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'sections.dart';

/// Adaptive navigation: a rail on desktop/tablet, a drawer on phones.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});
  final String location;
  final Widget child;

  int get _index {
    final i = sections.indexWhere((s) => location.startsWith(s.path));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final conn = ref.watch(connectionProvider);
    final status = _ConnectionBadge(conn);
    void go(int i) => context.go(sections[i].path);

    if (width < 720) {
      return Scaffold(
        appBar: AppBar(title: Text(sections[_index].label), actions: [status, const SizedBox(width: 12)]),
        drawer: Drawer(
          backgroundColor: AppColors.surface,
          child: SafeArea(
            child: ListView(children: [
              const _Brand(),
              for (var i = 0; i < sections.length; i++)
                ListTile(
                  leading: Icon(sections[i].icon, color: i == _index ? AppColors.accent : AppColors.textSecondary),
                  title: Text(sections[i].label),
                  selected: i == _index,
                  onTap: () {
                    Navigator.of(context).pop();
                    go(i);
                  },
                ),
            ]),
          ),
        ),
        body: child,
      );
    }
    final extended = width >= 1100;
    return Scaffold(
      body: Row(children: [
        NavigationRail(
          extended: extended,
          minExtendedWidth: 230,
          leading: extended ? const _Brand() : const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.car_repair, color: AppColors.accent)),
          selectedIndex: _index,
          onDestinationSelected: go,
          labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.none,
          destinations: [
            for (final s in sections) NavigationRailDestination(icon: Icon(s.icon), label: Text(s.label)),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(children: [
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerRight,
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.outline))),
              child: status,
            ),
            Expanded(child: child),
          ]),
        ),
      ]),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Row(children: [
          Icon(Icons.car_repair, color: AppColors.accent),
          SizedBox(width: 10),
          Text('OBD2 Diagnostics', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
      );
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge(this.c);
  final ConnectionInfo c;
  @override
  Widget build(BuildContext context) {
    final (label, level) = switch (c.state) {
      SessionState.ready => (c.simulated ? 'Simulator connected' : 'Vehicle connected', c.simulated ? StatusLevel.info : StatusLevel.ok),
      SessionState.connectingAdapter => ('Connecting adapter', StatusLevel.warning),
      SessionState.detectingProtocol => ('Detecting protocol', StatusLevel.warning),
      SessionState.reconnecting => ('Reconnecting', StatusLevel.warning),
      SessionState.failed => ('Connection failed', StatusLevel.critical),
      _ => ('Not connected', StatusLevel.idle),
    };
    return StatusPill(label, level);
  }
}
