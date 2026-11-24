# Icon Button

A square button holding a single icon.

## Variants

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class IconButtonVariantsExample extends StatelessWidget {
  const IconButtonVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(PhosphorIconsRegular.rocket),
        ),
        IconButton.secondary(
          onPressed: () {},
          icon: const Icon(PhosphorIconsRegular.rocket),
        ),
        IconButton.destructive(
          onPressed: () {},
          icon: const Icon(PhosphorIconsRegular.rocket),
        ),
        IconButton.outline(
          onPressed: () {},
          icon: const Icon(PhosphorIconsRegular.rocket),
        ),
        IconButton.ghost(
          onPressed: () {},
          icon: const Icon(PhosphorIconsRegular.rocket),
        ),
      ],
    );
  }
}
```

