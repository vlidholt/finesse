import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/app_bar/app_bar_basic.dart';
import 'package:example/docs/examples/app_bar/app_bar_bottom.dart';
import 'package:example/docs/examples/app_bar/app_bar_center_title.dart';
import 'package:example/docs/examples/app_bar/app_bar_leading.dart';
import 'package:example/docs/examples/app_bar/app_bar_middle.dart';
import 'package:example/docs/examples/app_bar/app_bar_scrolled.dart';
import 'package:example/docs/examples/app_bar/app_bar_tabs.dart';
import 'package:flutter/widgets.dart';

final appBarDoc = ComponentDoc(
  slug: 'app_bar',
  title: 'App Bar',
  description:
      'The bar across the top of a screen: a logo or back button, a title, '
      'and actions. Its height follows the form factor and its fill the '
      'bar opacity of the style. Put it in a `Scaffold` so the page scrolls '
      'beneath it. For a bar that scrolls with the page or carries a large '
      'title, see `SliverAppBar`.',
  examples: [
    ComponentExample(
      id: 'app_bar_basic',
      title: 'Leading, title and actions',
      description:
          'Without a `middle`, the title takes the space between '
          '`leading` and `actions` and truncates when it runs out. It is '
          'the page\'s heading for a screen reader. A `Button` or '
          '`IconButton` in the bar that names no variant takes the bar\'s: '
          'a bare glyph on the bar\'s surface, whose glyph rather than box '
          'lines up with the margin at either end; a plain icon on a '
          'capsule of Liquid Glass; an outline disc over a '
          '`SliverAppBar.background` picture. Name a variant to keep it.',
      minPreviewHeight: 260,
      builder: (_) => const AppBarBasicExample(),
    ),
    ComponentExample(
      id: 'app_bar_leading',
      title: 'The leading button it shows by itself',
      description:
          'A bar with no `leading` shows the button its place calls for: '
          'a `CloseButton` on a full-screen dialog, a `BackButton` on a '
          'page that can be popped, a menu button over a `Scaffold` with '
          'a drawer, and nothing on the first page. '
          '`automaticallyImplyLeading: false` turns it off.',
      minPreviewHeight: 480,
      padding: const EdgeInsets.all(24),
      builder: (_) => const AppBarLeadingExample(),
    ),
    ComponentExample(
      id: 'app_bar_center_title',
      title: 'Centred title',
      description:
          '`centerTitle` centres the title in the bar whatever sits on '
          'either side, and cuts it short rather than laying it under the '
          'buttons. `AppBarTheme.centerTitle` sets it for the whole app.',
      minPreviewHeight: 320,
      padding: const EdgeInsets.all(24),
      builder: (_) => const AppBarCenterTitleExample(),
    ),
    ComponentExample(
      id: 'app_bar_bottom',
      title: 'A row under the toolbar',
      description:
          '`bottom` is a second row inside the bar\'s surface and above '
          'its hairline — a `TabBar`, a search field, filter chips. It '
          'adds its own height, and the scaffold insets the page for all '
          'of it.',
      minPreviewHeight: 480,
      padding: const EdgeInsets.all(24),
      builder: (_) => const AppBarBottomExample(),
    ),
    ComponentExample(
      id: 'app_bar_tabs',
      title: 'Tabs and their pages',
      description:
          'A `TabBar` in `bottom` and a `TabBarView` as the body share one '
          '`TabsController`: tap a tab or swipe the page, and the line '
          'under the tabs follows.',
      minPreviewHeight: 520,
      padding: const EdgeInsets.all(24),
      builder: (_) => const AppBarTabsExample(),
    ),
    ComponentExample(
      id: 'app_bar_scrolled',
      title: 'A surface only when scrolled',
      description:
          'With `surfaceBehavior: AppBarSurfaceBehavior.whenScrolled` the '
          'fill, the hairline and the blur are absent while the page is at '
          'its top and fade in once content scrolls under the bar. It '
          'needs a `Scaffold` above it, which is what tells the bar the '
          'page has moved; nothing is rebuilt while it does.',
      minPreviewHeight: 480,
      padding: const EdgeInsets.all(24),
      builder: (_) => const AppBarScrolledExample(),
    ),
    ComponentExample(
      id: 'app_bar_middle',
      title: 'With a middle',
      description:
          'A `middle` is centred in the bar whatever sits on either side, '
          'which is where a `NavigationBar` goes on a wide screen. '
          '`NavigationScaffold` builds this bar for you.',
      minPreviewHeight: 260,
      // The three zones need the width.
      padding: const EdgeInsets.all(16),
      builder: (_) => const AppBarMiddleExample(),
    ),
  ],
);
