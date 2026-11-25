# Button

Displays a button or a component that looks like a button. Six variants share one API: pick the one matching the action's weight.

## Variants

Primary for the main action, secondary and outline for everything else, destructive for irreversible actions, ghost for toolbars, and link for inline navigation.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
          leading: const PhosphorIcon(PhosphorIconsRegular.envelopeSimple),
          child: const Text('Login with Email'),
        ),
        Button.outline(
          onPressed: () {},
          trailing: const PhosphorIcon(PhosphorIconsRegular.caretRight),
          child: const Text('Next'),
        ),
      ],
    );
  }
}
```

## Loading

`loading: true` shows a spinner in the place of the leading widget, or over the label when there is none, without changing the size of the button. A loading button ignores presses, keeps the focus and is announced as busy; it is not dimmed like a disabled one.

```dart
import 'dart:async';

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonLoadingExample extends StatefulWidget {
  const ButtonLoadingExample({super.key});

  @override
  State<ButtonLoadingExample> createState() => _ButtonLoadingExampleState();
}

class _ButtonLoadingExampleState extends State<ButtonLoadingExample> {
  final _busy = <String>{};
  final _timers = <Timer>[];

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  // Stands in for a request: two seconds of work.
  void _run(String action) {
    setState(() => _busy.add(action));
    _timers.add(
      Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _busy.remove(action));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // With no leading widget the spinner lies over the label, which
        // keeps its room: the button does not change size.
        Button(
          loading: _busy.contains('save'),
          onPressed: () => _run('save'),
          child: const Text('Save changes'),
        ),
        // With one, the spinner takes its place and the label stays.
        Button.outline(
          loading: _busy.contains('export'),
          leading: const PhosphorIcon(PhosphorIconsRegular.downloadSimple),
          onPressed: () => _run('export'),
          child: const Text('Export'),
        ),
        IconButton.outline(
          tooltip: 'Refresh',
          loading: _busy.contains('refresh'),
          onPressed: () => _run('refresh'),
          icon: const PhosphorIcon(PhosphorIconsRegular.arrowsClockwise),
        ),
      ],
    );
  }
}
```

