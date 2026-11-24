# Chip

A compact pill for a filter, a choice or a tag. With `onSelected` it toggles, with `onPressed` it is a button, and with neither it is a static tag. Its height follows the form factor.

## Filters

`onSelected` is called with the opposite of `selected`; the caller keeps the state.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Filter chips. Each one toggles on its own; a selected chip takes the
/// theme's accent fill, text and outline.
class ChipFiltersExample extends StatefulWidget {
  const ChipFiltersExample({super.key});

  @override
  State<ChipFiltersExample> createState() => _ChipFiltersExampleState();
}

class _ChipFiltersExampleState extends State<ChipFiltersExample> {
  static const _filters = {
    'Remote': PhosphorIconsRegular.globeHemisphereWest,
    'Full-time': PhosphorIconsRegular.briefcase,
    'Design': PhosphorIconsRegular.penNib,
    'Senior': PhosphorIconsRegular.medal,
    'Saved': PhosphorIconsRegular.bookmarkSimple,
  };

  final selected = {'Remote', 'Design'};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final MapEntry(key: label, value: icon) in _filters.entries)
          Chip(
            label: Text(label),
            leading: Icon(icon),
            selected: selected.contains(label),
            onSelected: (value) => setState(
              () => value ? selected.add(label) : selected.remove(label),
            ),
          ),
      ],
    );
  }
}
```

## Variants

`ChipVariant.outline` is the default. `soft` is a muted fill for read-only tags, and `dashed` marks something absent or suggested.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The three outlines. With no callback a chip is a static tag, not a
/// control, and is not announced as a button.
class ChipVariantsExample extends StatelessWidget {
  const ChipVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget row(String name, List<Widget> chips) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(name, style: theme.textTheme.muted),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          row('Outline', const [
            Chip(label: Text('Copenhagen')),
            Chip(
              label: Text('Hybrid'),
              leading: Icon(PhosphorIconsRegular.buildings),
            ),
          ]),
          // Soft: read-only tags, such as a person's skills.
          row('Soft', const [
            Chip(label: Text('Design systems'), variant: ChipVariant.soft),
            Chip(label: Text('Prototyping'), variant: ChipVariant.soft),
            Chip(label: Text('Research'), variant: ChipVariant.soft),
          ]),
          // Dashed: something absent or suggested.
          row('Dashed', [
            Chip(
              label: const Text('Add a skill'),
              leading: const Icon(PhosphorIconsRegular.plus),
              variant: ChipVariant.dashed,
              onPressed: () {},
            ),
            const Chip(
              label: Text('Accessibility'),
              variant: ChipVariant.dashed,
            ),
          ]),
        ],
      ),
    );
  }
}
```

## Removable

A trailing icon and `onPressed`. Give an icon-led action a `semanticLabel` that says what the tap does.

```dart
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
```

