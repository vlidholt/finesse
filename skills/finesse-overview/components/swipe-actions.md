# Swipe Actions

A row with actions behind it, uncovered by swiping it sideways: archive or delete a message, mark a notification read.

## An inbox

Swipe a row with a finger or a trackpad. Let go past half of the actions and they stay open; swipe across most of the row and the outer one runs. An action that returns true removes the row: it slides out, the gap closes and `onRemoved` is called. A mouse does not drag rows: right-click one, or press the menu key while it has the focus, for the same actions as a menu. `SwipeActionsScope` keeps one row open at a time.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// An inbox: swipe a message towards the start to archive or delete it,
/// towards the end to mark it unread. A full swipe runs the outer action.
/// With a mouse, right-click a message for the same actions.
class SwipeActionsInboxExample extends StatefulWidget {
  const SwipeActionsInboxExample({super.key});

  @override
  State<SwipeActionsInboxExample> createState() =>
      _SwipeActionsInboxExampleState();
}

class _SwipeActionsInboxExampleState extends State<SwipeActionsInboxExample> {
  final messages = [
    ('Omar Rahimi', 'The research readout moved to Thursday.'),
    ('Mei Tanaka', 'Sent you the interview notes.'),
    ('Claire Dubois', 'Can you review the audit before Friday?'),
    ('Julian Reyes', 'Lunch next week?'),
  ];
  final unread = <String>{'Mei Tanaka'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      // One row open at a time.
      child: SwipeActionsScope(
        child: ListSection(
          children: [
            for (final (name, text) in messages)
              SwipeActions(
                // The row is told apart by its message, not its position:
                // the list gets shorter under it.
                key: ValueKey(name),
                leading: [
                  SwipeAction(
                    icon: const PhosphorIcon(PhosphorIconsRegular.envelope),
                    label: unread.contains(name) ? 'Read' : 'Unread',
                    backgroundColor: theme.colorScheme.tint,
                    foregroundColor: theme.colorScheme.tintForeground,
                    onPressed: () {
                      setState(() {
                        if (!unread.remove(name)) unread.add(name);
                      });
                      return false;
                    },
                  ),
                ],
                trailing: [
                  SwipeAction(
                    icon: const PhosphorIcon(PhosphorIconsRegular.trash),
                    label: 'Delete',
                    destructive: true,
                    // True: the row slides out and the gap closes.
                    onPressed: () => true,
                  ),
                  SwipeAction(
                    icon: const PhosphorIcon(PhosphorIconsRegular.archive),
                    label: 'Archive',
                    onPressed: () => true,
                  ),
                ],
                onRemoved: () => setState(
                  () => messages.removeWhere((message) => message.$1 == name),
                ),
                child: ListTile(
                  leading: Avatar('', fallback: Text(name[0])),
                  title: Text(name),
                  subtitle: Text(text),
                  trailing: unread.contains(name)
                      ? IndicatorBadge(
                          color: theme.colorScheme.tint,
                          semanticLabel: 'Unread',
                        )
                      : null,
                  onTap: () {},
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

## Asking first

`onPressed` may return a future: the row stays open until it completes. With `fullSwipe: false` a long swipe only opens the row.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// An action can take its time: here Delete asks first, and the row stays
/// open until the answer comes. `fullSwipe: false` makes a long swipe only
/// open the row, so nothing destructive runs without a tap.
class SwipeActionsConfirmExample extends StatefulWidget {
  const SwipeActionsConfirmExample({super.key});

  @override
  State<SwipeActionsConfirmExample> createState() =>
      _SwipeActionsConfirmExampleState();
}

class _SwipeActionsConfirmExampleState
    extends State<SwipeActionsConfirmExample> {
  final files = ['Brand guidelines.pdf', 'Q3 roadmap.key', 'Interview notes'];

  Future<bool> _confirm(String file) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog.alert(
        title: Text('Delete "$file"?'),
        description: const Text(
          'It is removed for everyone it is shared with.',
        ),
        actions: [
          Button.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          Button.destructive(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return sure ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: ListSection(
        variant: ListSectionVariant.plain,
        children: [
          for (final file in files)
            SwipeActions(
              key: ValueKey(file),
              fullSwipe: false,
              trailing: [
                SwipeAction(
                  icon: const PhosphorIcon(PhosphorIconsRegular.trash),
                  label: 'Delete',
                  destructive: true,
                  onPressed: () => _confirm(file),
                ),
                SwipeAction(
                  icon: const PhosphorIcon(PhosphorIconsRegular.shareNetwork),
                  label: 'Share',
                  onPressed: () => false,
                ),
              ],
              onRemoved: () => setState(() => files.remove(file)),
              child: ListTile(
                leading: const IconTile(
                  icon: PhosphorIcon(PhosphorIconsRegular.file),
                ),
                title: Text(file),
                showChevron: true,
                onTap: () {},
              ),
            ),
        ],
      ),
    );
  }
}
```

