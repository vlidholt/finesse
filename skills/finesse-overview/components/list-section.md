# List Section

A group of rows under one heading: the grouped list of a settings page, the sections of a form, a menu of destinations.

## Settings

Rows on a card with a header above and a footer below. A hairline separates two rows and starts where the text does. The rows are `ListTile`, `SwitchListTile` and `RadioListTile`: the whole row is the target, and on a phone it is at least a touch target tall.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A settings page: sections of rows on a card, each with a heading and a
/// line of explanation, hairlines starting at the rows' text.
class ListSectionSettingsExample extends StatefulWidget {
  const ListSectionSettingsExample({super.key});

  @override
  State<ListSectionSettingsExample> createState() =>
      _ListSectionSettingsExampleState();
}

enum _Audience {
  everyone('Everyone'),
  connections('Your connections'),
  nobody('No one');

  const _Audience(this.label);

  final String label;
}

class _ListSectionSettingsExampleState
    extends State<ListSectionSettingsExample> {
  bool push = true;
  bool digest = false;
  _Audience audience = _Audience.connections;

  @override
  Widget build(BuildContext context) {
    // A style may set its overlines in capitals; the header is the caller's
    // text, so the caller applies the case.
    final overline = Theme.of(context).style.overline;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: FinesseColumn(
        gap: GapSize.lg,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListSection(
            header: Text(overline.applyCase('Notifications')),
            footer: const Text('Mentions and replies are always delivered.'),
            children: [
              SwitchListTile(
                secondary: const PhosphorIcon(PhosphorIconsRegular.bell),
                title: const Text('Push notifications'),
                value: push,
                onChanged: (value) => setState(() => push = value),
              ),
              SwitchListTile(
                secondary: const PhosphorIcon(
                  PhosphorIconsRegular.envelopeSimple,
                ),
                title: const Text('Weekly digest'),
                subtitle: const Text('Every Monday morning'),
                value: digest,
                onChanged: (value) => setState(() => digest = value),
              ),
              ListTile(
                leading: const PhosphorIcon(PhosphorIconsRegular.speakerHigh),
                title: const Text('Sound'),
                value: const Text('Chime'),
                showChevron: true,
                onTap: () {},
              ),
            ],
          ),
          FinesseRadioGroup<_Audience>(
            value: audience,
            onChanged: (value) => setState(() => audience = value),
            child: ListSection(
              header: Text(overline.applyCase('Who can message you')),
              children: [
                for (final option in _Audience.values)
                  RadioListTile<_Audience>(
                    title: Text(option.label),
                    value: option,
                  ),
              ],
            ),
          ),
          ListSection(
            children: [
              ListTile(
                leading: const PhosphorIcon(PhosphorIconsRegular.signOut),
                title: const Text('Sign out'),
                destructive: true,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

## A form

A form row is a `ListTile` with a control as its `trailing`. `headerTrailing` puts a link at the end of the heading.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A form laid out as a section: each row a `ListTile` with its control as
/// the trailing widget — a text field, a select, a switch.
class ListSectionFormExample extends StatefulWidget {
  const ListSectionFormExample({super.key});

  @override
  State<ListSectionFormExample> createState() => _ListSectionFormExampleState();
}

class _ListSectionFormExampleState extends State<ListSectionFormExample> {
  final name = TextEditingController(text: 'Maya Lindqvist');
  String language = 'English';
  bool public = true;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overline = Theme.of(context).style.overline;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: ListSection(
        header: Text(overline.applyCase('Profile')),
        headerTrailing: Button.link(
          size: ButtonSize.sm,
          onPressed: () {},
          child: const Text('Preview'),
        ),
        footer: const Text('Your name is shown on everything you post.'),
        children: [
          ListTile(
            title: const ExcludeSemantics(child: Text('Name')),
            trailing: SizedBox(
              width: 200,
              child: Semantics(
                label: 'Name',
                child: TextField(controller: name),
              ),
            ),
          ),
          ListTile(
            title: const ExcludeSemantics(child: Text('Language')),
            trailing: Semantics(
              label: 'Language',
              child: Select<String>(
                initialValue: language,
                minWidth: 200,
                options: [
                  for (final option in ['English', 'Svenska', 'Deutsch'])
                    SelectOption(value: option, child: Text(option)),
                ],
                selectedOptionBuilder: (context, value) => Text(value),
                onChanged: (value) {
                  if (value != null) setState(() => language = value);
                },
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Public profile'),
            subtitle: const Text('Anyone on Demo can find you'),
            value: public,
            onChanged: (value) => setState(() => public = value),
          ),
        ],
      ),
    );
  }
}
```

## Plain

`ListSectionVariant.plain` drops the card: rows run from edge to edge with only hairlines between them.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The plain variant: no card, rows from edge to edge with hairlines that
/// start at the names, whatever the rows lead with.
class ListSectionPlainExample extends StatelessWidget {
  const ListSectionPlainExample({super.key});

  static const _people = [
    ('assets/images/avatar_omar_rahimi.jpg', 'Omar Rahimi', 'Birchline'),
    ('assets/images/avatar_mei_tanaka.jpg', 'Mei Tanaka', 'Lumen Labs'),
    ('assets/images/avatar_claire_dubois.jpg', 'Claire Dubois', 'Collective'),
  ];

  @override
  Widget build(BuildContext context) {
    final overline = Theme.of(context).style.overline;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: ListSection(
        variant: ListSectionVariant.plain,
        header: Text(overline.applyCase('Suggested')),
        children: [
          for (final (photo, name, company) in _people)
            ListTile(
              leading: Avatar(photo, fallback: Text(name[0])),
              title: Text(name),
              subtitle: Text(company),
              showChevron: true,
              onTap: () {},
            ),
        ],
      ),
    );
  }
}
```

## Long lists

A `ListSection` builds all of its rows. `SliverListSection` is the same section as a sliver of a `CustomScrollView`, and `SliverListSection.builder` builds its rows as they scroll into view: the card is one decoration behind them, and no row is clipped or composited on its own.

```dart
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
```
