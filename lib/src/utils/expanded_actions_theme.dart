import 'package:finesse/src/theme/components/button.dart';
import 'package:finesse/src/theme/data.dart';

final _expandedActionsThemes = Expando<ThemeData>();

/// [theme] with every button variant as wide as its parent: what the actions
/// of a dialog or sheet on a narrow screen are built under.
///
/// `ThemeData.copyWith` runs the theme factory again, so the result is kept
/// per theme. Deriving it in `build` paid for every component theme on each
/// build of each open dialog, and handed the actions a new `ThemeData` to
/// compare against the last one.
ThemeData expandedActionsThemeOf(ThemeData theme) {
  return _expandedActionsThemes[theme] ??= () {
    ButtonTheme expanded(ButtonTheme button) =>
        button.copyWith(width: double.infinity, expands: true);
    return theme.copyWith(
      primaryButtonTheme: expanded(theme.primaryButtonTheme),
      secondaryButtonTheme: expanded(theme.secondaryButtonTheme),
      outlineButtonTheme: expanded(theme.outlineButtonTheme),
      ghostButtonTheme: expanded(theme.ghostButtonTheme),
      destructiveButtonTheme: expanded(theme.destructiveButtonTheme),
    );
  }();
}
