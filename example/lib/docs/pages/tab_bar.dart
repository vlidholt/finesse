import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/tab_bar/tab_bar_expanded.dart';
import 'package:example/docs/examples/tab_bar/tab_bar_scrollable.dart';

final tabBarDoc = ComponentDoc(
  slug: 'tab_bar',
  title: 'Tab Bar',
  description:
      'A row of text tabs with a line under the selected one, for the '
      'sections of a page. `TabBar` only reports which tab is selected. '
      'Use `Tabs` instead for a segmented control: a filled strip with a '
      'raised selection that can also own and switch its content.',
  examples: [
    ComponentExample(
      id: 'tab_bar_expanded',
      title: 'Expanded',
      description:
          'By default the tabs share the width equally. Show the '
          'matching section yourself from `selectedIndex`.',
      builder: (_) => const TabBarExpandedExample(),
    ),
    ComponentExample(
      id: 'tab_bar_scrollable',
      title: 'Scrollable',
      description:
          'With `expand: false` each tab hugs its label, and the row '
          'scrolls sideways when the tabs do not fit.',
      minPreviewHeight: 160,
      builder: (_) => const TabBarScrollableExample(),
    ),
  ],
);
