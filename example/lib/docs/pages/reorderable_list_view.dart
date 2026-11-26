import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/reorderable_list_view/reorderable_list_view_basic.dart';
import 'package:example/docs/examples/reorderable_list_view/reorderable_list_view_handles.dart';
import 'package:example/docs/examples/reorderable_list_view/reorderable_list_view_no_handles.dart';
import 'package:example/docs/examples/reorderable_list_view/reorderable_list_view_sliver.dart';

final reorderableListViewDoc = ComponentDoc(
  slug: 'reorderable_list_view',
  title: 'Reorderable List View',
  description:
      'A list whose rows can be dragged into a new order: a playlist, a set '
      'of priorities, the sections of a profile.',
  examples: [
    ComponentExample(
      id: 'reorderable_list_view_basic',
      title: 'A playlist',
      description:
          'Every row has a key and a `ReorderableDragHandle`. A finger also '
          'picks a row up by pressing and holding anywhere on it; a mouse '
          'uses the grip, which shows under the pointer. The row lifts as '
          'a card does on a `Board`, the others make way on springs, and '
          'on release it flies to its place and lands. From the keyboard, '
          'Space or Enter on a focused grip picks the row up, the arrow '
          'keys move it, Space drops it and Escape puts it back. '
          '`onReorder(from, to)` reports the row\'s final index, so '
          '`list.insert(to, list.removeAt(from))` is all there is to do.',
      minPreviewHeight: 340,
      builder: (_) => const ReorderableListViewBasicExample(),
    ),
    ComponentExample(
      id: 'reorderable_list_view_no_handles',
      title: 'No handles: the row is the grip',
      description:
          'A row without a `ReorderableDragHandle` is dragged by the row '
          'itself, as a card on a `Board` is: a mouse picks it up once a '
          'press moves, a finger once it has been held, and a click or a '
          'tap still goes to the row. The row is its own Tab stop: Space '
          'picks it up for the keyboard.',
      builder: (_) => const ReorderableListViewNoHandlesExample(),
    ),
    ComponentExample(
      id: 'reorderable_list_view_handles',
      title: 'Grips only, in a list that scrolls',
      description:
          '`longPressToDrag: false` leaves a long press to the rows. '
          '`ReorderableListView.builder` builds rows as they scroll into '
          'view — `itemId` says which item is at an index, so the rows '
          'need no key — and the list scrolls when a row is held near its '
          'edge. A row keeps its state when it is moved.',
      minPreviewHeight: 380,
      builder: (_) => const ReorderableListViewHandlesExample(),
    ),
    ComponentExample(
      id: 'reorderable_list_view_sliver',
      title: 'A sliver, and changes made from code',
      description:
          '`SliverReorderableListView` is the same list among the other '
          'slivers of a `CustomScrollView`. A change the parent makes by '
          'itself is animated too: sort or shuffle the queue and the rows '
          'glide to where they now belong.',
      minPreviewHeight: 420,
      builder: (_) => const ReorderableListViewSliverExample(),
    ),
  ],
);
