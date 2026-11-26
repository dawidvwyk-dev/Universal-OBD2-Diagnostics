import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UnitSystem { metric, imperial }

class AppSettings {
  const AppSettings({
    this.units = UnitSystem.metric,
    this.developerMode = false,
    this.refreshMs = 500,
    this.wifiHost = '192.168.0.10',
    this.wifiPort = 35000,
  });

  final UnitSystem units;

  /// Unlocks the simulator. Simulated data is always labelled in the UI.
  final bool developerMode;

  /// Live data refresh interval.
  final int refreshMs;
  final String wifiHost;
  final int wifiPort;

  AppSettings copyWith({UnitSystem? units, bool? developerMode, int? refreshMs, String? wifiHost, int? wifiPort}) =>
      AppSettings(
        units: units ?? this.units,
        developerMode: developerMode ?? this.developerMode,
        refreshMs: refreshMs ?? this.refreshMs,
        wifiHost: wifiHost ?? this.wifiHost,
        wifiPort: wifiPort ?? this.wifiPort,
      );
}

final sharedPrefsProvider = Provider<SharedPreferences?>((ref) => null);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final p = ref.watch(sharedPrefsProvider);
    if (p == null) return const AppSettings();
    return AppSettings(
      units: UnitSystem.values[(p.getInt('units') ?? 0).clamp(0, 1)],
      developerMode: p.getBool('developerMode') ?? false,
      refreshMs: p.getInt('refreshMs') ?? 500,
      wifiHost: p.getString('wifiHost') ?? '192.168.0.10',
      wifiPort: p.getInt('wifiPort') ?? 35000,
    );
  }

  void update(AppSettings s) {
    state = s;
    final p = ref.read(sharedPrefsProvider);
    if (p == null) return;
    p.setInt('units', s.units.index);
    p.setBool('developerMode', s.developerMode);
    p.setInt('refreshMs', s.refreshMs);
    p.setString('wifiHost', s.wifiHost);
    p.setInt('wifiPort', s.wifiPort);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
