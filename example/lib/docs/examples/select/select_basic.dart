import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

const _fruits = {
  'apple': 'Apple',
  'banana': 'Banana',
  'blueberry': 'Blueberry',
  'grapes': 'Grapes',
  'pineapple': 'Pineapple',
};

/// A plain select. Each option has a `label`, which is what the trigger
/// shows for the chosen one; the parent holds the value.
class SelectBasicExample extends StatefulWidget {
  const SelectBasicExample({super.key});

  @override
  State<SelectBasicExample> createState() => _SelectBasicExampleState();
}

class _SelectBasicExampleState extends State<SelectBasicExample> {
  String? fruit;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180),
      child: Select<String>(
        placeholder: const Text('Select a fruit'),
        value: fruit,
        onChanged: (value) => setState(() => fruit = value),
        options: [
          for (final MapEntry(:key, :value) in _fruits.entries)
            SelectOption(value: key, label: value),
        ],
      ),
    );
  }
}
