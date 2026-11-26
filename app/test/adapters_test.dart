import 'dart:async';

import 'package:diag_store/diag_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obd_diag_app/main.dart';
import 'package:obd_diag_app/state/settings.dart';
import 'package:obd_diag_app/state/storage.dart';
import 'package:obd_diag_app/transport/discovery.dart';
import 'package:obd_sim/obd_sim.dart';
import 'package:obd_transport/obd_transport.dart';

/// Discovery backed by the simulator: a BLE adapter with 20-byte writes and
/// fragmented notifications, a phone that is not an adapter, and a USB cable
/// that only answers at 115200 baud.
class FakeDiscovery implements AdapterDiscovery {
  final links = <SimByteLink>[];
  @override
  List<TransportKind> get kinds => const [TransportKind.bluetoothLe, TransportKind.usbSerial];
  @override
  String help(TransportKind kind) => 'help for ${kind.name}';
  @override
  Future<String?> prepare(TransportKind kind) async => null;

  @override
  Stream<List<DiscoveredAdapter>> discover(TransportKind kind) => switch (kind) {
        TransportKind.bluetoothLe => Stream.fromIterable([
            [
              const DiscoveredAdapter(
                  TransportEndpoint(kind: TransportKind.bluetoothLe, address: 'AA:BB:CC:00:11:22', name: 'OBDII', signalStrength: -60),
                  likelyObd: true),
              const DiscoveredAdapter(TransportEndpoint(kind: TransportKind.bluetoothLe, address: 'DD:EE:FF:00:11:22', name: 'Phone')),
            ],
          ]),
        _ => Stream.value([
            const DiscoveredAdapter(TransportEndpoint(kind: TransportKind.usbSerial, address: 'COM5', name: 'COM5 (USB Serial Port)'),
                detail: 'WCH CH340', likelyObd: true),
          ]),
      };

  @override
  ObdTransport transportFor(TransportEndpoint e) {
    final emu = ElmEmulator(vehicle: Scenarios.healthyCan(), profile: SimAdapterProfile.cloneV21);
    final link = e.kind == TransportKind.bluetoothLe
        ? SimByteLink(emu, maxChunk: 20, replyChunk: 7)
        : SimByteLink(emu, answersAtBaud: 115200, baud: e.baudRate);
    links.add(link);
    return LinkTransport(e, link);
  }
}

class _Settings extends SettingsNotifier {
  @override
  AppSettings build() => const AppSettings();
  @override
  void update(AppSettings s) => state = s;
}

/// Pumps fake time, and lets real microtasks run too: cancelling a stream
/// subscription can complete in the root zone, outside the fake clock.
Future<void> _settle(WidgetTester t, [int ms = 3000]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await t.runAsync(() => Future<void>.delayed(Duration.zero));
    await t.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('find and connect BLE and USB adapters', (t) async {
    t.view.physicalSize = const Size(1400, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final fake = FakeDiscovery();
    await t.pumpWidget(ProviderScope(
      overrides: [
        settingsProvider.overrideWith(_Settings.new),
        adapterDiscoveryProvider.overrideWithValue(fake),
        databaseProvider.overrideWith((ref) async {
          final db = DiagDatabase.memory();
          ref.onDispose(db.close);
          return db;
        }),
      ],
      child: const DiagnosticsApp(),
    ));
    await t.pump();
    await t.tap(find.text('Connect Vehicle').first);
    await _settle(t, 200);

    // Bluetooth LE.
    expect(find.text('help for bluetoothLe'), findsOneWidget);
    await t.ensureVisible(find.byKey(const Key('adapter-search')));
    await t.pump();
    await t.tap(find.byKey(const Key('adapter-search')));
    await _settle(t, 200);
    expect(find.text('OBDII'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('likely OBD adapter'), findsOneWidget);
    await t.ensureVisible(find.widgetWithText(OutlinedButton, 'Connect').first);
    await t.pump();
    await t.tap(find.widgetWithText(OutlinedButton, 'Connect').first);
    await _settle(t, 4000);
    await t.ensureVisible(find.text('Connection status'));
    await t.pump();
    expect(find.text('Connected'), findsWidgets);
    expect(find.textContaining('Bluetooth LE OBDII'), findsWidgets);
    expect(fake.links.single.writeSizes.every((n) => n <= 20), isTrue);
    // Remembered for next time.
    expect(find.text('Last adapter'), findsOneWidget);

    await t.ensureVisible(find.text('Disconnect'));
    await t.pump();
    await t.tap(find.text('Disconnect'));
    await _settle(t, 300);

    // USB with baud rate detection.
    await t.ensureVisible(find.text('USB serial'));
    await t.pump();
    await t.tap(find.text('USB serial'));
    await _settle(t, 100);
    await t.ensureVisible(find.byKey(const Key('adapter-search')));
    await t.pump();
    await t.tap(find.byKey(const Key('adapter-search')));
    await _settle(t, 200);
    expect(find.text('COM5 (USB Serial Port)'), findsOneWidget);
    await t.ensureVisible(find.widgetWithText(OutlinedButton, 'Connect').first);
    await t.pump();
    await t.tap(find.widgetWithText(OutlinedButton, 'Connect').first);
    await _settle(t, 8000);
    await t.ensureVisible(find.text('Connection status'));
    await t.pump();
    expect(find.text('Connected'), findsWidgets);
    expect(find.text('115200 baud'), findsOneWidget);
    // 38400 then 115200 probed, then the session's own transport.
    expect(fake.links.where((l) => l.baud == 38400), isNotEmpty);
    expect(fake.links.last.baud, 115200);

    await t.ensureVisible(find.text('Disconnect'));
    await t.pump();
    await t.tap(find.text('Disconnect'));
    await _settle(t, 300);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
  });
}
