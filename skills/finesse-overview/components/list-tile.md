# List Tile

A row with a leading widget, a title, a subtitle and a trailing widget: a conversation, a person to follow, a shared file, a settings entry.

## Leading, subtitle and trailing

The title and subtitle each truncate to one line by default, so a long name never pushes the trailing widget out.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// People to follow: an avatar, a name, a quieter second line and a trailing
/// action. Long text truncates instead of pushing the button out.
class ListTileBasicExample extends StatelessWidget {
  const ListTileBasicExample({super.key});

  static const _people = [
    (
      'assets/strand/avatar_omar_rahimi.jpg',
      'Omar Rahimi',
      'Design lead at Birchline',
    ),
    (
      'assets/strand/avatar_mei_tanaka.jpg',
      'Mei Tanaka',
      'Staff researcher at Lumen Labs',
    ),
    (
      'assets/strand/avatar_claire_dubois.jpg',
      'Claire Dubois',
      'Founder of the Accessibility Collective',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (photo, name, role) in _people)
              ListTile(
                leading: Avatar(photo, fallback: Text(name[0])),
                title: Text(name),
                subtitle: Text(role),
                trailing: Button.outline(
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Follow'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

## Tappable and selected

With an `onTap` the row highlights under the pointer and takes keyboard focus. `selected` marks the current row of a list.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A list of conversations. With `onTap` a row highlights under the pointer
/// and takes keyboard focus; `selected` gives it the accent fill.
class ListTileSelectableExample extends StatefulWidget {
  const ListTileSelectableExample({super.key});

  @override
  State<ListTileSelectableExample> createState() =>
      _ListTileSelectableExampleState();
}

class _ListTileSelectableExampleState extends State<ListTileSelectableExample> {
  static const _conversations = [
    ('Omar Rahimi', 'Sending the deck now.', '9:41', 2),
    ('Design Systems Guild', 'Mei: the tokens are merged', '8:15', 0),
    ('Claire Dubois', 'Loved the talk yesterday!', 'Tue', 0),
    ('Julian Reyes', 'Here is the recording', 'Mon', 12),
  ];

  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          for (final (index, (name, message, time, unread))
              in _conversations.indexed)
            ListTile(
              selected: index == selected,
              onTap: () => setState(() => selected = index),
              leading: Avatar('', fallback: Text(name[0])),
              title: Text(name),
              subtitle: Text(message),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  Text(time, style: theme.textTheme.muted),
                  // Without a child the badge lays out on its own.
                  IndicatorBadge(count: unread, ringWidth: 0),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
```

## Settings

`subtitleMaxLines` lets the second line wrap. A row with a control at the end leaves `onTap` out, so the control is the only target.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Settings rows: an icon tile in front, a control or a chevron behind, and
/// a subtitle that is allowed to wrap to two lines.
class ListTileSettingsExample extends StatefulWidget {
  const ListTileSettingsExample({super.key});

  @override
  State<ListTileSettingsExample> createState() =>
      _ListTileSettingsExampleState();
}

class _ListTileSettingsExampleState extends State<ListTileSettingsExample> {
  bool digest = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const IconTile(
                icon: Icon(PhosphorIconsRegular.envelopeSimple),
              ),
              title: const Text('Weekly digest'),
              subtitle: const Text(
                'A summary of what your network posted, every Monday '
                'morning.',
              ),
              subtitleMaxLines: 2,
              trailing: Switch(
                value: digest,
                onChanged: (value) => setState(() => digest = value),
              ),
            ),
            ListTile(
              leading: const IconTile(
                icon: Icon(PhosphorIconsRegular.lockSimple),
              ),
              title: const Text('Privacy'),
              subtitle: const Text('Who can see your profile and activity'),
              trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const IconTile(
                icon: Icon(PhosphorIconsRegular.translate),
              ),
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```

