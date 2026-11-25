import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/tab_bar/tab_bar_expanded.dart';
import 'package:example/docs/examples/tab_bar/tab_bar_scrollable.dart';
import 'package:example/docs/examples/tab_bar/tab_bar_segmented.dart';
import 'package:example/docs/examples/tab_bar/tab_bar_view.dart';
import 'package:flutter/widgets.dart';

final tabBarDoc = ComponentDoc(
  slug: 'tab_bar',
  title: 'Tab Bar',
  description:
      'The list of tabs, in two looks: text tabs with a line under the '
      'selected one, and a filled strip with a raised pill. `TabBar` '
      'reports which tab was chosen through `value` and `onChanged`; a '
      '`TabBarView` shows the matching page, and `Tabs` is the two put '
      'together. To pick a value rather than show a view, use a '
      '`SegmentedControl`.',
  examples: [
    ComponentExample(
      id: 'tab_bar_expanded',
      title: 'Underline',
      description:
          'The default look, for the sections of a page. The tabs share '
          'the width equally, and each `Tab` has the `value` the bar '
          'reports when it is chosen. The bar is one stop for the Tab '
          'key: the arrow keys, Home and End move the selection.',
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
    ComponentExample(
      id: 'tab_bar_segmented',
      title: 'Segmented',
      description:
          '`variant: TabBarVariant.segmented` is the strip with a pill. '
          'It is as wide as its tabs unless `expand` is set. A tab can '
          'have a `leading` and a `trailing` widget, a `tooltip`, and be '
          'disabled.',
      minPreviewHeight: 180,
      builder: (_) => const TabBarSegmentedExample(),
    ),
    ComponentExample(
      id: 'tab_bar_view',
      title: 'With a TabBarView',
      description:
          'When the bar and its pages are placed apart, give both the '
          'same `TabsController`. `TabBarView` takes a page builder per '
          'value. Swipe a page and it follows the finger, with the line '
          'under the tabs travelling between them; let go and it springs '
          'to the nearer page. Given a height, as here, the view fills '
          'it; in a column it is as tall as the page it shows.',
      minPreviewHeight: 480,
      padding: const EdgeInsets.all(24),
      builder: (_) => const TabBarViewExample(),
    ),
  ],
);
