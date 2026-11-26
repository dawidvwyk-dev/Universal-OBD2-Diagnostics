import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obd_engine/obd_engine.dart';
import 'package:obd_protocols/obd_protocols.dart';
import 'package:obd_sim/obd_sim.dart';
import 'package:obd_transport/obd_transport.dart';

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

  Future<void> connectWifi(String host, int port, {ObdProtocol protocol = ObdProtocol.auto}) =>
      _connect(
        TcpTransport(TransportEndpoint(kind: TransportKind.wifi, address: host, port: port, name: 'Wi-Fi adapter')),
        protocol: protocol,
        simulated: false,
      );

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
      state = state.copyWith(quality: quality, identity: identity, busy: false);
      _transportSub = transport.stateChanges.listen((t) {
        if (t == TransportState.failed && !_userClosed) unawaited(_recover());
      });
    } catch (e) {
      state = state.copyWith(state: SessionState.failed, error: _describe(e), busy: false, adapter: session.adapter);
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
        TransportException(:final message) => message,
        ElmTimeoutException() => 'The adapter stopped answering. Check it is powered and in range.',
        LinkClosedException() => 'The connection to the adapter closed.',
        _ => e.toString(),
      };
}

final connectionProvider = NotifierProvider<ConnectionController, ConnectionInfo>(ConnectionController.new);
