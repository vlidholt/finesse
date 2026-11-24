/// Material and Cupertino interop for finesse.
///
/// `package:finesse/finesse.dart` does not depend on Material or Cupertino. Import
/// this library as well when an app puts Material or Cupertino widgets next
/// to finesse's, and wrap them in a [FinesseMaterial]:
///
/// ```dart
/// import 'package:finesse/material.dart';
/// import 'package:finesse/finesse.dart';
///
/// FinesseApp(
///   builder: (context, child) => FinesseMaterial(child: child!),
///   home: const HomePage(),
/// )
/// ```
///
/// This library uses the Material and Cupertino libraries in the Flutter SDK
/// (`package:flutter/material.dart`), not the `material_ui` and
/// `cupertino_ui` packages.
library;

import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/text_theme/theme.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart'
    hide ColorScheme, TextTheme, Theme, ThemeData;
import 'package:flutter/material.dart' as m;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalCupertinoLocalizations, GlobalMaterialLocalizations;

/// Derives the Material [ThemeData] a [ThemeData] implies: its colours,
/// font, divider, text selection, icon and scrollbar themes.
///
/// [FinesseMaterial] installs it. Call it yourself to theme a `MaterialApp`
/// built by `FinesseApp.custom`:
///
/// ```dart
/// FinesseApp.custom(
///   appBuilder: (context) => MaterialApp(
///     theme: materialThemeFrom(Theme.of(context)),
///     builder: (context, child) => FinesseAppBuilder(child: child!),
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

/// {@template FinesseMaterial}
/// Lets Material and Cupertino widgets in [child] follow the nearest finesse
/// theme.
///
/// It installs the Material [Theme] that [materialThemeFrom] derives
/// (Cupertino widgets take their theme from it) and a transparent [Material],
/// and adds the Material and Cupertino localizations when no ancestor
/// provides them. Widgets such as `TextField`, `Slider` and `InkWell` need
/// all three.
///
/// Put one around the whole app through `FinesseApp.builder`, or around a
/// subtree. Inside a `ThemeScope` it follows that scope's theme.
/// {@endtemplate}
class FinesseMaterial extends StatelessWidget {
  /// {@macro FinesseMaterial}
  const FinesseMaterial({super.key, required this.child, this.themeBuilder});

  /// The widget below this widget in the tree.
  final Widget child;

  /// Changes the Material [ThemeData] derived from the finesse theme. It
  /// receives the derived theme and returns the theme to use.
  final m.ThemeData Function(BuildContext context, m.ThemeData theme)?
  themeBuilder;

  @override
  Widget build(BuildContext context) {
    var theme = materialThemeFrom(Theme.of(context));
    if (themeBuilder case final builder?) theme = builder(context, theme);

    Widget result = m.Theme(
      data: theme,
      // A transparent Material, which widgets such as Slider and InkWell
      // look for, keeping the text style that finesse set.
      child: Material(
        type: MaterialType.transparency,
        textStyle: DefaultTextStyle.of(context).style,
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
