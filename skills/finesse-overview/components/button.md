# Button

Displays a button or a component that looks like a button. Six variants share one API: pick the one matching the action's weight.

## Variants

Primary for the main action, secondary and outline for everything else, destructive for irreversible actions, ghost for toolbars, and link for inline navigation.

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class ButtonVariantsExample extends StatelessWidget {
  const ButtonVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Button(
          onPressed: () {},
          child: const Text('Primary'),
        ),
        Button.secondary(
          onPressed: () {},
          child: const Text('Secondary'),
        ),
        Button.destructive(
          onPressed: () {},
          child: const Text('Destructive'),
        ),
        Button.outline(
          onPressed: () {},
          child: const Text('Outline'),
        ),
        Button.ghost(
          onPressed: () {},
          child: const Text('Ghost'),
        ),
        Button.link(
          onPressed: () {},
          child: const Text('Link'),
        ),
      ],
    );
  }
}
```

## Sizes

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class ButtonSizesExample extends StatelessWidget {
  const ButtonSizesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Button.outline(
          size: ButtonSize.sm,
          onPressed: () {},
          child: const Text('Small'),
        ),
        Button.outline(
          onPressed: () {},
          child: const Text('Regular'),
        ),
        Button.outline(
          size: ButtonSize.lg,
          onPressed: () {},
          child: const Text('Large'),
        ),
      ],
    );
  }
}
```

## With icon

Use leading and trailing to place icons around the label.

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class ButtonIconExample extends StatelessWidget {
  const ButtonIconExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Button(
          onPressed: () {},
          leading: const Icon(PhosphorIconsRegular.envelopeSimple),
          child: const Text('Login with Email'),
        ),
        Button.outline(
          onPressed: () {},
          trailing: const Icon(PhosphorIconsRegular.caretRight),
          child: const Text('Next'),
        ),
      ],
    );
  }
}
```

## Loading

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class ButtonLoadingExample extends StatelessWidget {
  const ButtonLoadingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Button(
      enabled: false,
      leading: const SizedBox.square(
        dimension: 16,
        child: Spinner(),
      ),
      child: const Text('Please wait'),
    );
  }
}
```

