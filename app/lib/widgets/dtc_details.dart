import 'dart:convert';

import 'package:diag_store/diag_store.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'common.dart';

List<String> _items(String json) {
  try {
    return [for (final e in jsonDecode(json) as List) e as String];
  } catch (_) {
    return const [];
  }
}

StatusLevel _level(String? severity) => switch (severity) {
      'critical' || 'high' => StatusLevel.critical,
      'medium' => StatusLevel.warning,
      'low' => StatusLevel.info,
      _ => StatusLevel.idle,
    };

class SeverityPill extends StatelessWidget {
  const SeverityPill(this.severity, {super.key});
  final String? severity;
  @override
  Widget build(BuildContext context) => StatusPill(severity == null ? 'severity unknown' : 'severity: $severity', _level(severity));
}

String confidenceLabel(DtcDefinition d) => d.confidence == 'verified'
    ? 'Verified ${d.manufacturer ?? ''} definition'.replaceAll('  ', ' ')
    : 'Generic interpretation. Manufacturers can define details differently.';

Future<void> showDtcDetails(BuildContext context, DtcDefinition def) => showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${def.code}  ${def.description}'),
        content: SizedBox(width: 560, child: SingleChildScrollView(child: DtcDetails(def))),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );

/// Full guidance for one code: causes, symptoms, checks and repairs.
class DtcDetails extends StatelessWidget {
  const DtcDetails(this.def, {super.key});
  final DtcDefinition def;

  @override
  Widget build(BuildContext context) {
    Widget section(String title, String json) {
      final items = _items(json);
      if (items.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          for (final i in items)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text('•  $i', style: const TextStyle(color: AppColors.textSecondary)),
            ),
        ]),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Wrap(spacing: 8, runSpacing: 8, children: [
        SeverityPill(def.severity),
        if (def.category != null) StatusPill(def.category!, StatusLevel.idle),
      ]),
      const SizedBox(height: 8),
      Text(confidenceLabel(def), style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
      section('Possible causes (most common first)', def.causes),
      section('Symptoms you may notice', def.symptoms),
      section('Checks before replacing parts', def.inspection),
      section('Typical repairs', def.repairs),
      section('Components involved', def.components),
      const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Text('This is guidance, not a confirmed diagnosis. Confirm the fault with the checks above before replacing parts.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ),
    ]);
  }
}

/// Searchable library of every installed fault-code description.
class DtcLibraryCard extends StatefulWidget {
  const DtcLibraryCard({super.key, required this.count, required this.search});
  final int? count;
  final Widget Function(String query) search;
  @override
  State<DtcLibraryCard> createState() => _DtcLibraryCardState();
}

class _DtcLibraryCardState extends State<DtcLibraryCard> {
  String _q = '';
  @override
  Widget build(BuildContext context) => InfoCard(
        title: 'Code library${widget.count == null ? '' : ' (${widget.count} codes)'}',
        icon: Icons.menu_book_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
              'Look up any code, for example P0171, or search a word such as misfire. Descriptions are our own generic '
              'interpretations. Codes not in the library are shown as unknown; the app never guesses a meaning.',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextField(
            key: const Key('dtc-search'),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Code or keyword', border: OutlineInputBorder()),
            onChanged: (v) => setState(() => _q = v.trim()),
          ),
          if (_q.length >= 2) widget.search(_q),
        ]),
      );
}
