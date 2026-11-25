# Textarea

A multi-line text input, optionally user-resizable.

## Default

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TextareaBasicExample extends StatelessWidget {
  const TextareaBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Textarea(
        placeholder: const Text('Type your message here...'),
        onChanged: (value) {},
      ),
    );
  }
}
```

## Character count

`showCounter` counts what is typed against `maxLength`. On iOS and Android a textarea has the same selection handles, toolbar and magnifier as a text field.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TextareaCounterExample extends StatelessWidget {
  const TextareaCounterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: const Textarea(
        placeholder: Text('Tell us a little about yourself'),
        // The count sits at the end, under the text.
        maxLength: 160,
        showCounter: true,
      ),
    );
  }
}
```

