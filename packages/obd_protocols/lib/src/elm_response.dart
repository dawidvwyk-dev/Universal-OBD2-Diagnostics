/// Parsing of ELM327/STN text responses into frames and messages.
library;

import 'protocol.dart';

/// Error/status lines an ELM327 can return instead of data.
enum ElmError {
  noData('NO DATA', 'The vehicle did not answer this request. It may not support it.'),
  unableToConnect('UNABLE TO CONNECT', 'The adapter could not find a vehicle protocol. Check the ignition is on.'),
  busInitError('BUS INIT', 'The adapter could not initialise the vehicle bus.'),
  busBusy('BUS BUSY', 'The vehicle bus is too busy to send the request.'),
  busError('BUS ERROR', 'Electrical error on the vehicle bus.'),
  canError('CAN ERROR', 'The adapter saw errors on the CAN bus.'),
  dataError('DATA ERROR', 'The vehicle replied with corrupt data.'),
  bufferFull('BUFFER FULL', 'The adapter ran out of memory for the reply.'),
  fbError('FB ERROR', 'Feedback error on the bus line.'),
  lvReset('LV RESET', 'The adapter reset because of low voltage.'),
  stopped('STOPPED', 'The request was interrupted.'),
  unknownCommand('?', 'The adapter does not support this command.'),
  error('ERROR', 'The adapter reported an error.');

  const ElmError(this.token, this.message);
  final String token;
  final String message;

  static ElmError? match(String line) {
    final l = line.toUpperCase();
    for (final e in values) {
      if (e == unknownCommand) {
        if (l.trim() == '?') return e;
        continue;
      }
      if (e == error) {
        if (RegExp(r'\bERROR\b').hasMatch(l) &&
            !l.contains('BUS ERROR') && !l.contains('CAN ERROR') &&
            !l.contains('DATA ERROR') && !l.contains('FB ERROR')) {
          return e;
        }
        continue;
      }
      if (l.contains(e.token)) return e;
    }
    return null;
  }
}

/// One frame (line) of vehicle data with its source address.
class ObdFrame {
  const ObdFrame(this.source, this.data);

  /// ECU/sender address as hex, e.g. `7E8`, `18DAF110` or `10` (legacy).
  final String source;
  final List<int> data;

  @override
  String toString() => '$source: ${hex(data)}';
}

/// A complete message from one ECU after ISO-TP reassembly.
class ObdMessage {
  const ObdMessage(this.source, this.data);
  final String source;
  final List<int> data;

  @override
  String toString() => '$source: ${hex(data)}';
}

class ElmParseResult {
  const ElmParseResult({this.messages = const [], this.error, this.raw = ''});
  final List<ObdMessage> messages;
  final ElmError? error;
  final String raw;
  bool get ok => error == null && messages.isNotEmpty;
}

String hex(List<int> d) =>
    d.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');

List<int>? _hexBytes(String s) {
  if (s.length.isOdd) return null;
  final out = <int>[];
  for (var i = 0; i < s.length; i += 2) {
    final v = int.tryParse(s.substring(i, i + 2), radix: 16);
    if (v == null) return null;
    out.add(v);
  }
  return out;
}

final _hexOnly = RegExp(r'^[0-9A-Fa-f]+$');

/// Status lines that carry no data and are skipped.
bool _isStatus(String l) {
  final u = l.toUpperCase();
  return u.startsWith('SEARCHING') ||
      u.startsWith('BUS INIT') && u.endsWith('OK') ||
      u == 'OK';
}

