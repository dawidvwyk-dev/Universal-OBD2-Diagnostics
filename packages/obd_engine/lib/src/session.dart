/// A diagnostic session with one vehicle through one adapter.
library;

import 'dart:async';

import 'package:obd_decoders/obd_decoders.dart';
import 'package:obd_protocols/obd_protocols.dart';
import 'package:obd_transport/obd_transport.dart';

import 'adapter_probe.dart';
import 'comm_log.dart';
import 'elm_link.dart';
import 'safety.dart';

class ObdException implements Exception {
  ObdException(this.message, {this.elmError});
  final String message;
  final ElmError? elmError;
  @override
  String toString() => message;
}

enum SessionState { idle, connectingAdapter, detectingProtocol, ready, reconnecting, closed, failed }

/// Per-ECU answer to one request.
class EcuReply {
  EcuReply(this.ecu, this.payload);
  final String ecu;

  /// Bytes after the positive-response service byte.
  final List<int> payload;
}

class DtcReport {
  DtcReport(this.status, this.byEcu);
  final DtcStatus status;
  final Map<String, List<Dtc>> byEcu;
  List<Dtc> get all => {for (final l in byEcu.values) ...l}.toList()..sort();
}

class VehicleIdentity {
  VehicleIdentity({this.vin, this.calibrationIds = const {}, this.ecuNames = const {}, required this.ecus, required this.protocol, this.obdStandard, this.fuelType});
  final String? vin;
  final Map<String, List<String>> calibrationIds;
  final Map<String, String> ecuNames;
  final List<String> ecus;
  final ObdProtocol protocol;
  final String? obdStandard;
  final String? fuelType;

  String? get manufacturer => vin == null ? null : manufacturerFromVin(vin!);
  List<int> get modelYearCandidates => vin == null ? const [] : vinModelYearCandidates(vin!);
}

class ObdSession {
  ObdSession(this.transport, {CommLog? log, SafetyGate? gate})
      : log = log ?? CommLog(),
        gate = gate ?? SafetyGate();

  final ObdTransport transport;
  final CommLog log;
  final SafetyGate gate;
  late ElmLink _link;
  ElmLink get link => _link;

  final _state = StreamController<SessionState>.broadcast();
  SessionState _current = SessionState.idle;
  SessionState get state => _current;
  Stream<SessionState> get states => _state.stream;

  AdapterInfo? adapter;
  ObdProtocol protocol = ObdProtocol.auto;
  ObdProtocol _requested = ObdProtocol.auto;

  /// ECU addresses that answered 0100, in reply order.
  List<String> ecus = [];

  /// Mode 01 PIDs supported per ECU.
  Map<String, Set<int>> supportedPids = {};
  String? vin;

  /// Timeout for ordinary requests; the first request (protocol search) uses
  /// a longer one.
  Duration requestTimeout = const Duration(seconds: 2);

  void _set(SessionState s) {
    _current = s;
    _state.add(s);
    log.add(LogDirection.info, 'session: ${s.name}');
  }

  /// Opens the transport, probes the adapter and finds the vehicle protocol.
  /// Pass [protocol] to force a protocol when automatic detection fails.
  Future<void> connect({ObdProtocol protocol = ObdProtocol.auto, AdapterInfo? knownAdapter}) async {
    _requested = protocol;
    _set(SessionState.connectingAdapter);
    try {
      await transport.open();
      _link = ElmLink(transport, log: log);
      adapter = knownAdapter ?? await probeAdapter(_link);
      if (knownAdapter != null) {
        await _link.send('ATZ', timeout: const Duration(seconds: 5));
        for (final c in ['ATE0', 'ATL0', 'ATS0', 'ATH1']) {
          await _link.send(c);
        }
      }
      _set(SessionState.detectingProtocol);
      await _detectProtocol(protocol);
      await _loadSupportedPids();
      _set(SessionState.ready);
    } catch (e) {
      _set(SessionState.failed);
      rethrow;
    }
  }

