/// Material and Cupertino interop for una.
///
/// `package:una/una.dart` does not depend on Material or Cupertino. Import
/// this library as well when an app puts Material or Cupertino widgets next
/// to una's, and wrap them in a [UnaMaterial]:
///
/// ```dart
/// import 'package:una/material.dart';
/// import 'package:una/una.dart';
///
/// UnaApp(
///   builder: (context, child) => UnaMaterial(child: child!),
///   home: const HomePage(),
/// )
/// ```
///
/// This library uses the Material and Cupertino libraries in the Flutter SDK
/// (`package:flutter/material.dart`), not the `material_ui` and
/// `cupertino_ui` packages.
library;

import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart'
    hide ColorScheme, TextTheme, Theme, ThemeData;
import 'package:flutter/material.dart' as m;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalCupertinoLocalizations, GlobalMaterialLocalizations;
// Flutter deprecated the SDK's Material and Cupertino libraries in 3.47 in
// favour of the `material_ui` and `cupertino_ui` packages. This library wraps
// the SDK ones on purpose, as its comment above says.
// ignore_for_file: deprecated_member_use

import 'package:una/src/theme/data.dart';
import 'package:una/src/theme/text_theme/theme.dart';
import 'package:una/src/theme/theme.dart';

/// Derives the Material [ThemeData] a [ThemeData] implies: its colours,
/// font, divider, text selection, icon and scrollbar themes.
///
/// [UnaMaterial] installs it. Call it yourself to theme a `MaterialApp`
/// built by `UnaApp.custom`:
///
/// ```dart
/// UnaApp.custom(
///   appBuilder: (context) => MaterialApp(
///     theme: materialThemeFrom(Theme.of(context)),
///     builder: (context, child) => UnaAppBuilder(child: child!),
///   ),
/// )
/// ```
m.ThemeData materialThemeFrom(ThemeData themeData) {
  final theme = m.ThemeData(
    fontFamily: themeData.textTheme.family,
    colorScheme: m.ColorScheme(
      brightness: themeData.brightness,
      primary: themeData.colorScheme.primary,
      onPrimary: themeData.colorScheme.primaryForeground,
      secondary: themeData.colorScheme.secondary,
      onSecondary: themeData.colorScheme.secondaryForeground,
      error: themeData.colorScheme.destructive,
      onError: themeData.colorScheme.destructiveForeground,
      surface: themeData.colorScheme.background,
      onSurface: themeData.colorScheme.foreground,
    ),
    scaffoldBackgroundColor: themeData.colorScheme.background,
    brightness: themeData.brightness,
    dividerTheme: DividerThemeData(
      color: themeData.dividerTheme.color ?? themeData.colorScheme.border,
      thickness: themeData.dividerTheme.thickness ?? 1,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: themeData.colorScheme.primary,
      selectionColor: themeData.colorScheme.selection,
      selectionHandleColor: themeData.colorScheme.primary,
    ),
    iconTheme: IconThemeData(
      size: 16,
      color: themeData.colorScheme.foreground,
    ),
    scrollbarTheme: ScrollbarThemeData(
      crossAxisMargin: 1,
      mainAxisMargin: 1,
      thickness: const WidgetStatePropertyAll(8),
      radius: const Radius.circular(999),
      thumbColor: WidgetStatePropertyAll(themeData.colorScheme.border),
    ),
  );
  final builder = themeData.textTheme.googleFontBuilder;
  if (builder == null) return theme;
  return theme.copyWith(textTheme: _withFontBuilder(theme.textTheme, builder));
}

/// {@template UnaMaterial}
/// Lets Material and Cupertino widgets in [child] follow the nearest una
/// theme.
///
/// It installs the Material [Theme] that [materialThemeFrom] derives
/// (Cupertino widgets take their theme from it) and a transparent [Material],
/// and adds the Material and Cupertino localizations when no ancestor
/// provides them. Widgets such as `TextField`, `Slider` and `InkWell` need
/// all three.
///
/// Put one around the whole app through `UnaApp.builder`, or around a
/// subtree. Inside a `ThemeScope` it follows that scope's theme.
/// {@endtemplate}
class UnaMaterial extends StatelessWidget {
  /// {@macro UnaMaterial}
  const UnaMaterial({super.key, required this.child, this.themeBuilder});

  /// The widget below this widget in the tree.
  final Widget child;

  /// Changes the Material [ThemeData] derived from the una theme. It
  /// receives the derived theme and returns the theme to use.
  final m.ThemeData Function(BuildContext context, m.ThemeData theme)?
  themeBuilder;

  /// The Material theme derived from each una theme. Deriving one
  /// builds a whole Material `ThemeData`, and this widget is rebuilt
  /// whenever what is above it is — on every frame of a window resize when
  /// it sits in `UnaApp.builder`.
  static final _derived = Expando<m.ThemeData>();

  @override
  Widget build(BuildContext context) {
    final source = Theme.of(context);
    var theme = _derived[source] ??= materialThemeFrom(source);
    if (themeBuilder case final builder?) theme = builder(context, theme);

    Widget result = m.Theme(
      data: theme,
      // A transparent Material, which widgets such as Slider and InkWell
      // look for, keeping the text style that una set.
      child: Material(
        type: MaterialType.transparency,
        textStyle: DefaultTextStyle.of(context).style,
        // A Material animates a change of its text style, which here is
        // the default text style of everything under it: for the 200 ms
        // after a change of theme every `Text` in the subtree would be
        // rebuilt on every frame. una changes theme as a whole (see
        // `CrossFadeTheme`); the style follows at once.
        animationDuration: Duration.zero,
        child: child,
      ),
    );

    final delegates = <LocalizationsDelegate<dynamic>>[
      if (Localizations.of<MaterialLocalizations>(
            context,
            MaterialLocalizations,
          ) ==
          null)
        GlobalMaterialLocalizations.delegate,
      if (Localizations.of<CupertinoLocalizations>(
            context,
            CupertinoLocalizations,
          ) ==
          null)
        GlobalCupertinoLocalizations.delegate,
    ];
    if (delegates.isNotEmpty) {
      // Localizations sets the text direction from the locale, which would
      // undo a Directionality the app put above this widget.
      final direction = Directionality.maybeOf(context);
      if (direction != null) {
        result = Directionality(textDirection: direction, child: result);
      }
      result = Localizations.override(
        context: context,
        delegates: delegates,
        child: result,
      );
    }
    return result;
  }
}

m.TextTheme _withFontBuilder(m.TextTheme textTheme, FontBuilder builder) {
  TextStyle apply(TextStyle? style) => BuilderTextStyle(
    (style ?? const TextStyle()).omitFamilyAndPackage,
    builder: builder,
    overrideFamilyWithBuilder: true,
  );
  return m.TextTheme(
    displayLarge: apply(textTheme.displayLarge),
    displayMedium: apply(textTheme.displayMedium),
    displaySmall: apply(textTheme.displaySmall),
    headlineLarge: apply(textTheme.headlineLarge),
    headlineMedium: apply(textTheme.headlineMedium),
    headlineSmall: apply(textTheme.headlineSmall),
    titleLarge: apply(textTheme.titleLarge),
    titleMedium: apply(textTheme.titleMedium),
    titleSmall: apply(textTheme.titleSmall),
    bodyLarge: apply(textTheme.bodyLarge),
    bodyMedium: apply(textTheme.bodyMedium),
    bodySmall: apply(textTheme.bodySmall),
    labelLarge: apply(textTheme.labelLarge),
    labelMedium: apply(textTheme.labelMedium),
    labelSmall: apply(textTheme.labelSmall),
  );
}
