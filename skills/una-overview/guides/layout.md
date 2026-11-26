# Layout and spacing

Space between things comes from the theme: a scale of five named gaps that
follows the form factor, and a spacing step for everything measured in units.

## Name the relationship, not the pixel count

A layout rarely means "16 pixels". It means "these are two cards" or "this label
belongs to that icon". `GapSize` names those relationships, and the theme
decides what each one measures:

| `GapSize` | Between | Desktop | Phone |
| --- | --- | --- | --- |
| `xs` | an icon and its label | 4 | 4 |
| `sm` | related controls | 8 | 8 |
| `md` | the rows of a group | 12 | 12 |
| `lg` | cards and sections | 16 | 12 |
| `xl` | the columns of a page | 24 | 16 |

Because the name is resolved against the theme, the same line of code yields 16
in a desktop window and 12 on a phone. Nothing in the layout checks which it is
in (see [form-factors.md](form-factors.md)). Prefer a named gap to
`SizedBox(height: 16)` anywhere the space is between components.

## Using the scale

`UnaRow` and `UnaColumn` take a `gap` and put it between every child. In
a plain `Row` or `Column`, where only some children need space between them, use
a `Gap`: `Gap.xs()` to `Gap.xl()`, or `Gap.size(size)` for a step held in a
variable. A `Gap` sizes itself along whichever axis its flex runs.

```dart
const cards = UnaColumn(
  gap: GapSize.lg, // 16 on a desktop, 12 on a phone
  children: [
    Card(title: Text('Profile')),
    Card(title: Text('Activity')),
  ],
);

const place = Row(
  children: [
    PhosphorIcon(PhosphorIconsRegular.mapPin),
    Gap.xs(),
    Text('Copenhagen'),
    Gap.md(),
    Text('Hybrid'),
  ],
);
```

`UnaRow` and `UnaColumn` otherwise take what `Row` and `Column` take;
`gap` wins over `spacing` when both are given. A full card:

```dart
import 'package:una/una.dart';
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
        child: UnaColumn(
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
                UnaRow(
                  gap: GapSize.xs,
                  children: [
                    PhosphorIcon(
                      PhosphorIconsRegular.mapPin,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    Text('Copenhagen', style: theme.textTheme.muted),
                  ],
                ),
              ],
            ),
            const Divider(margin: EdgeInsets.zero),
            UnaRow(
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

The scale lives on `ThemeData.layoutTheme`, a `LayoutTheme`, together with the
page margins and the page width. The style fills it in for the current form
factor. Read it for a value the layout widgets do not cover, and override it
like any other component theme:

```dart
// Reading: padding that matches the gap between cards.
final layout = Theme.of(context).layoutTheme;
final inset = EdgeInsets.all(layout.gap(GapSize.lg));

