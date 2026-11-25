import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
