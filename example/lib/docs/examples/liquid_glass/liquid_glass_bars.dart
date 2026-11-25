import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The bars of a screen on Liquid Glass. The app bar has no fill of its
/// own: what scrolls under it is blurred and faded into the page, and its
/// buttons sit on glass capsules. The bottom bar is a capsule whose
/// selection is a lens that slides between the tabs, with its action on a
/// capsule of its own beside them: iOS 26's split bar.
class LiquidGlassBarsExample extends StatefulWidget {
  const LiquidGlassBarsExample({super.key});

  @override
  State<LiquidGlassBarsExample> createState() => _LiquidGlassBarsExampleState();
}

final _themes = Expando<ThemeData>();

/// The ambient theme with Liquid Glass on everywhere, derived once.
ThemeData _liquid(ThemeData ambient) => _themes[ambient] ??= ambient.copyWith(
  liquidGlass: ambient.liquidGlass.copyWith(mode: LiquidGlassMode.always),
);

class _LiquidGlassBarsExampleState extends State<LiquidGlassBarsExample> {
  var selected = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: _liquid(theme),
      child: ClipRRect(
        borderRadius: theme.radii.xl2,
        child: SizedBox(
          width: 390,
          height: 520,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Inbox'),
              surfaceBehavior: AppBarSurfaceBehavior.whenScrolled,
              actions: [
                IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.funnel),
                  semanticLabel: 'Filter',
                  onPressed: () {},
                ),
                IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.dotsThree),
                  semanticLabel: 'More',
                  onPressed: () {},
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedIndex: selected,
              onDestinationSelected: (index) =>
                  setState(() => selected = index),
              action: NavigationAction(
                icon: const PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
                label: 'Search',
                onPressed: () {},
              ),
              destinations: const [
                NavigationDestination(
                  icon: PhosphorIcon(PhosphorIconsRegular.tray),
                  selectedIcon: PhosphorIcon(PhosphorIconsFill.tray),
                  label: 'Inbox',
                ),
                NavigationDestination(
                  icon: PhosphorIcon(PhosphorIconsRegular.paperPlaneTilt),
                  selectedIcon: PhosphorIcon(PhosphorIconsFill.paperPlaneTilt),
                  label: 'Sent',
                ),
                NavigationDestination(
                  icon: PhosphorIcon(PhosphorIconsRegular.archive),
                  selectedIcon: PhosphorIcon(PhosphorIconsFill.archive),
                  label: 'Archive',
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: 30,
              itemBuilder: (context, index) => ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HSLColor.fromAHSL(
                      1,
                      index * 37 % 360,
                      .6,
                      .55,
                    ).toColor(),
                  ),
                ),
                title: Text('Message ${index + 1}'),
                subtitle: const Text('Scroll me under the bars'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
