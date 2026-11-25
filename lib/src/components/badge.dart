import 'package:finesse/src/theme/components/badge.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/pop_in.dart';
import 'package:flutter/widgets.dart';

/// Variants available for the [Badge] widget.
enum BadgeVariant {
  /// Filled with the primary colour. The default.
  primary,

  /// Filled with the secondary colour.
  secondary,

  /// No fill, with a border.
  outline,

  /// In the destructive colour, for errors and warnings.
  destructive,
}

/// A small pill that states something: a status, a category, a count.
///
/// ```dart
/// Badge.secondary(child: const Text('Draft'))
/// ```
///
/// A badge is read, not pressed: it has no hover, no cursor and no
/// callback. A pill that does something when pressed — a filter, a tag that
/// can be removed, a choice — is a `Chip`; the count on the corner of an
/// icon is an `IndicatorBadge`.
///
/// It comes in four variants (primary, secondary, outline, destructive):
/// pass `variant:` or use the named constructors, which are shortcuts for
/// it. A badge whose text changes pops once, so the change is noticed.
class Badge extends StatelessWidget {
  /// Creates a badge: the primary variant unless [variant] says otherwise.
  const Badge({
    super.key,
    this.variant = BadgeVariant.primary,
    required this.child,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.textStyle,
  });

  /// Creates a secondary variant badge widget, typically for less prominent
  /// information.
  const Badge.secondary({
    super.key,
    required this.child,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.textStyle,
  }) : variant = BadgeVariant.secondary;

  /// Creates an outline variant badge widget, typically with a bordered
  /// appearance.
  const Badge.outline({
    super.key,
    required this.child,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.textStyle,
  }) : variant = BadgeVariant.outline;

  /// Creates a destructive variant badge widget, typically for error or warning
  /// states.
  const Badge.destructive({
    super.key,
    required this.child,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.textStyle,
  }) : variant = BadgeVariant.destructive;

  /// {@template Badge.variant}
  /// The variant of the badge, one of [BadgeVariant] options (primary,
  /// secondary, outline, destructive).
  /// Determines the visual style applied through the [Theme].
  /// {@endtemplate}
  final BadgeVariant variant;

  /// {@template Badge.child}
  /// The content widget displayed within the badge, typically a [Text] widget.
  /// Styled with the foreground color and theme text styles.
  /// {@endtemplate}
  final Widget child;

  /// {@template Badge.borderRadius}
  /// The corners of the badge. Defaults to the theme's; null there makes
  /// it a pill.
  /// {@endtemplate}
  final BorderRadius? borderRadius;

  /// {@template Badge.backgroundColor}
  /// The background color of the badge, overriding the theme default if
  /// provided.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Badge.foregroundColor}
  /// The color of the badge's content (e.g., text), overriding the theme
  /// default if provided.
  /// Ensures readability against the background.
  /// {@endtemplate}
  final Color? foregroundColor;

  /// {@template Badge.padding}
  /// Padding around the badge's content, overriding the theme default if
  /// specified.
  /// Controls the internal spacing of the badge.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Badge.textStyle}
  /// The text style of the badge's label.
  /// {@endtemplate}
  final TextStyle? textStyle;

  BadgeTheme _badgeTheme(ThemeData theme) {
    return switch (variant) {
      BadgeVariant.primary => theme.primaryBadgeTheme,
      BadgeVariant.secondary => theme.secondaryBadgeTheme,
      BadgeVariant.destructive => theme.destructiveBadgeTheme,
      BadgeVariant.outline => theme.outlineBadgeTheme,
    };
  }

  static ShapeBorder _shape(BorderRadius? borderRadius, BorderSide side) =>
      borderRadius == null
      ? StadiumBorder(side: side)
      : RoundedRectangleBorder(borderRadius: borderRadius, side: side);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final badgeTheme = _badgeTheme(theme);
    final label = child;
    final foreground = foregroundColor ?? badgeTheme.foregroundColor;
    final borderColor = badgeTheme.borderColor;
    final side = borderColor == null
        ? BorderSide.none
        : BorderSide(color: borderColor);

    // A badge whose text changes — a count, a status — pops once, so the
    // change is noticed. Only a plain `Text` can be compared.
    return PopOnChange(
      value: label is Text ? (label.data ?? label.textSpan) : null,
      child: Semantics(
        container: true,
        child: Container(
          decoration: ShapeDecoration(
            shape: _shape(borderRadius ?? badgeTheme.borderRadius, side),
            color: backgroundColor ?? badgeTheme.backgroundColor,
          ),
          padding: padding ?? badgeTheme.padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme.merge(
                data: IconThemeData(
                  size: badgeTheme.iconSize ?? 12,
                  color: foreground,
                ),
                child: DefaultTextStyle(
                  style:
                      (textStyle ??
                              badgeTheme.textStyle ??
                              theme.textTheme.small)
                          .copyWith(color: foreground),
                  textAlign: TextAlign.center,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
