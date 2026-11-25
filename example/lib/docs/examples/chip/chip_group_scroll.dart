import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A filter bar: one row that scrolls sideways and fades where it goes on,
/// as above a list on a phone. One chip at a time, and never none; the
/// order is an action held at the start while the chips scroll past.
class ChipGroupScrollExample extends StatefulWidget {
  const ChipGroupScrollExample({super.key});

  @override
  State<ChipGroupScrollExample> createState() => _ChipGroupScrollExampleState();
}

class _ChipGroupScrollExampleState extends State<ChipGroupScrollExample> {
  static const _filters = {
    'All': PhosphorIconsRegular.squaresFour,
    'Unread': PhosphorIconsRegular.envelopeSimple,
    'Mentions': PhosphorIconsRegular.at,
    'Following': PhosphorIconsRegular.userCheck,
    'Jobs': PhosphorIconsRegular.briefcase,
    'Events': PhosphorIconsRegular.calendarDots,
    'Archived': PhosphorIconsRegular.archive,
  };

  String filter = 'All';
  bool newestFirst = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: ChipGroup<String>(
        semanticLabel: 'Show',
        value: filter,
        onChanged: (value) => setState(() => filter = value!),
        allowDeselection: false,
        wrap: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Chip(
            leading: PhosphorIcon(
              newestFirst
                  ? PhosphorIconsRegular.sortDescending
                  : PhosphorIconsRegular.sortAscending,
            ),
            label: Text(newestFirst ? 'Newest' : 'Oldest'),
            onPressed: () => setState(() => newestFirst = !newestFirst),
          ),
        ),
        items: [
          for (final MapEntry(key: name, value: icon) in _filters.entries)
            ChipGroupItem(
              value: name,
              label: Text(name),
              leading: PhosphorIcon(icon),
            ),
        ],
      ),
    );
  }
}
