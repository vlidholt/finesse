import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class CheckboxDisabledExample extends StatelessWidget {
  const CheckboxDisabledExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: true,
      enabled: false,
      onChanged: (v) {},
      label: const Text('Accept terms and conditions'),
    );
  }
}
