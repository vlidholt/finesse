import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class SearchFieldBasicExample extends StatefulWidget {
  const SearchFieldBasicExample({super.key});

  @override
  State<SearchFieldBasicExample> createState() =>
      _SearchFieldBasicExampleState();
}

class _SearchFieldBasicExampleState extends State<SearchFieldBasicExample> {
  static const fruits = ['Apple', 'Apricot', 'Banana', 'Cherry', 'Peach'];

  String query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matches = [
      for (final fruit in fruits)
        if (fruit.toLowerCase().contains(query.toLowerCase())) fruit,
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The clear button and Escape both empty the field.
          SearchField(
            placeholder: const Text('Search fruit'),
            onChanged: (value) => setState(() => query = value),
          ),
          const Gap.sm(),
          Text(
            matches.isEmpty ? 'No fruit found' : matches.join(', '),
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}
