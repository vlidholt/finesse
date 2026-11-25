import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A long list as sections of a scroll view: every country, grouped by its
/// first letter. Each `SliverListSection.builder` builds only the rows that
/// are in view, and its card is painted once behind them.
class ListSectionSliverExample extends StatefulWidget {
  const ListSectionSliverExample({super.key});

  @override
  State<ListSectionSliverExample> createState() =>
      _ListSectionSliverExampleState();
}

class _ListSectionSliverExampleState extends State<ListSectionSliverExample> {
  static const _countries = [
    'Albania', 'Algeria', 'Argentina', 'Armenia', 'Australia', 'Austria', //
    'Bahamas', 'Bangladesh', 'Belgium', 'Bolivia', 'Botswana', 'Brazil',
    'Cambodia', 'Cameroon', 'Canada', 'Chile', 'Colombia', 'Croatia',
    'Denmark', 'Dominica', 'Ecuador', 'Egypt', 'Estonia', 'Ethiopia',
    'Fiji', 'Finland', 'France', 'Georgia', 'Germany', 'Ghana', 'Greece',
  ];

  String selected = 'Denmark';

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<String>>{};
    for (final country in _countries) {
      (groups[country[0]] ??= []).add(country);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 420),
      child: CustomScrollView(
        slivers: [
          for (final MapEntry(key: letter, value: countries) in groups.entries)
            SliverListSection.builder(
              header: Text(letter),
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                return ListTile(
                  title: Text(country),
                  selected: country == selected,
                  trailing: country == selected
                      ? const PhosphorIcon(PhosphorIconsRegular.check)
                      : null,
                  onTap: () => setState(() => selected = country),
                );
              },
            ),
        ],
      ),
    );
  }
}
