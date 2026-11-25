import 'package:finesse/src/components/app_bar.dart';
import 'package:finesse/src/components/navigation_bar.dart';
import 'package:finesse/src/components/scaffold.dart';
import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// A [Scaffold] whose navigation adapts to the theme's form factor.
///
/// On a desktop the [destinations] sit in the middle of the [AppBar], between
/// [leading], [title] and [actions]. On a phone the app bar shrinks to
/// [leading] and [mobileActions], and the destinations move to a
/// [BottomNavigationBar] with [action] in its middle.
///
/// ```dart
/// NavigationScaffold(
///   leading: const Logo(),
///   title: const SearchField(),
///   destinations: destinations,
///   selectedIndex: index,
///   onDestinationSelected: (i) => setState(() => index = i),
///   action: NavigationAction(
///     icon: const PhosphorIcon(PhosphorIconsRegular.plus),
///     label: 'Create post',
///     onPressed: _compose,
///   ),
///   body: pages[index],
/// )
/// ```
///
/// A destination can opt out of either bar with
/// [NavigationDestination.showInTopBar] and
/// [NavigationDestination.showInBottomBar] — notifications that live in the
/// top bar on a desktop but behind an app bar button on a phone, say.
/// [selectedIndex] and [onDestinationSelected] always use indices into the
/// full [destinations] list.
class NavigationScaffold extends StatelessWidget {
  /// Creates an adaptive navigation scaffold.
  const NavigationScaffold({
    required this.destinations,
    required this.selectedIndex,
    required this.body,
    this.onDestinationSelected,
    this.leading,
    this.title,
    this.actions = const [],
    this.mobileActions,
    this.action,
    this.mobileAppBar,
    this.showMobileAppBar = true,
    this.showBottomNavigationBar = true,
    this.backgroundColor,
    super.key,
  });

  /// Every destination of the app.
  final List<NavigationDestination> destinations;

  /// The index into [destinations] of the selected one.
  final int? selectedIndex;

  /// Called with the index into [destinations] of the one that was tapped.
  final ValueChanged<int>? onDestinationSelected;

  /// The page.
  final Widget body;

  /// The widget at the start of the app bar, usually a logo.
  final Widget? leading;

  /// The widget after [leading] on a desktop, usually a search field.
  final Widget? title;

  /// The app bar's actions on a desktop.
  final List<Widget> actions;

  /// The app bar's actions on a phone. Defaults to [actions].
  final List<Widget>? mobileActions;

  /// The primary action in the middle of the bottom bar on a phone.
  final NavigationAction? action;

  /// Replaces the app bar on a phone, for a screen with its own header such
  /// as a conversation.
  final Widget? mobileAppBar;

  /// Whether a phone shows an app bar at all.
  final bool showMobileAppBar;

  /// Whether a phone shows the bottom navigation bar. Turn it off for a
  /// screen that needs the whole height, such as a conversation.
  final bool showBottomNavigationBar;

  /// The page's colour. Defaults to the theme's background.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<int> indicesWhere(bool Function(NavigationDestination) test) => [
      for (final (index, destination) in destinations.indexed)
        if (test(destination)) index,
    ];

    if (theme.formFactor == FormFactor.desktop) {
      final indices = indicesWhere((d) => d.showInTopBar);
      final selected = selectedIndex == null
          ? -1
          : indices.indexOf(selectedIndex!);
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          leading: leading,
          title: title,
          middle: NavigationBar(
            destinations: [for (final i in indices) destinations[i]],
            selectedIndex: selected < 0 ? null : selected,
            onDestinationSelected: onDestinationSelected == null
                ? null
                : (i) => onDestinationSelected!(indices[i]),
          ),
          actions: actions,
        ),
        body: body,
      );
    }

    final indices = indicesWhere((d) => d.showInBottomBar);
    final selected = selectedIndex == null
        ? -1
        : indices.indexOf(selectedIndex!);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: !showMobileAppBar
          ? null
          : mobileAppBar ??
                AppBar(leading: leading, actions: mobileActions ?? actions),
      bottomNavigationBar: !showBottomNavigationBar
          ? null
          : BottomNavigationBar(
              destinations: [for (final i in indices) destinations[i]],
              selectedIndex: selected < 0 ? null : selected,
              onDestinationSelected: onDestinationSelected == null
                  ? null
                  : (i) => onDestinationSelected!(indices[i]),
              action: action,
            ),
      body: body,
    );
  }
}
