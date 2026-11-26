import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router.dart';
import 'state/connection.dart';
import 'state/settings.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    prefs = null; // settings fall back to defaults
  }
  runApp(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: const DiagnosticsApp(),
  ));
}

class DiagnosticsApp extends ConsumerStatefulWidget {
  const DiagnosticsApp({super.key});
  @override
  ConsumerState<DiagnosticsApp> createState() => _DiagnosticsAppState();
}

class _DiagnosticsAppState extends ConsumerState<DiagnosticsApp> {
  final _router = buildRouter();

  @override
  void initState() {
    super.initState();
    // Reconnect to the last adapter that worked, when the user allows it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(settingsProvider);
      if (s.autoConnect && s.lastAdapter != null) ref.read(connectionProvider.notifier).connectLast();
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Rogue OBD2 Diagnostic Tool',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        darkTheme: buildTheme(),
        themeMode: ThemeMode.dark,
        routerConfig: _router,
      );
}
