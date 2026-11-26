import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obd_transport/obd_transport.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UnitSystem { metric, imperial }

class AppSettings {
  const AppSettings({
    this.units = UnitSystem.metric,
    this.developerMode = false,
    this.refreshMs = 500,
    this.wifiHost = '192.168.0.10',
    this.wifiPort = 35000,
    this.lastAdapter,
    this.autoConnect = true,
  });

  final UnitSystem units;

  /// Unlocks the simulator. Simulated data is always labelled in the UI.
  final bool developerMode;

  /// Live data refresh interval.
  final int refreshMs;
  final String wifiHost;
  final int wifiPort;

  /// The last adapter that connected successfully (never the simulator).
  final TransportEndpoint? lastAdapter;

  /// Connect to [lastAdapter] when the app starts.
  final bool autoConnect;

  AppSettings copyWith(
          {UnitSystem? units,
          bool? developerMode,
          int? refreshMs,
          String? wifiHost,
          int? wifiPort,
          TransportEndpoint? lastAdapter,
          bool clearLastAdapter = false,
          bool? autoConnect}) =>
      AppSettings(
        lastAdapter: clearLastAdapter ? null : (lastAdapter ?? this.lastAdapter),
        autoConnect: autoConnect ?? this.autoConnect,
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
      lastAdapter: _decodeEndpoint(p.getStringList('lastAdapter')),
      autoConnect: p.getBool('autoConnect') ?? true,
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
    p.setBool('autoConnect', s.autoConnect);
    final a = s.lastAdapter;
    if (a == null) {
      p.remove('lastAdapter');
    } else {
      p.setStringList('lastAdapter', [a.kind.name, a.address, a.name, '${a.port ?? ''}', '${a.baudRate ?? ''}']);
    }
  }
}

TransportEndpoint? _decodeEndpoint(List<String>? v) {
  if (v == null || v.length != 5) return null;
  final kind = TransportKind.values.where((k) => k.name == v[0]).firstOrNull;
  if (kind == null || kind == TransportKind.simulator) return null;
  return TransportEndpoint(kind: kind, address: v[1], name: v[2], port: int.tryParse(v[3]), baudRate: int.tryParse(v[4]));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
