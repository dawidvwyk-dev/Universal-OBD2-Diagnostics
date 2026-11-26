/// Identifies an adapter and measures what it really supports.
///
/// Version strings from clones are unreliable, so every optional feature is
/// tested directly and the result, not the claimed version, decides what
/// the engine uses.
library;

import 'elm_link.dart';

/// An optional adapter capability and the command used to test it.
enum AdapterCapability {
  readVoltage('RV', 'ATRV', 'Read battery voltage at the OBD port'),
  describeProtocol('DPN', 'ATDPN', 'Report the detected protocol'),
  canAutoFormat('CAF', 'ATCAF1', 'CAN auto-formatting control'),
  adaptiveTiming('AT', 'ATAT1', 'Adaptive response timing'),
  setTimeout('ST', 'ATST64', 'Configurable response timeout'),
  setHeader('SH', 'ATSH7DF', 'Custom request headers (needed for enhanced diagnostics)'),
  canReceiveFilter('CRA', 'ATCRA', 'CAN receive address filter (needed for enhanced diagnostics)'),
  flowControl('FC', 'ATFCSM0', 'ISO-TP flow control settings (needed for UDS)'),
  programmableParams('PP', 'ATPPS', 'Programmable parameters'),
  stnExtensions('STI', 'STI', 'STN extended commands (OBDLink)');

  const AdapterCapability(this.key, this.probe, this.description);
  final String key;
  final String probe;
  final String description;
}

enum ChipFamily { elm327, stn, unknown }

class AdapterInfo {
  AdapterInfo({
    required this.identity,
    required this.description,
    required this.chip,
    required this.claimedVersion,
    required this.capabilities,
    this.stnIdentity,
    this.stnDevice,
    this.voltage,
  });

  /// Reply to ATI, e.g. `ELM327 v1.5`.
  final String identity;

  /// Reply to AT@1 (manufacturer description, often blank on clones).
  final String description;
  final ChipFamily chip;
  final String? claimedVersion;
  final String? stnIdentity;
  final String? stnDevice;
  final double? voltage;
  final Map<AdapterCapability, bool> capabilities;

  bool supports(AdapterCapability c) => capabilities[c] ?? false;

  /// Enhanced diagnostics need header control and receive filtering.
  bool get supportsEnhanced =>
      supports(AdapterCapability.setHeader) &&
      supports(AdapterCapability.canReceiveFilter);

  /// Heuristic: an "ELM327 v1.5+" that fails commands every genuine chip of
  /// that version has is almost certainly a clone.
  bool get likelyClone {
    if (chip != ChipFamily.elm327) return false;
    final v = double.tryParse(claimedVersion ?? '');
    if (v == null) return true;
    if (v >= 1.4 && !supports(AdapterCapability.programmableParams)) return true;
    if (v >= 1.3 && !supports(AdapterCapability.canReceiveFilter)) return true;
    return false;
  }

  String get manufacturer {
    if (chip == ChipFamily.stn) {
      return stnDevice?.toUpperCase().contains('OBDLINK') ?? false
          ? 'OBD Solutions (OBDLink)'
          : 'STN-based adapter';
    }
    if (description.isNotEmpty && description != 'OBDII to RS232 Interpreter') {
      return description;
    }
    return likelyClone ? 'ELM327-compatible (clone)' : 'ELM Electronics ELM327';
  }

  String get model => stnDevice ?? identity;

  /// Plain-language list of what will not work with this adapter.
  List<String> get limitations => [
        for (final c in AdapterCapability.values)
          if (!supports(c) && c != AdapterCapability.stnExtensions)
            'Not supported: ${c.description}.',
      ];
}

final _version = RegExp(r'v(\d+\.\d+)', caseSensitive: false);

/// Runs reset, configuration and capability probing. Leaves the adapter with
/// echo off, linefeeds off, spaces off and headers on.
Future<AdapterInfo> probeAdapter(ElmLink link) async {
  final resetReply = await link.send('ATZ', timeout: const Duration(seconds: 5));
  for (final cmd in ['ATE0', 'ATL0', 'ATS0', 'ATH1']) {
    await link.send(cmd);
  }
  var identity = (await link.send('ATI')).split('\n').last.trim();
  if (identity.isEmpty || identity == '?') {
    identity = resetReply.split('\n').lastWhere((l) => l.trim().isNotEmpty,
        orElse: () => 'Unknown adapter').trim();
  }
  final desc = await link.send('AT@1');
  final caps = <AdapterCapability, bool>{};
  String? stnId, stnDev;
  double? volts;
  for (final c in AdapterCapability.values) {
    String reply;
    try {
      reply = await link.send(c.probe);
    } on ElmTimeoutException {
      caps[c] = false;
      continue;
    }
    final ok = reply.isNotEmpty && !reply.contains('?') && !reply.toUpperCase().contains('ERROR');
    caps[c] = ok;
    if (ok && c == AdapterCapability.readVoltage) {
      volts = double.tryParse(reply.replaceAll(RegExp(r'[^0-9.]'), ''));
    }
    if (ok && c == AdapterCapability.stnExtensions) {
      stnId = reply;
      final di = await link.send('STDI');
      stnDev = di.contains('?') ? null : di;
    }
  }
  // Restore defaults changed by the probe.
  if (caps[AdapterCapability.setHeader] ?? false) await link.send('ATSH7DF');
  if (caps[AdapterCapability.canReceiveFilter] ?? false) await link.send('ATCRA');

  final chip = stnId != null
      ? ChipFamily.stn
      : identity.toUpperCase().contains('ELM327')
          ? ChipFamily.elm327
          : ChipFamily.unknown;
  return AdapterInfo(
    identity: identity,
    description: desc.contains('?') ? '' : desc,
    chip: chip,
    claimedVersion: _version.firstMatch(identity)?.group(1),
    capabilities: caps,
    stnIdentity: stnId,
    stnDevice: stnDev,
    voltage: volts,
  );
}

/// Result of a reliability burst.
class LinkQuality {
  LinkQuality({required this.sent, required this.answered, required this.average, required this.worst});
  final int sent;
  final int answered;
  final Duration average;
  final Duration worst;

  double get successRate => sent == 0 ? 0 : answered / sent;

  /// 0..100 score for display: success rate weighted by latency.
  int get score {
    final latencyFactor = average.inMilliseconds <= 60
        ? 1.0
        : (300 - average.inMilliseconds.clamp(60, 300)) / 240 * 0.5 + 0.5;
    return (successRate * latencyFactor * 100).round();
  }
}

/// Sends [count] copies of [command] and measures answers and latency.
Future<LinkQuality> measureLinkQuality(ElmLink link,
    {String command = '0100', int count = 10}) async {
  var answered = 0;
  final times = <Duration>[];
  for (var i = 0; i < count; i++) {
    final sw = Stopwatch()..start();
    try {
      final r = await link.send(command, timeout: const Duration(seconds: 3));
      sw.stop();
      if (!r.contains('NO DATA') && !r.contains('ERROR') && !r.contains('?')) {
        answered++;
        times.add(sw.elapsed);
      }
    } on ElmTimeoutException {
      // counted as a failure
    }
  }
  final avg = times.isEmpty
      ? Duration.zero
      : Duration(microseconds: times.fold<int>(0, (a, d) => a + d.inMicroseconds) ~/ times.length);
  final worst = times.isEmpty ? Duration.zero : times.reduce((a, b) => a > b ? a : b);
  return LinkQuality(sent: count, answered: answered, average: avg, worst: worst);
}
