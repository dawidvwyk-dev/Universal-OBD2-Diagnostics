import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obd_engine/obd_engine.dart';
import 'package:obd_protocols/obd_protocols.dart';
import 'package:obd_sim/obd_sim.dart';
import 'package:obd_transport/obd_transport.dart';

import '../transport/discovery.dart';
import 'settings.dart';

/// Everything the UI knows about the current adapter and vehicle link.
class ConnectionInfo {
  const ConnectionInfo({
    this.session,
    this.state = SessionState.idle,
    this.endpoint,
    this.adapter,
    this.quality,
    this.identity,
    this.error,
    this.simulated = false,
    this.busy = false,
    this.note,
  });

  final ObdSession? session;
  final SessionState state;
  final TransportEndpoint? endpoint;
  final AdapterInfo? adapter;
  final LinkQuality? quality;
  final VehicleIdentity? identity;
  final String? error;

  /// True when connected to the built-in simulator. Every screen that shows
  /// vehicle data must display the simulated-data banner in this case.
  final bool simulated;
  final bool busy;

  /// Progress text while connecting, such as the baud rate being tried.
  final String? note;

  bool get isReady => session != null && state == SessionState.ready;

  ConnectionInfo copyWith({
    ObdSession? session,
    SessionState? state,
    TransportEndpoint? endpoint,
    AdapterInfo? adapter,
    LinkQuality? quality,
    VehicleIdentity? identity,
    String? error,
    bool clearError = false,
    bool? simulated,
    bool? busy,
    String? note,
    bool clearNote = false,
  }) =>
      ConnectionInfo(
        session: session ?? this.session,
        state: state ?? this.state,
        endpoint: endpoint ?? this.endpoint,
        adapter: adapter ?? this.adapter,
        quality: quality ?? this.quality,
        identity: identity ?? this.identity,
        error: clearError ? null : (error ?? this.error),
        simulated: simulated ?? this.simulated,
        busy: busy ?? this.busy,
        note: clearNote ? null : (note ?? this.note),
      );
}

class ConnectionController extends Notifier<ConnectionInfo> {
  StreamSubscription<SessionState>? _sub;
  StreamSubscription<TransportState>? _transportSub;
  bool _userClosed = false;

  @override
  ConnectionInfo build() {
    ref.onDispose(() {
      _sub?.cancel();
      _transportSub?.cancel();
    });
    return const ConnectionInfo();
  }

  Future<void> connectWifi(String host, int port, {ObdProtocol protocol = ObdProtocol.auto}) => connectEndpoint(
      TransportEndpoint(kind: TransportKind.wifi, address: host, port: port, name: 'Wi-Fi adapter'),
      protocol: protocol);

  /// Connects to a real adapter. Serial endpoints without a baud rate get one
  /// detected first. On success the endpoint is remembered for next time.
  Future<void> connectEndpoint(TransportEndpoint endpoint, {ObdProtocol protocol = ObdProtocol.auto}) async {
    final discovery = ref.read(adapterDiscoveryProvider);
    var ep = endpoint;
    if (ep.kind == TransportKind.usbSerial && ep.baudRate == null) {
      await disconnect();
      state = ConnectionInfo(state: SessionState.connectingAdapter, endpoint: ep, busy: true, note: 'Detecting baud rate...');
      final (baud, attempts) = await detectBaudRate(
          baudOrderFor(product: ep.name), (b) => discovery.transportFor(_withBaud(ep, b)));
      if (baud == null) {
        state = ConnectionInfo(
          state: SessionState.failed,
          endpoint: ep,
          error: 'No OBD adapter answered on ${ep.address}. Tried ${attempts.map((a) => '${a.baud} (${a.detail})').join(', ')}.',
        );
        return;
      }
      ep = _withBaud(ep, baud);
    }
    await _connect(discovery.transportFor(ep), protocol: protocol, simulated: false);
    if (state.isReady) {
      final settings = ref.read(settingsProvider.notifier);
      settings.update(ref.read(settingsProvider).copyWith(lastAdapter: ep));
    }
  }

