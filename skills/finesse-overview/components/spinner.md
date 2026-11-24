# Spinner

An animated loading indicator.

## Sizes

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class SpinnerBasicExample extends StatelessWidget {
  const SpinnerBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: [
        Spinner(size: 16),
        Spinner(),
        Spinner(size: 32),
      ],
    );
  }
}
```

