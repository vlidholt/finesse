# Board

Columns of cards that are dragged to reorder them and to move them between columns, like a kanban or Trello board. A mouse drags a card at once and a finger after a long press; from the keyboard, Space picks a focused card up, the arrow keys move it and Space drops it.

## Default

The board does not own the cards: it reports a `BoardMove` through `onMove` and the parent updates its lists, here with `move.apply`. A `Card` inside a board takes the tighter padding and radius of the board. Give the board a height; the columns fill it.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A board of three columns. The board reports each move through `onMove`
/// and the example carries it out on its own lists.
class BoardBasicExample extends StatefulWidget {
  const BoardBasicExample({super.key});

  @override
  State<BoardBasicExample> createState() => _BoardBasicExampleState();
}

class _BoardBasicExampleState extends State<BoardBasicExample> {
  final columns = <String, List<String>>{
    'To do': [
      'Write the launch post',
      'Review the pricing page',
      'Book the venue for the offsite',
      'Draft the Q3 roadmap',
    ],
    'In progress': [
      'Design the onboarding flow',
      'Fix the sign-up error on Safari',
    ],
    'Done': ['Set up analytics'],
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // A board fills the height it is given; each column scrolls its own
      // cards.
      height: 420,
      child: Board<String>(
        columns: [
          for (final MapEntry(key: name, value: tasks) in columns.entries)
            BoardColumn(id: name, label: name, items: tasks),
        ],
        itemBuilder: (context, task, details) => Card(child: Text(task)),
        onMove: (move) => setState(() {
          move.apply(columns[move.fromColumn]!, columns[move.toColumn]!);
        }),
      ),
    );
  }
}
```

## A limit, custom cards and a grip

`BoardColumn.limit` caps a column: a card dragged over a full one is refused and springs back. `canAccept` on a column and `canMove` on the board refuse by any rule. With `BoardDragTrigger.handle` only a `BoardDragHandle` drags. `footer` pins a row under the cards and `itemId` tells cards apart when `==` will not do.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Custom cards, a work-in-progress limit and a grip.
///
/// "In review" takes two tickets: drag a third over it and the column says
/// no, and the ticket springs back when it is let go. With
/// `BoardDragTrigger.handle` only the grip drags, so the rest of the card
/// stays free for its own gestures.
class BoardLimitExample extends StatefulWidget {
  const BoardLimitExample({super.key});

  @override
  State<BoardLimitExample> createState() => _BoardLimitExampleState();
}

typedef _Ticket = ({int id, String title, String area, int points});

class _BoardLimitExampleState extends State<BoardLimitExample> {
  final columns = <String, List<_Ticket>>{
    'Backlog': [
      (id: 412, title: 'Export a board as CSV', area: 'Data', points: 3),
      (id: 408, title: 'Keyboard shortcuts sheet', area: 'Docs', points: 1),
      (id: 397, title: 'Dark mode for emails', area: 'Design', points: 5),
    ],
    'In review': [
      (id: 391, title: 'Rate-limit the search API', area: 'API', points: 3),
      (id: 388, title: 'Invite by link', area: 'Growth', points: 2),
    ],
    'Shipped': [
      (id: 380, title: 'Two-factor sign-in', area: 'Security', points: 8),
    ],
  };

  var nextId = 413;

  void addTicket() => setState(() {
    columns['Backlog']!.insert(
      0,
      (id: nextId++, title: 'A new ticket', area: 'Triage', points: 1),
    );
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 440,
      child: Board<_Ticket>(
        // Tickets are told apart by their number, so one keeps its place
        // and its state when its other fields change.
        itemId: (ticket) => ticket.id,
        itemSemanticLabel: (ticket) => ticket.title,
        dragTrigger: BoardDragTrigger.handle,
        columns: [
          for (final MapEntry(key: name, value: tickets) in columns.entries)
            BoardColumn(
              id: name,
              label: name,
              items: tickets,
              limit: name == 'In review' ? 2 : null,
              footer: name == 'Backlog'
                  ? Button.ghost(
                      style: ButtonTheme(
                        width: double.infinity,
                        mainAxisAlignment: MainAxisAlignment.start,
                      ),
                      leading: const PhosphorIcon(PhosphorIconsRegular.plus),
                      onPressed: addTicket,
                      child: const Text('Add a ticket'),
                    )
                  : null,
            ),
        ],
        itemBuilder: (context, ticket, details) => Card(
          leading: Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: BoardDragHandle(
              child: PhosphorIcon(
                PhosphorIconsRegular.dotsSixVertical,
                size: 18,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(ticket.title, style: theme.textTheme.small),
              Row(
                spacing: 8,
                children: [
                  Badge.secondary(child: Text(ticket.area)),
                  Text('#${ticket.id}', style: theme.textTheme.muted),
                  const Spacer(),
                  Text('${ticket.points} pt', style: theme.textTheme.muted),
                ],
              ),
            ],
          ),
        ),
        onMove: (move) => setState(() {
          move.apply(columns[move.fromColumn]!, columns[move.toColumn]!);
        }),
      ),
    );
  }
}
```

## Many cards

Columns build their cards lazily and scroll on their own. A card held near an edge scrolls the column, or the board, under it. Inside a page that scrolls, pass `shrinkWrap: true` instead: the columns are then as tall as their cards and the page scrolls.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Nine hundred cards. Each column builds only the cards in view, and a
/// card dragged to the top or bottom edge of a column scrolls it — faster
/// the closer to the edge — so any card can reach any place.
class BoardManyExample extends StatefulWidget {
  const BoardManyExample({super.key});

  @override
  State<BoardManyExample> createState() => _BoardManyExampleState();
}

class _BoardManyExampleState extends State<BoardManyExample> {
  static const _names = ['Inbox', 'Sorted', 'Archived'];

  final columns = <String, List<int>>{
    for (final (index, name) in _names.indexed)
      name: [for (var i = 0; i < 300; i++) index * 300 + i + 1],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 440,
      child: Board<int>(
        columns: [
          for (final MapEntry(key: name, value: cards) in columns.entries)
            BoardColumn(id: name, label: name, items: cards),
        ],
        itemBuilder: (context, number, details) => Card(
          child: Row(
            spacing: 8,
            children: [
              Expanded(child: Text('Card $number')),
              Text(
                // Where the card is now, which the builder is told.
                '${details.index + 1} of ${details.column.items.length}',
                style: theme.textTheme.muted,
              ),
            ],
          ),
        ),
        onMove: (move) => setState(() {
          move.apply(columns[move.fromColumn]!, columns[move.toColumn]!);
        }),
      ),
    );
  }
}
```
