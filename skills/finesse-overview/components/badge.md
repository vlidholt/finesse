# Badge

Displays a badge or a component that looks like a badge.

## Variants

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class BadgeVariantsExample extends StatelessWidget {
  const BadgeVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Badge(child: Text('Primary')),
        Badge.secondary(child: Text('Secondary')),
        Badge.destructive(child: Text('Destructive')),
        Badge.outline(child: Text('Outline')),
      ],
    );
  }
}
```

