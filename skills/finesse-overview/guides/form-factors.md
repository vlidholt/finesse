# Form factors

Every style carries two sets of metrics, one for a desktop and one for a phone. The theme holds the choice, so the same widgets come out denser under a pointer and larger under a thumb.

A `FormFactor` is `desktop` or `mobile`. It is a property of the theme, not of a widget: a button does not ask how wide the window is, it reads its height from the theme, and the theme was built for one form factor or the other.

| Default style | Desktop | Mobile |
| --- | --- | --- |
| Button height | 36 | 44 |
| Text field height | 40 | 46 |
| Chip height | 32 | 36 |
| Body text | 14 | 15 |
| App bar height | 64 | 60 |
| Page margins | 24 | 16 |
| `GapSize.lg` / `GapSize.xl` | 16 / 24 | 12 / 16 |

## How it is chosen

`FinesseApp` picks the form factor from the window width: narrower than the theme's `md` breakpoint (768 by default) is `mobile`, anything wider is `desktop`. To pin one regardless of width, pass it:

```dart
FinesseApp(
  // Null, the default, follows the window width.
  formFactor: FormFactor.mobile,
  home: const HomePage(),
)
```

Move the threshold by changing the breakpoint it reads: `ThemeData(breakpoints: Breakpoints(md: 600))`.

## Reading it

Most code never needs to. Sizes follow the form factor on their own, through component themes, the gap scale ([layout.md](layout.md)) and `PageContainer`. Read it only where a screen is arranged differently on a phone:

```dart
// A one-off branch.
final isPhone = Theme.of(context).formFactor == FormFactor.mobile;

// Two layouts.
FormFactorBuilder(
  mobile: (context) => const ConversationList(),
  desktop: (context) => const Row(
    children: [ConversationList(), Expanded(child: Conversation())],
  ),
)
```

Rules:

- Do not read `MediaQuery` width in a component to pick a size. A widget that does stops following a pinned `formFactor` and a re-themed subtree.
- Do not hard-code a control height, a page margin or a gap between cards. Leave the widget's default, use `PageContainer`, use `GapSize`.
- Layout that only resizes needs no branch. Layout that rearranges uses `FormFactorBuilder` or `NavigationScaffold`, which moves an app's destinations from the app bar to a bottom bar by itself.

## Laying out a subtree for the other one

`ThemeData.withFormFactor` returns the same theme laid out for another form factor: every component theme is rebuilt from the style's other set of metrics. The result is cached, so calling it in `build` is cheap. Use it for a phone preview inside a desktop page:

```dart
Theme(
  data: Theme.of(context).withFormFactor(FormFactor.mobile),
  child: const PhonePreview(),
)
```

`ThemeData(formFactor: FormFactor.mobile)` builds a theme for one directly, which is what a widget test of a phone layout wants.

## Where the mobile metrics come from

A `StyleTokens` has a `mobile` field: a second, complete set of tokens for a touch-sized screen. `StyleTokens.finesse` points it at `StyleTokens.finesseMobile`. A style that leaves it null gets derived metrics instead. `forFormFactor` resolves either:

```dart
StyleTokens.finesse.forFormFactor(FormFactor.mobile); // finesseMobile
StyleTokens.nova.forFormFactor(FormFactor.mobile);    // derived from nova
```

The derivation only ever loosens a style:

- Buttons, icon buttons and fields grow to at least 44, small buttons to 36 and large ones to 48.
- Body and field text grow to at least 15 on a 22 line.
- Chips grow to 36, checkboxes and radios to 20, menu rows gain vertical padding, calendar cells reach 40.
- The app bar is 60 tall and page margins are 16.
- The `lg` gap drops from 16 to 12 and `xl` from 24 to 16.

For a custom style, either accept the derivation or supply your own phone metrics:

```dart
final mine = StyleTokens.nova.copyWith(buttonHeight: 34);

ThemeData(
  style: mine.copyWith(
    // Start from the derived set and adjust it.
    mobile: mine
        .forFormFactor(FormFactor.mobile)
        .copyWith(buttonHeight: 48),
  ),
)
```

`copyWith` on `StyleTokens.finesse` does not touch `finesseMobile`: a change meant for both form factors has to be made to both.

## Side by side

The same widgets under both form factors. Nothing in `_Controls` knows which one it is in.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The same widgets under both form factors. Nothing in `_Controls` knows
/// which one it is in; every size comes from the theme above it.
class FormFactorsSideBySideExample extends StatelessWidget {
  const FormFactorsSideBySideExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget column(FormFactor formFactor) {
      return SizedBox(
        width: 260,
        child: Theme(
          data: theme.withFormFactor(formFactor),
          child: _Controls(
            title: switch (formFactor) {
              FormFactor.desktop => 'Desktop',
              FormFactor.mobile => 'Mobile',
            },
          ),
        ),
      );
    }

    return Wrap(
      spacing: 40,
      runSpacing: 32,
      children: [
        column(FormFactor.desktop),
        column(FormFactor.mobile),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.style;
    return FinesseColumn(
      gap: GapSize.lg,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.h4),
        Text(
          'Buttons ${style.buttonHeight.round()}, fields '
          '${style.inputHeight.round()}, chips ${style.chipHeight.round()}, '
          'body text ${style.body.fontSize.round()}.',
          style: theme.textTheme.p,
        ),
        const TextField(placeholder: Text('Email')),
        Button(onPressed: () {}, child: const Text('Continue')),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('Remote'), selected: true),
            Chip(label: Text('Hybrid')),
          ],
        ),
        const Checkbox(value: true, label: Text('Remember me')),
      ],
    );
  }
}
```
