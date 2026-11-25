# Layout and spacing

Space between things comes from the theme: a scale of five named gaps that follows the form factor, and a spacing step for everything measured in units.

## Name the relationship, not the pixel count

A layout rarely means "16 pixels". It means "these are two cards" or "this label belongs to that icon". `GapSize` names those relationships, and the theme decides what each one measures:

| `GapSize` | Between | Desktop | Phone |
| --- | --- | --- | --- |
| `xs` | an icon and its label | 4 | 4 |
| `sm` | related controls | 8 | 8 |
| `md` | the rows of a group | 12 | 12 |
| `lg` | cards and sections | 16 | 12 |
| `xl` | the columns of a page | 24 | 16 |

Because the name is resolved against the theme, the same line of code yields 16 in a desktop window and 12 on a phone. Nothing in the layout checks which it is in (see [form-factors.md](form-factors.md)). Prefer a named gap to `SizedBox(height: 16)` anywhere the space is between components.

## Using the scale

`FinesseRow` and `FinesseColumn` take a `gap` and put it between every child. In a plain `Row` or `Column`, where only some children need space between them, use a `Gap`: `Gap.xs()` to `Gap.xl()`, or `Gap.size(size)` for a step held in a variable. A `Gap` sizes itself along whichever axis its flex runs.

```dart
FinesseColumn(
  gap: GapSize.lg, // 16 on a desktop, 12 on a phone
  children: [
    const ProfileCard(),
    const ActivityCard(),
  ],
)

Row(
  children: [
    const Icon(PhosphorIconsRegular.mapPin),
    const Gap.xs(),
    const Text('Copenhagen'),
    const Gap.md(),
    const Text('Hybrid'),
  ],
)
```

`FinesseRow` and `FinesseColumn` otherwise take what `Row` and `Column` take; `gap` wins over `spacing` when both are given. A full card:

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A card laid out entirely with named gaps: `lg` between its sections,
/// `sm` between related controls, `xs` between an icon and its label.
class LayoutNamedGapsExample extends StatelessWidget {
  const LayoutNamedGapsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Card(
        child: FinesseColumn(
          gap: GapSize.lg,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Senior product designer', style: theme.textTheme.large),
                // One odd gap in a plain Column: reach for `Gap`.
                const Gap.xs(),
                FinesseRow(
                  gap: GapSize.xs,
                  children: [
                    Icon(
                      PhosphorIconsRegular.mapPin,
                      size: 16,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    Text('Copenhagen', style: theme.textTheme.muted),
                  ],
                ),
              ],
            ),
            const Divider(margin: EdgeInsets.zero),
            FinesseRow(
              gap: GapSize.sm,
              children: [
                Expanded(
                  child: Button(onPressed: () {}, child: const Text('Apply')),
                ),
                Button.outline(onPressed: () {}, child: const Text('Save')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## The layout theme

The scale lives on `ThemeData.layoutTheme`, a `LayoutTheme`, together with the page margins and the page width. The style fills it in for the current form factor. Read it for a value the layout widgets do not cover, and override it like any other component theme:

```dart
// Reading: padding that matches the gap between cards.
final layout = Theme.of(context).layoutTheme;
EdgeInsets.all(layout.gap(GapSize.lg));

// Overriding: a roomier app.
ThemeData(
  layoutTheme: const LayoutTheme(
    gapLg: 20,
    gapXl: 32,
    pageMaxWidth: 1120,
  ),
)
```

An override on `ThemeData.layoutTheme` applies to both form factors. To change the scale for one only, set the style's tokens instead: `gapLg` and `gapXl` on `StyleTokens`, and on its `mobile` counterpart.

## Page margins

`PageContainer` is the gap scale's counterpart for a whole page: it applies `layoutTheme.pagePadding` (24 on a desktop, 16 on a phone), caps the content at `pageMaxWidth` (1280) and centres it. An `AppBar` caps its content to match, so the bar and the page line up. The safe area, which inside a `Scaffold` includes the bars, is added to the padding.

```dart
Scaffold(
  appBar: const AppBar(title: Text('Jobs')),
  body: PageContainer(
    scrollable: true,
    child: FinesseColumn(gap: GapSize.lg, children: sections),
  ),
)
```

See [page-container.md](../components/page-container.md).

## Spacing steps

The second scale is numeric. `ThemeData.spacing` is one step, 4 logical pixels by default, and `spacing: 3`, `Gap(2)` and `FinessePadding.all(4)` are multiples of it. Steps do not follow the form factor. They rescale together when the step changes (`ThemeData(spacing: const Spacing(step: 5))`), and the named gaps scale with them. Use steps for the inside of a component, where a design gives a specific measure, and the named gaps for the space between components. `Gap.raw(10)` bypasses both scales, for a value that is deliberately off them.

### Row and column spacing

`FinesseRow` and `FinesseColumn` accept a `spacing` argument in theme steps.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// `FinesseRow` and `FinesseColumn` accept a `spacing` argument in theme steps.
class LayoutSpacingExample extends StatelessWidget {
  const LayoutSpacingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FinesseColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Card(
          child: FinesseRow(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              for (final label in ['One', 'Two', 'Three'])
                Badge.secondary(child: Text(label)),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Card(
            child: FinesseColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              spacing: 3,
              children: [
                const TextField(placeholder: Text('Email')),
                const TextField(placeholder: Text('Password')),
                Button(onPressed: () {}, child: const Text('Sign in')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

### Gaps in steps

`Gap(2)` is two steps.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// `Gap` inserts space along the flex axis in spacing steps.
class LayoutGapExample extends StatelessWidget {
  const LayoutGapExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Account', style: theme.textTheme.h4),
            const Gap(1),
            Text(
              'Manage your profile and security settings.',
              style: theme.textTheme.muted,
            ),
            const Gap(4),
            Button.outline(
              onPressed: () {},
              child: const Text('Open settings'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Padding

`FinessePadding` takes steps, not pixels. It has no plain constructor, only `.all`, `.symmetric`, `.only`, and `.directional`; `symmetric(horizontal: 6, vertical: 4)` is 24 by 16 at the default step.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// `FinessePadding` takes theme spacing steps, not logical pixels.
class LayoutPaddingExample extends StatelessWidget {
  const LayoutPaddingExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return ColoredBox(
      color: theme.colorScheme.muted,
      child: FinessePadding.symmetric(
        horizontal: 6,
        vertical: 4,
        child: Card(
          child: Text(
            'Inset by ${spacing(6)} x ${spacing(4)}',
            style: theme.textTheme.small,
          ),
        ),
      ),
    );
  }
}
```

## Card sections and form actions

`FinesseColumn` with `crossAxisAlignment: stretch` lines up full-width children inside a card, with `Divider` between groups. The same pattern stacks fields and buttons in a form: put the primary action above an outline cancel. See `example/lib/docs/examples/layout/layout_card_sections.dart` and `layout_form_actions.dart` for the full examples.
