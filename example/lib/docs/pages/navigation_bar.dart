import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/navigation_bar/navigation_bar_bottom.dart';
import 'package:example/docs/examples/navigation_bar/navigation_bar_docked.dart';
import 'package:example/docs/examples/navigation_bar/navigation_bar_top.dart';
import 'package:flutter/widgets.dart';

final navigationBarDoc = ComponentDoc(
  slug: 'navigation_bar',
  title: 'Navigation Bar',
  description:
      'The destinations of an app. `NavigationBar` is the row of icons over '
      'labels for the top of a wide screen; `BottomNavigationBar` is the '
      'icon-only bar at the bottom of a phone. Both take the same '
      '`NavigationDestination`s, and `NavigationScaffold` switches between '
      'them.',
  examples: [
    ComponentExample(
      id: 'navigation_bar_top',
      title: 'Top bar',
      description:
          'Give each destination a `selectedIcon`, usually the fill '
          'weight of its icon. `badgeCount` pins a count to the icon and '
          '`showBadge` a dot.',
      builder: (_) => const NavigationBarTopExample(),
    ),
    ComponentExample(
      id: 'navigation_bar_bottom',
      title: 'Floating bottom bar with an action',
      description:
          'In the default style the bottom bar floats: a glass pill as '
          'wide as its destinations. A `NavigationAction` sits between '
          'the two halves, for the one thing the app is for. Labels are '
          'read to assistive technology rather than shown.',
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
      builder: (_) => const NavigationBarBottomExample(),
    ),
    ComponentExample(
      id: 'navigation_bar_docked',
      title: 'Docked bottom bar',
      description:
          'Styles decide whether the bar floats; `floating` overrides '
          'them either way.',
      minPreviewHeight: 280,
      builder: (_) => const NavigationBarDockedExample(),
    ),
  ],
);
