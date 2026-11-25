# Text Field

A single-line text field. `TextField` is the control; `TextFormField` is the same field inside a `FinesseForm`.

## Default

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TextFieldBasicExample extends StatelessWidget {
  const TextFieldBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: const TextField(
        placeholder: Text('Email'),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }
}
```

## Password

`TextField.password` obscures the text and adds a button that reveals it. `leading` and `trailing` hold icons and actions.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TextFieldPasswordExample extends StatelessWidget {
  const TextFieldPasswordExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      // Obscured, with a button that shows and hides the text, the
      // password keyboard and the password manager's autofill.
      child: TextField.password(
        placeholder: const Text('Password'),
        leading: PhosphorIcon(
          PhosphorIconsRegular.lock,
          size: 16,
          color: theme.colorScheme.mutedForeground,
        ),
      ),
    );
  }
}
```

## Clearable

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TextFieldClearableExample extends StatelessWidget {
  const TextFieldClearableExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: const TextField(
        initialValue: 'ada@example.com',
        placeholder: Text('Email'),
        // A clear button while the field has text. It keeps the focus.
        clearable: true,
      ),
    );
  }
}
```

## Character count

`showCounter` counts against `maxLength`. `Textarea` takes it too.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TextFieldCounterExample extends StatelessWidget {
  const TextFieldCounterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: const TextField(
        initialValue: 'Design systems',
        placeholder: Text('Headline'),
        // Counts user-perceived characters, and tells assistive technology
        // when the limit is reached.
        maxLength: 40,
        showCounter: true,
      ),
    );
  }
}
```

## Disabled

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TextFieldDisabledExample extends StatelessWidget {
  const TextFieldDisabledExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: const TextField(
        enabled: false,
        placeholder: Text('Email'),
      ),
    );
  }
}
```

## Selection on touch

On iOS and Android every field has selection handles, a horizontal `TextSelectionToolbar` and a `TextMagnifier`, styled by `ThemeData.textSelectionTheme`; a desktop keeps its pointer selection and menu. This field asks for the touch controls by name so they show here too.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// On iOS and Android a field shows these on its own. This example asks for
/// them by name, so they can be tried on a desktop too: long-press or
/// right-click a word for the toolbar; with a touch screen, drag a handle.
class TextFieldTouchSelectionExample extends StatelessWidget {
  const TextFieldTouchSelectionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: TextField(
        initialValue: 'Long-press a word to select it',
        // The handles at the ends of a selection.
        selectionControls: finesseTextSelectionControls,
        // The horizontal toolbar over it, in place of the desktop menu.
        useBrowserContextMenu: false,
        contextMenuBuilder: (context, editableTextState) {
          return TextSelectionToolbar.editableText(
            editableTextState: editableTextState,
          );
        },
        // The loupe above the finger while a handle is dragged.
        magnifierConfiguration: TextMagnifierConfiguration(
          shouldDisplayHandlesInMagnifier: false,
          magnifierBuilder: (context, controller, magnifierInfo) {
            return TextMagnifier(magnifierInfo: magnifierInfo);
          },
        ),
      ),
    );
  }
}
```
