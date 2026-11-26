import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class AutocompleteBasicExample extends StatefulWidget {
  const AutocompleteBasicExample({super.key});

  @override
  State<AutocompleteBasicExample> createState() =>
      _AutocompleteBasicExampleState();
}

class _AutocompleteBasicExampleState extends State<AutocompleteBasicExample> {
  static const cities = [
    'Amsterdam',
    'Athens',
    'Barcelona',
    'Berlin',
    'Bern',
    'Copenhagen',
    'Lisbon',
    'London',
    'Madrid',
    'Stockholm',
  ];

  String? destination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            placeholder: const Text('City'),
            clearable: true,
            // Asked on every change. Arrow keys walk the list, Enter takes
            // the highlighted row, and the text stays free otherwise.
            optionsBuilder: (value) {
              final query = value.text.toLowerCase();
              if (query.isEmpty) return const [];
              return cities.where(
                (city) => city.toLowerCase().startsWith(query),
              );
            },
            onSelected: (city) => setState(() => destination = city),
          ),
          const Gap.sm(),
          Text(
            destination == null ? 'Try "b"' : 'Going to $destination',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}
