import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
