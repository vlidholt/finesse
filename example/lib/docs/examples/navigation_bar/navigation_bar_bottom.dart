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
