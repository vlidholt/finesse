import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A site's top navigation. Rest the pointer on Products or Resources, then
/// move to the other: the one panel slides under the trigger and resizes
/// for its content. Tab, the arrow keys and Escape work it from the
/// keyboard.
class NavigationMenuBasicExample extends StatefulWidget {
  const NavigationMenuBasicExample({super.key});

  @override
  State<NavigationMenuBasicExample> createState() =>
      _NavigationMenuBasicExampleState();
}

class _NavigationMenuBasicExampleState
    extends State<NavigationMenuBasicExample> {
  String page = 'Customers';

  void go(String to) => setState(() => page = to);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NavigationMenu(
          items: [
            NavigationMenuItem(
              label: const Text('Products'),
              // The panel's content: links in a column, as wide as it says.
              builder: (context) => SizedBox(
                width: 340,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NavigationMenuLink(
                      leading: const PhosphorIcon(
                        PhosphorIconsRegular.chartLine,
                      ),
                      title: const Text('Analytics'),
                      description: const Text(
                        'Traffic and conversion, as it happens.',
                      ),
                      selected: page == 'Analytics',
                      onPressed: () => go('Analytics'),
                    ),
                    NavigationMenuLink(
                      leading: const PhosphorIcon(
                        PhosphorIconsRegular.lightning,
                      ),
                      title: const Text('Automation'),
                      description: const Text(
                        'Rules that run while you sleep.',
                      ),
                      selected: page == 'Automation',
                      onPressed: () => go('Automation'),
                    ),
                    NavigationMenuLink(
                      leading: const PhosphorIcon(
                        PhosphorIconsRegular.shieldCheck,
                      ),
                      title: const Text('Security'),
                      description: const Text(
                        'Single sign-on, audit logs and roles.',
                      ),
                      selected: page == 'Security',
                      onPressed: () => go('Security'),
                    ),
                  ],
                ),
              ),
            ),
            NavigationMenuItem(
              label: const Text('Resources'),
              builder: (context) => SizedBox(
                width: 220,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final name in ['Documentation', 'Changelog', 'Blog'])
                      NavigationMenuLink(
                        title: Text(name),
                        selected: page == name,
                        onPressed: () => go(name),
                      ),
                  ],
                ),
              ),
            ),
            // An entry without a panel is a link.
            NavigationMenuItem(
              label: const Text('Pricing'),
              selected: page == 'Pricing',
              onPressed: () => go('Pricing'),
            ),
            NavigationMenuItem(
              label: const Text('Customers'),
              selected: page == 'Customers',
              onPressed: () => go('Customers'),
            ),
          ],
        ),
        const Gap.xl(),
        Text('You are on $page', style: theme.textTheme.muted),
      ],
    );
  }
}
