/// Behaviour profiles that mimic real adapter firmware, including clones
/// that reject commands or behave oddly. Used to test the engine's probing.
class SimAdapterProfile {
  const SimAdapterProfile({
    required this.id,
    required this.identity,
    this.description = 'OBDII to RS232 Interpreter',
    this.unsupported = const {},
    this.stn,
    this.allowsRawCanHeaders = true,
  });

  final String id;

  /// Reply to `ATI`, e.g. `ELM327 v1.5`.
  final String identity;

  /// Reply to `AT@1`.
  final String description;

  /// AT command stems (without `AT`) that answer `?`.
  final Set<String> unsupported;

  /// Reply to `STI` for STN-based adapters (OBDLink); null if not STN.
  final String? stn;

  /// False for clones whose `ATSH` is accepted but ignored.
  final bool allowsRawCanHeaders;

  static const genuineElm = SimAdapterProfile(
    id: 'genuine_elm327_v2_3',
    identity: 'ELM327 v2.3',
  );

  /// Common cheap clone: claims v1.5, lacks several 1.4+ commands.
  static const cloneV15 = SimAdapterProfile(
    id: 'clone_v1_5',
    identity: 'ELM327 v1.5',
    unsupported: {'PP', 'CRA', 'FC', 'CSM', 'AMC', 'AMT', 'IGN', 'MA'},
  );

  /// Clone that claims v2.1 but implements the v1.0-era command set.
  static const cloneV21 = SimAdapterProfile(
    id: 'clone_v2_1',
    identity: 'ELM327 v2.1',
    unsupported: {'PP', 'CRA', 'FC', 'CSM', 'AMC', 'AMT', 'IGN', 'MA', 'CAF', 'DPN', 'RV', 'AT', 'ST'},
    allowsRawCanHeaders: false,
  );

  static const obdLinkStn = SimAdapterProfile(
    id: 'obdlink_stn2120',
    identity: 'ELM327 v1.4b',
    description: 'OBDLink MX+',
    stn: 'STN2120 r5.10.3',
  );

  static const all = [genuineElm, cloneV15, cloneV21, obdLinkStn];
}
