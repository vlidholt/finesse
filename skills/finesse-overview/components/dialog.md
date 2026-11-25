# Dialog

A modal window overlaid on the page, rendering the content underneath inert.

## With a form

A dialog has no close button of its own. Its actions close it, as do Escape and a tap outside; pass `showCloseButton: true` for an x in the corner.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

const _profile = [
  (title: 'Name', value: 'Alexandru'),
  (title: 'Username', value: 'nank1ro'),
];

class DialogFormExample extends StatelessWidget {
  const DialogFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Button.outline(
      child: const Text('Edit Profile'),
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            title: const Text('Edit Profile'),
            description: const Text(
              "Make changes to your profile here. Click save when you're "
              'done.',
            ),
            // A dialog has no close button of its own, so its actions are
            // the way out — next to Escape and a tap outside.
            actions: [
              Button.outline(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              Button(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Save changes'),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.stretch,
            child: Container(
              width: 375,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  for (final field in _profile)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            field.title,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.small,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: TextField(initialValue: field.value),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## Alert dialog

Interrupts the user with an important question and explicit actions.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class DialogAlertExample extends StatelessWidget {
  const DialogAlertExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      child: const Text('Delete account'),
      onPressed: () {
        showDialog<bool>(
          context: context,
          builder: (context) => Dialog.alert(
            title: const Text('Are you absolutely sure?'),
            description: const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'This action cannot be undone. This will permanently delete '
                'your account and remove your data from our servers.',
              ),
            ),
            actions: [
              Button.outline(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Button(
                child: const Text('Continue'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );
      },
    );
  }
}
```
