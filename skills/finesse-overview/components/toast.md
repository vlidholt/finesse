# Toast

A short message that floats over the app and leaves by itself. `FinesseApp` installs one `Toaster` above the navigator; `Toaster.of(context)` shows, replaces and dismisses `Toast`s in it. On a desktop the stack sits in the bottom end corner and a toast has a close button on hover; on a phone a toast spans the bottom of the page and is swiped away, down or sideways.

## Default

`show` returns what identifies the toast; give it an `id` of your own when its `action` has to dismiss it. Pressing the action does not dismiss the toast by itself.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToastBasicExample extends StatelessWidget {
  const ToastBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      child: const Text('Add to calendar'),
      onPressed: () {
        final toaster = Toaster.of(context);
        // The id is how the action finds its own toast again.
        final id = UniqueKey();
        toaster.show(
          Toast(
            id: id,
            title: const Text('Scheduled: Catch up'),
            description: const Text('Friday at 5:57 PM'),
            action: Button.outline(
              size: ButtonSize.sm,
              child: const Text('Undo'),
              onPressed: () => toaster.dismiss(id),
            ),
          ),
        );
      },
    );
  }
}
```

## Variants

Every variant is the same surface — a popover surface, glass in a style whose popovers are — and says what it is with the icon it leads with, in the `success`, `warning` and `destructive` colours of the scheme. `leading` replaces the icon. A destructive toast is announced assertively.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToastVariantsExample extends StatelessWidget {
  const ToastVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    void show(ToastVariant variant, String title, [String? description]) {
      Toaster.of(context).show(
        Toast(
          variant: variant,
          title: Text(title),
          description: description == null ? null : Text(description),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        Button.outline(
          child: const Text('Neutral'),
          onPressed: () => show(ToastVariant.neutral, 'Link copied'),
        ),
        Button.outline(
          child: const Text('Success'),
          onPressed: () => show(
            ToastVariant.success,
            'Changes saved',
            'Your profile is up to date.',
          ),
        ),
        Button.outline(
          child: const Text('Warning'),
          onPressed: () => show(
            ToastVariant.warning,
            'Storage almost full',
            '2 GB of 50 GB left.',
          ),
        ),
        Button.outline(
          child: const Text('Destructive'),
          onPressed: () => show(
            ToastVariant.destructive,
            'Could not send the message',
            'Check your connection and try again.',
          ),
        ),
      ],
    );
  }
}
```

## Loading, then a result

A `ToastVariant.loading` toast shows a spinner and stays. `update` replaces it where it is with its result, which then lives as long as any result. `dismissible: false` takes away the swipe, the close button and Escape.

```dart
import 'dart:async';

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToastLoadingExample extends StatefulWidget {
  const ToastLoadingExample({super.key});

  @override
  State<ToastLoadingExample> createState() => _ToastLoadingExampleState();
}

class _ToastLoadingExampleState extends State<ToastLoadingExample> {
  Timer? _upload;

  @override
  void dispose() {
    _upload?.cancel();
    super.dispose();
  }

  void _start() {
    final toaster = Toaster.of(context);
    // A loading toast stays until it is replaced or dismissed.
    final id = toaster.show(
      const Toast(
        variant: ToastVariant.loading,
        title: Text('Uploading 3 photos…'),
        dismissible: false,
      ),
    );
    _upload?.cancel();
    _upload = Timer(const Duration(seconds: 2), () {
      // The same toast, where it is, with its result.
      toaster.update(
        id,
        const Toast(
          variant: ToastVariant.success,
          title: Text('3 photos uploaded'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      onPressed: _start,
      child: const Text('Upload'),
    );
  }
}
```

## The stack

The newest toast is in front and the ones behind it show an edge. Pointing at the stack opens it and stops every clock until the pointer leaves. More than three wait unseen and come back as the ones in front leave. F6 moves the keyboard focus into the toasts and back; Escape dismisses the one that has it. `duration: Duration.zero` keeps a toast until it is dismissed.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToastStackExample extends StatefulWidget {
  const ToastStackExample({super.key});

  @override
  State<ToastStackExample> createState() => _ToastStackExampleState();
}

class _ToastStackExampleState extends State<ToastStackExample> {
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    final toaster = Toaster.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        Button.outline(
          child: const Text('Show a toast'),
          onPressed: () {
            _count++;
            toaster.show(
              Toast(
                title: Text('Message $_count'),
                description: const Text('Point at the stack to open it.'),
              ),
            );
          },
        ),
        Button.outline(
          child: const Text('One that stays'),
          onPressed: () => toaster.show(
            const Toast(
              variant: ToastVariant.warning,
              title: Text('You are offline'),
              description: Text('Changes are kept on this device.'),
              // No clock: it stays until it is dismissed.
              duration: Duration.zero,
            ),
          ),
        ),
        Button.ghost(
          onPressed: toaster.dismissAll,
          child: const Text('Dismiss all'),
        ),
      ],
    );
  }
}
```

## On its own

Outside a toaster a `Toast` is a plain widget, for a settings preview or a design review. Its look comes from `ThemeData.toastTheme`; where the stack sits, how wide a toast is and how many show come from `ThemeData.toasterTheme`.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToastInlineExample extends StatelessWidget {
  const ToastInlineExample({super.key});

  @override
  Widget build(BuildContext context) {
    // A `Toast` is a widget: outside a toaster it is a picture of one.
    return FinesseColumn(
      gap: GapSize.md,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Toast(title: Text('Link copied')),
        const Toast(
          variant: ToastVariant.success,
          title: Text('Changes saved'),
          description: Text('Your profile is up to date.'),
        ),
        Toast(
          variant: ToastVariant.destructive,
          title: const Text('Could not send the message'),
          action: Button.outline(
            size: ButtonSize.sm,
            onPressed: () {},
            child: const Text('Retry'),
          ),
        ),
        const Toast(
          variant: ToastVariant.loading,
          title: Text('Uploading 3 photos…'),
        ),
      ],
    );
  }
}
```
