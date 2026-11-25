import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A filter bar: one row that scrolls sideways and fades where it goes on,
/// as above a list on a phone. One chip at a time, and never none.
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

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: ChipGroup<String>(
        semanticLabel: 'Show',
        values: {filter},
        onChanged: (values) => setState(() => filter = values.single),
        multiple: false,
        allowEmpty: false,
        wrap: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
