# Collapsible

An interactive component that expands and collapses a panel.

## Default

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class CollapsibleBasicExample extends StatelessWidget {
  const CollapsibleBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 350,
      child: Collapsible(
        trigger: (context, open, toggle) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '@noor starred 3 repositories',
                style: theme.textTheme.small,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton.ghost(
              icon: PhosphorIcon(
                open
                    ? PhosphorIconsRegular.arrowsInLineVertical
                    : PhosphorIconsRegular.caretUpDown,
              ),
              semanticLabel: open ? 'Collapse' : 'Expand',
              onPressed: toggle,
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(child: Text('@radix-ui/primitives')),
              SizedBox(height: 8),
              Card(child: Text('@radix-ui/colors')),
              SizedBox(height: 8),
              Card(child: Text('@stitches/react')),
            ],
          ),
        ),
      ),
    );
  }
}
```
