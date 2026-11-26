import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/sheet/sheet_detents.dart';
import 'package:example/docs/examples/sheet/sheet_inline.dart';
import 'package:example/docs/examples/sheet/sheet_list.dart';
import 'package:example/docs/examples/sheet/sheet_sides.dart';

final sheetDoc = ComponentDoc(
  slug: 'sheet',
  title: 'Sheet',
  description:
      'A panel attached to an edge of the page. showSheet presents one over '
      'a barrier; a Sheet placed in the tree stays beside the content. It '
      'rests at detents, follows a finger, and takes its drag from the list '
      'inside it.',
  examples: [
    ComponentExample(
      id: 'sheet_sides',
      title: 'Sides',
      description:
          'On a phone a sheet from the bottom spans the screen, has a drag '
          'handle and is pulled down to close. On a desktop it is centred '
          'and no wider than a readable column; a sheet from a side is the '
          'usual choice there. A tap outside, a drag and Escape dismiss '
          'it, so it has no close button unless showCloseButton asks for '
          'one.',
      builder: (_) => const SheetSidesExample(),
    ),
    ComponentExample(
      id: 'sheet_detents',
      title: 'Detents',
      description:
          'SheetDetent.content (the default), medium, large, full, '
          'fraction(…) and height(…). The handle resizes it with a mouse, '
          'the arrow keys and a screen reader; a SheetController sends it '
          'to a detent or closes it.',
      builder: (_) => const SheetDetentsExample(),
    ),
    ComponentExample(
      id: 'sheet_list',
      title: 'A list that drives the sheet',
      description:
          'With a builder the sheet hands its scroll controller to your '
          'list, and one drag does both: the sheet grows before the list '
          'scrolls, and comes down from the top of the list.',
      builder: (_) => const SheetListExample(),
    ),
    ComponentExample(
      id: 'sheet_inline',
      title: 'Inline',
      description:
          'No route, no barrier. Use it for something that stays with the '
          'page: a player, the results under a map, the bottom sheet of a '
          'scaffold.',
      builder: (_) => const SheetInlineExample(),
      minPreviewHeight: 480,
    ),
  ],
);
