import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Filter chips. Each one toggles on its own; a selected chip takes the
/// theme's accent fill, text and outline.
class ChipFiltersExample extends StatefulWidget {
  const ChipFiltersExample({super.key});

  @override
  State<ChipFiltersExample> createState() => _ChipFiltersExampleState();
}

class _ChipFiltersExampleState extends State<ChipFiltersExample> {
  static const _filters = {
    'Remote': PhosphorIconsRegular.globeHemisphereWest,
    'Full-time': PhosphorIconsRegular.briefcase,
    'Design': PhosphorIconsRegular.penNib,
    'Senior': PhosphorIconsRegular.medal,
    'Saved': PhosphorIconsRegular.bookmarkSimple,
  };

  final selected = {'Remote', 'Design'};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final MapEntry(key: label, value: icon) in _filters.entries)
          Chip(
            label: Text(label),
            leading: Icon(icon),
            selected: selected.contains(label),
            onSelected: (value) => setState(
              () => value ? selected.add(label) : selected.remove(label),
            ),
          ),
      ],
    );
  }
}
