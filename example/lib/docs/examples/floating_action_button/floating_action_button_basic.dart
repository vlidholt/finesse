import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The three variants, each with a label and without. Without a label the
/// button needs a `semanticLabel`.
class FloatingActionButtonBasicExample extends StatelessWidget {
  const FloatingActionButtonBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FinesseColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.lg,
      children: [
        for (final variant in FloatingActionButtonVariant.values)
          FinesseRow(
            mainAxisSize: MainAxisSize.min,
            gap: GapSize.lg,
            children: [
              FloatingActionButton(
                icon: const PhosphorIcon(PhosphorIconsRegular.pencilSimple),
                label: const Text('Compose'),
                variant: variant,
                onPressed: () {},
              ),
              FloatingActionButton(
                icon: const PhosphorIcon(PhosphorIconsRegular.pencilSimple),
                semanticLabel: 'Compose',
                variant: variant,
                onPressed: () {},
              ),
            ],
          ),
      ],
    );
  }
}
