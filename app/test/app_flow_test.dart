import 'dart:io';

import 'package:diag_store/diag_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obd_diag_app/main.dart';
import 'package:obd_diag_app/state/settings.dart';
import 'package:obd_diag_app/state/storage.dart';

/// Loads real fonts so optional screenshots are readable.
Future<void> _loadFonts() async {
  final dir = Platform.environment['FLUTTER_ROOT'] ?? '/opt/sdk/flutter';
  final base = '$dir/bin/cache/artifacts/material_fonts';
  Future<void> load(String family, List<String> files) async {
    final l = FontLoader(family);
    for (final f in files) {
      final file = File('$base/$f');
      if (file.existsSync()) {
        l.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
      }
    }
    await l.load();
  }

  await load('Roboto', [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]);
  await load('MaterialIcons', ['MaterialIcons-Regular.otf']);
}

class _DevSettings extends SettingsNotifier {
  @override
  AppSettings build() => const AppSettings(developerMode: true);
}

Future<void> _settle(WidgetTester t, [int ms = 3000]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await t.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _shot(WidgetTester t, String name) async {
  if (Platform.environment['SCREENSHOTS'] != '1') return;
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('screenshots/$name.png'),
  );
}

void main() {
  setUpAll(_loadFonts);

  Future<void> pumpApp(WidgetTester t, Size size) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(_DevSettings.new),
          databaseProvider.overrideWith((ref) async {
            final db = DiagDatabase.memory();
            ref.onDispose(db.close);
            return db;
          }),
        ],
        child: const DiagnosticsApp(),
      ),
    );
    await t.pump();
  }

  testWidgets('desktop: connect simulator, quick scan, codes, live data', (
    t,
  ) async {
    await pumpApp(t, const Size(1400, 900));
    expect(find.text('No vehicle connected'), findsOneWidget);
    await _shot(t, 'desktop_dashboard_disconnected');

    await t.tap(find.text('Connect Vehicle').first);
    await t.pump();
    // Choose the lean scenario.
    await t.tap(find.byType(DropdownButtonFormField<String>));
    await t.pump();
    await t.tap(find.text('Lean bank 1 (P0171), CAN 11-bit').last);
    await t.pump();
    await t.tap(find.text('Start simulator'));
    await _settle(t, 6000);
    expect(find.textContaining('SIMULATED DATA'), findsOneWidget);
    expect(find.text('Simulator connected'), findsOneWidget);
    await _shot(t, 'desktop_connect');

    await t.tap(find.text('Full Diagnostic Scan').first);
    await t.pump();
    await t.tap(find.text('Start scan'));
    await _settle(t, 8000);
    expect(find.text('P0171'), findsWidgets);
    expect(find.text('Check engine light ON'), findsOneWidget);
    // The built-in description pack loads from the app's assets.
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await _settle(t, 200);
    expect(find.textContaining('Fuel mixture too lean (bank 1)'), findsWidgets);
    await _shot(t, 'desktop_full_scan');
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await _settle(t, 200);
    await t.scrollUntilVisible(
      find.text('Saved to history as a simulated scan.'),
      400,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Saved to history as a simulated scan.'), findsOneWidget);

    await t.tap(find.text('Vehicle History').first);
    await _settle(t, 200);
    await t.tap(find.text('Simulated scans'));
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await _settle(t, 200);
    expect(find.textContaining('Full scan · SIMULATED'), findsOneWidget);
    await _shot(t, 'desktop_history');

    await t.tap(find.text('Live Data').first);
    await t.pump();
    await t.tap(find.text('Start'));
    await _settle(t, 3000);
    expect(find.text('Engine speed'), findsWidgets);
    await _shot(t, 'desktop_live');
    await t.tap(find.text('Pause'));
    await t.pump();

    await t.tap(find.text('Adapter Manager').first);
    await _settle(t, 200);
    expect(find.text('ELM327 v2.3'), findsWidgets);
    await _shot(t, 'desktop_adapter');

    await t.tap(find.text('Fault Codes').first);
    await t.pump();
    await t.tap(find.text('Clear codes...'));
    await t.pump();
    expect(find.text('Clear diagnostic trouble codes?'), findsOneWidget);
    // Button disabled until the user ticks the acknowledgement.
    final btn = t.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Clear codes'),
    );
    expect(btn.onPressed, isNull);
    await _shot(t, 'desktop_clear_confirm');
    await t.tap(find.text('Cancel'));
    await _settle(t, 200);

    // Code library search and detail view.
    await t.scrollUntilVisible(
      find.byKey(const Key('dtc-search')),
      400,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await t.enterText(find.byKey(const Key('dtc-search')), 'P0302');
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await _settle(t, 200);
    expect(find.text('Misfire detected in cylinder 2'), findsOneWidget);
    await t.tap(find.text('Misfire detected in cylinder 2'));
    await _settle(t, 300);
    expect(find.text('Possible causes (most common first)'), findsOneWidget);
    expect(find.textContaining('Generic interpretation'), findsOneWidget);
    await _shot(t, 'desktop_code_details');
    await t.tap(find.text('Close'));
    await _settle(t, 200);
    await t.enterText(find.byKey(const Key('dtc-search')), 'P1234');
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await _settle(t, 200);
    expect(find.textContaining('P1234 is not in the library'), findsOneWidget);
    // Dispose the app so database stream timers are cancelled.
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
  });

  testWidgets('phone layout uses a drawer', (t) async {
    await pumpApp(t, const Size(400, 860));
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byTooltip('Open navigation menu'), findsOneWidget);
    await _shot(t, 'phone_dashboard');
    await t.tap(find.byTooltip('Open navigation menu'));
    await _settle(t, 500);
    expect(find.text('Adapter Manager'), findsOneWidget);
    await _shot(t, 'phone_drawer');
  });
}