  Future<void> _detectProtocol(ObdProtocol requested) async {
    await _link.send('ATSP${requested.elmCode}');
    final reply = await _link.send('0100', timeout: const Duration(seconds: 12));
    var parsed = parseElmResponse(reply, ObdProtocol.can11b500);
    // Protocol not yet known: ask the adapter, then parse properly.
    if (adapter!.supports(AdapterCapability.describeProtocol)) {
      final dpn = await _link.send('ATDPN');
      protocol = ObdProtocol.fromDpn(dpn);
    } else {
      protocol = requested == ObdProtocol.auto ? _guessProtocol(reply) : requested;
    }
    parsed = parseElmResponse(reply, protocol);
    if (!parsed.ok) {
      final err = parsed.error;
      throw ObdException(
          err == null ? 'The vehicle did not answer.' : err.message,
          elmError: err);
    }
    ecus = <String>{for (final m in parsed.messages) m.source}.toList();
    log.add(LogDirection.info, 'protocol ${protocol.label}, ECUs ${ecus.join(', ')}');
  }

  /// Fallback when ATDPN is unavailable: infer from header shape.
  ObdProtocol _guessProtocol(String reply) {
    final line = reply.split('\n').map((l) => l.replaceAll(' ', '')).firstWhere(
        (l) => RegExp(r'^[0-9A-F]+$').hasMatch(l), orElse: () => '');
    if (line.startsWith('18DA')) return ObdProtocol.can29b500;
    if (line.startsWith('7E')) return ObdProtocol.can11b500;
    return ObdProtocol.iso9141;
  }

  Future<void> _loadSupportedPids() async {
    supportedPids = {for (final e in ecus) e: <int>{}};
    var base = 0x00;
    while (base <= 0xE0) {
      final replies = await request(ObdRequest(0x01, [base]), allowEmpty: true);
      var more = false;
      for (final r in replies) {
        if (r.payload.length < 5) continue;
        final pids = decodeSupportedBitmap(base, r.payload.sublist(1, 5));
        supportedPids.putIfAbsent(r.ecu, () => <int>{}).addAll(pids);
        if (pids.contains(base + 0x20)) more = true;
      }
      if (!more) break;
      base += 0x20;
    }
  }

  /// Sends a raw OBD request and returns validated per-ECU replies.
  /// Throws [ObdException] on adapter errors, except NO DATA when
  /// [allowEmpty] is true.
  Future<List<EcuReply>> request(ObdRequest req,
      {bool allowEmpty = false, Duration? timeout, WritePermit? permit}) async {
    final svc = ObdService.values.where((s) => s.id == req.service).firstOrNull;
    if (svc != null && !svc.readOnly) {
      gate.redeem(permit, svc == ObdService.clearDtcs ? WriteAction.clearDtcs : WriteAction.controlSystem, vin: vin);
    }
    final reply = await _link.send(req.toHex(), timeout: timeout ?? requestTimeout);
    final parsed = parseElmResponse(reply, protocol);
    if (parsed.error != null) {
      if (parsed.error == ElmError.noData && allowEmpty) return const [];
      throw ObdException(parsed.error!.message, elmError: parsed.error);
    }
    final out = <EcuReply>[];
    for (final m in parsed.messages) {
      final check = checkResponse(req, m);
      switch (check) {
        case PositiveResponse(:final source, :final payload):
          out.add(EcuReply(source, payload));
        case NegativeResponse(:final source, :final description):
          log.add(LogDirection.info, '$source refused ${req.toHex()}: $description');
        case UnrelatedResponse():
          log.add(LogDirection.info, 'ignored unrelated frame ${m.source}: ${hex(m.data)}');
      }
    }
    return out;
  }

  bool isSupported(int pid) => supportedPids.values.any((s) => s.contains(pid));

