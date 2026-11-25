# Button

A label that does something when pressed. Six variants share one small API: pick the one matching the action's weight, and say anything else about its look with one `style` object. A button that holds only an icon is an `IconButton`.

## Variants

Primary for the main action, secondary and outline for everything else, destructive for irreversible actions, ghost for toolbars, and link for inline navigation. Pass `variant:` or use the named constructors.

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

## Restyling one button

How a button looks comes from its variant's `ButtonTheme` in the theme. `style` takes the same object for one button and is merged over the variant's, so it only says what is different: colours for each state, padding, width and height, the decoration, the text style, the icon size. `theme.buttonDecoration(radius:)` reshapes a button and its focus ring together.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonStyleExample extends StatelessWidget {
  const ButtonStyleExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // The green is dark in a light theme and pale in a dark one.
    final onSuccess = ColorScheme.contrastingForeground(scheme.success);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // New corners: the outline and the focus ring follow them.
        Button.outline(
          style: ButtonTheme(
            decoration: theme.buttonDecoration(radius: theme.radii.full),
          ),
          onPressed: () {},
          child: const Text('Follow'),
        ),
        // Colours for each state; the rest is still the primary button.
        Button(
          style: ButtonTheme(
            backgroundColor: scheme.success,
            hoverBackgroundColor: scheme.success.withValues(alpha: .85),
            foregroundColor: onSuccess,
            hoverForegroundColor: onSuccess,
          ),
          onPressed: () {},
          leading: const PhosphorIcon(PhosphorIconsRegular.check),
          child: const Text('Approve'),
        ),
        // A fixed width, with the label at the start.
        Button.secondary(
          style: const ButtonTheme(
            width: 200,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          onPressed: () {},
          leading: const PhosphorIcon(PhosphorIconsRegular.folder),
          child: const Text('Documents'),
        ),
      ],
    );
  }
}
```

## Other gestures

A button answers a press, a long press and the keyboard. For a double tap, a secondary tap or anything rarer, put a `FinesseGestureDetector` around it: the button keeps its press.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonGesturesExample extends StatefulWidget {
  const ButtonGesturesExample({super.key});

  @override
  State<ButtonGesturesExample> createState() => _ButtonGesturesExampleState();
}

class _ButtonGesturesExampleState extends State<ButtonGesturesExample> {
  String last = 'Nothing yet';

  void _say(String what) => setState(() => last = what);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        // The button answers a press and a long press; the detector around
        // it adds what a button has no callback for.
        FinesseGestureDetector(
          onDoubleTap: () => _say('Double tap'),
          onSecondaryTapDown: (_) => _say('Secondary tap'),
          child: Button.outline(
            onPressed: () => _say('Pressed'),
            onLongPress: () => _say('Long press'),
            leading: const PhosphorIcon(PhosphorIconsRegular.image),
            child: const Text('Photo'),
          ),
        ),
        Text(last, style: theme.textTheme.muted),
      ],
    );
  }
}
```
