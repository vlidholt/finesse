# Surface

The popover and menu chrome as a widget, for floating UI finesse has no component for, and a popover anchored to any rectangle.

## Popover and menu surfaces

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The popover and menu surfaces, around any widget: for floating UI that
/// finesse has no component for.
class SurfaceBasicExample extends StatelessWidget {
  const SurfaceBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        Surface(
          child: SizedBox(
            width: 200,
            child: Text(
              'A popover surface: the outline, radius, padding and shadow '
              'of Popover.',
              style: theme.textTheme.small,
            ),
          ),
        ),
        Surface(
          kind: SurfaceKind.menu,
          child: SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final label in ['Cut', 'Copy', 'Paste'])
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Text(label, style: theme.textTheme.small),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

## Anchored to a rectangle

showPopover takes a global Rect: a text selection, a table cell, a point on a canvas. With showArrow, an arrow points at it.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// showPopover anchors a popover to a rectangle rather than a widget:
/// here, wherever the canvas was clicked, with an arrow pointing at it.
class SurfaceAnchoredExample extends StatelessWidget {
  const SurfaceAnchoredExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapUp: (details) => showPopover<void>(
        context: context,
        anchorRect: Rect.fromCenter(
          center: details.globalPosition,
          width: 1,
          height: 1,
        ),
        showArrow: true,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text('Point', style: theme.textTheme.small),
            Text(
              '${details.localPosition.dx.round()}, '
              '${details.localPosition.dy.round()}',
              style: theme.textTheme.muted,
            ),
          ],
        ),
      ),
      child: Container(
        width: 320,
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.muted,
          borderRadius: theme.radius,
        ),
        child: Text('Click anywhere', style: theme.textTheme.muted),
      ),
    );
  }
}
```
