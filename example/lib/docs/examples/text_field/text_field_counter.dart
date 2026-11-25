import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
