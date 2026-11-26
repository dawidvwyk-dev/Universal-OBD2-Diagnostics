/// A software ELM327/STN adapter connected to a [VirtualVehicle].
///
/// TEST USE ONLY. Every response it produces is synthetic.
library;

import 'dart:convert';

import 'adapter_profile.dart';
import 'vehicle.dart';

class ElmEmulator {
  ElmEmulator({
    required this.vehicle,
    this.profile = SimAdapterProfile.genuineElm,
    double Function()? clock,
    this.canPadding = 0x00,
  }) : _clock = clock ?? _wallClock() {
    _defaults();
  }

  static double Function() _wallClock() {
    final sw = Stopwatch()..start();
    return () => sw.elapsedMilliseconds / 1000;
  }

  VirtualVehicle vehicle;
  final SimAdapterProfile profile;
  final double Function() _clock;
  final int canPadding;

  // Adapter settings.
  late bool echo, linefeeds, spaces, headers, caf;
  late int selectedProtocol; // 0 = auto
  late bool autoFallback;
  int? _connectedProtocol;
  String? _txHeader;

  /// Number of OBD requests answered (for tests).
  int requestCount = 0;

  /// When set, every OBD request answers with this line (fault injection).
  String? forcedReply;

  final _input = StringBuffer();

  void _defaults() {
    echo = true;
    linefeeds = false;
    spaces = true;
    headers = false;
    caf = true;
    selectedProtocol = 0;
    autoFallback = true;
    _connectedProtocol = null;
    _txHeader = null;
  }

  /// Feeds raw bytes from the host. Returns bytes to send back (may be empty
  /// until a full command terminated by CR has arrived).
  List<int> receive(List<int> bytes) {
    final out = StringBuffer();
    for (final ch in latin1.decode(bytes).split('')) {
      if (ch == '\r') {
        final cmd = _input.toString();
        _input.clear();
        out.write(_handleLine(cmd));
      } else if (ch != '\n' && ch != ' ') {
        _input.write(ch);
      }
    }
    return latin1.encode(out.toString());
  }

  String get _eol => linefeeds ? '\r\n' : '\r';

  String _handleLine(String raw) {
    final cmd = raw.replaceAll(' ', '').toUpperCase();
    final sb = StringBuffer();
    if (echo) sb.write('$raw$_eol');
    final body = cmd.isEmpty ? '' : _dispatch(cmd);
    sb.write(body);
    if (!body.endsWith(_eol) && body.isNotEmpty) sb.write(_eol);
    sb.write('$_eol>');
    return sb.toString();
  }

  String _dispatch(String cmd) {
    if (cmd.startsWith('AT')) return _at(cmd.substring(2));
    if (cmd.startsWith('ST')) return _st(cmd.substring(2));
    if (!RegExp(r'^[0-9A-F]+$').hasMatch(cmd) || cmd.length.isOdd) return '?';
    return _obd(cmd);
  }

  bool _unsupported(String stem) => profile.unsupported.contains(stem);

  String _at(String a) {
    String ok(String stem) => _unsupported(stem) ? '?' : 'OK';
    if (a == 'Z' || a == 'WS') {
      _defaults();
      return '$_eol${profile.identity}';
    }
    if (a == 'D') {
      final keepEcho = echo;
      _defaults();
      echo = keepEcho;
      return 'OK';
    }
    if (a == 'I') return profile.identity;
    if (a == '@1') return profile.description;
    if (a == 'RV') {
      if (_unsupported('RV')) return '?';
      return '${vehicle.batteryVolts.toStringAsFixed(1)}V';
    }
    if (a == 'DPN') {
      if (_unsupported('DPN')) return '?';
      final p = _connectedProtocol ?? selectedProtocol;
      final code = p.toRadixString(16).toUpperCase();
      return selectedProtocol == 0 ? 'A$code' : code;
    }
    if (a == 'DP') {
      final p = _connectedProtocol;
      if (p == null) return 'AUTO';
      final n = SimProtocol.values.firstWhere((s) => s.elmNumber == p).name;
      return '${selectedProtocol == 0 ? 'AUTO, ' : ''}$n';
    }
    final flag = RegExp(r'^(E|L|S|H|CAF|M|R|AT|IB|BI|DM|JE|JS|V)([0-2])$').firstMatch(a);
    if (flag != null) {
      final stem = flag.group(1)!;
      if (_unsupported(stem)) return '?';
      final on = flag.group(2) != '0';
      switch (stem) {
        case 'E':
          echo = on;
        case 'L':
          linefeeds = on;
        case 'S':
          spaces = on;
        case 'H':
          headers = on;
        case 'CAF':
          caf = on;
      }
      return 'OK';
    }
    final sp = RegExp(r'^(SP|TP)(A?)([0-9A-C])$').firstMatch(a);
    if (sp != null) {
      selectedProtocol = int.parse(sp.group(3)!, radix: 16);
      autoFallback = sp.group(2) == 'A' || selectedProtocol == 0;
      _connectedProtocol = null;
      return 'OK';
    }
    final sh = RegExp(r'^SH([0-9A-F]{3}|[0-9A-F]{6}|[0-9A-F]{8})$').firstMatch(a);
    if (sh != null) {
      if (_unsupported('SH')) return '?';
      if (profile.allowsRawCanHeaders) _txHeader = sh.group(1);
      return 'OK';
    }
    final stemMatch = RegExp(r'^[A-Z@]+').firstMatch(a);
    final stem = stemMatch?.group(0) ?? a;
    const known = {'ST', 'CRA', 'FC', 'PP', 'CSM', 'AMC', 'AMT', 'IGN', 'MA', 'PC', 'CF', 'CM', 'SW', 'WM', 'IIA', 'SR', 'TA'};
    for (final k in known) {
      if (stem.startsWith(k)) return ok(k);
    }
    return '?';
  }

