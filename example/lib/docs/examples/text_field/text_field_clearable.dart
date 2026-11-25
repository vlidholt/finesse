import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TextFieldClearableExample extends StatelessWidget {
  const TextFieldClearableExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: const TextField(
        initialValue: 'ada@example.com',
        placeholder: Text('Email'),
        // A clear button while the field has text. It keeps the focus.
        clearable: true,
      ),
    );
  }
}
