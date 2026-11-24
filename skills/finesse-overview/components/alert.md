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
            icon: Icon(PhosphorIconsRegular.checkCircle),
            title: Text('Success! Your changes have been saved'),
            description: Text(
              'This is an alert with icon, title and description.',
            ),
          ),
          Alert(
            icon: Icon(PhosphorIconsRegular.popcorn),
            title: Text('This Alert has a title and an icon. No description.'),
          ),
          Alert.destructive(
            icon: Icon(PhosphorIconsRegular.warningCircle),
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
        icon: Icon(PhosphorIconsRegular.warningCircle),
        title: Text('Error'),
        description: Text('Your session has expired. Please log in again.'),
      ),
    );
  }
}
```

