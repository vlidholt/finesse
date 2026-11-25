import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A label with a description, and the switch after them:
/// `controlAffinity: ControlAffinity.trailing`.
class SwitchDescriptionExample extends StatefulWidget {
  const SwitchDescriptionExample({super.key});

  @override
  State<SwitchDescriptionExample> createState() =>
      _SwitchDescriptionExampleState();
}

class _SwitchDescriptionExampleState extends State<SwitchDescriptionExample> {
  bool digest = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: digest,
      onChanged: (value) => setState(() => digest = value),
      controlAffinity: ControlAffinity.trailing,
      label: const Text('Weekly digest'),
      description: const Text('One email on Monday, nothing else.'),
    );
  }
}
