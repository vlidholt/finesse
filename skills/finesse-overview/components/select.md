# Select

Displays a list of options for the user to pick from, triggered by a button. Give `value` to hold the choice yourself or `initialValue` to let the select keep it; `Select.multiple` holds `values`. The searchable and multiple variants open a bottom sheet on a phone. `SelectFormField` and `SelectMultipleFormField` put a select in a form.

## Default

A `SelectOption` with a `label` needs no child, and the trigger shows that label for the chosen value. `selectedOptionBuilder` builds something else there.

```dart
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
```

## With search

Filter a long list of Dart frameworks and tools — Serverpod, Relic, Flutter, and more.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

const _dartFrameworks = {
  'serverpod': 'Serverpod',
  'relic': 'Relic',
  'flutter': 'Flutter',
  'flame': 'Flame',
  'jaspr': 'Jaspr',
  'drift': 'Drift',
  'riverpod': 'Riverpod',
  'melos': 'Melos',
  'mason': 'Mason',
  'very_good_cli': 'Very Good CLI',
};

class SelectSearchExample extends StatefulWidget {
  const SelectSearchExample({super.key});

  @override
  State<SelectSearchExample> createState() => _SelectSearchExampleState();
}

class _SelectSearchExampleState extends State<SelectSearchExample> {
  var searchValue = '';

  Map<String, String> get filtered => {
    for (final entry in _dartFrameworks.entries)
      if (entry.value.toLowerCase().contains(searchValue.toLowerCase()))
        entry.key: entry.value,
  };

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180),
      child: Select<String>.withSearch(
        minWidth: 180,
        placeholder: const Text('Select framework...'),
        onSearchChanged: (value) => setState(() => searchValue = value),
        searchPlaceholder: const Text('Search framework'),
        options: [
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No framework found'),
            ),
          for (final entry in _dartFrameworks.entries)
            Offstage(
              offstage: !filtered.containsKey(entry.key),
              child: SelectOption(value: entry.key, child: Text(entry.value)),
            ),
        ],
        selectedOptionBuilder: (context, value) =>
            Text(_dartFrameworks[value]!),
        onChanged: (value) {},
      ),
    );
  }
}
```

## Multiple, in a sheet

`Select.multipleWithSearch` with `values` and `onChanged`. `PickerPresentation.auto`, the default, opens the sheet on a phone and a popover on a desktop; a plain single select stays a popover everywhere.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

const _skills = [
  'Dart',
  'Flutter',
  'Serverpod',
  'Kotlin',
  'Swift',
  'TypeScript',
  'Rust',
  'Go',
  'Python',
  'SQL',
];

/// Several values, with a search field. On a desktop the options open in
/// a popover; on a phone, in a bottom sheet with the search pinned at its
/// top, rows at touch height and Done. `presentation` forces either one —
/// here the sheet, so it shows on any screen.
class SelectMultipleExample extends StatefulWidget {
  const SelectMultipleExample({super.key});

  @override
  State<SelectMultipleExample> createState() => _SelectMultipleExampleState();
}

class _SelectMultipleExampleState extends State<SelectMultipleExample> {
  Set<String> skills = {'Dart', 'Flutter'};
  String query = '';

  @override
  Widget build(BuildContext context) {
    final shown = _skills.where(
      (skill) => skill.toLowerCase().contains(query.toLowerCase()),
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      child: Select<String>.multipleWithSearch(
        presentation: PickerPresentation.sheet,
        placeholder: const Text('Skills'),
        searchPlaceholder: const Text('Search skills'),
        values: skills,
        onChanged: (values) => setState(() => skills = values),
        onSearchChanged: (value) => setState(() => query = value),
        allowDeselection: true,
        options: [
          for (final skill in shown) SelectOption(value: skill, label: skill),
        ],
      ),
    );
  }
}
```

