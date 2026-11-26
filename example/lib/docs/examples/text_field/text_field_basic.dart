import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class TextFieldBasicExample extends StatelessWidget {
  const TextFieldBasicExample({super.key});

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
