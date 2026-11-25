import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/context_menu/context_menu_basic.dart';
import 'package:example/docs/examples/context_menu/context_menu_show_menu.dart';
import 'package:example/docs/examples/context_menu/context_menu_submenus.dart';

final contextMenuDoc = ComponentDoc(
  slug: 'context_menu',
  title: 'Context Menu',
  description:
      'Displays a menu at the pointer, triggered by a right click or a long '
      'press.',
  examples: [
    ComponentExample(
      id: 'context_menu_basic',
      title: 'Default',
      description:
          'Checkbox rows, a radio group under a label, dividers and '
          'shortcuts. Space toggles a checkable row and keeps the menu '
          'open; Enter and a click do what the row is set to do.',
      minPreviewHeight: 280,
      builder: (_) => const ContextMenuBasicExample(),
    ),
    ComponentExample(
      id: 'context_menu_submenus',
      title: 'Submenus',
      description:
          'Eight rows in a row open a submenu, and two of them nest a '
          'second level. Sweep the pointer down the list: each submenu '
          'closes the moment the next row is reached.',
      minPreviewHeight: 280,
      builder: (_) => const ContextMenuSubmenusExample(),
    ),
    ComponentExample(
      id: 'context_menu_show_menu',
      title: 'At a point',
      description:
          'showMenu opens a menu where there is no widget to anchor it to: '
          'at a point of a canvas, or under a rectangle. Its future '
          'completes with the value of the row that was chosen.',
      minPreviewHeight: 280,
      builder: (_) => const ContextMenuShowMenuExample(),
    ),
  ],
);
