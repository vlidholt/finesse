import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/navigation_rail/navigation_rail_basic.dart';
import 'package:flutter/widgets.dart';

final navigationRailDoc = ComponentDoc(
  slug: 'navigation_rail',
  title: 'Navigation Rail',
  description:
      "An app's destinations down the start edge of a wide screen: the "
      'middle ground between the bottom bar of a phone and the top bar of '
      'a desktop window. It takes the same `NavigationDestination`s as the '
      'other bars, and `NavigationScaffold(layout: NavigationLayout.rail)` '
      'places one under the app bar.',
  examples: [
    ComponentExample(
      id: 'navigation_rail_basic',
      title: 'Rail',
      description:
          'An icon over a small label, with one line beside the selected '
          'destination that travels between them. `extended` puts the '
          'labels beside the icons in a wider rail, and the change is '
          "animated on the theme's `Motion.smooth`. `leading` sits at the "
          'top, a `NavigationAction` under it, and `trailing` at the '
          'bottom. The page beside it is a `DestinationStack`, which '
          'keeps each destination alive once it has been visited. Up and '
          'Down move the focus along the rail.',
      minPreviewHeight: 480,
      padding: const EdgeInsets.all(24),
      builder: (_) => const NavigationRailBasicExample(),
    ),
  ],
);
