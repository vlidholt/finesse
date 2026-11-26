import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
