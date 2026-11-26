import 'package:flutter/widgets.dart';
import 'package:una/src/theme/data.dart';
import 'package:una/src/theme/theme.dart';

/// {@template ThemeScope}
/// Applies a [ThemeData] to a subtree, including the ambient text and icon
/// styling that comes with it.
///
/// [Theme] alone only publishes the Una theme: `Theme.of` picks it up,
/// but a plain [Text] keeps whatever [DefaultTextStyle] it inherited from
/// further up, so a light-on-dark panel inside a light app renders dark text on
/// a dark surface. This widget also sets the text style, icon theme and
/// selection colours for the subtree.
///
/// Material widgets in the subtree follow it too when they are wrapped in a
/// `UnaMaterial` from `package:una/material.dart`, which reads the nearest
/// una theme.
///
/// Reach for it when part of the UI is deliberately themed differently from the
/// app — a dark settings panel, a themed preview pane, an embedded editor:
///
/// ```dart
/// ThemeScope(
///   data: ThemeData(
///     brightness: Brightness.dark,
///     colorScheme: const NeutralColorScheme.dark(),
///   ),
///   child: const SettingsPanel(),
/// )
/// ```
///
/// Overlays opened from inside the scope — popovers, tooltips, selects — stay
/// within it, because they are built through `OverlayPortal` from this position
/// in the tree. Routes do not: `showDialog` re-publishes the ambient theme
/// itself for that reason.
/// {@endtemplate}
class ThemeScope extends StatelessWidget {
  /// {@macro ThemeScope}
  const ThemeScope({
    super.key,
    required this.data,
    required this.child,
  });

  /// The theme to apply to [child].
  final ThemeData data;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: data,
      child: DefaultTextStyle(
        style: data.textTheme.p.copyWith(color: data.colorScheme.foreground),
        child: DefaultStyles(data: data, child: child),
      ),
    );
  }
}

/// Sets the icon theme and the text selection colours that a [ThemeData]
/// implies for [child].
///
/// `UnaApp` puts one at the root and [ThemeScope] one in each re-themed
/// subtree.
class DefaultStyles extends StatelessWidget {
  /// Creates the default icon and selection styles for [data].
  const DefaultStyles({super.key, required this.data, required this.child});

  /// The theme the styles come from.
  final ThemeData data;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(size: 16, color: data.colorScheme.foreground),
      child: DefaultSelectionStyle(
        cursorColor: data.colorScheme.primary,
        selectionColor: data.colorScheme.selection,
        child: child,
      ),
    );
  }
}
