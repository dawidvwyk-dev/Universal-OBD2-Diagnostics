import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'screens/adapter_screen.dart';
import 'screens/codes_screen.dart';
import 'screens/connect_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/live_data_screen.dart';
import 'screens/planned_screens.dart';
import 'screens/scan_screens.dart';
import 'screens/settings_screen.dart';
import 'screens/vehicle_screen.dart';
import 'shell/app_shell.dart';

GoRouter buildRouter() => GoRouter(
      initialLocation: '/dashboard',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(location: state.uri.path, child: child),
          routes: [
            _r('/dashboard', const DashboardScreen()),
            _r('/connect', const ConnectScreen()),
            _r('/vehicle', const VehicleScreen()),
            _r('/quick-scan', const ScanScreen(full: false)),
            _r('/full-scan', const ScanScreen(full: true)),
            _r('/codes', const CodesScreen()),
            _r('/live', const LiveDataScreen()),
            _r('/advanced', const AdvancedScreen()),
            _r('/health', const HealthScreen()),
            _r('/reports', const ReportsScreen()),
            _r('/history', const HistoryScreen()),
            _r('/adapter', const AdapterScreen()),
            _r('/settings', const SettingsScreen()),
          ],
        ),
      ],
    );

GoRoute _r(String path, Widget screen) =>
    GoRoute(path: path, pageBuilder: (context, state) => NoTransitionPage(child: screen));
