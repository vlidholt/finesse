# App Bar

The bar across the top of a screen: a logo or back button, a title, and actions. Its height follows the form factor and its fill the bar opacity of the style. Put it in a `Scaffold` so the page scrolls beneath it.

## Leading, title and actions

Without a `middle`, the title takes the space between `leading` and `actions` and truncates when it runs out.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A back button, a title and two actions. Without a `middle`, the title
/// takes the space between the leading widget and the actions.
class AppBarBasicExample extends StatelessWidget {
  const AppBarBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 520,
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
            // Not at the top of the screen here, so no status bar inset.
            primary: false,
            leading: IconButton.ghost(
              icon: const Icon(PhosphorIconsRegular.arrowLeft),
              semanticLabel: 'Back',
              onPressed: () {},
            ),
            title: const Text('Messages'),
            actions: [
              IconButton.ghost(
                icon: const Icon(PhosphorIconsRegular.magnifyingGlass),
                semanticLabel: 'Search',
                onPressed: () {},
              ),
              IconButton.ghost(
                icon: const Icon(PhosphorIconsRegular.notePencil),
                semanticLabel: 'New message',
                onPressed: () {},
              ),
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
    );
  }
}
```

## With a middle

A `middle` is centred in the bar whatever sits on either side, which is where a `NavigationBar` goes on a wide screen. `NavigationScaffold` builds this bar for you.

```dart
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
                child: Icon(
                  PhosphorIconsBold.waves,
                  size: 18,
                  color: theme.colorScheme.primaryForeground,
                ),
              ),
              title: const TextField(
                placeholder: Text('Search'),
                leading: Icon(PhosphorIconsRegular.magnifyingGlass),
              ),
              middle: NavigationBar(
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
                  ),
                  NavigationDestination(
                    icon: Icon(PhosphorIconsRegular.briefcase),
                    selectedIcon: Icon(PhosphorIconsFill.briefcase),
                    label: 'Jobs',
                  ),
                ],
              ),
              actions: [
                IconButton.ghost(
                  icon: const Icon(PhosphorIconsRegular.bell),
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
```

