import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/app_bar/app_bar_basic.dart';
import 'package:example/docs/examples/app_bar/app_bar_middle.dart';
import 'package:flutter/widgets.dart';

final appBarDoc = ComponentDoc(
  slug: 'app_bar',
  title: 'App Bar',
  description:
      'The bar across the top of a screen: a logo or back button, a title, '
      'and actions. Its height follows the form factor and its fill the '
      'bar opacity of the style. Put it in a `Scaffold` so the page scrolls '
      'beneath it.',
  examples: [
    ComponentExample(
      id: 'app_bar_basic',
      title: 'Leading, title and actions',
      description:
          'Without a `middle`, the title takes the space between '
          '`leading` and `actions` and truncates when it runs out.',
      minPreviewHeight: 260,
      builder: (_) => const AppBarBasicExample(),
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
