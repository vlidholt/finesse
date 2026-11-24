import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// One `NavigationScaffold`, two arrangements. The frame's theme is switched
/// between form factors, which is what `FinesseApp` does from the window
/// width.
class ScaffoldNavigationExample extends StatefulWidget {
  const ScaffoldNavigationExample({super.key});

  @override
  State<ScaffoldNavigationExample> createState() =>
      _ScaffoldNavigationExampleState();
}

class _ScaffoldNavigationExampleState extends State<ScaffoldNavigationExample> {
  static const _destinations = [
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
      icon: PhosphorIcon(PhosphorIconsRegular.chatCircleDots),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.chatCircleDots),
      label: 'Messages',
      badgeCount: 3,
    ),
    // In the top bar on a desktop; behind an app bar button on a phone.
    NavigationDestination(
      icon: PhosphorIcon(PhosphorIconsRegular.bell),
      selectedIcon: PhosphorIcon(PhosphorIconsFill.bell),
      label: 'Notifications',
      showInBottomBar: false,
    ),
  ];

  /// Null until a tab is chosen: the frame starts as whatever the app is.
  FormFactor? chosen;
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formFactor = chosen ?? theme.formFactor;
    final isDesktop = formFactor == FormFactor.desktop;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        SizedBox(
          width: 220,
          child: Tabs<FormFactor>(
            value: formFactor,
            expandTabs: true,
            onChanged: (value) => setState(() => chosen = value),
            tabs: const [
              Tab(value: FormFactor.desktop, child: Text('Desktop')),
              Tab(value: FormFactor.mobile, child: Text('Phone')),
            ],
          ),
        ),
        // The desktop frame is wider than a phone's screen, so it scrolls.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: theme.withFormFactor(formFactor),
            child: Container(
              width: isDesktop ? 760 : 340,
              height: 460,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: theme.radii.xl2,
              ),
              // Painted over the content, so nothing covers the frame's corners.
              foregroundDecoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.border),
                borderRadius: theme.radii.xl2,
              ),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: NavigationScaffold(
                  destinations: _destinations,
                  selectedIndex: index,
                  onDestinationSelected: (i) => setState(() => index = i),
                  leading: PhosphorIcon(
                    PhosphorIconsFill.waves,
                    size: 28,
                    color: theme.colorScheme.tint,
                  ),
                  title: const Text('Strand'),
                  actions: [
                    IconButton.ghost(
                      icon: const PhosphorIcon(PhosphorIconsRegular.gear),
                      semanticLabel: 'Settings',
                      onPressed: () {},
                    ),
                  ],
                  mobileActions: [
                    IconButton.ghost(
                      icon: const PhosphorIcon(PhosphorIconsRegular.bell),
                      semanticLabel: 'Notifications',
                      onPressed: () => setState(() => index = 3),
                    ),
                  ],
                  action: NavigationAction(
                    icon: const PhosphorIcon(PhosphorIconsBold.plus),
                    label: 'Create post',
                    onPressed: () {},
                  ),
                  body: PageContainer(
                    scrollable: true,
                    child: FinesseColumn(
                      gap: GapSize.lg,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 1; i <= 4; i++)
                          Card(
                            title: Text('${_destinations[index].label} $i'),
                            description: const Text(
                              'The page scrolls beneath both bars.',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
