# Autocomplete

A text field that suggests completions under itself as the user types. The text stays free; where the value has to be one of a list, use `Select.withSearch`. The focus never leaves the field: arrow keys move a highlight, Enter takes it, Escape closes the list.

## Default

```dart
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
```

## Options from a server

`optionsBuilder` may return a future. `loadingBuilder` and `emptyBuilder` fill the list meanwhile and when nothing is found.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class AutocompleteAsyncExample extends StatelessWidget {
  const AutocompleteAsyncExample({super.key});

  static const packages = [
    'una',
    'flutter_animate',
    'flutter_hooks',
    'flutter_svg',
    'freezed',
    'go_router',
    'google_fonts',
  ];

  /// A stand-in for a request to a server.
  static Future<Iterable<String>> search(TextEditingValue value) async {
    final query = value.text.trim().toLowerCase();
    if (query.isEmpty) return const [];
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return packages.where((name) => name.contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const padding = EdgeInsets.all(8);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Autocomplete<String>(
        placeholder: const Text('Search packages'),
        leading: PhosphorIcon(
          PhosphorIconsRegular.package,
          size: 16,
          color: theme.colorScheme.mutedForeground,
        ),
        // A builder that answers with a future is asked again only once
        // typing has paused, and a late answer is dropped.
        optionsBuilder: search,
        debounce: const Duration(milliseconds: 250),
        loadingBuilder: (context) => Padding(
          padding: padding,
          child: const Row(
            children: [Spinner(size: 14), Gap.sm(), Text('Searching…')],
          ),
        ),
        emptyBuilder: (context) => Padding(
          padding: padding,
          child: Text('No package found', style: theme.textTheme.muted),
        ),
      ),
    );
  }
}
```

## Options of any type

`displayStringForOption` and `optionBuilder` for options that are more than a string; `openOnFocus` to suggest before anything is typed.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

typedef Person = ({String name, String role});

class AutocompleteCustomExample extends StatelessWidget {
  const AutocompleteCustomExample({super.key});

  static const List<Person> people = [
    (name: 'Ada Lovelace', role: 'Mathematics'),
    (name: 'Alan Turing', role: 'Computing'),
    (name: 'Grace Hopper', role: 'Compilers'),
    (name: 'Katherine Johnson', role: 'Orbital mechanics'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Autocomplete<Person>(
        placeholder: const Text('Invite someone'),
        // Asks as soon as the field has the focus, before anything is
        // typed, and highlights the first row so Enter takes it.
        openOnFocus: true,
        autoHighlight: true,
        optionsBuilder: (value) {
          final query = value.text.toLowerCase();
          return people.where(
            (person) => person.name.toLowerCase().contains(query),
          );
        },
        // What the field shows for a chosen option...
        displayStringForOption: (person) => person.name,
        // ...and what its row shows.
        optionBuilder: (context, person) => Row(
          children: [
            Expanded(
              child: Text(
                person.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Gap.sm(),
            Text(person.role, style: theme.textTheme.caption),
          ],
        ),
      ),
    );
  }
}
```
