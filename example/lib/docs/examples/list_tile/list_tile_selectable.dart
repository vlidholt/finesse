import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
