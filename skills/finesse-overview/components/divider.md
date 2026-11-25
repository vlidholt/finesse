# Divider

A `Divider` is a hairline that separates content, horizontally or vertically.

## Default

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class DividerBasicExample extends StatelessWidget {
  const DividerBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Finesse', style: theme.textTheme.small),
          const SizedBox(height: 4),
          Text(
            'A design system for Flutter.',
            style: theme.textTheme.muted,
          ),
          const Divider(
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

