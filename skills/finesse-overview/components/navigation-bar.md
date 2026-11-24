# Navigation Bar

The destinations of an app. `NavigationBar` is the row of icons over labels for the top of a wide screen; `BottomNavigationBar` is the icon-only bar at the bottom of a phone. Both take the same `NavigationDestination`s, and `NavigationScaffold` switches between them.

## Top bar

Give each destination a `selectedIcon`, usually the fill weight of its icon. `badgeCount` pins a count to the icon and `showBadge` a dot.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
            icon: Icon(PhosphorIconsRegular.house),
            selectedIcon: Icon(PhosphorIconsFill.house),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.usersThree),
            selectedIcon: Icon(PhosphorIconsFill.usersThree),
            label: 'Network',
            // A dot: something is new, without saying how much.
            showBadge: true,
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.chatCircleDots),
            selectedIcon: Icon(PhosphorIconsFill.chatCircleDots),
            label: 'Messages',
            badgeCount: 3,
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.bell),
            selectedIcon: Icon(PhosphorIconsFill.bell),
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

In the default style the bottom bar floats: a glass pill as wide as its destinations. A `NavigationAction` sits between the two halves, for the one thing the app is for. Labels are read to assistive technology rather than shown.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The phone's bar: a floating glass pill with the primary action between
/// the two halves of the destinations.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Text(
          posts == 0 ? 'Tap + to post' : 'Posts created: $posts',
          style: theme.textTheme.muted,
        ),
        BottomNavigationBar(
          floating: true,
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          action: NavigationAction(
            icon: const Icon(PhosphorIconsBold.plus),
            label: 'Create post',
            onPressed: () => setState(() => posts++),
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.house),
              selectedIcon: Icon(PhosphorIconsFill.house),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.usersThree),
              selectedIcon: Icon(PhosphorIconsFill.usersThree),
              label: 'Network',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.chatCircleDots),
              selectedIcon: Icon(PhosphorIconsFill.chatCircleDots),
              label: 'Messages',
              badgeCount: 3,
            ),
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.briefcase),
              selectedIcon: Icon(PhosphorIconsFill.briefcase),
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
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
      icon: Icon(PhosphorIconsRegular.house),
      selectedIcon: Icon(PhosphorIconsFill.house),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(PhosphorIconsRegular.magnifyingGlass),
      selectedIcon: Icon(PhosphorIconsBold.magnifyingGlass),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(PhosphorIconsRegular.bell),
      selectedIcon: Icon(PhosphorIconsFill.bell),
      label: 'Notifications',
      showBadge: true,
    ),
    NavigationDestination(
      icon: Icon(PhosphorIconsRegular.user),
      selectedIcon: Icon(PhosphorIconsFill.user),
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

