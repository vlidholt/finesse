import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The same menu on a phone: one button in the app bar, and a sheet with
/// every entry. The links are rows, and each trigger's content is a section
/// under its label.
class NavigationMenuCollapsedExample extends StatefulWidget {
  const NavigationMenuCollapsedExample({super.key});

  @override
  State<NavigationMenuCollapsedExample> createState() =>
      _NavigationMenuCollapsedExampleState();
}

class _NavigationMenuCollapsedExampleState
    extends State<NavigationMenuCollapsedExample> {
  String page = 'Pricing';

  void go(String to) => setState(() => page = to);

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Strand'),
          actions: [
            // Inside the frame the theme is a phone's, so the menu
            // collapses by itself; `collapsed: true` does it anywhere.
            NavigationMenu(
              items: [
                NavigationMenuItem(
                  label: const Text('Products'),
                  builder: (context) => Column(
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
                    ],
                  ),
                ),
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
          ],
        ),
        body: Center(
          child: Text(
            'You are on $page',
            style: Theme.of(context).textTheme.muted,
          ),
        ),
      ),
    );
  }
}