  String _st(String s) {
    final stn = profile.stn;
    if (stn == null) return '?';
    if (s == 'I') return stn;
    if (s == 'DI') return profile.description;
    if (s == 'SN') return 'SIM000000001';
    return 'OK';
  }

  int? _resolveProtocol() {
    final want = vehicle.protocol.elmNumber;
    if (_connectedProtocol != null) return _connectedProtocol;
    if (!vehicle.ignitionOn) return null;
    if (selectedProtocol == 0 || selectedProtocol == want) {
      _connectedProtocol = want;
      return want;
    }
    if (autoFallback) {
      _connectedProtocol = want;
      return want;
    }
    return null;
  }

  String _obd(String cmd) {
    final bytes = [
      for (var i = 0; i < cmd.length; i += 2)
        int.parse(cmd.substring(i, i + 2), radix: 16)
    ];
    final wasSearching = _connectedProtocol == null && selectedProtocol == 0;
    final proto = _resolveProtocol();
    final prefix = wasSearching ? 'SEARCHING...$_eol' : '';
    if (proto == null) {
      final legacy = selectedProtocol >= 3 && selectedProtocol <= 5;
      return '$prefix${legacy ? 'BUS INIT: ...ERROR' : 'UNABLE TO CONNECT'}';
    }
    requestCount++;
    if (forcedReply != null) return '$prefix$forcedReply';

    final sp = SimProtocol.values.firstWhere((s) => s.elmNumber == proto);
    final lines = <String>[];
    for (final ecu in vehicle.ecus) {
      if (_txHeader != null && !_headerTargets(ecu, sp)) continue;
      final msgs = _answer(ecu, bytes, sp);
      for (final m in msgs) {
        lines.addAll(_format(ecu, m, sp));
      }
    }
    if (lines.isEmpty) return '${prefix}NO DATA';
    return prefix + lines.join(_eol);
  }

  bool _headerTargets(VirtualEcu ecu, SimProtocol sp) {
    final h = _txHeader!;
    if (h == '7DF' || h.endsWith('33F1') || h == '686AF1' || h == '68 6A F1') return true;
    if (sp.isCan && !sp.is29Bit && h.length == 3) {
      return int.parse(h, radix: 16) == ecu.canId - 8;
    }
    if (sp.is29Bit && h.length == 8) {
      return h.substring(4, 6) == ecu.legacyAddress.toRadixString(16).padLeft(2, '0').toUpperCase();
    }
    return true;
  }

  /// Returns response messages (service byte first) for one ECU.
  List<List<int>> _answer(VirtualEcu ecu, List<int> req, SimProtocol sp) {
    if (req.isEmpty) return const [];
    final t = _clock();
    final service = req[0];
    switch (service) {
      case 0x01:
        if (req.length < 2) return const [];
        final out = <int>[0x41];
        for (final pid in req.sublist(1)) {
          final data = _pid01(ecu, pid, t);
          if (data != null) out..add(pid)..addAll(data);
        }
        return out.length > 1 ? [out] : const [];
      case 0x02:
        if (req.length < 3 || ecu.freezeFrameDtc == null) return const [];
        final pid = req[1];
        if (pid == 0x02) {
          return [[0x42, 0x02, req[2], ...dtcBytes(ecu.freezeFrameDtc!)]];
        }
        if (pid == 0x00) {
          final keys = {...ecu.freezeFrame.keys, 0x02};
          final bm = [0, 0, 0, 0];
          for (final p in keys) {
            if (p > 0 && p <= 0x20) bm[(p - 1) ~/ 8] |= 0x80 >> ((p - 1) % 8);
          }
          return [[0x42, 0x00, req[2], ...bm]];
        }
        final d = ecu.freezeFrame[pid];
        return d == null ? const [] : [[0x42, pid, req[2], ...d]];
      case 0x03:
        return _dtcs(0x43, ecu.storedDtcs, sp, ecu);
      case 0x07:
        return _dtcs(0x47, ecu.pendingDtcs, sp, ecu);
      case 0x0A:
        return _dtcs(0x4A, ecu.permanentDtcs, sp, ecu);
      case 0x04:
        if (ecu.pids.isEmpty && ecu.storedDtcs.isEmpty) return const [];
        ecu.storedDtcs.clear();
        ecu.pendingDtcs.clear();
        ecu.freezeFrameDtc = null;
        ecu.freezeFrame.clear();
        return [[0x44]];
      case 0x09:
        return _mode09(ecu, req.length > 1 ? req[1] : -1, sp);
      default:
        return [[0x7F, service, 0x11]];
    }
  }

