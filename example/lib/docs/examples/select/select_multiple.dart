import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
        onValuesChanged: (values) => setState(() => skills = values),
        onSearchChanged: (value) => setState(() => query = value),
        allowDeselection: true,
        options: [
          for (final skill in shown) SelectOption(value: skill, label: skill),
        ],
      ),
    );
  }
}
