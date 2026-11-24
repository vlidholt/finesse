# Sonner

An opinionated toast stack: notifications collect and expand on hover.

## Default

```dart
import 'dart:math';

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SonnerBasicExample extends StatelessWidget {
  const SonnerBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      child: const Text('Show Toast'),
      onPressed: () {
        final sonner = Sonner.of(context);
        final id = Random().nextInt(1000);
        sonner.show(
          Toast(
            id: id,
            title: const Text('Event has been created'),
            description: Text('${DateTime.now()}'),
            action: Button(
              child: const Text('Undo'),
              onPressed: () => sonner.hide(id),
            ),
          ),
        );
      },
    );
  }
}
```

