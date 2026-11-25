import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A queue as a sliver, under a header that scrolls away with it. The
/// buttons change the list from code: the rows glide to their new places
/// on the same springs a drag uses.
class ReorderableListViewSliverExample extends StatefulWidget {
  const ReorderableListViewSliverExample({super.key});

  @override
  State<ReorderableListViewSliverExample> createState() =>
      _ReorderableListViewSliverExampleState();
}

class _ReorderableListViewSliverExampleState
    extends State<ReorderableListViewSliverExample> {
  var queue = [
    'Tidewater',
    'Analogue Hearts',
    'Meridian',
    'Half Light',
    'Cedar Street',
    'Unmapped',
    'Low Sun',
    'Kite Season',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 360),
      child: Card(
        style: CardTheme(
          padding: EdgeInsets.zero,
          columnCrossAxisAlignment: CrossAxisAlignment.stretch,
          rowMainAxisSize: MainAxisSize.max,
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(child: Text('Up next', style: theme.textTheme.h4)),
                    Button.ghost(
                      size: ButtonSize.sm,
                      onPressed: () => setState(
                        () => queue = [...queue]..sort(),
                      ),
                      child: const Text('Sort'),
                    ),
                    Button.ghost(
                      size: ButtonSize.sm,
                      onPressed: () => setState(
                        () => queue = [...queue]..shuffle(),
                      ),
                      child: const Text('Shuffle'),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              sliver: SliverReorderableListView(
                itemCount: queue.length,
                itemId: (index) => queue[index],
                itemSemanticLabel: (index) => queue[index],
                onReorder: (from, to) => setState(
                  () => queue.insert(to, queue.removeAt(from)),
                ),
                itemBuilder: (context, index) => ListTile(
                  leading: const IconTile(
                    icon: PhosphorIcon(PhosphorIconsRegular.musicNote),
                  ),
                  title: Text(queue[index]),
                  trailing: const ReorderableDragHandle(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
