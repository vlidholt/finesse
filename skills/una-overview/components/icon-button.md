# Icon Button

A square button holding a single icon. It is a `Button` in the square sizes, with the name an icon-only control needs.

## Variants

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class IconButtonTooltipExample extends StatelessWidget {
  const IconButtonTooltipExample({super.key});

  @override
  Widget build(BuildContext context) {
    // The tooltip names the button: on hover, on focus, on a long press,
    // and to a screen reader.
    return UnaRow(
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

## Sizes and style

`size` takes the three button sizes and reads them as the theme's square ones, which size the glyph on their own. Anything else is the `style`, the same `ButtonTheme` a `Button` takes: its width, height, padding and icon size replace the size's.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class IconButtonSizesExample extends StatelessWidget {
  const IconButtonSizesExample({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton.outline(
          size: ButtonSize.sm,
          tooltip: 'Add',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.plus),
        ),
        IconButton.outline(
          tooltip: 'Add',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.plus),
        ),
        IconButton.outline(
          size: ButtonSize.lg,
          tooltip: 'Add',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.plus),
        ),
        // Anything else is the style: a small, quiet close button.
        IconButton.ghost(
          style: ButtonTheme(
            width: 24,
            height: 24,
            iconSize: 14,
            foregroundColor: scheme.mutedForeground,
            hoverForegroundColor: scheme.foreground,
          ),
          tooltip: 'Close',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.x),
        ),
      ],
    );
  }
}
```
