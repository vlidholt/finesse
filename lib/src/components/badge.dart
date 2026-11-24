import 'package:finesse/src/components/disabled.dart';
import 'package:finesse/src/theme/components/badge.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
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

/// A customizable badge widget that displays content with variant-based
/// styling.
///
/// The [Badge] widget is used to highlight brief pieces of information,
/// such as tags or status indicators. It supports multiple variants
/// (primary, secondary, outline, destructive) with hover effects and optional
/// tap functionality. Use the named constructors for specific variants or
/// [Badge.raw] for full control.
class Badge extends StatefulWidget {
  /// Creates a primary variant badge widget.
  const Badge({
    super.key,
    required this.child,
    this.shape,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.padding,
    this.onPressed,
    this.enabled = true,
    this.cursor,
    this.textStyle,
  }) : variant = BadgeVariant.primary;

  /// Creates a secondary variant badge widget, typically for less prominent
  /// information.
  const Badge.secondary({
    super.key,
    required this.child,
    this.shape,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.padding,
    this.onPressed,
    this.enabled = true,
    this.cursor,
    this.textStyle,
  }) : variant = BadgeVariant.secondary;

  /// Creates an outline variant badge widget, typically with a bordered
  /// appearance.
  const Badge.outline({
    super.key,
    required this.child,
    this.shape,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.padding,
    this.onPressed,
    this.enabled = true,
    this.cursor,
    this.textStyle,
  }) : variant = BadgeVariant.outline;

  /// Creates a destructive variant badge widget, typically for error or warning
  /// states.
  const Badge.destructive({
    super.key,
    required this.child,
    this.shape,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.padding,
    this.onPressed,
    this.enabled = true,
    this.cursor,
    this.textStyle,
  }) : variant = BadgeVariant.destructive;

  /// Creates a badge widget with a specified [variant], allowing full control
  /// over configuration.
  const Badge.raw({
    super.key,
    required this.variant,
    required this.child,
    this.shape,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.padding,
    this.onPressed,
    this.enabled = true,
    this.cursor,
    this.textStyle,
  });

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

  /// {@template Badge.shape}
  /// The shape of the badge's border, overriding the theme default if
  /// specified.
  /// Typically a [StadiumBorder], but can be customized
  /// (e.g., [RoundedRectangleBorder]).
  /// {@endtemplate}
  final ShapeBorder? shape;

  /// {@template Badge.backgroundColor}
  /// The background color of the badge when not hovered, overriding the theme
  /// default if provided.
  /// Changes based on [variant] if not explicitly set.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Badge.hoverBackgroundColor}
  /// The background color of the badge when hovered, overriding the theme
  /// default if provided.
  /// Applied during mouse hover for visual feedback.
  /// {@endtemplate}
  final Color? hoverBackgroundColor;

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

  /// {@template Badge.onPressed}
  /// The callback invoked when the badge is tapped, making it interactive if
  /// provided.
  /// If null, the badge remains non-interactive.
  /// {@endtemplate}
  final VoidCallback? onPressed;

  /// {@template Badge.enabled}
  /// Whether the badge is interactive, defaults to `true`.
  ///
  /// When `false` the badge is dimmed and [onPressed] is not called. Has no
  /// visible effect on a badge without an [onPressed].
  /// {@endtemplate}
  final bool enabled;

  /// {@template Badge.cursor}
  /// The cursor displayed when hovering over the badge, providing feedback
  /// when the badge is interactive. Defaults to [SystemMouseCursors.click] if
  /// [onPressed] is provided, otherwise [MouseCursor.defer].
  /// {@endtemplate}
  final MouseCursor? cursor;

  @override
  State<Badge> createState() => _BadgeState();
}

class _BadgeState extends State<Badge> {
  final isHovered = ValueNotifier(false);

  @override
  void dispose() {
    isHovered.dispose();
    super.dispose();
  }

  BadgeTheme badgeTheme(ThemeData theme) {
    return switch (widget.variant) {
      BadgeVariant.primary => theme.primaryBadgeTheme,
      BadgeVariant.secondary => theme.secondaryBadgeTheme,
      BadgeVariant.destructive => theme.destructiveBadgeTheme,
      BadgeVariant.outline => theme.outlineBadgeTheme,
    };
  }

  Color? background(ThemeData theme) {
    return widget.backgroundColor ?? badgeTheme(theme).backgroundColor;
  }

  Color? hoverBackground(ThemeData theme) {
    return widget.hoverBackgroundColor ??
        badgeTheme(theme).hoverBackgroundColor;
  }

  Color? foreground(ThemeData theme) {
    return widget.foregroundColor ?? badgeTheme(theme).foregroundColor;
  }

  ShapeBorder shape(ThemeData theme) {
    return widget.shape ?? badgeTheme(theme).shape ?? const StadiumBorder();
  }

  EdgeInsetsGeometry? padding(ThemeData theme) {
    return widget.padding ?? badgeTheme(theme).padding;
  }

  TextStyle textStyle(ThemeData theme) {
    return widget.textStyle ??
        badgeTheme(theme).textStyle ??
        theme.textTheme.small;
  }

  MouseCursor cursor(ThemeData theme) {
    final defaultCursor = widget.onPressed != null
        ? SystemMouseCursors.click
        : MouseCursor.defer;
    return widget.cursor ?? badgeTheme(theme).cursor ?? defaultCursor;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);

    Widget badge = Semantics(
      container: true,
      child: MouseRegion(
        cursor: cursor(theme),
        onEnter: (_) {
          isHovered.value = true;
        },
        onExit: (_) {
          isHovered.value = false;
        },
        child: ValueListenableBuilder(
          valueListenable: isHovered,
          builder: (context, hovered, child) {
            return Container(
              decoration: ShapeDecoration(
                shape: shape(theme),
                color: hovered ? hoverBackground(theme) : background(theme),
              ),
              padding: padding(theme),
              child: child,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme.merge(
                data: IconThemeData(
                  size: badgeTheme(theme).iconSize ?? 12,
                  color: foreground(theme),
                ),
                child: DefaultTextStyle(
                  style: textStyle(theme).copyWith(color: foreground(theme)),
                  textAlign: TextAlign.center,
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.onPressed != null) {
      badge = FinesseGestureDetector(
        onTap: widget.enabled ? widget.onPressed : null,
        child: badge,
      );
    }
    if (!widget.enabled) {
      badge = Disabled(disabled: true, child: badge);
    }
    return badge;
  }
}
