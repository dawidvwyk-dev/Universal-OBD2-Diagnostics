import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router.dart';
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

class DiagnosticsApp extends StatefulWidget {
  const DiagnosticsApp({super.key});
  @override
  State<DiagnosticsApp> createState() => _DiagnosticsAppState();
}

class _DiagnosticsAppState extends State<DiagnosticsApp> {
  final _router = buildRouter();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'OBD2 Diagnostics',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        darkTheme: buildTheme(),
        themeMode: ThemeMode.dark,
        routerConfig: _router,
      );
}
