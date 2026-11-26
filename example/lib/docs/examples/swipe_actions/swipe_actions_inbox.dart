import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
