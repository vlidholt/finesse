# Back Button

The two buttons that leave a page. `BackButton` is a caret pointing at the start of the line; `CloseButton` is a cross. Each pops the page it is on, and an `AppBar` shows the right one by itself: a back button on a page that can be popped, a close button on a full-screen dialog.

## Back and close

Without an `onPressed` each calls `Navigator.maybePop`, so a `PopScope` on the page gets its say. The caret turns round in a right-to-left language; the cross does not. Both are announced in the app's language ("Back", "Close"), and on a desktop the same word is the tooltip.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The two buttons. Pressed, each pops the page it is on; here they are
/// given an `onPressed` instead, because the docs page is not theirs to
/// close.
class BackButtonBasicExample extends StatelessWidget {
  const BackButtonBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FinesseRow(
      mainAxisSize: MainAxisSize.min,
      children: [
        BackButton(onPressed: () {}),
        CloseButton(onPressed: () {}),
      ],
    );
  }
}
```

## Another icon, another name

`icon` replaces the glyph and `semanticLabel` the name — "Back to inbox" tells a screen reader more than "Back". `enabled: false` keeps the button in place and inert.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Another icon, another name. The name is what a screen reader says and,
/// on a desktop, the tooltip.
class BackButtonCustomExample extends StatelessWidget {
  const BackButtonCustomExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FinesseRow(
      mainAxisSize: MainAxisSize.min,
      children: [
        BackButton(
          icon: const PhosphorIcon(PhosphorIconsRegular.arrowLeft),
          semanticLabel: 'Back to inbox',
          onPressed: () {},
        ),
        CloseButton(
          icon: const PhosphorIcon(PhosphorIconsRegular.caretDown),
          semanticLabel: 'Minimise',
          onPressed: () {},
        ),
        const BackButton(enabled: false),
      ],
    );
  }
}
```

