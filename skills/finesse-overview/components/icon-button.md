# Icon Button

A square button holding a single icon.

## Variants

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class IconButtonVariantsExample extends StatelessWidget {
  const IconButtonVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        IconButton(
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.rocket),
        ),
        IconButton.secondary(
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.rocket),
        ),
        IconButton.destructive(
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.rocket),
        ),
        IconButton.outline(
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.rocket),
        ),
        IconButton.ghost(
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.rocket),
        ),
      ],
    );
  }
}
```

## With a tooltip

An icon alone says little. `tooltip` names the button on hover, on keyboard focus and on a long press, and is what a screen reader calls it unless `semanticLabel` says otherwise. `loading` swaps the icon for a spinner, as on `Button`.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class IconButtonTooltipExample extends StatelessWidget {
  const IconButtonTooltipExample({super.key});

  @override
  Widget build(BuildContext context) {
    // The tooltip names the button: on hover, on focus, on a long press,
    // and to a screen reader.
    return FinesseRow(
      gap: GapSize.xs,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.ghost(
          tooltip: 'Reply',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.arrowBendUpLeft),
        ),
        IconButton.ghost(
          tooltip: 'Archive',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.archive),
        ),
        IconButton.ghost(
          tooltip: 'Move to trash',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.trash),
        ),
      ],
    );
  }
}
```