  /// Reads Mode 01 PIDs. Unsupported PIDs are skipped, never guessed.
  /// On CAN up to 6 PIDs are batched into one request.
  Future<Map<int, List<PidValue>>> readPids(List<int> pids) async {
    final wanted = pids.where(isSupported).toList();
    final result = <int, List<PidValue>>{};
    final batch = protocol.isCan ? 6 : 1;
    for (var i = 0; i < wanted.length; i += batch) {
      final chunk = wanted.sublist(i, i + batch > wanted.length ? wanted.length : i + batch);
      final known = chunk.every((p) => mode01Pids.containsKey(p));
      if (chunk.length > 1 && !known) {
        for (final p in chunk) {
          result.addAll(await readPids([p]));
        }
        continue;
      }
      final replies = await request(ObdRequest(0x01, chunk), allowEmpty: true);
      if (replies.isEmpty) continue;
      // Prefer the engine ECU (first to answer 0100).
      replies.sort((a, b) => ecus.indexOf(a.ecu).compareTo(ecus.indexOf(b.ecu)));
      final parsed = _splitMultiPid(replies.first.payload);
      if (chunk.length > 1 && !chunk.every(parsed.containsKey)) {
        // Some ECUs ignore multi-PID requests: fall back to single requests.
        for (final p in chunk.where((p) => !parsed.containsKey(p))) {
          result.addAll(await readPids([p]));
        }
      }
      for (final e in parsed.entries) {
        final v = decodePid(e.key, e.value);
        if (v != null) result[e.key] = v;
      }
    }
    return result;
  }

  Map<int, List<int>> _splitMultiPid(List<int> payload) {
    final out = <int, List<int>>{};
    var i = 0;
    while (i < payload.length) {
      final pid = payload[i];
      final def = mode01Pids[pid];
      if (def == null || i + 1 + def.bytes > payload.length) break;
      out[pid] = payload.sublist(i + 1, i + 1 + def.bytes);
      i += 1 + def.bytes;
    }
    return out;
  }

  Future<ReadinessStatus?> readReadiness() async {
    if (!isSupported(0x01) && supportedPids.isNotEmpty) return null;
    final replies = await request(const ObdRequest(0x01, [0x01]), allowEmpty: true);
    if (replies.isEmpty || replies.first.payload.length < 5) return null;
    return decodeReadiness(replies.first.payload.sublist(1, 5));
  }

  Future<DtcReport> readDtcs(DtcStatus status) async {
    final service = switch (status) {
      DtcStatus.stored => 0x03,
      DtcStatus.pending => 0x07,
      DtcStatus.permanent => 0x0A,
      DtcStatus.freezeFrame => throw ArgumentError('Use readFreezeFrameDtc'),
    };
    final replies = await request(ObdRequest(service), allowEmpty: true);
    final byEcu = <String, List<Dtc>>{};
    for (final r in replies) {
      final codes = decodeDtcPayload(r.payload, hasCountByte: protocol.isCan);
      byEcu.putIfAbsent(r.ecu, () => []).addAll(codes.where((c) => !byEcu[r.ecu]!.contains(c)));
    }
    return DtcReport(status, byEcu);
  }

  /// Mode 02 frame 0: the DTC that stored the freeze frame and its values.
  Future<(Dtc?, Map<int, List<PidValue>>)> readFreezeFrame({int frame = 0}) async {
    final dtcReplies = await request(ObdRequest(0x02, [0x02, frame]), allowEmpty: true);
    Dtc? dtc;
    if (dtcReplies.isNotEmpty && dtcReplies.first.payload.length >= 4) {
      final p = dtcReplies.first.payload;
      if (p[2] != 0 || p[3] != 0) dtc = Dtc.fromBytes(p[2], p[3]);
    }
    final values = <int, List<PidValue>>{};
    if (dtc == null) return (null, values);
    final bm = await request(ObdRequest(0x02, [0x00, frame]), allowEmpty: true);
    if (bm.isEmpty || bm.first.payload.length < 6) return (dtc, values);
    for (final pid in decodeSupportedBitmap(0, bm.first.payload.sublist(2, 6))) {
      if (pid == 0x02 || pid % 0x20 == 0) continue;
      final r = await request(ObdRequest(0x02, [pid, frame]), allowEmpty: true);
      if (r.isEmpty || r.first.payload.length < 3) continue;
      final v = decodePid(pid, r.first.payload.sublist(2));
      if (v != null) values[pid] = v;
    }
    return (dtc, values);
  }

