import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Chips that can be removed: `onDeleted` adds a cross that is a target of
/// its own, so the chip itself can still do something else. Backspace and
/// Delete on a focused chip remove it too.
class ChipRemovableExample extends StatefulWidget {
  const ChipRemovableExample({super.key});

  @override
  State<ChipRemovableExample> createState() => _ChipRemovableExampleState();
}

class _ChipRemovableExampleState extends State<ChipRemovableExample> {
  static const _all = ['Product design', 'Copenhagen', 'Remote', 'Senior'];

  late final terms = [..._all];
  String? opened;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UnaColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.md,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final term in terms)
              Chip(
                label: Text(term),
                onPressed: () => setState(() => opened = term),
                onDeleted: () => setState(() => terms.remove(term)),
                deleteSemanticLabel: 'Remove $term',
              ),
            if (terms.length < _all.length)
              Chip(
                label: const Text('Reset'),
                leading: const PhosphorIcon(
                  PhosphorIconsRegular.arrowCounterClockwise,
                ),
                variant: ChipVariant.dashed,
                onPressed: () => setState(
                  () => terms
                    ..clear()
                    ..addAll(_all),
                ),
              ),
          ],
        ),
        Text(
          opened == null ? 'Tap a chip, or its cross' : 'Opened "$opened"',
          style: theme.textTheme.muted,
        ),
      ],
    );
  }
}
