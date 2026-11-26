# Kbd

Displays a keyboard key or chord.

## Default

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class KbdBasicExample extends StatelessWidget {
  const KbdBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Kbd('K'),
        Kbd.group(['⌘', 'K']),
        // A Wrap, so the sentence breaks around the keys on a narrow screen.
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          children: [
            Text('Press '),
            Kbd.group(['Ctrl', 'Shift', 'P']),
            Text(' to open the palette'),
          ],
        ),
      ],
    );
  }
}
```
