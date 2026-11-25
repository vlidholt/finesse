# Navigation Menu

The links of a site or an app's top level, in a row. Some go somewhere; some open a panel of further links under the row. Put it in an `AppBar`'s `middle` or `actions`.

## Links and panels

A `NavigationMenuItem` with a `builder` is a trigger: its panel opens when the pointer rests on it, on a press, and with Enter, Space or the down arrow. There is one panel for the whole row: moving to another trigger slides it under that trigger and resizes it for the new content. An item without a builder is a link. `selected` marks where the user is, and the mark moves to the open trigger while a panel is open. A `NavigationMenuLink` in a panel closes the menu when it is pressed.

```dart
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
```

## On a phone

A row of links has no room on a phone, and a finger does not hover. There — or anywhere with `collapsed: true` — the menu is one button that opens a sheet: links as rows a touch target tall, and each trigger's content as a section under its label. The content is laid out at the sheet's width, so build it to fit what it is given.

```dart
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
          title: const Text('Demo'),
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
```
