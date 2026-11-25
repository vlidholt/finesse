# Form factors and responsive layout

Every style carries two sets of metrics, one for a desktop and one for a
phone. The theme holds the choice, so the same widgets come out denser
under a pointer and larger under a thumb.

A `FormFactor` is `desktop` or `mobile`. It is a property of the theme,
not of a widget: a button does not ask how wide the window is, it reads
its height from the theme, and the theme was built for one form factor or
the other.

| Default style | Desktop | Mobile |
| --- | --- | --- |
| Button height | 36 | 44 |
| Text field height | 40 | 46 |
| Chip height | 32 | 36 |
| Body text | 14 | 15 |
| App bar height | 64 | 60 |
| Page margins | 24 | 16 |
| `GapSize.lg` / `GapSize.xl` | 16 / 24 | 12 / 16 |

The form factor also decides how things are *presented*: a `Select` with
search, a `DatePicker`, a `ColorPickerButton` and an action sheet open a
bottom sheet on a phone and a popover or menu on a desktop; a dialog's
actions stack; `NavigationScaffold` moves its destinations to a bottom
bar; `showSearch` is a full page.

## How it is chosen

`FinesseApp` picks it from the window width: narrower than the theme's
`md` breakpoint (768 by default) is `mobile`, anything wider `desktop`.
To pin one regardless of width, pass it:

```dart
const app = FinesseApp(
  // Null, the default, follows the window width.
  formFactor: FormFactor.mobile,
  home: HomePage(),
);
```

Move the threshold with the breakpoint it reads:
`ThemeData(breakpoints: Breakpoints(md: 600))`.

## Reading it

Most code never needs to. Sizes follow the form factor through component
themes, the gap scale ([layout.md](layout.md)) and `PageContainer`. Read
it only where a screen is *arranged* differently on a phone:

```dart
// A one-off branch.
final isPhone = Theme.of(context).formFactor == FormFactor.mobile;

// Two layouts.
final inbox = FormFactorBuilder(
  mobile: (context) => const Text('List, then a pushed conversation'),
  desktop: (context) => const Row(
    children: [Text('List'), Expanded(child: Text('Conversation'))],
  ),
);
```

Rules:

- Never read `MediaQuery` width in a component to pick a size. A widget
  that does stops following a pinned `formFactor` and a re-themed subtree.
- Never hard-code a control height, a text size, a page margin or a gap
  between cards. Leave the widget's default, use `PageContainer`, use
  `GapSize`.
- Layout that only resizes needs no branch. Layout that rearranges uses
  `FormFactorBuilder`, `NavigationScaffold` or `ListDetailLayout`.
- Decide how many columns fit from a `LayoutBuilder`'s width, so windows
  between 800 and 1200 wide degrade gracefully.

## Laying out a subtree for the other one

`ThemeData.withFormFactor` returns the same theme laid out for the other
form factor, every component theme rebuilt from the style's other set of
metrics. The result is cached per theme, so calling it in `build` is
cheap. Use it for a phone preview inside a desktop page:

```dart
final preview = Theme(
  data: Theme.of(context).withFormFactor(FormFactor.mobile),
  child: const SizedBox(width: 390, height: 844, child: HomePage()),
);
```

`ThemeData(formFactor: FormFactor.mobile)` builds a theme for one
directly, which is what a widget test of a phone layout wants (a narrow
test window under `FinesseApp` gives the phone form factor as well).

## Where the phone metrics come from

A `StyleTokens` has a `mobile` field: a second, complete set of tokens for
a touch screen. `StyleTokens.finesse` points it at
`StyleTokens.finesseMobile`; a style that leaves it null gets derived
metrics. `forFormFactor` resolves either:

```dart
final phone = StyleTokens.finesse.forFormFactor(FormFactor.mobile);
final novaPhone = StyleTokens.nova.forFormFactor(FormFactor.mobile);
```

The derivation only loosens a style: buttons, icon buttons and fields
grow to at least 44 (small buttons 36, large 48), body and field text to
15 on a 22 line, chips to 36, checkboxes and radios to 20, calendar cells
to 40; the app bar is 60 tall, page margins 16, the `lg` gap 12 and `xl`
16.

`copyWith` on a style carries each change to the phone set where the two
had the same value. To set a phone value of its own, pass `mobile:`:

```dart
final mine = StyleTokens.nova.copyWith(buttonHeight: 34);
final theme = ThemeData(
  style: mine.copyWith(
    mobile: mine.forFormFactor(FormFactor.mobile).copyWith(buttonHeight: 48),
  ),
);
```

## Breakpoints

For layouts that change with the window width beyond phone versus desktop
(a third column from `lg` up), the theme carries six breakpoints on
Tailwind's scale, overridable on `ThemeData(breakpoints: ...)`: `tn` 0,
`sm` 640, `md` 768, `lg` 1024, `xl` 1280, `xxl` 1536.

```dart
final layout = ResponsiveBuilder(
  builder: (context, breakpoint) {
    final wide = breakpoint >= Theme.of(context).breakpoints.lg;
    return wide ? const Text('Three columns') : const Text('Two columns');
  },
);
```

`context.breakpoint` reads the same value inline. Comparisons follow
Tailwind: `sm` means "small and up", so test with `>=`. Each band is its
own type on a sealed class, so a `switch` covers the scale:

```dart
final label = switch (context.breakpoint) {
  BreakpointTN() => 'Tiny',
  BreakpointSM() => 'Small',
  BreakpointMD() => 'Medium',
  BreakpointLG() => 'Large',
  BreakpointXL() => 'Extra large',
  BreakpointXXL() => 'Extra extra large',
};
```

See also: [page-container.md](../components/page-container.md),
[app-structure.md](app-structure.md).
