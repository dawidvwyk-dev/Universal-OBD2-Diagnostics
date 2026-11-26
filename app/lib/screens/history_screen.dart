import 'package:diag_store/diag_store.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obd_decoders/obd_decoders.dart';

import '../state/settings.dart';
import '../state/storage.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/value_format.dart';

final _vehiclesProvider = StreamProvider<List<Vehicle>>((ref) async* {
  final repo = await ref.watch(repositoryProvider.future);
  yield* repo.watchVehicles();
});

final _scansProvider = StreamProvider.family<List<Scan>, (int?, bool)>((ref, arg) async* {
  final repo = await ref.watch(repositoryProvider.future);
  yield* repo.watchScans(vehicleId: arg.$1, includeSimulated: arg.$2);
});

final _notesProvider = StreamProvider.family<List<MaintenanceNote>, int>((ref, id) async* {
  final repo = await ref.watch(repositoryProvider.future);
  yield* repo.watchNotes(id);
});

String _date(DateTime t) =>
    '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int? _vehicleId;
  bool _simulatedOnly = false;
  final Set<int> _compare = {};

  @override
  Widget build(BuildContext context) {
    final repoAsync = ref.watch(repositoryProvider);
    if (repoAsync.hasError) {
      return SectionPage(title: 'Vehicle History', children: [
        InfoCard(title: 'The history database could not be opened', icon: Icons.error_outline,
            child: Text('${repoAsync.error}', style: const TextStyle(color: AppColors.critical))),
      ]);
    }
    final vehicles = ref.watch(_vehiclesProvider).value ?? const [];
    final dev = ref.watch(settingsProvider).developerMode;
    final selected = vehicles.where((v) => v.id == _vehicleId).firstOrNull;
    final scans = _simulatedOnly
        ? (ref.watch(_scansProvider((null, true))).value ?? const []).where((s) => s.simulated).toList()
        : selected == null
            ? const <Scan>[]
            : ref.watch(_scansProvider((selected.id, false))).value ?? const [];
    return SectionPage(
      title: 'Vehicle History',
      actions: [
        FilledButton.icon(onPressed: () => _editVehicle(null), icon: const Icon(Icons.add), label: const Text('Add vehicle')),
      ],
      children: [
        const Text('Stored on this device in an encrypted database. Scans are saved automatically and linked to the vehicle by its VIN.',
            style: TextStyle(color: AppColors.textSecondary)),
        InfoCard(
          title: 'Vehicles (${vehicles.length})',
          icon: Icons.garage_outlined,
          child: vehicles.isEmpty && !dev
              ? const Text('No vehicles yet. Run a scan on a vehicle or add one here.', style: TextStyle(color: AppColors.textSecondary))
              : Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final v in vehicles)
                    ChoiceChip(
                      label: Text(v.registration == null ? v.name : '${v.name} · ${v.registration}'),
                      selected: v.id == _vehicleId && !_simulatedOnly,
                      onSelected: (_) => setState(() {
                        _vehicleId = v.id;
                        _simulatedOnly = false;
                        _compare.clear();
                      }),
                    ),
                  if (dev)
                    ChoiceChip(
                      avatar: const Icon(Icons.science_outlined, size: 16, color: AppColors.simulated),
                      label: const Text('Simulated scans'),
                      selected: _simulatedOnly,
                      onSelected: (_) => setState(() {
                        _simulatedOnly = true;
                        _compare.clear();
                      }),
                    ),
                ]),
        ),
        if (selected != null && !_simulatedOnly)
          InfoCard(
            title: selected.name,
            icon: Icons.directions_car,
            trailing: TextButton.icon(onPressed: () => _editVehicle(selected), icon: const Icon(Icons.edit), label: const Text('Edit')),
            child: KeyValueList([
              ('Registration', selected.registration ?? '-'),
              ('VIN', selected.vin ?? '-'),
              ('Manufacturer', selected.manufacturer ?? '-'),
              ('Model', selected.model ?? '-'),
              ('Engine', selected.engine ?? '-'),
              ('Model year', selected.modelYear?.toString() ?? '-'),
            ]),
          ),
        if (selected != null || _simulatedOnly)
          InfoCard(
            title: 'Scans (${scans.length})',
            icon: Icons.history,
            trailing: _compare.length == 2
                ? FilledButton.tonal(onPressed: _showComparison, child: const Text('Compare selected'))
                : const Text('Tick two scans to compare', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            child: scans.isEmpty
                ? const Text('No scans saved yet.', style: TextStyle(color: AppColors.textSecondary))
                : Column(children: [
                    for (final s in scans)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _compare.contains(s.id),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            if (_compare.length == 2) _compare.remove(_compare.first);
                            _compare.add(s.id);
                          } else {
                            _compare.remove(s.id);
                          }
                        }),
                        title: Text('${_date(s.time)} · ${s.kind == 'full' ? 'Full scan' : 'Quick scan'}${s.simulated ? ' · SIMULATED' : ''}'),
                        subtitle: Text([
                          if (s.milOn != null) s.milOn! ? 'Check engine light on' : 'Check engine light off',
                          if (s.batteryVolts != null) 'Battery ${s.batteryVolts!.toStringAsFixed(1)} V',
                          ?s.protocol,
                        ].join(' · ')),
                        secondary: IconButton(icon: const Icon(Icons.open_in_new), tooltip: 'Open scan', onPressed: () => _openScan(s.id)),
                      ),
                  ]),
          ),
        if (selected != null && !_simulatedOnly) _NotesCard(vehicleId: selected.id),
      ],
    );
  }

  Future<void> _openScan(int id) async {
    final repo = await ref.read(repositoryProvider.future);
    final r = await repo.loadScan(id);
    if (r == null || !mounted) return;
    final units = ref.read(settingsProvider).units;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Scan ${_date(r.time)}${r.simulated ? ' (simulated)' : ''}'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              KeyValueList([
                ('VIN', r.vin ?? '-'),
                ('Protocol', r.protocol ?? '-'),
                ('Adapter', r.adapter ?? '-'),
                ('Codes', r.dtcs.isEmpty ? 'None' : r.dtcs.map((d) => '${d.$1} (${d.$2.name})').join(', ')),
                ('Incomplete monitors', r.monitors.where((m) => m.state == MonitorState.incomplete).map((m) => m.name).join(', ').ifEmpty('None')),
              ]),
              if (r.snapshot.isNotEmpty) ...[
                const Divider(),
                KeyValueList([
                  for (final vs in r.snapshot.values)
                    for (final v in vs) (v.name, '${formatValue(v, units).$1} ${formatValue(v, units).$2}'.trim()),
                ]),
              ],
              if (r.errors.isNotEmpty) ...[
                const Divider(),
                for (final e in r.errors) Text(e, style: const TextStyle(color: AppColors.warning)),
              ],
            ]),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _showComparison() async {
    final ids = _compare.toList();
    final repo = await ref.read(repositoryProvider.future);
    final c = await repo.compare(ids[0], ids[1]);
    if (c == null || !mounted) return;
    final units = ref.read(settingsProvider).units;
    String fmt(PidValue v) => '${formatValue(v, units).$1} ${formatValue(v, units).$2}'.trim();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${_date(c.older.time)}  →  ${_date(c.newer.time)}'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              KeyValueList([
                ('New codes', c.newCodes.join(', ').ifEmpty('None')),
                ('No longer present', c.resolvedCodes.join(', ').ifEmpty('None')),
                ('Still present', c.persistingCodes.join(', ').ifEmpty('None')),
              ]),
              if (c.readingChanges.isNotEmpty) ...[
                const Divider(),
                KeyValueList([
                  for (final e in c.readingChanges.values) (e.$2.name, '${fmt(e.$1)}  →  ${fmt(e.$2)}'),
                ]),
              ],
            ]),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _editVehicle(Vehicle? v) async {
    final result = await showDialog<VehiclesCompanion>(context: context, builder: (_) => _VehicleDialog(v));
    if (result == null) return;
    final repo = await ref.read(repositoryProvider.future);
    try {
      if (v == null) {
        final id = await repo.addVehicle(result);
        setState(() => _vehicleId = id);
      } else {
        await repo.updateVehicle(v.copyWith(
          name: result.name.value,
          registration: result.registration.present ? Value(result.registration.value) : const Value.absent(),
          vin: result.vin.present ? Value(result.vin.value) : const Value.absent(),
          manufacturer: result.manufacturer.present ? Value(result.manufacturer.value) : const Value.absent(),
          model: result.model.present ? Value(result.model.value) : const Value.absent(),
          engine: result.engine.present ? Value(result.engine.value) : const Value.absent(),
          modelYear: result.modelYear.present ? Value(result.modelYear.value) : const Value.absent(),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not saved: $e')));
    }
  }
}

extension on String {
  String ifEmpty(String other) => isEmpty ? other : this;
}

class _VehicleDialog extends StatefulWidget {
  const _VehicleDialog(this.v);
  final Vehicle? v;
  @override
  State<_VehicleDialog> createState() => _VehicleDialogState();
}

class _VehicleDialogState extends State<_VehicleDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.v?.name);
  late final _reg = TextEditingController(text: widget.v?.registration);
  late final _vin = TextEditingController(text: widget.v?.vin);
  late final _make = TextEditingController(text: widget.v?.manufacturer);
  late final _model = TextEditingController(text: widget.v?.model);
  late final _engine = TextEditingController(text: widget.v?.engine);
  late final _year = TextEditingController(text: widget.v?.modelYear?.toString());

  Value<String?> _opt(TextEditingController c) => Value(c.text.trim().isEmpty ? null : c.text.trim());

  @override
  Widget build(BuildContext context) {
    Widget field(TextEditingController c, String label, {String? Function(String?)? validator}) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextFormField(controller: c, decoration: InputDecoration(labelText: label), validator: validator),
        );
    return AlertDialog(
      title: Text(widget.v == null ? 'Add vehicle' : 'Edit vehicle'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              field(_name, 'Name', validator: (s) => (s ?? '').trim().isEmpty ? 'Enter a name' : ((s!.trim().length > 80) ? 'At most 80 characters' : null)),
              field(_reg, 'Registration number'),
              field(_vin, 'VIN', validator: (s) {
                final t = (s ?? '').trim().toUpperCase();
                return t.isEmpty || isVinSyntaxValid(t) ? null : '17 characters, no I, O or Q';
              }),
              field(_make, 'Manufacturer'),
              field(_model, 'Model'),
              field(_engine, 'Engine'),
              field(_year, 'Model year', validator: (s) {
                final t = (s ?? '').trim();
                if (t.isEmpty) return null;
                final y = int.tryParse(t);
                return y == null || y < 1980 || y > DateTime.now().year + 1 ? 'Enter a year from 1980' : null;
              }),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (!(_form.currentState?.validate() ?? false)) return;
            final vin = _vin.text.trim().toUpperCase();
            Navigator.pop(
              context,
              VehiclesCompanion.insert(
                name: _name.text.trim(),
                registration: _opt(_reg),
                vin: Value(vin.isEmpty ? null : vin),
                manufacturer: _opt(_make),
                model: _opt(_model),
                engine: _opt(_engine),
                modelYear: Value(int.tryParse(_year.text.trim())),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _NotesCard extends ConsumerStatefulWidget {
  const _NotesCard({required this.vehicleId});
  final int vehicleId;
  @override
  ConsumerState<_NotesCard> createState() => _NotesCardState();
}

class _NotesCardState extends ConsumerState<_NotesCard> {
  final _c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(_notesProvider(widget.vehicleId)).value ?? const [];
    return InfoCard(
      title: 'Maintenance notes',
      icon: Icons.sticky_note_2_outlined,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: TextField(controller: _c, maxLength: 4000, decoration: const InputDecoration(labelText: 'Add a note', counterText: ''))),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () async {
              if (_c.text.trim().isEmpty) return;
              final repo = await ref.read(repositoryProvider.future);
              await repo.addNote(widget.vehicleId, _c.text);
              _c.clear();
            },
            child: const Text('Add'),
          ),
        ]),
        const SizedBox(height: 8),
        for (final n in notes)
          ListTile(contentPadding: EdgeInsets.zero, title: Text(n.body), subtitle: Text(_date(n.time))),
      ]),
    );
  }
}