// Overriding: a roomier app.
final roomy = ThemeData(
  layoutTheme: const LayoutTheme(
    gapLg: 20,
    gapXl: 32,
    pageMaxWidth: 1120,
  ),
);
```

`layoutTheme.gap(GapSize.x)` is how a padding, a `Wrap`'s `spacing` or a
`Row`'s `spacing` stays on the scale: `EdgeInsets.only(top:
layout.gap(GapSize.xs))`, `Wrap(spacing: layout.gap(GapSize.sm), ...)`.
`ThemeData` itself has no `gap` method; an app that reaches for it often
adds a one-line extension (`double gap(GapSize s) => layoutTheme.gap(s);`
on `ThemeData`), as the Demo app does.

An override on `ThemeData.layoutTheme` applies to both form factors. To change
the scale for one only, set the style's tokens instead: `gapLg` and `gapXl` on
`StyleTokens`, and on its `mobile` counterpart.

## Page margins

`PageContainer` is the gap scale's counterpart for a whole page: it applies
`layoutTheme.pagePadding` (24 on a desktop, 16 on a phone), caps the content at
`pageMaxWidth` (1280) and centres it. An `AppBar` caps its content to match, so
the bar and the page line up. The safe area, which inside a `Scaffold` includes
the bars, is added to the padding.

```dart
const jobs = Scaffold(
  appBar: AppBar(title: Text('Jobs')),
  body: PageContainer(
    scrollable: true,
    child: UnaColumn(
      gap: GapSize.lg,
      children: [Card(title: Text('Recommended')), Card(title: Text('Saved'))],
    ),
  ),
);
```

A page of a few cards scrolls with `scrollable: true`, and the page is a
layer of its own, so scrolling repaints nothing. A long feed is a lazy
list instead (a `ListView.builder` or slivers) with the same margins:
`PageContainer` is the margins, a builder is the feed.

- `PageContainer(maxWidth: 1200)` centres a page narrower than the app
  bar (a profile, a form); `PageContainer(padding: ...)` replaces the page
  margins, and the safe area is still added.
- **A strip that runs to the screen edge** (a filter bar of chips that
  scrolls sideways on a phone, a row of stories) cannot live inside the
  side margins. Give the page only its vertical margins and let every
  other child take the side margins itself:

```dart
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final margin = (theme.layoutTheme.pagePadding ?? EdgeInsets.zero)
      .resolve(Directionality.of(context));
  Widget inset(Widget child) => Padding(
    padding: EdgeInsets.only(left: margin.left, right: margin.right),
    child: child,
  );
  return PageContainer(
    scrollable: true,
    padding: EdgeInsets.only(top: margin.top, bottom: margin.bottom),
    child: UnaColumn(
      gap: GapSize.lg,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        inset(Text('Jobs', style: theme.textTheme.h1)),
        ChipGroup<String>(
          value: _filter,
          onChanged: (value) => setState(() => _filter = value!),
          allowDeselection: false,
          wrap: false, // one row that scrolls, fading at its edges
          padding: EdgeInsets.symmetric(horizontal: margin.left),
          items: const [
            ChipGroupItem(value: 'all', label: Text('All')),
            ChipGroupItem(value: 'remote', label: Text('Remote')),
            ChipGroupItem(value: 'hybrid', label: Text('Hybrid')),
          ],
        ),
        inset(const Card(title: Text('Results'))),
      ],
    ),
  );
}
```

See [page-container.md](../components/page-container.md).

## Columns that fit the window

On a desktop, decide how many columns fit from the width the page
actually has, not from the form factor, so a window between 800 and 1200
wide degrades column by column. Read it with a `LayoutBuilder` inside the
`PageContainer`, put `GapSize.xl` between the columns and `GapSize.lg`
between the cards in each:

```dart
PageContainer(
  scrollable: true,
  child: LayoutBuilder(
    builder: (context, constraints) {
      final columnGap = Theme.of(context).layoutTheme.gap(GapSize.xl);
      const railWidth = 320.0;
      final main = UnaColumn(
        gap: GapSize.lg,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: posts,
      );
      if (constraints.maxWidth < 560 + columnGap + railWidth) {
        return main; // the rail drops away (or moves under the feed)
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: columnGap,
        children: [
          Expanded(child: main),
          SizedBox(
            width: railWidth,
            child: UnaColumn(
              gap: GapSize.lg,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: sideCards,
            ),
          ),
        ],
      );
    },
  ),
)
```

A column's *width* is a design value (a 320-point rail) and can be a
constant; the space between things never is. Key columns that come and go
(`ValueKey`), so the one that stays keeps its state. The phone layout of
the same screen is usually a different widget under `FormFactorBuilder`
([form-factors.md](form-factors.md)).

## Inside a card

A `Card` already pads its content with `theme.cardTheme.padding`, gives its
title and description their styles and spaces them; do not pad inside it
again. Lay the content out with the same gap scale:

- `GapSize.md` between the blocks of a card (header, body, media,
  actions), `GapSize.xs` between a title and its muted line, `GapSize.sm`
  between buttons.
- A `Divider` between sections of a card passes `margin: EdgeInsets.zero`;
  the shadcn-derived styles give a divider a margin of its own.
- Change a card's padding or radius through its `style`, never by
  wrapping it: `Card(style: CardTheme(padding: EdgeInsets.all(
  theme.layoutTheme.gap(GapSize.xl))), child: ...)`.
- A surface that is laid out like a card without being one (a panel in a
  pane) takes `theme.cardTheme.padding` as its padding, so it lines up.

## Spacing steps

The second scale is numeric. `ThemeData.spacing` is one step, 4 logical pixels
by default, and `spacing: 3`, `Gap(2)` and `UnaPadding.all(4)` are multiples
of it. Steps do not follow the form factor. They rescale together when the step
changes (`ThemeData(spacing: const Spacing(step: 5))`), and the named gaps scale
with them. Use steps for the inside of a component, where a design gives a
specific measure, and the named gaps for the space between components.
`Gap.raw(10)` bypasses both scales, for a value that is deliberately off them.

### Row and column spacing

`UnaRow` and `UnaColumn` accept a `spacing` argument in theme steps.

```dart
import 'package:una/una.dart';
import 'package:flutter/widgets.dart';

/// `UnaRow` and `UnaColumn` accept a `spacing` argument in theme steps.
class LayoutSpacingExample extends StatelessWidget {
  const LayoutSpacingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UnaColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Card(
          child: UnaRow(
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
            child: UnaColumn(
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
import 'package:una/una.dart';
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

`UnaPadding` takes steps, not pixels. It has no plain constructor, only
`.all`, `.symmetric`, `.only`, and `.directional`; `symmetric(horizontal: 6,
vertical: 4)` is 24 by 16 at the default step.

```dart
import 'package:una/una.dart';
import 'package:flutter/widgets.dart';

/// `UnaPadding` takes theme spacing steps, not logical pixels.
class LayoutPaddingExample extends StatelessWidget {
  const LayoutPaddingExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return ColoredBox(
      color: theme.colorScheme.muted,
      child: UnaPadding.symmetric(
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

`UnaColumn` with `crossAxisAlignment: stretch` lines up full-width children
inside a card, with `Divider` between groups. The same pattern stacks fields and
buttons in a form: put the primary action above an outline cancel. See
`example/lib/docs/examples/layout/layout_card_sections.dart` and
`layout_form_actions.dart` for the full examples.
