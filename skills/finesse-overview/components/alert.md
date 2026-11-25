# Alert

Displays a callout for user attention.

## Default

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class AlertDefaultExample extends StatelessWidget {
  const AlertDefaultExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 576),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Alert(
            icon: PhosphorIcon(PhosphorIconsRegular.checkCircle),
            title: Text('Success! Your changes have been saved'),
            description: Text(
              'This is an alert with icon, title and description.',
            ),
          ),
          Alert(
            icon: PhosphorIcon(PhosphorIconsRegular.popcorn),
            title: Text('This Alert has a title and an icon. No description.'),
          ),
          Alert.destructive(
            icon: PhosphorIcon(PhosphorIconsRegular.warningCircle),
            title: Text('Unable to process your payment.'),
            description: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text('Please verify your billing information and try again.'),
                Text('• Check your card details'),
                Text('• Ensure sufficient funds'),
                Text('• Verify billing address'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Destructive

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class AlertDestructiveExample extends StatelessWidget {
  const AlertDestructiveExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 576),
      child: const Alert.destructive(
        icon: PhosphorIcon(PhosphorIconsRegular.warningCircle),
        title: Text('Error'),
        description: Text('Your session has expired. Please log in again.'),
      ),
    );
  }
}
```

## Success, warning and info

Three variants tinted with the `success`, `warning` and `tint` colours of the scheme, each with an icon of its own. `icon` replaces it.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class AlertVariantsExample extends StatelessWidget {
  const AlertVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: const FinesseColumn(
        gap: GapSize.md,
        mainAxisSize: MainAxisSize.min,
        children: [
          Alert(
            variant: AlertVariant.success,
            title: Text('Payment received'),
            description: Text('A receipt is on its way to your inbox.'),
          ),
          Alert(
            variant: AlertVariant.warning,
            title: Text('Your trial ends in 3 days'),
            description: Text('Add a payment method to keep your projects.'),
          ),
          Alert(
            variant: AlertVariant.info,
            title: Text('A new version is available'),
            description: Text('Reload the page to get the latest changes.'),
          ),
        ],
      ),
    );
  }
}
```

## Dismissible

With `onDismissed` the alert has a close button. Pressing it folds the alert away and then calls `onDismissed`, where the parent stops building it.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class AlertDismissibleExample extends StatefulWidget {
  const AlertDismissibleExample({super.key});

  @override
  State<AlertDismissibleExample> createState() =>
      _AlertDismissibleExampleState();
}

class _AlertDismissibleExampleState extends State<AlertDismissibleExample> {
  var _shown = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: FinesseColumn(
        gap: GapSize.md,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_shown)
            Alert(
              variant: AlertVariant.info,
              title: const Text('Scheduled maintenance'),
              description: const Text(
                'Strand will be read-only on Saturday from 02:00 to 03:00.',
              ),
              // Called once the alert has folded away.
              onDismissed: () => setState(() => _shown = false),
            )
          else
            Button.outline(
              onPressed: () => setState(() => _shown = true),
              child: const Text('Show it again'),
            ),
        ],
      ),
    );
  }
}
```
