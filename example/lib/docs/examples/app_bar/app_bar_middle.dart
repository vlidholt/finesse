import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The three-zone bar of a wide screen: a logo and a search field at the
/// start, the destinations centred, the actions at the end.
class AppBarMiddleExample extends StatefulWidget {
  const AppBarMiddleExample({super.key});

  @override
  State<AppBarMiddleExample> createState() => _AppBarMiddleExampleState();
}

class _AppBarMiddleExampleState extends State<AppBarMiddleExample> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A desktop arrangement: it needs the width, so on a narrow screen the
    // frame scrolls sideways rather than squeezing the three zones together.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 800,
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
            AppBar(
              primary: false,
              leading: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: theme.radii.md,
                ),
                child: PhosphorIcon(
                  PhosphorIconsBold.waves,
                  size: 18,
                  color: theme.colorScheme.primaryForeground,
                ),
              ),
              title: const TextField(
                placeholder: Text('Search'),
                leading: PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
              ),
              middle: NavigationBar(
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
                  ),
                  NavigationDestination(
                    icon: PhosphorIcon(PhosphorIconsRegular.briefcase),
                    selectedIcon: PhosphorIcon(PhosphorIconsFill.briefcase),
                    label: 'Jobs',
                  ),
                ],
              ),
              actions: [
                IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.bell),
                  semanticLabel: 'Notifications',
                  onPressed: () {},
                ),
                const Avatar('', fallback: Text('NH')),
              ],
            ),
            SizedBox(
              height: 120,
              child: Center(
                child: Text('Page content', style: theme.textTheme.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
