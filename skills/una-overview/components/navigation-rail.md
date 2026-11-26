# Navigation Rail

An app's destinations down the start edge of a wide screen: the middle ground between the bottom bar of a phone and the top bar of a desktop window. It takes the same `NavigationDestination`s as the other bars, and `NavigationScaffold(layout: NavigationLayout.rail)` places one under the app bar.

## Rail

An icon over a small label, with one line beside the selected destination that travels between them. `extended` puts the labels beside the icons in a wider rail, and the change is animated on the theme's `Motion.smooth`. `leading` sits at the top, a `NavigationAction` under it, and `trailing` at the bottom. The page beside it is a `DestinationStack`, which keeps each destination alive once it has been visited. Up and Down move the focus along the rail.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A rail beside a page. The button at its foot extends it: the labels
/// move from under the icons to beside them.
class NavigationRailBasicExample extends StatefulWidget {
  const NavigationRailBasicExample({super.key});

  @override
  State<NavigationRailBasicExample> createState() =>
      _NavigationRailBasicExampleState();
}

class _NavigationRailBasicExampleState
    extends State<NavigationRailBasicExample> {
  static const _destinations = [
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.tray),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.tray),
      label: 'Inbox',
      badgeCount: 4,
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.paperPlaneTilt),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.paperPlaneTilt),
      label: 'Sent',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.notePencil),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.notePencil),
      label: 'Drafts',
    ),
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.archive),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.archive),
      label: 'Archive',
    ),
  ];

  int index = 0;
  bool extended = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 560,
      height: 420,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: theme.radii.xl2,
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: theme.radii.xl2,
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: Row(
          children: [
            NavigationRail(
              extended: extended,
              selectedIndex: index,
              onDestinationSelected: (i) => setState(() => index = i),
              destinations: _destinations,
              leading: PhosphorIcon(
                PhosphorIconsFill.waves,
                size: 28,
                color: theme.colorScheme.tint,
              ),
              action: NavigationAction(
                icon: const PhosphorIcon(PhosphorIconsBold.plus),
                label: 'Compose',
                onPressed: () {},
              ),
              trailing: IconButton.ghost(
                icon: PhosphorIcon(
                  extended
                      ? PhosphorIconsRegular.caretDoubleLeft
                      : PhosphorIconsRegular.caretDoubleRight,
                ),
                semanticLabel: extended ? 'Collapse' : 'Expand',
                onPressed: () => setState(() => extended = !extended),
              ),
            ),
            Expanded(
              // Each folder keeps its place while another one shows.
              child: DestinationStack(
                index: index,
                axis: Axis.vertical,
                builders: [
                  for (final destination in _destinations)
                    (context) => ListView(
                      padding: EdgeInsets.all(
                        theme.layoutTheme.gap(GapSize.lg),
                      ),
                      children: [
                        Text(destination.label, style: theme.textTheme.h4),
                        const Gap.md(),
                        for (var i = 1; i <= 8; i++)
                          ListTile(
                            title: Text('${destination.label} $i'),
                            subtitle: const Text('Scroll, leave, come back'),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```