  Future<VehicleIdentity> readIdentity() async {
    final vinReplies = await request(const ObdRequest(0x09, [0x02]), allowEmpty: true, timeout: const Duration(seconds: 4));
    final payload = <int>[];
    for (final r in vinReplies) {
      payload.addAll(r.payload.sublist(1));
    }
    vin = extractVin(payload);
    final cal = <String, List<String>>{};
    for (final r in await request(const ObdRequest(0x09, [0x04]), allowEmpty: true, timeout: const Duration(seconds: 4))) {
      final text = String.fromCharCodes(r.payload.sublist(protocol.isCan ? 2 : 2).where((b) => b >= 0x20 && b < 0x7F));
      if (text.isNotEmpty) cal.putIfAbsent(r.ecu, () => []).add(text);
    }
    final names = <String, String>{};
    if (protocol.isCan) {
      for (final r in await request(const ObdRequest(0x09, [0x0A]), allowEmpty: true)) {
        final text = String.fromCharCodes(r.payload.sublist(2).where((b) => b >= 0x20 && b < 0x7F)).trim();
        if (text.isNotEmpty) names[r.ecu] = text;
      }
    }
    final info = await readPids([0x1C, 0x51]);
    return VehicleIdentity(
      vin: vin,
      calibrationIds: cal,
      ecuNames: names,
      ecus: ecus,
      protocol: protocol,
      obdStandard: info[0x1C]?.first.text,
      fuelType: info[0x51]?.first.text,
    );
  }

  /// Mode 04. Requires a permit from [gate] for [WriteAction.clearDtcs].
  Future<bool> clearDtcs(WritePermit permit) async {
    final r = await request(const ObdRequest(0x04), permit: permit, allowEmpty: true, timeout: const Duration(seconds: 5));
    return r.isNotEmpty;
  }

  /// Battery voltage at the OBD port, from the adapter (ATRV) when
  /// supported, else from PID 42 (control module voltage).
  Future<double?> readBatteryVoltage() async {
    if (adapter?.supports(AdapterCapability.readVoltage) ?? false) {
      final r = await _link.send('ATRV');
      final v = double.tryParse(r.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (v != null) return v;
    }
    final p = await readPids([0x42]);
    return p[0x42]?.first.value;
  }

  /// Re-establishes the session after the link dropped, restoring the
  /// protocol and adapter settings. Retries with exponential backoff.
  Future<bool> reconnect({int attempts = 5, Duration firstDelay = const Duration(milliseconds: 500)}) async {
    _set(SessionState.reconnecting);
    var delay = firstDelay;
    for (var i = 0; i < attempts; i++) {
      try {
        await transport.close();
        await _link.dispose();
        await transport.open();
        _link = ElmLink(transport, log: log);
        await _link.send('ATZ', timeout: const Duration(seconds: 5));
        for (final c in ['ATE0', 'ATL0', 'ATS0', 'ATH1']) {
          await _link.send(c);
        }
        await _detectProtocol(protocol == ObdProtocol.auto ? _requested : protocol);
        _set(SessionState.ready);
        return true;
      } catch (e) {
        log.add(LogDirection.error, 'reconnect attempt ${i + 1} failed: $e');
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }
    _set(SessionState.failed);
    return false;
  }

  Future<void> close() async {
    try {
      await _link.dispose();
    } catch (_) {}
    await transport.close();
    _set(SessionState.closed);
  }
}