  /// Connects to the last adapter that worked, if any.
  Future<void> connectLast() async {
    final last = ref.read(settingsProvider).lastAdapter;
    if (last == null || state.session != null || state.busy) return;
    if (last.kind != TransportKind.wifi) {
      final err = await ref.read(adapterDiscoveryProvider).prepare(last.kind);
      if (err != null) {
        state = state.copyWith(error: err);
        return;
      }
    }
    await connectEndpoint(last);
  }

  static TransportEndpoint _withBaud(TransportEndpoint e, int baud) =>
      TransportEndpoint(kind: e.kind, address: e.address, name: e.name, port: e.port, baudRate: baud, signalStrength: e.signalStrength);

  Future<void> connectSimulator(String scenario, SimAdapterProfile profile) {
    final factory = Scenarios.all[scenario] ?? Scenarios.healthyCan;
    final emu = ElmEmulator(vehicle: factory(), profile: profile);
    return _connect(simulatorTransport(emu, latency: const Duration(milliseconds: 15)),
        protocol: ObdProtocol.auto, simulated: true);
  }

  Future<void> _connect(ObdTransport transport, {required ObdProtocol protocol, required bool simulated}) async {
    await disconnect();
    _userClosed = false;
    final session = ObdSession(transport);
    state = ConnectionInfo(
      session: session,
      state: SessionState.connectingAdapter,
      endpoint: transport.endpoint,
      simulated: simulated,
      busy: true,
    );
    _sub = session.states.listen((s) => state = state.copyWith(state: s));
    try {
      await session.connect(protocol: protocol);
      state = state.copyWith(adapter: session.adapter, clearError: true);
      final quality = await measureLinkQuality(session.link, count: 5);
      final identity = await session.readIdentity();
      state = state.copyWith(quality: quality, identity: identity, busy: false, clearNote: true);
      _transportSub = transport.stateChanges.listen((t) {
        if (t == TransportState.failed && !_userClosed) unawaited(_recover());
      });
    } catch (e) {
      try {
        await session.close();
      } catch (_) {}
      state = state.copyWith(
          state: SessionState.failed, error: _describe(e), busy: false, adapter: session.adapter, clearNote: true);
    }
  }

  Future<void> _recover() async {
    final s = state.session;
    if (s == null) return;
    state = state.copyWith(error: 'Connection lost. Reconnecting...');
    final ok = await s.reconnect();
    state = ok
        ? state.copyWith(clearError: true)
        : state.copyWith(error: 'Could not reconnect to the adapter. Check power and range, then connect again.');
  }

  Future<void> disconnect() async {
    _userClosed = true;
    await _sub?.cancel();
    await _transportSub?.cancel();
    _sub = null;
    _transportSub = null;
    final s = state.session;
    if (s != null) {
      try {
        await s.close();
      } catch (_) {}
    }
    state = const ConnectionInfo();
  }

  Future<void> retestQuality() async {
    final s = state.session;
    if (s == null || !state.isReady) return;
    state = state.copyWith(busy: true);
    final q = await measureLinkQuality(s.link, count: 10);
    state = state.copyWith(quality: q, busy: false);
  }

  static String _describe(Object e) => switch (e) {
        ObdException(:final message) => message,
        TransportException(:final message, :final cause) =>
          cause == null ? message : '$message: ${cause.toString().replaceFirst(RegExp(r'^(Bad state|Exception|PlatformException\([^,]*,)\s*:?\s*'), '')}',
        ElmTimeoutException() => 'The adapter stopped answering. Check it is powered and in range.',
        LinkClosedException() => 'The connection to the adapter closed.',
        _ => e.toString(),
      };
}

final connectionProvider = NotifierProvider<ConnectionController, ConnectionInfo>(ConnectionController.new);
