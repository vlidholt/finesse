import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class CheckboxBasicExample extends StatefulWidget {
  const CheckboxBasicExample({super.key});

  @override
  State<CheckboxBasicExample> createState() => _CheckboxBasicExampleState();
}

class _CheckboxBasicExampleState extends State<CheckboxBasicExample> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: (v) => setState(() => value = v),
      label: const Text('Accept terms and conditions'),
      description: const Text(
        'You agree to our Terms of Service and Privacy Policy.',
      ),
    );
  }
}
