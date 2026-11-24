# Separator

Visually or semantically separates content.

## Default

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class SeparatorBasicExample extends StatelessWidget {
  const SeparatorBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Radix Primitives', style: theme.textTheme.small),
          const SizedBox(height: 4),
          Text(
            'An open-source UI component library.',
            style: theme.textTheme.muted,
          ),
          const Divider.horizontal(
            margin: EdgeInsets.symmetric(vertical: 16),
          ),
          const SizedBox(
            height: 20,
            child: Row(
              children: [
                Text('Blog'),
                Divider.vertical(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                ),
                Text('Docs'),
                Divider.vertical(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                ),
                Text('Source'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

