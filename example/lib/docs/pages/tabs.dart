import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/tabs/tabs_basic.dart';
import 'package:example/docs/examples/tabs/tabs_list.dart';
import 'package:example/docs/examples/tabs/tabs_underline.dart';

final tabsDoc = ComponentDoc(
  slug: 'tabs',
  title: 'Tabs',
  description:
      'Sections of content shown one at a time: a `TabBar` with the '
      "selected tab's `content` under it. Controlled with `value` and "
      '`onChanged`, or by a `TabsController`. On a touch screen the '
      "content can be swiped to the next tab's, and the bar's selection "
      'follows the finger.',
  examples: [
    ComponentExample(
      id: 'tabs_basic',
      title: 'Default',
      description:
          'The segmented strip is as wide as its tabs; `expandTabs` makes '
          'them share the width, and `tabBarAlignment` places a strip that '
          'is narrower than its content. A tab that is not showing keeps '
          'its state unless `maintainState` is false.',
      minPreviewHeight: 480,
      builder: (_) => const TabsBasicExample(),
    ),
    ComponentExample(
      id: 'tabs_underline',
      title: 'Underline',
      description:
          '`variant: TabBarVariant.underline` puts the content under a '
          'row of text tabs. The content is as tall as the tab showing; '
          'set `expandContent` to fill the height left under the bar '
          'instead. `swipeable: false` switches the swipe off.',
      minPreviewHeight: 260,
      builder: (_) => const TabsUnderlineExample(),
    ),
    ComponentExample(
      id: 'tabs_list',
      title: 'Tabs list',
      description:
          'With no content, only the bar is shown. To pick a value this '
          'way, use a `SegmentedControl`, which a screen reader hears as '
          'radio buttons rather than tabs.',
      minPreviewHeight: 160,
      builder: (_) => const TabsListExample(),
    ),
  ],
);
