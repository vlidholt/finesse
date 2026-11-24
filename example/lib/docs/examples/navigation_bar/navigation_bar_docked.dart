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
