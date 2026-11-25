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

## Description and side

`description` is a muted line under the label; `controlAffinity` puts the switch before or after them. `Checkbox` and `Radio` take the same two.

```dart
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
```