  List<int>? _pid01(VirtualEcu ecu, int pid, double t) {
    if (pid % 0x20 == 0) {
      if (pid != 0 && !ecu.pids.keys.any((p) => p > pid)) {
        return null;
      }
      return ecu.supportedBitmap(pid);
    }
    final src = ecu.pids[pid];
    return src?.call(t);
  }

  List<List<int>> _dtcs(int sid, List<String> codes, SimProtocol sp, VirtualEcu ecu) {
    if (ecu.pids.isEmpty) return const [];
    final raw = [for (final c in codes) ...dtcBytes(c)];
    if (sp.isCan) return [[sid, codes.length, ...raw]];
    // Legacy: 3 codes per frame, padded with zeros; at least one frame.
    final frames = <List<int>>[];
    var i = 0;
    do {
      final chunk = raw.sublist(i, i + 6 > raw.length ? raw.length : i + 6);
      frames.add([sid, ...chunk, ...List.filled(6 - chunk.length, 0)]);
      i += 6;
    } while (i < raw.length);
    return frames;
  }

  List<List<int>> _mode09(VirtualEcu ecu, int pid, SimProtocol sp) {
    switch (pid) {
      case 0x00:
        final b0 = (ecu.vin != null ? 0x40 : 0) |
            (ecu.calibrationId != null ? 0x10 : 0) |
            (ecu.cvn != null ? 0x04 : 0);
        return [[0x49, 0x00, b0, sp.isCan ? 0x40 : 0x00, 0x00, 0x00]];
      case 0x02:
        final vin = ecu.vin;
        if (vin == null) return const [];
        if (sp.isCan) return [[0x49, 0x02, 0x01, ...vin.codeUnits]];
        final padded = [0, 0, 0, ...vin.codeUnits];
        return [
          for (var i = 0; i < 5; i++) [0x49, 0x02, i + 1, ...padded.sublist(i * 4, i * 4 + 4)]
        ];
      case 0x04:
        final cal = ecu.calibrationId;
        if (cal == null) return const [];
        final padded = [...cal.codeUnits, ...List.filled(16 - cal.length, 0)];
        if (sp.isCan) return [[0x49, 0x04, 0x01, ...padded]];
        return [
          for (var i = 0; i < 4; i++) [0x49, 0x04, i + 1, ...padded.sublist(i * 4, i * 4 + 4)]
        ];
      case 0x06:
        final cvn = ecu.cvn;
        if (cvn == null) return const [];
        return [[0x49, 0x06, 0x01, ...cvn]];
      case 0x0A:
        final name = ecu.name.padRight(20, '\u0000').substring(0, 20);
        return sp.isCan ? [[0x49, 0x0A, 0x01, ...name.codeUnits]] : const [];
      default:
        return const [];
    }
  }

  String _hex(List<int> d) {
    final parts = d.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase());
    return parts.join(spaces ? ' ' : '');
  }

  /// Formats one message as the ELM would print it.
  List<String> _format(VirtualEcu ecu, List<int> msg, SimProtocol sp) {
    if (!sp.isCan) {
      final hdr = [0x48, 0x6B, ecu.legacyAddress];
      final sum = [...hdr, ...msg].fold<int>(0, (a, b) => a + b) & 0xFF;
      return [headers ? _hex([...hdr, ...msg, sum]) : _hex(msg)];
    }
    final id = sp.is29Bit
        ? '18DAF1${ecu.legacyAddress.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        : ecu.canId.toRadixString(16).toUpperCase();
    final idText = sp.is29Bit && spaces
        ? [for (var i = 0; i < 8; i += 2) id.substring(i, i + 2)].join(' ')
        : id;
    String line(List<int> frame) {
      final padded = [...frame, ...List.filled(8 - frame.length, canPadding)];
      if (headers) return '$idText${spaces ? ' ' : ''}${_hex(padded)}';
      return _hex(caf ? frame.sublist(1) : padded);
    }

    if (msg.length <= 7) return [line([msg.length, ...msg])];
    // ISO-TP first + consecutive frames.
    final out = <String>[];
    if (!headers && caf) {
      out.add(msg.length.toRadixString(16).toUpperCase().padLeft(3, '0'));
      var seq = 0;
      out.add('$seq: ${_hex(msg.sublist(0, 6))}');
      for (var i = 6; i < msg.length; i += 7) {
        seq = (seq + 1) & 0x0F;
        out.add('${seq.toRadixString(16).toUpperCase()}: ${_hex(msg.sublist(i, i + 7 > msg.length ? msg.length : i + 7))}');
      }
      return out;
    }
    out.add(line([0x10 | (msg.length >> 8), msg.length & 0xFF, ...msg.sublist(0, 6)]));
    var seq = 1;
    for (var i = 6; i < msg.length; i += 7) {
      out.add(line([0x20 | seq, ...msg.sublist(i, i + 7 > msg.length ? msg.length : i + 7)]));
      seq = (seq + 1) & 0x0F;
    }
    return out;
  }
}
