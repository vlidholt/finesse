import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/navigation_menu/navigation_menu_basic.dart';
import 'package:example/docs/examples/navigation_menu/navigation_menu_collapsed.dart';
import 'package:flutter/widgets.dart';

final navigationMenuDoc = ComponentDoc(
  slug: 'navigation_menu',
  title: 'Navigation Menu',
  description:
      "The links of a site or an app's top level, in a row. Some go "
      'somewhere; some open a panel of further links under the row. Put it '
      "in an `AppBar`'s `middle` or `actions`.",
  examples: [
    ComponentExample(
      id: 'navigation_menu_basic',
      title: 'Links and panels',
      description:
          'A `NavigationMenuItem` with a `builder` is a trigger: its panel '
          'opens when the pointer rests on it, on a press, and with Enter, '
          'Space or the down arrow. There is one panel for the whole row: '
          'moving to another trigger slides it under that trigger and '
          'resizes it for the new content. An item without a builder is a '
          'link. `selected` marks where the user is, and the mark moves to '
          'the open trigger while a panel is open. A `NavigationMenuLink` '
          'in a panel closes the menu when it is pressed.',
      minPreviewHeight: 380,
      padding: const EdgeInsets.all(24),
      builder: (_) => const NavigationMenuBasicExample(),
    ),
    ComponentExample(
      id: 'navigation_menu_collapsed',
      title: 'On a phone',
      description:
          'A row of links has no room on a phone, and a finger does not '
          'hover. There — or anywhere with `collapsed: true` — the menu is '
          'one button that opens a sheet: links as rows a touch target '
          "tall, and each trigger's content as a section under its label. "
          "The content is laid out at the sheet's width, so build it to "
          'fit what it is given.',
      minPreviewHeight: 600,
      builder: (_) => const NavigationMenuCollapsedExample(),
    ),
  ],
);
