# Navigation Bar

The destinations of an app. `NavigationBar` is the row of icons over labels for the top of a wide screen; `BottomNavigationBar` is the bar at the bottom of a phone, icons only unless it is asked for labels. Both take the same `NavigationDestination`s, and `NavigationScaffold` switches between them — or puts them in a rail down the start edge, for a tablet. For a sidebar of sections, use `Sidebar`.

## Top bar

Give each destination a `selectedIcon`, usually the fill weight of its icon. `badgeCount` pins a count to the icon and `showBadge` a dot.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The top bar of a wide screen. Each destination has a filled icon for its
/// selected state; a count or a dot is pinned to the icon as a badge.
class NavigationBarTopExample extends StatefulWidget {
  const NavigationBarTopExample({super.key});

  @override
  State<NavigationBarTopExample> createState() =>
      _NavigationBarTopExampleState();
}

class _NavigationBarTopExampleState extends State<NavigationBarTopExample> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    // Four 88-point destinations do not fit a phone: this bar is for wide
    // screens, so here it scrolls sideways when it has to.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: PhosphorIcon(PhosphorIconsRegular.house),
            selectedIcon: PhosphorIcon(PhosphorIconsFill.house),
            label: 'Home',
          ),
          NavigationDestination(
            icon: PhosphorIcon(PhosphorIconsRegular.usersThree),
            selectedIcon: PhosphorIcon(PhosphorIconsFill.usersThree),
            label: 'Network',
            // A dot: something is new, without saying how much.
            showBadge: true,
          ),
          NavigationDestination(
            icon: PhosphorIcon(PhosphorIconsRegular.chatCircleDots),
            selectedIcon: PhosphorIcon(PhosphorIconsFill.chatCircleDots),
            label: 'Messages',
            badgeCount: 3,
          ),
          NavigationDestination(
            icon: PhosphorIcon(PhosphorIconsRegular.bell),
            selectedIcon: PhosphorIcon(PhosphorIconsFill.bell),
            label: 'Notifications',
            badgeCount: 128,
          ),
        ],
      ),
    );
  }
}
```

## Floating bottom bar with an action

In the default style the bottom bar floats: a glass pill as wide as its destinations. A `NavigationAction` sits between the two halves, for the one thing the app is for — or, with `actionPlacement: NavigationActionPlacement.detached`, on a disc of its own at the end of the bar, the destinations on a pill as wide as they are: the split bar of iOS 26, which a bar on Liquid Glass always is. Labels are read to assistive technology rather than shown.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The phone's bar: a floating glass pill with the primary action between
/// the two halves of the destinations, or detached on a disc of its own
/// at the end, as on Liquid Glass.
class NavigationBarBottomExample extends StatefulWidget {
  const NavigationBarBottomExample({super.key});

  @override
  State<NavigationBarBottomExample> createState() =>
      _NavigationBarBottomExampleState();
}

class _NavigationBarBottomExampleState
    extends State<NavigationBarBottomExample> {
  int index = 0;
  int posts = 0;
  var placement = NavigationActionPlacement.between;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        SegmentedControl<NavigationActionPlacement>(
          value: placement,
          onChanged: (value) => setState(() => placement = value),
          segments: const [
            Segment(
              value: NavigationActionPlacement.between,
              label: Text('Between'),
            ),
            Segment(
              value: NavigationActionPlacement.detached,
              label: Text('Detached'),
            ),
          ],
        ),
        Text(
          posts == 0 ? 'Tap + to post' : 'Posts created: $posts',
          style: theme.textTheme.muted,
        ),
        BottomNavigationBar(
          floating: true,
          actionPlacement: placement,
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          action: NavigationAction(
            icon: const PhosphorIcon(PhosphorIconsBold.plus),
            label: 'Create post',
            onPressed: () => setState(() => posts++),
          ),
          destinations: const [
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.house),
              selectedIcon: PhosphorIcon(PhosphorIconsFill.house),
              label: 'Home',
            ),
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.usersThree),
              selectedIcon: PhosphorIcon(PhosphorIconsFill.usersThree),
              label: 'Network',
            ),
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.chatCircleDots),
              selectedIcon: PhosphorIcon(PhosphorIconsFill.chatCircleDots),
              label: 'Messages',
              badgeCount: 3,
            ),
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.briefcase),
              selectedIcon: PhosphorIcon(PhosphorIconsFill.briefcase),
              label: 'Jobs',
            ),
          ],
        ),
      ],
    );
  }
}
```

## Docked bottom bar

Styles decide whether the bar floats; `floating` overrides them either way.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// With `floating: false` the bar spans the bottom edge and the destinations
/// share its width.
class NavigationBarDockedExample extends StatefulWidget {
  const NavigationBarDockedExample({super.key});

  @override
  State<NavigationBarDockedExample> createState() =>
      _NavigationBarDockedExampleState();
}

class _NavigationBarDockedExampleState
    extends State<NavigationBarDockedExample> {
  static const _destinations = [
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.house),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.house),
      label: 'Home',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
      selectedIcon: PhosphorIcon(PhosphorIconsBold.magnifyingGlass),
      label: 'Search',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.bell),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.bell),
      label: 'Notifications',
      showBadge: true,
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.user),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.user),
      label: 'Profile',
    ),
  ];

  int index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 360,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: theme.radii.xl,
      ),
      // Painted over the content, so nothing covers the frame's corners.
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: theme.radii.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120,
            child: Center(
              child: Text(
                _destinations[index].label,
                style: theme.textTheme.muted,
              ),
            ),
          ),
          BottomNavigationBar(
            floating: false,
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => index = i),
            destinations: _destinations,
          ),
        ],
      ),
    );
  }
}
```

## With labels

`showLabels` puts each label under its icon, in the caption style; the selection stays behind the icon. Set it for a whole app with the theme's `bottomNavigationBarTheme`.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// `showLabels` puts each destination's label under its icon, floating or
/// docked. The bar is one line of the label taller.
class NavigationBarLabelsExample extends StatefulWidget {
  const NavigationBarLabelsExample({super.key});

  @override
  State<NavigationBarLabelsExample> createState() =>
      _NavigationBarLabelsExampleState();
}

class _NavigationBarLabelsExampleState
    extends State<NavigationBarLabelsExample> {
  static const _destinations = [
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.house),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.house),
      label: 'Home',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
      selectedIcon: PhosphorIcon(PhosphorIconsBold.magnifyingGlass),
      label: 'Search',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.chatCircleDots),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.chatCircleDots),
      label: 'Messages',
      badgeCount: 3,
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.user),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.user),
      label: 'Profile',
    ),
  ];

  int index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.layoutTheme.gap(GapSize.xl),
        children: [
          for (final floating in [true, false])
            // No screen under the bar here, so no safe area to keep clear
            // of.
            MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: BottomNavigationBar(
                showLabels: true,
                floating: floating,
                selectedIndex: index,
                onDestinationSelected: (i) => setState(() => index = i),
                destinations: _destinations,
              ),
            ),
        ],
      ),
    );
  }
}
```
