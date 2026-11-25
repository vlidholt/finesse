import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A playlist to put in order. Drag a row by its grip — or, with a finger,
/// press and hold anywhere on it. With the keyboard, focus a grip, press
/// Space, move with the arrow keys and press Space again.
class ReorderableListViewBasicExample extends StatefulWidget {
  const ReorderableListViewBasicExample({super.key});

  @override
  State<ReorderableListViewBasicExample> createState() =>
      _ReorderableListViewBasicExampleState();
}

class _ReorderableListViewBasicExampleState
    extends State<ReorderableListViewBasicExample> {
  final tracks = [
    ('Northern Lights', '4:12'),
    ('Paper Boats', '3:38'),
    ('Slow Harbour', '5:01'),
    ('Glasshouse', '2:57'),
    ('Evening Ferry', '4:44'),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        padding: const EdgeInsets.all(8),
        columnCrossAxisAlignment: CrossAxisAlignment.stretch,
        rowMainAxisSize: MainAxisSize.max,
        child: ReorderableListView(
          // As tall as its rows: the page around it scrolls.
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // `to` is where the row ends up: no index to correct.
          onReorder: (from, to) =>
              setState(() => tracks.insert(to, tracks.removeAt(from))),
          itemSemanticLabel: (index) => tracks[index].$1,
          children: [
            for (final (index, (title, length)) in tracks.indexed)
              ListTile(
                // The key belongs to the track, not to its place.
                key: ValueKey(title),
                leading: SizedBox(
                  width: 20,
                  child: Text(
                    '${index + 1}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.muted,
                  ),
                ),
                title: Text(title),
                value: Text(length),
                trailing: const ReorderableDragHandle(),
              ),
          ],
        ),
      ),
    );
  }
}
