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
                      width: double.infinity,
                      mainAxisAlignment: MainAxisAlignment.start,
                      leading: const Icon(PhosphorIconsRegular.plus),
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
              child: Icon(
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
