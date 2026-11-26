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
