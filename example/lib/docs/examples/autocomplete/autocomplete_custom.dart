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
