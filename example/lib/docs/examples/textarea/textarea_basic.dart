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
