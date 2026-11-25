import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
