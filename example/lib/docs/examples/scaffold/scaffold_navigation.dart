import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// One `NavigationScaffold`, three arrangements. Desktop and Phone switch
/// the frame's form factor, which is what `UnaApp` does from the window
/// width, and leave the layout to it; Tablet asks for the rail.
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

  /// Null until one is chosen: the frame starts as whatever the app is.
  String? chosen;
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final frame =
        chosen ??
        (theme.formFactor == FormFactor.desktop ? 'desktop' : 'phone');
    final isDesktop = frame == 'desktop';
    final isTablet = frame == 'tablet';
    final formFactor = frame == 'phone'
        ? FormFactor.mobile
        : FormFactor.desktop;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Semantics(
          label: 'Frame',
          container: true,
          child: SegmentedControl<String>(
            value: frame,
            onChanged: (value) => setState(() => chosen = value),
            segments: const [
              Segment(value: 'desktop', label: Text('Desktop')),
              Segment(value: 'tablet', label: Text('Tablet')),
              Segment(value: 'phone', label: Text('Phone')),
            ],
          ),
        ),
        // The desktop frame is wider than a phone's screen, so it scrolls.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: theme.withFormFactor(formFactor),
            child: Container(
              width: isDesktop
                  ? 760
                  : isTablet
                  ? 560
                  : 340,
              height: 460,
              // Painted over the content, so nothing covers the frame's corners.
              foregroundDecoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.border),
                borderRadius: theme.radii.xl2,
              ),
              child: ClipRRect(
                // A rounded-rectangle clip, which the renderer draws without a
                // path, rather than `Container.clipBehavior`, which clips to the
                // decoration's path.
                borderRadius: theme.radii.xl2,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  removeBottom: true,
                  child: NavigationScaffold(
                    // Auto follows the form factor; the rail is asked for.
                    layout: isTablet
                        ? NavigationLayout.rail
                        : NavigationLayout.auto,
                    destinations: _destinations,
                    selectedIndex: index,
                    onDestinationSelected: (i) => setState(() => index = i),
                    leading: PhosphorIcon(
                      PhosphorIconsFill.waves,
                      size: 28,
                      color: theme.colorScheme.tint,
                    ),
                    title: const Text('Demo'),
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
                    // Each destination's page is built when it is first
                    // shown and kept, with its scroll offset, after that.
                    body: DestinationStack(
                      index: index,
                      axis: isTablet ? Axis.vertical : Axis.horizontal,
                      builders: [
                        for (final destination in _destinations)
                          (context) => PageContainer(
                            scrollable: true,
                            child: UnaColumn(
                              gap: GapSize.lg,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var i = 1; i <= 4; i++)
                                  Card(
                                    title: Text('${destination.label} $i'),
                                    description: const Text(
                                      'The page scrolls beneath the bars.',
                                    ),
                                  ),
                              ],
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
