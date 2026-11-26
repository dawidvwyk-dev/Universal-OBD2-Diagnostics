/// Building and validating OBD2 service requests.
library;

import 'elm_response.dart';

/// Standard OBD2 services (modes) per SAE J1979.
enum ObdService {
  currentData(0x01, 'Current powertrain data', readOnly: true),
  freezeFrame(0x02, 'Freeze frame data', readOnly: true),
  storedDtcs(0x03, 'Stored DTCs', readOnly: true),
  clearDtcs(0x04, 'Clear DTCs and stored values', readOnly: false),
  o2Monitoring(0x05, 'Oxygen sensor monitoring (non-CAN)', readOnly: true),
  monitorResults(0x06, 'On-board monitoring test results', readOnly: true),
  pendingDtcs(0x07, 'Pending DTCs', readOnly: true),
  controlSystem(0x08, 'Control of on-board system', readOnly: false),
  vehicleInfo(0x09, 'Vehicle information', readOnly: true),
  permanentDtcs(0x0A, 'Permanent DTCs', readOnly: true);

  const ObdService(this.id, this.label, {required this.readOnly});
  final int id;
  final String label;

  /// False for services that change vehicle state. The engine refuses these
  /// unless a write permit is supplied.
  final bool readOnly;

  int get positiveResponse => id + 0x40;
}

/// UDS / OBD negative response codes (ISO 14229-1).
const negativeResponseCodes = {
  0x10: 'General reject',
  0x11: 'Service not supported',
  0x12: 'Sub-function not supported',
  0x13: 'Incorrect message length or invalid format',
  0x14: 'Response too long',
  0x21: 'Busy, repeat request',
  0x22: 'Conditions not correct',
  0x24: 'Request sequence error',
  0x31: 'Request out of range',
  0x33: 'Security access denied',
  0x35: 'Invalid key',
  0x36: 'Exceeded number of attempts',
  0x37: 'Required time delay not expired',
  0x72: 'General programming failure',
  0x78: 'Response pending',
  0x7E: 'Sub-function not supported in active session',
  0x7F: 'Service not supported in active session',
};

class ObdRequest {
  const ObdRequest(this.service, [this.data = const []]);
  final int service;
  final List<int> data;

  String toHex({bool spaces = false}) {
    final parts = [service, ...data]
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase());
    return parts.join(spaces ? ' ' : '');
  }
}

/// Result of matching a message against the request that produced it.
sealed class ResponseCheck {}

class PositiveResponse extends ResponseCheck {
  PositiveResponse(this.source, this.payload);
  final String source;

  /// Bytes after the service id (PID echo included).
  final List<int> payload;
}

class NegativeResponse extends ResponseCheck {
  NegativeResponse(this.source, this.code);
  final String source;
  final int code;
  String get description =>
      negativeResponseCodes[code] ?? 'Unknown negative response 0x${code.toRadixString(16)}';
}

class UnrelatedResponse extends ResponseCheck {
  UnrelatedResponse(this.message);
  final ObdMessage message;
}

/// Checks that [m] answers [req]: the service byte must be req+0x40 and,
/// for PID-based services, the PID byte must echo the request.
ResponseCheck checkResponse(ObdRequest req, ObdMessage m) {
  final d = m.data;
  if (d.isEmpty) return UnrelatedResponse(m);
  if (d[0] == 0x7F && d.length >= 3 && d[1] == req.service) {
    return NegativeResponse(m.source, d[2]);
  }
  if (d[0] != req.service + 0x40) return UnrelatedResponse(m);
  final echoesPid = req.service == 0x01 || req.service == 0x02 ||
      req.service == 0x05 || req.service == 0x06 || req.service == 0x09;
  if (echoesPid && req.data.isNotEmpty) {
    if (d.length < 2 || d[1] != req.data[0]) return UnrelatedResponse(m);
  }
  return PositiveResponse(m.source, d.sublist(1));
}
