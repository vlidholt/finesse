import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class TextFieldCounterExample extends StatelessWidget {
  const TextFieldCounterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: const TextField(
        initialValue: 'Design systems',
        placeholder: Text('Headline'),
        // Counts user-perceived characters, and tells assistive technology
        // when the limit is reached.
        maxLength: 40,
        showCounter: true,
      ),
    );
  }
}
