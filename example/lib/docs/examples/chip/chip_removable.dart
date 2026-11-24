import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Chips as buttons: `onPressed` instead of `onSelected`, with a trailing
/// icon that says what the tap does.
class ChipRemovableExample extends StatefulWidget {
  const ChipRemovableExample({super.key});

  @override
  State<ChipRemovableExample> createState() => _ChipRemovableExampleState();
}

class _ChipRemovableExampleState extends State<ChipRemovableExample> {
  static const _all = ['Product design', 'Copenhagen', 'Remote', 'Senior'];

  late final terms = [..._all];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final term in terms)
          Chip(
            label: Text(term),
            trailing: const Icon(PhosphorIconsRegular.x),
            semanticLabel: 'Remove $term',
            onPressed: () => setState(() => terms.remove(term)),
          ),
        if (terms.length < _all.length)
          Chip(
            label: const Text('Reset'),
            leading: const Icon(PhosphorIconsRegular.arrowCounterClockwise),
            variant: ChipVariant.dashed,
            onPressed: () => setState(
              () => terms
                ..clear()
                ..addAll(_all),
            ),
          ),
      ],
    );
  }
}
