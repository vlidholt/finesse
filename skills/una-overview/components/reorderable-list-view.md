# Reorderable List View

A list whose rows can be dragged into a new order: a playlist, a set of priorities, the sections of a profile.

## A playlist

Every row has a key and a `ReorderableDragHandle`. A finger also picks a row up by pressing and holding anywhere on it; a mouse uses the grip, which shows under the pointer. The row lifts as a card does on a `Board`, the others make way on springs, and on release it flies to its place and lands. From the keyboard, Space or Enter on a focused grip picks the row up, the arrow keys move it, Space drops it and Escape puts it back. `onReorder(from, to)` reports the row's final index, so `list.insert(to, list.removeAt(from))` is all there is to do.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
        style: CardTheme(
          padding: const EdgeInsets.all(8),
          columnCrossAxisAlignment: CrossAxisAlignment.stretch,
          rowMainAxisSize: MainAxisSize.max,
        ),
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
```

## No handles: the row is the grip

A row without a `ReorderableDragHandle` is dragged by the row itself, as a card on a `Board` is: a mouse picks it up once a press moves, a finger once it has been held, and a click or a tap still goes to the row. The row is its own Tab stop: Space picks it up for the keyboard.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Rows with no grip: the whole row is the handle, as a card is on a
/// board. Drag one with the mouse, or press and hold it with a finger. A
/// click is still a click. With the keyboard, Tab to a row and press Space.
class ReorderableListViewNoHandlesExample extends StatefulWidget {
  const ReorderableListViewNoHandlesExample({super.key});

  @override
  State<ReorderableListViewNoHandlesExample> createState() =>
      _ReorderableListViewNoHandlesExampleState();
}

class _ReorderableListViewNoHandlesExampleState
    extends State<ReorderableListViewNoHandlesExample> {
  final priorities = [
    (PhosphorIconsRegular.rocketLaunch, 'Ship the beta', 'Due Friday'),
    (PhosphorIconsRegular.usersThree, 'Hire a designer', 'Three interviews'),
    (PhosphorIconsRegular.chartLineUp, 'Grow activation', 'Up to 40%'),
    (PhosphorIconsRegular.lifebuoy, 'Halve support tickets', 'This quarter'),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        style: CardTheme(
          padding: const EdgeInsets.all(8),
          columnCrossAxisAlignment: CrossAxisAlignment.stretch,
          rowMainAxisSize: MainAxisSize.max,
        ),
        child: ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (from, to) => setState(
            () => priorities.insert(to, priorities.removeAt(from)),
          ),
          itemSemanticLabel: (index) => priorities[index].$2,
          children: [
            for (final (index, (icon, title, detail)) in priorities.indexed)
              ListTile(
                key: ValueKey(title),
                leading: IconTile(icon: PhosphorIcon(icon)),
                title: Text(title),
                subtitle: Text(detail),
                trailing: Badge.secondary(child: Text('#${index + 1}')),
                onTap: () {},
              ),
          ],
        ),
      ),
    );
  }
}
```

## Grips only, in a list that scrolls

`longPressToDrag: false` leaves a long press to the rows. `ReorderableListView.builder` builds rows as they scroll into view — `itemId` says which item is at an index, so the rows need no key — and the list scrolls when a row is held near its edge. A row keeps its state when it is moved.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Rows with controls of their own, dragged by their grips only
/// (`longPressToDrag: false`), built on demand in a list that scrolls: hold
/// a row near an edge and the list scrolls under it. A row keeps its state
/// — here, its switch — when it moves.
class ReorderableListViewHandlesExample extends StatefulWidget {
  const ReorderableListViewHandlesExample({super.key});

  @override
  State<ReorderableListViewHandlesExample> createState() =>
      _ReorderableListViewHandlesExampleState();
}

class _ReorderableListViewHandlesExampleState
    extends State<ReorderableListViewHandlesExample> {
  final sections = [
    for (final name in [
      'Summary',
      'Experience',
      'Education',
      'Skills',
      'Projects',
      'Publications',
      'Volunteering',
      'Languages',
      'Recommendations',
      'Interests',
    ])
      (name: name, shown: ValueNotifier(true)),
  ];

  @override
  void dispose() {
    for (final section in sections) {
      section.shown.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 320),
      child: Card(
        style: CardTheme(
          padding: EdgeInsets.zero,
          columnCrossAxisAlignment: CrossAxisAlignment.stretch,
          rowMainAxisSize: MainAxisSize.max,
        ),
        child: ReorderableListView.builder(
          padding: const EdgeInsets.all(8),
          longPressToDrag: false,
          itemCount: sections.length,
          // Which item is at an index, without building its row.
          itemId: (index) => sections[index].name,
          onReorder: (from, to) =>
              setState(() => sections.insert(to, sections.removeAt(from))),
          itemSemanticLabel: (index) => sections[index].name,
          itemBuilder: (context, index) {
            final section = sections[index];
            return ListTile(
              leading: const ReorderableDragHandle(),
              title: Text(section.name),
              trailing: ValueListenableBuilder(
                valueListenable: section.shown,
                builder: (context, shown, _) => Semantics(
                  label: 'Show ${section.name}',
                  child: Switch(
                    value: shown,
                    onChanged: (value) => section.shown.value = value,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

## A sliver, and changes made from code

`SliverReorderableListView` is the same list among the other slivers of a `CustomScrollView`. A change the parent makes by itself is animated too: sort or shuffle the queue and the rows glide to where they now belong.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
```
