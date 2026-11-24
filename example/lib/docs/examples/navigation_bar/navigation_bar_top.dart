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
