import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class InputBasicExample extends StatelessWidget {
  const InputBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: const TextField(
        placeholder: Text('Email'),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }
}
