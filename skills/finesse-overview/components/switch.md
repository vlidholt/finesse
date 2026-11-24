# Switch

A control that allows the user to toggle between checked and not checked.

## Default

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SwitchBasicExample extends StatefulWidget {
  const SwitchBasicExample({super.key});

  @override
  State<SwitchBasicExample> createState() => _SwitchBasicExampleState();
}

class _SwitchBasicExampleState extends State<SwitchBasicExample> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: (v) => setState(() => value = v),
      label: const Text('Airplane Mode'),
    );
  }
}
```

