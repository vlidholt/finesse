import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/navigation_bar/navigation_bar_bottom.dart';
import 'package:example/docs/examples/navigation_bar/navigation_bar_docked.dart';
import 'package:example/docs/examples/navigation_bar/navigation_bar_labels.dart';
import 'package:example/docs/examples/navigation_bar/navigation_bar_top.dart';
import 'package:flutter/widgets.dart';

final navigationBarDoc = ComponentDoc(
  slug: 'navigation_bar',
  title: 'Navigation Bar',
  description:
      'The destinations of an app. `NavigationBar` is the row of icons over '
      'labels for the top of a wide screen; `BottomNavigationBar` is the '
      'bar at the bottom of a phone, icons only unless it is asked for '
      'labels. Both take the same `NavigationDestination`s, and '
      '`NavigationScaffold` switches between them — or puts them in a '
      'rail down the start edge, for a tablet. For a sidebar of '
      'sections, use `Sidebar`.',
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
          'the two halves, for the one thing the app is for — or, with '
          '`actionPlacement: NavigationActionPlacement.detached`, on a '
          'disc of its own at the end of the bar, the destinations on a '
          'pill as wide as they are: the split bar of iOS 26, which a bar '
          'on Liquid Glass always is. Labels are read to assistive '
          'technology rather than shown.',
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
    ComponentExample(
      id: 'navigation_bar_labels',
      title: 'With labels',
      description:
          '`showLabels` puts each label under its icon, in the caption '
          'style; the selection stays behind the icon. Set it for a whole '
          "app with the theme's `bottomNavigationBarTheme`.",
      minPreviewHeight: 280,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
      builder: (_) => const NavigationBarLabelsExample(),
    ),
  ],
);
