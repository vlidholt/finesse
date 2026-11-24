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

Leading and trailing slots hold icons and actions.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TextFieldPasswordExample extends StatefulWidget {
  const TextFieldPasswordExample({super.key});

  @override
  State<TextFieldPasswordExample> createState() =>
      _TextFieldPasswordExampleState();
}

class _TextFieldPasswordExampleState extends State<TextFieldPasswordExample> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: TextField(
        placeholder: const Text('Password'),
        obscureText: obscure,
        leading: PhosphorIcon(
          PhosphorIconsRegular.lock,
          size: 16,
          color: theme.colorScheme.mutedForeground,
        ),
        trailing: FinesseGestureDetector(
          cursor: SystemMouseCursors.click,
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => obscure = !obscure),
          child: PhosphorIcon(
            obscure ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye,
            size: 16,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
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

