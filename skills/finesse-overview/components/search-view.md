# Search View

`showSearch` opens a search and returns what was chosen: a page with a back button and a focused field on a phone, a palette on the command dialog's surface on a desktop. The builder is called with the query once typing has paused. For a fixed set of actions filtered in memory, use `Command`.

## Default

The arrow keys walk from the field into the results, Enter takes one, and Escape clears the query and then closes the view.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SearchViewBasicExample extends StatefulWidget {
  const SearchViewBasicExample({super.key});

  @override
  State<SearchViewBasicExample> createState() => _SearchViewBasicExampleState();
}

class _SearchViewBasicExampleState extends State<SearchViewBasicExample> {
  static const people = [
    ('Ada Lovelace', 'Mathematics'),
    ('Alan Turing', 'Computing'),
    ('Grace Hopper', 'Compilers'),
    ('Katherine Johnson', 'Orbital mechanics'),
    ('Margaret Hamilton', 'Flight software'),
  ];

  String? invited;

  Future<void> search() async {
    // A palette on a desktop, a page of its own on a phone. The future
    // completes with what the builder closed the view with.
    final person = await showSearch<String>(
      context: context,
      placeholder: const Text('Search people'),
      builder: (context, query, close) {
        final theme = Theme.of(context);
        final matches = [
          for (final person in people)
            if (person.$1.toLowerCase().contains(query.toLowerCase())) person,
        ];
        if (matches.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Nobody called "$query"',
              style: theme.textTheme.muted,
              textAlign: TextAlign.center,
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (name, field) in matches)
              ListTile(
                leading: const PhosphorIcon(PhosphorIconsRegular.user),
                title: Text(name),
                subtitle: Text(field),
                onTap: () => close(name),
              ),
          ],
        );
      },
    );
    if (mounted && person != null) setState(() => invited = person);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Button.outline(
          leading: const PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
          onPressed: search,
          child: const Text('Search people'),
        ),
        const Gap.sm(),
        Text(
          invited == null ? 'Nobody invited yet' : 'Invited $invited',
          style: theme.textTheme.muted,
        ),
      ],
    );
  }
}
```
