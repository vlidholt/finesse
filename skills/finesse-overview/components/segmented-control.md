# Segmented Control

Picks one of a few values that are all in view: a filled strip with a raised thumb on the chosen segment. It is controlled with `value` and `onChanged`, and announced as a group of radio buttons. To show one of several views, use `Tabs` or a `TabBar`, which look the same and mean something else; where none or several can be on, use a `ToggleGroup`.

## Default

The thumb is one shape that slides to the chosen segment on the theme's `Motion.snappy`. The control is one stop for the Tab key; the arrow keys, Home and End change the value. On a touch screen, drag along the strip and the thumb follows the finger.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

enum Density { compact, comfortable, spacious }

/// Picks one value of a few. The thumb slides to the chosen segment; on a
/// touch screen a finger dragged along the strip takes it along.
class SegmentedControlBasicExample extends StatefulWidget {
  const SegmentedControlBasicExample({super.key});

  @override
  State<SegmentedControlBasicExample> createState() =>
      _SegmentedControlBasicExampleState();
}

class _SegmentedControlBasicExampleState
    extends State<SegmentedControlBasicExample> {
  Density density = Density.comfortable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.layoutTheme.gap(GapSize.lg),
      children: [
        // The group's name, for a screen reader: the segments are its
        // radio buttons.
        Semantics(
          label: 'Density',
          container: true,
          child: SegmentedControl<Density>(
            value: density,
            onChanged: (value) => setState(() => density = value),
            segments: const [
              Segment(value: Density.compact, label: Text('Compact')),
              Segment(value: Density.comfortable, label: Text('Comfortable')),
              Segment(value: Density.spacious, label: Text('Spacious')),
            ],
          ),
        ),
        Text('Rows are ${density.name}.', style: theme.textTheme.muted),
      ],
    );
  }
}
```

## Icons

A `Segment` has a `label`, an `icon` or both. Give an icon on its own a `semanticLabel` and a `tooltip`.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Segments with an icon, on its own or before a label. An icon on its own
/// is named by `semanticLabel` for a screen reader and by `tooltip` for a
/// pointer.
class SegmentedControlIconsExample extends StatefulWidget {
  const SegmentedControlIconsExample({super.key});

  @override
  State<SegmentedControlIconsExample> createState() =>
      _SegmentedControlIconsExampleState();
}

class _SegmentedControlIconsExampleState
    extends State<SegmentedControlIconsExample> {
  String layout = 'list';
  ThemeMode mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.layoutTheme.gap(GapSize.lg),
      children: [
        Semantics(
          label: 'Layout',
          container: true,
          child: SegmentedControl<String>(
            value: layout,
            onChanged: (value) => setState(() => layout = value),
            segments: const [
              Segment(
                value: 'list',
                icon: PhosphorIcon(PhosphorIconsRegular.listBullets),
                semanticLabel: 'List',
                tooltip: 'List',
              ),
              Segment(
                value: 'grid',
                icon: PhosphorIcon(PhosphorIconsRegular.squaresFour),
                semanticLabel: 'Grid',
                tooltip: 'Grid',
              ),
              Segment(
                value: 'board',
                icon: PhosphorIcon(PhosphorIconsRegular.kanban),
                semanticLabel: 'Board',
                tooltip: 'Board',
              ),
            ],
          ),
        ),
        Semantics(
          label: 'Appearance',
          container: true,
          child: SegmentedControl<ThemeMode>(
            value: mode,
            onChanged: (value) => setState(() => mode = value),
            segments: const [
              Segment(
                value: ThemeMode.light,
                icon: PhosphorIcon(PhosphorIconsRegular.sun),
                label: Text('Light'),
              ),
              Segment(
                value: ThemeMode.dark,
                icon: PhosphorIcon(PhosphorIconsRegular.moon),
                label: Text('Dark'),
              ),
              Segment(
                value: ThemeMode.system,
                icon: PhosphorIcon(PhosphorIconsRegular.desktop),
                label: Text('System'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

## Expanded and disabled

By default the control is as wide as its segments. `expand` shares the width between them, the usual arrangement on a phone. A label that does not fit its segment ends in an ellipsis.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// With `expand` the segments share the width, as they do across a phone.
/// A segment can be disabled on its own, and the whole control with
/// `enabled: false`.
class SegmentedControlExpandedExample extends StatefulWidget {
  const SegmentedControlExpandedExample({super.key});

  @override
  State<SegmentedControlExpandedExample> createState() =>
      _SegmentedControlExpandedExampleState();
}

class _SegmentedControlExpandedExampleState
    extends State<SegmentedControlExpandedExample> {
  String plan = 'monthly';
  bool locked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: theme.layoutTheme.gap(GapSize.lg),
        children: [
          Semantics(
            label: 'Billing period',
            container: true,
            child: SegmentedControl<String>(
              expand: true,
              enabled: !locked,
              value: plan,
              onChanged: (value) => setState(() => plan = value),
              segments: const [
                Segment(value: 'monthly', label: Text('Monthly')),
                Segment(value: 'yearly', label: Text('Yearly')),
                // Not on offer yet.
                Segment(
                  value: 'lifetime',
                  label: Text('Lifetime'),
                  enabled: false,
                ),
              ],
            ),
          ),
          Switch(
            value: locked,
            onChanged: (value) => setState(() => locked = value),
            label: const Text('Lock the choice'),
          ),
        ],
      ),
    );
  }
}
```
