# Reorderable List View

A list whose rows can be dragged into a new order: a playlist, a set of priorities, the sections of a profile.

## A playlist

Every row has a key and a `ReorderableDragHandle`. A finger also picks a row up by pressing and holding anywhere on it; a mouse uses the grip, which shows under the pointer. From the keyboard, Space or Enter on a focused grip picks the row up, the arrow keys move it, Space drops it and Escape puts it back. `onReorder(from, to)` reports the row's final index, so `list.insert(to, list.removeAt(from))` is all there is to do.

```dart
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
```

## Grips only, in a list that scrolls

`longPressToDrag: false` leaves a long press to the rows. `ReorderableListView.builder` builds rows as they scroll into view, and the list scrolls when a row is held near its edge. A row keeps its state when it is moved.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
        padding: EdgeInsets.zero,
        columnCrossAxisAlignment: CrossAxisAlignment.stretch,
        rowMainAxisSize: MainAxisSize.max,
        child: ReorderableListView.builder(
          padding: const EdgeInsets.all(8),
          longPressToDrag: false,
          itemCount: sections.length,
          onReorder: (from, to) =>
              setState(() => sections.insert(to, sections.removeAt(from))),
          itemSemanticLabel: (index) => sections[index].name,
          itemBuilder: (context, index) {
            final section = sections[index];
            return ListTile(
              key: ValueKey(section.name),
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

