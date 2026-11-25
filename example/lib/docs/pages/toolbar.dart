import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/toolbar/toolbar_basic.dart';
import 'package:example/docs/examples/toolbar/toolbar_docked.dart';
import 'package:flutter/widgets.dart';

final toolbarDoc = ComponentDoc(
  slug: 'toolbar',
  title: 'Toolbar',
  description:
      'A bar of actions along the bottom of a screen: what can be done '
      'with what is showing. It has the surface of a '
      "`BottomNavigationBar` and follows the same theme, so in a style "
      'whose bottom bar floats it is a glass pill, and otherwise it spans '
      'the bottom edge.',
  examples: [
    ComponentExample(
      id: 'toolbar_basic',
      title: 'In a Scaffold',
      description:
          "Give it to a `Scaffold` as its `bottomNavigationBar`: the page "
          'scrolls beneath it and is told how far to keep clear. '
          '`children` are the actions, usually `IconButton.ghost`s, and '
          '`trailing` the one that stands apart. The arrow keys move the '
          'focus along the bar.',
      minPreviewHeight: 480,
      padding: const EdgeInsets.all(24),
      builder: (_) => const ToolbarBasicExample(),
    ),
    ComponentExample(
      id: 'toolbar_docked',
      title: 'Docked',
      description:
          '`floating: false` docks the bar under a hairline. `leading` '
          'stands at the start, and `alignment` places the actions in the '
          'width that is left. Plain text and icons take the colour and '
          'size of the bar.',
      minPreviewHeight: 220,
      builder: (_) => const ToolbarDockedExample(),
    ),
  ],
);
