/// Read-only by default: any request that changes vehicle state needs a
/// single-use [WritePermit] issued after explicit user confirmation.
library;

import 'dart:math';

enum WriteAction {
  clearDtcs('Clear diagnostic trouble codes and freeze-frame data',
      'Erases stored codes, freeze frames and readiness monitor results. '
          'The vehicle will need a full drive cycle before it passes an emissions test.'),
  controlSystem('Run an on-board system test (Mode 08)',
      'Commands a component on the vehicle. Only run it with the engine in the state the test requires.');

  const WriteAction(this.title, this.warning);
  final String title;
  final String warning;
}

class SafetyException implements Exception {
  SafetyException(this.message);
  final String message;
  @override
  String toString() => 'Blocked by safety gate: $message';
}

class WritePermit {
  WritePermit._(this.action, this.vin, this.issuedAt, this._token);
  final WriteAction action;
  final String? vin;
  final DateTime issuedAt;
  final int _token;
  bool _used = false;
}

/// Issues and redeems permits. The UI calls [authorize] only after showing
/// [WriteAction.warning] and receiving the user's explicit confirmation.
class SafetyGate {
  SafetyGate({this.validity = const Duration(seconds: 60)});
  final Duration validity;
  final _random = Random.secure();
  final _issued = <int>{};

  WritePermit authorize(WriteAction action,
      {required String? vin, required bool userConfirmed}) {
    if (!userConfirmed) {
      throw SafetyException('${action.title} needs explicit user confirmation.');
    }
    final token = _random.nextInt(1 << 31);
    _issued.add(token);
    return WritePermit._(action, vin, DateTime.now(), token);
  }

  /// Consumes [permit] for [action] on the vehicle identified by [vin].
  void redeem(WritePermit? permit, WriteAction action, {required String? vin}) {
    if (permit == null) {
      throw SafetyException('${action.title} is not allowed in read-only mode.');
    }
    if (permit._used || !_issued.contains(permit._token)) {
      throw SafetyException('This confirmation was already used.');
    }
    if (permit.action != action) {
      throw SafetyException('The confirmation was for a different action.');
    }
    if (permit.vin != null && vin != null && permit.vin != vin) {
      throw SafetyException('The confirmation was for a different vehicle.');
    }
    if (DateTime.now().difference(permit.issuedAt) > validity) {
      throw SafetyException('The confirmation expired. Confirm again.');
    }
    permit._used = true;
    _issued.remove(permit._token);
  }
}
