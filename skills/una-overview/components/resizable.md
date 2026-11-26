# Resizable

Resizable panel groups and layouts, with nesting and drag handles.

## Default

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class ResizableBasicExample extends StatelessWidget {
  const ResizableBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 300,
      height: 200,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: theme.radius,
          border: Border.all(color: theme.colorScheme.border),
        ),
        child: ClipRRect(
          borderRadius: theme.radius,
          child: ResizablePanelGroup(
            showHandle: true,
            children: [
              ResizablePanel(
                id: 0,
                defaultSize: .5,
                minSize: .2,
                child: const Center(child: Text('One')),
              ),
              ResizablePanel(
                id: 1,
                defaultSize: .5,
                child: ResizablePanelGroup(
                  axis: Axis.vertical,
                  showHandle: true,
                  children: [
                    ResizablePanel(
                      id: 0,
                      defaultSize: .5,
                      child: const Center(child: Text('Two')),
                    ),
                    ResizablePanel(
                      id: 1,
                      defaultSize: .5,
                      child: const Center(child: Text('Three')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
