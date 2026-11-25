# Checkbox

A control that allows the user to toggle between checked and not checked.

## With label

```dart
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
```

## Disabled

```dart
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
```

## Mixed

`tristate` allows a null value, the mixed state, drawn as a dash and announced as "mixed". `onChanged` still reports a bool: a tap on a mixed box checks it.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A box that stands for several others. With `tristate` its value may be
/// null — mixed, drawn as a dash — while only some of them are checked. A
/// tap on a mixed box checks it, and so all of them.
class CheckboxTristateExample extends StatefulWidget {
  const CheckboxTristateExample({super.key});

  @override
  State<CheckboxTristateExample> createState() =>
      _CheckboxTristateExampleState();
}

class _CheckboxTristateExampleState extends State<CheckboxTristateExample> {
  final channels = {'Email': true, 'Push': false, 'SMS': false};

  bool? get _all {
    final on = channels.values.where((value) => value).length;
    if (on == 0) return false;
    return on == channels.length ? true : null;
  }

  @override
  Widget build(BuildContext context) {
    return FinesseColumn(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      gap: GapSize.sm,
      children: [
        Checkbox(
          value: _all,
          tristate: true,
          label: const Text('All notifications'),
          onChanged: (value) =>
              setState(() => channels.updateAll((_, _) => value)),
        ),
        for (final name in channels.keys)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 24),
            child: Checkbox(
              value: channels[name],
              label: Text(name),
              onChanged: (value) => setState(() => channels[name] = value),
            ),
          ),
      ],
    );
  }
}
```

