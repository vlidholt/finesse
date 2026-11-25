import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Without `onChanged` a rating only shows a value, exactly: 4.3 fills
/// the fifth star by a third. `allowHalf` rates in halves, and the icons,
/// their size, colour and number are the caller's.
class RatingVariantsExample extends StatefulWidget {
  const RatingVariantsExample({super.key});

  @override
  State<RatingVariantsExample> createState() => _RatingVariantsExampleState();
}

class _RatingVariantsExampleState extends State<RatingVariantsExample> {
  double halves = 2.5;
  double hearts = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FinesseColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.md,
      children: [
        FinesseRow(
          mainAxisSize: MainAxisSize.min,
          gap: GapSize.sm,
          children: [
            const Rating(value: 4.3, size: 16, semanticLabel: 'Average'),
            Text('4.3 · 1,284 reviews', style: theme.textTheme.muted),
          ],
        ),
        Rating(
          semanticLabel: 'In halves',
          value: halves,
          allowHalf: true,
          onChanged: (value) => setState(() => halves = value),
        ),
        Rating(
          semanticLabel: 'Hearts',
          value: hearts,
          count: 3,
          size: 28,
          color: theme.colorScheme.destructive,
          icon: const PhosphorIcon(PhosphorIconsRegular.heart),
          selectedIcon: const PhosphorIcon(PhosphorIconsFill.heart),
          onChanged: (value) => setState(() => hearts = value),
        ),
      ],
    );
  }
}
