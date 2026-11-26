/// Choosing the GATT characteristics that carry the ELM327 serial stream.
///
/// BLE OBD adapters do not share one standard service. Most use one of a few
/// "serial over GATT" layouts; others can be found by looking for a custom
/// service with one notifying and one writable characteristic.
library;

/// Characteristic properties as reported by the platform.
class BleCharacteristicInfo {
  const BleCharacteristicInfo(this.uuid, {this.notify = false, this.indicate = false, this.write = false, this.writeWithoutResponse = false});
  final String uuid;
  final bool notify, indicate, write, writeWithoutResponse;
  bool get canNotify => notify || indicate;
  bool get canWrite => write || writeWithoutResponse;
}

class BleServiceInfo {
  const BleServiceInfo(this.uuid, this.characteristics);
  final String uuid;
  final List<BleCharacteristicInfo> characteristics;
}

/// The characteristics to use for a BLE adapter.
class BleChannel {
  const BleChannel({required this.service, required this.notify, required this.write, required this.withoutResponse, required this.profile});
  final String service, notify, write;

  /// Use write-without-response (faster) when the characteristic supports it.
  final bool withoutResponse;

  /// Which known layout matched, or 'generic'.
  final String profile;

  @override
  String toString() => '$profile: service $service, notify $notify, write $write';
}

/// Expands a 16-bit UUID such as `FFF0` to the full 128-bit form.
String fullUuid(String uuid) {
  final u = uuid.toLowerCase().replaceAll(RegExp('[{}]'), '');
  if (RegExp(r'^[0-9a-f]{4}$').hasMatch(u)) return '0000$u-0000-1000-8000-00805f9b34fb';
  if (RegExp(r'^[0-9a-f]{8}$').hasMatch(u)) return '$u-0000-1000-8000-00805f9b34fb';
  return u;
}

class _Known {
  const _Known(this.name, this.service, this.notify, this.write);
  final String name, service, notify, write;
}

/// Common layouts, checked in order.
const _known = [
  _Known('FFF0 serial (many ELM327 BLE clones)', 'fff0', 'fff1', 'fff2'),
  _Known('FFE0 serial (HM-10 style modules)', 'ffe0', 'ffe1', 'ffe1'),
  _Known('18F0 serial', '18f0', '2af0', '2af1'),
  _Known('Vgate / iCar BLE', 'e7810a71-73ae-499d-8c15-faa9aef0c3f2', 'bef8d6c9-9c21-4c9e-b632-bd58c1009f9f', 'bef8d6c9-9c21-4c9e-b632-bd58c1009f9f'),
];

/// Standard services that never carry adapter data.
const _standard = {'1800', '1801', '180a', '180f', '1805', '1804'};

bool _isStandard(String uuid) {
  final f = fullUuid(uuid);
  return _standard.any((s) => f == fullUuid(s));
}

/// Picks the notify/write pair, preferring known layouts, then any custom
/// service with both a notifying and a writable characteristic.
/// Returns null when the device exposes nothing usable.
BleChannel? selectBleChannel(List<BleServiceInfo> services) {
  BleCharacteristicInfo? find(BleServiceInfo s, String uuid) {
    for (final c in s.characteristics) {
      if (fullUuid(c.uuid) == fullUuid(uuid)) return c;
    }
    return null;
  }

  for (final k in _known) {
    for (final s in services) {
      if (fullUuid(s.uuid) != fullUuid(k.service)) continue;
      final n = find(s, k.notify);
      final w = find(s, k.write);
      if (n != null && w != null && n.canNotify && w.canWrite) {
        return BleChannel(
            service: s.uuid, notify: n.uuid, write: w.uuid, withoutResponse: w.writeWithoutResponse, profile: k.name);
      }
    }
  }
  for (final s in services) {
    if (_isStandard(s.uuid)) continue;
    final n = s.characteristics.where((c) => c.canNotify).firstOrNull;
    // Prefer a separate writable characteristic, else the same one.
    final w = s.characteristics.where((c) => c.canWrite && c.uuid != n?.uuid).firstOrNull ??
        s.characteristics.where((c) => c.canWrite).firstOrNull;
    if (n != null && w != null) {
      return BleChannel(service: s.uuid, notify: n.uuid, write: w.uuid, withoutResponse: w.writeWithoutResponse, profile: 'generic');
    }
  }
  return null;
}

/// True when an advertised name looks like an OBD adapter. Only used to sort
/// and badge scan results, never to hide devices.
bool looksLikeObdAdapter(String? name) {
  if (name == null) return false;
  final n = name.toLowerCase();
  return const ['obd', 'elm', 'vlink', 'v-link', 'vgate', 'icar', 'obdlink', 'veepeak', 'konnwei', 'carista', 'kiwi', 'scan', 'bafx', 'lelink', 'ios-vlink', 'android-vlink']
      .any(n.contains);
}

/// Write size for a BLE link given the negotiated ATT MTU (3 bytes of header).
int bleChunkSize(int? mtu) => mtu == null || mtu < 23 ? 20 : (mtu - 3).clamp(20, 512);
