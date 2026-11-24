import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

const _fruits = {
  'apple': 'Apple',
  'banana': 'Banana',
  'blueberry': 'Blueberry',
  'grapes': 'Grapes',
  'pineapple': 'Pineapple',
};

class SelectBasicExample extends StatelessWidget {
  const SelectBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180),
      child: Select<String>(
        placeholder: const Text('Select a fruit'),
        options: [
          for (final fruit in _fruits.entries)
            SelectOption(value: fruit.key, child: Text(fruit.value)),
        ],
        selectedOptionBuilder: (context, value) => Text(_fruits[value]!),
        onChanged: (value) {},
      ),
    );
  }
}
