# Rating

A row of stars that shows a rating, and takes one when it is given `onChanged`. A tap or a drag rates, a mouse previews, the arrow keys adjust, and assistive technology sees a slider.

## Give a rating

Controlled: `value` and `onChanged`.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A rating that can be given. Tap a star, drag across them, hover with a
/// mouse to preview, or focus it and use the arrow keys.
class RatingBasicExample extends StatefulWidget {
  const RatingBasicExample({super.key});

  @override
  State<RatingBasicExample> createState() => _RatingBasicExampleState();
}

class _RatingBasicExampleState extends State<RatingBasicExample> {
  static const _words = ['Not rated', 'Poor', 'Fair', 'Good', 'Great', 'Loved'];

  double stars = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FinesseColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.sm,
      children: [
        Rating(
          semanticLabel: 'Your rating',
          value: stars,
          onChanged: (value) => setState(() => stars = value),
        ),
        Text(_words[stars.round()], style: theme.textTheme.muted),
      ],
    );
  }
}
```

## Read-only, halves and other icons

Read-only without `onChanged`. `allowHalf`, `count`, `size`, `color`, `icon` and `selectedIcon` shape it.

```dart
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
```

