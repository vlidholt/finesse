import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/list_detail_layout/list_detail_layout_basic.dart';
import 'package:flutter/widgets.dart';

final listDetailLayoutDoc = ComponentDoc(
  slug: 'list_detail_layout',
  title: 'List Detail Layout',
  description:
      'A list and the detail of what is chosen in it. On a desktop they '
      'are side by side; on a phone the list has the screen and the '
      'detail is pushed over it as a page. It follows the '
      "theme's form factor, and both keep their state when it changes.",
  examples: [
    ComponentExample(
      id: 'list_detail_layout_basic',
      title: 'Conversations',
      description:
          'Give it the `list`, the `detail` of the current choice — or '
          'null — and a `placeholder` for the desktop while nothing is '
          'chosen. On a phone, setting `detail` pushes it with the page '
          "route's transition and clearing it pops it; when the user goes "
          'back instead — the system back, a swipe from the edge on iOS '
          '— `onDetailClosed` is called, where you clear the choice. '
          '`resizable` lets the line between the two be dragged.',
      minPreviewHeight: 500,
      padding: const EdgeInsets.all(16),
      builder: (_) => const ListDetailLayoutBasicExample(),
    ),
  ],
);
