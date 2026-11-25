# Chip

A compact pill for a filter, a choice or a tag. With `onSelected` it toggles, with `onPressed` it is a button, and with neither it is a static tag. Its height follows the form factor. `onDeleted` adds a cross that removes it, `showCheckmark` a check while it is selected, and `ChipGroup` holds the set of chosen chips.

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
            leading: PhosphorIcon(icon),
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
              leading: PhosphorIcon(PhosphorIconsRegular.buildings),
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
              leading: const PhosphorIcon(PhosphorIconsRegular.plus),
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

`onDeleted` adds a cross with its own target and its own name for assistive technology (`deleteSemanticLabel`). Backspace or Delete on the focused chip removes it as well.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
    return FinesseColumn(
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
```

## A group

`ChipGroup` is controlled: `values` is the chosen set and `onChanged` reports the set a tap would make. It is one Tab stop; the arrow keys, Home and End move between its chips. `showCheckmark` marks the chosen ones.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// `ChipGroup` holds the set of chosen chips. Here any number may be
/// chosen and each one shows a check; the arrow keys move between chips.
class ChipGroupExample extends StatefulWidget {
  const ChipGroupExample({super.key});

  @override
  State<ChipGroupExample> createState() => _ChipGroupExampleState();
}

class _ChipGroupExampleState extends State<ChipGroupExample> {
  static const _toppings = [
    'Mozzarella',
    'Basil',
    'Mushrooms',
    'Olives',
    'Artichoke',
    'Anchovies',
    'Chili',
  ];

  Set<String> chosen = {'Mozzarella', 'Basil'};

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: ChipGroup<String>(
        semanticLabel: 'Toppings',
        values: chosen,
        onChanged: (values) => setState(() => chosen = values),
        showCheckmark: true,
        alignment: WrapAlignment.center,
        items: [
          for (final topping in _toppings)
            ChipGroupItem(
              value: topping,
              label: Text(topping),
              enabled: topping != 'Anchovies',
            ),
        ],
      ),
    );
  }
}
```

## A scrolling filter bar

`wrap: false` keeps the chips on one row that scrolls and fades at an edge it continues beyond. `multiple: false` with `allowEmpty: false` makes it a choice of exactly one. Give the page's margin as `padding` so the chips scroll to the screen's edge. `leading` and `trailing` hold an action beside the chips — here the order — that stays put while they scroll.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A filter bar: one row that scrolls sideways and fades where it goes on,
/// as above a list on a phone. One chip at a time, and never none; the
/// order is an action held at the start while the chips scroll past.
class ChipGroupScrollExample extends StatefulWidget {
  const ChipGroupScrollExample({super.key});

  @override
  State<ChipGroupScrollExample> createState() => _ChipGroupScrollExampleState();
}

class _ChipGroupScrollExampleState extends State<ChipGroupScrollExample> {
  static const _filters = {
    'All': PhosphorIconsRegular.squaresFour,
    'Unread': PhosphorIconsRegular.envelopeSimple,
    'Mentions': PhosphorIconsRegular.at,
    'Following': PhosphorIconsRegular.userCheck,
    'Jobs': PhosphorIconsRegular.briefcase,
    'Events': PhosphorIconsRegular.calendarDots,
    'Archived': PhosphorIconsRegular.archive,
  };

  String filter = 'All';
  bool newestFirst = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: ChipGroup<String>(
        semanticLabel: 'Show',
        values: {filter},
        onChanged: (values) => setState(() => filter = values.single),
        multiple: false,
        allowEmpty: false,
        wrap: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Chip(
            leading: PhosphorIcon(
              newestFirst
                  ? PhosphorIconsRegular.sortDescending
                  : PhosphorIconsRegular.sortAscending,
            ),
            label: Text(newestFirst ? 'Newest' : 'Oldest'),
            onPressed: () => setState(() => newestFirst = !newestFirst),
          ),
        ),
        items: [
          for (final MapEntry(key: name, value: icon) in _filters.entries)
            ChipGroupItem(
              value: name,
              label: Text(name),
              leading: PhosphorIcon(icon),
            ),
        ],
      ),
    );
  }
}
```
