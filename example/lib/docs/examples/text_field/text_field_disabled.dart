import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TextFieldDisabledExample extends StatelessWidget {
  const TextFieldDisabledExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: const TextField(
        enabled: false,
        placeholder: Text('Email'),
      ),
    );
  }
}
