import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/reorderable_list_view/reorderable_list_view_basic.dart';
import 'package:example/docs/examples/reorderable_list_view/reorderable_list_view_handles.dart';

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
          'uses the grip, which shows under the pointer. From the keyboard, '
          'Space or Enter on a focused grip picks the row up, the arrow '
          'keys move it, Space drops it and Escape puts it back. '
          '`onReorder(from, to)` reports the row\'s final index, so '
          '`list.insert(to, list.removeAt(from))` is all there is to do.',
      minPreviewHeight: 340,
      builder: (_) => const ReorderableListViewBasicExample(),
    ),
    ComponentExample(
      id: 'reorderable_list_view_handles',
      title: 'Grips only, in a list that scrolls',
      description:
          '`longPressToDrag: false` leaves a long press to the rows. '
          '`ReorderableListView.builder` builds rows as they scroll into '
          'view, and the list scrolls when a row is held near its edge. '
          'A row keeps its state when it is moved.',
      minPreviewHeight: 380,
      builder: (_) => const ReorderableListViewHandlesExample(),
    ),
  ],
);
