import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/board/board_basic.dart';
import 'package:example/docs/examples/board/board_limit.dart';
import 'package:example/docs/examples/board/board_many.dart';
import 'package:flutter/widgets.dart';

final boardDoc = ComponentDoc(
  slug: 'board',
  title: 'Board',
  description:
      'Columns of cards that are dragged to reorder them and to move them '
      'between columns, like a kanban or Trello board. A mouse drags a '
      'card at once and a finger after a long press; from the keyboard, '
      'Space picks a focused card up, the arrow keys move it and Space '
      'drops it.',
  examples: [
    ComponentExample(
      id: 'board_basic',
      title: 'Default',
      description:
          'The board does not own the cards: it reports a `BoardMove` '
          'through `onMove` and the parent updates its lists, here with '
          '`move.apply`. A `Card` inside a board takes the tighter padding '
          'and radius of the board. Give the board a height; the columns '
          'fill it.',
      minPreviewHeight: 480,
      padding: const EdgeInsets.all(16),
      builder: (_) => const BoardBasicExample(),
    ),
    ComponentExample(
      id: 'board_limit',
      title: 'A limit, custom cards and a grip',
      description:
          '`BoardColumn.limit` caps a column: a card dragged over a full '
          'one is refused and springs back. `canAccept` on a column and '
          '`canMove` on the board refuse by any rule. With '
          '`BoardDragTrigger.handle` only a `BoardDragHandle` drags. '
          '`footer` pins a row under the cards and `itemId` tells cards '
          'apart when `==` will not do.',
      minPreviewHeight: 500,
      padding: const EdgeInsets.all(16),
      builder: (_) => const BoardLimitExample(),
    ),
    ComponentExample(
      id: 'board_many',
      title: 'Many cards',
      description:
          'Columns build their cards lazily and scroll on their own. A '
          'card held near an edge scrolls the column, or the board, under '
          'it. Inside a page that scrolls, pass `shrinkWrap: true` '
          'instead: the columns are then as tall as their cards and the '
          'page scrolls.',
      minPreviewHeight: 500,
      padding: const EdgeInsets.all(16),
      builder: (_) => const BoardManyExample(),
    ),
  ],
);
