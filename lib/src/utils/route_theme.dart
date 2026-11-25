import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/theme/theme_scope.dart';
import 'package:flutter/widgets.dart';

/// Wraps [builder] so that a route pushed on [navigator] from [opener] is
/// themed like the place it was opened from.
///
/// A route is built under the navigator, so it does not see a `Theme` that
/// was applied to a subtree — only the app-level one. When the call site is
/// re-themed (see [ThemeScope]) its theme is republished inside the route so
/// the dialog or sheet matches its surroundings. Otherwise the route follows
/// the app-level theme live: capturing it at push time froze an open dialog
/// or sheet in the theme it was opened with, so a light/dark switch left it
/// behind.
WidgetBuilder routeThemedBuilder({
  required BuildContext opener,
  required NavigatorState navigator,
  required WidgetBuilder builder,
}) {
  final ambientTheme = Theme.of(opener, listen: false);
  final themedLocally =
      ambientTheme != Theme.maybeOf(navigator.context, listen: false);
  return (routeContext) {
    // Depend on the app-level theme in both cases, so the route rebuilds
    // when it changes; a re-themed opener is re-read at that point.
    final appTheme = Theme.maybeOf(routeContext);
    final ThemeData data;
    if (!themedLocally && appTheme != null) {
      data = appTheme;
    } else if (opener.mounted) {
      data = Theme.of(opener, listen: false);
    } else {
      data = ambientTheme;
    }
    return ThemeScope(
      data: data,
      child: Builder(builder: builder),
    );
  };
}