/// Parses a full ELM response (everything before the `>` prompt) that was
/// produced with headers ON (`ATH1`) for [protocol].
///
/// Works with spaces on or off. Legacy frames have their trailing checksum
/// byte removed. CAN frames are reassembled per ISO 15765-2 (single, first
/// and consecutive frames); out-of-order or incomplete sequences are dropped
/// rather than returned partially.
ElmParseResult parseElmResponse(String response, ObdProtocol protocol,
    {String? echo}) {
  final lines = response
      .replaceAll('\r', '\n')
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && l != '>')
      .toList();
  if (echo != null && lines.isNotEmpty &&
      lines.first.replaceAll(' ', '').toUpperCase() ==
          echo.replaceAll(' ', '').toUpperCase()) {
    lines.removeAt(0);
  }

  final frames = <ObdFrame>[];
  for (final line in lines) {
    if (_isStatus(line)) continue;
    final err = ElmError.match(line);
    if (err != null) {
      if (frames.isEmpty) return ElmParseResult(error: err, raw: response);
      continue;
    }
    final compact = line.replaceAll(' ', '');
    if (!_hexOnly.hasMatch(compact)) continue;
    final frame = _parseFrame(compact, protocol);
    if (frame != null) frames.add(frame);
  }
  if (frames.isEmpty) {
    return ElmParseResult(error: ElmError.noData, raw: response);
  }
  final messages = protocol.isCan ? _assembleCan(frames) : _assembleLegacy(frames);
  return ElmParseResult(messages: messages, raw: response);
}

ObdFrame? _parseFrame(String compact, ObdProtocol protocol) {
  if (protocol.isCan) {
    // 11-bit headers are 3 hex chars; 29-bit are 8.
    final hc = protocol.is29Bit ? 8 : 3;
    if (compact.length <= hc) return null;
    final bytes = _hexBytes(compact.substring(hc));
    if (bytes == null) return null;
    return ObdFrame(compact.substring(0, hc).toUpperCase(), bytes);
  }
  // Legacy: 3 header bytes (priority, target, source) + data + checksum.
  final bytes = _hexBytes(compact);
  if (bytes == null || bytes.length < 5) return null;
  final source = bytes[2].toRadixString(16).padLeft(2, '0').toUpperCase();
  return ObdFrame(source, bytes.sublist(3, bytes.length - 1));
}

/// ISO-TP reassembly. Each frame's first byte is the PCI.
List<ObdMessage> _assembleCan(List<ObdFrame> frames) {
  final out = <ObdMessage>[];
  final pending = <String, _IsoTpBuffer>{};
  for (final f in frames) {
    if (f.data.isEmpty) continue;
    final pci = f.data[0] >> 4;
    switch (pci) {
      case 0: // single frame
        final len = f.data[0] & 0x0F;
        if (len == 0 || f.data.length < 1 + len) continue;
        out.add(ObdMessage(f.source, f.data.sublist(1, 1 + len)));
      case 1: // first frame
        if (f.data.length < 2) continue;
        final len = ((f.data[0] & 0x0F) << 8) | f.data[1];
        pending[f.source] = _IsoTpBuffer(len)..add(f.data.sublist(2));
      case 2: // consecutive frame
        final buf = pending[f.source];
        if (buf == null) continue;
        final seq = f.data[0] & 0x0F;
        if (seq != buf.nextSeq) {
          pending.remove(f.source);
          continue;
        }
        buf.nextSeq = (buf.nextSeq + 1) & 0x0F;
        buf.add(f.data.sublist(1));
        if (buf.complete) {
          out.add(ObdMessage(f.source, buf.bytes.sublist(0, buf.length)));
          pending.remove(f.source);
        }
      default: // flow control or unknown: ignore
        continue;
    }
  }
  return out;
}

class _IsoTpBuffer {
  _IsoTpBuffer(this.length);
  final int length;
  final List<int> bytes = [];
  int nextSeq = 1;
  void add(List<int> d) => bytes.addAll(d);
  bool get complete => bytes.length >= length;
}

/// Legacy protocols: each ECU answers with one or more frames. Frames from
/// the same ECU are kept as separate messages; the caller decides whether
/// they belong together (e.g. VIN over 5 frames, DTCs 3 per frame).
List<ObdMessage> _assembleLegacy(List<ObdFrame> frames) =>
    [for (final f in frames) ObdMessage(f.source, f.data)];
