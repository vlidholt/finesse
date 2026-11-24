import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:flutter/widgets.dart';

/// Variants available for the [Alert] widget.
enum AlertVariant {
  /// The default alert, in the foreground colour.
  primary,

  /// An alert in the destructive colour, for errors.
  destructive,
}

/// A customizable alert widget that displays a message with optional icon and
/// styling.
///
/// The [Alert] widget can be used to show informational or warning messages
/// to users. It supports two variants: primary (default) and destructive, which
/// can be styled through the [Theme].
/// Use the named constructors [Alert.destructive] or [Alert.raw] for
/// specific configurations.
class Alert extends StatelessWidget {
  /// Creates a primary variant alert widget.
  const Alert({
    super.key,
    this.icon,
    this.title,
    this.description,
    this.textDirection,
    this.decoration,
    this.iconPadding,
    this.iconColor,
    this.iconSize,
    this.titleStyle,
    this.descriptionStyle,
    this.gap,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.leading,
    this.trailing,
    this.top,
    this.bottom,
  }) : variant = AlertVariant.primary;

  /// Creates a destructive variant alert widget, typically used for error or
  /// warning messages.
  const Alert.destructive({
    super.key,
    this.icon,
    this.title,
    this.description,
    this.textDirection,
    this.decoration,
    this.iconPadding,
    this.iconColor,
    this.iconSize,
    this.titleStyle,
    this.descriptionStyle,
    this.gap,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.leading,
    this.trailing,
    this.top,
    this.bottom,
  }) : variant = AlertVariant.destructive;

  /// Creates a raw alert widget with a specified [variant], allowing full
  /// control over configuration.
  const Alert.raw({
    super.key,
    required this.variant,
    this.icon,
    this.title,
    this.description,
    this.textDirection,
    this.decoration,
    this.iconPadding,
    this.iconColor,
    this.iconSize,
    this.titleStyle,
    this.descriptionStyle,
    this.gap,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.leading,
    this.trailing,
    this.top,
    this.bottom,
  });

  /// {@template Alert.variant}
  /// The variant of the alert, either [AlertVariant.primary] or
  /// [AlertVariant.destructive].
  /// Determines the visual style applied through the [Theme].
  /// {@endtemplate}
  final AlertVariant variant;

  /// {@template Alert.icon}
  /// A custom widget to use as the alert's icon.
  /// {@endtemplate}
  final Widget? icon;

  /// {@template Alert.title}
  /// The title widget of the alert, typically a [Text] widget.
  /// Displayed with the style defined by [titleStyle] or theme defaults.
  /// {@endtemplate}
  final Widget? title;

  /// {@template Alert.description}
  /// The description widget of the alert, typically a [Text] widget providing
  /// additional details.
  /// Displayed with the style defined by [descriptionStyle] or theme defaults.
  /// {@endtemplate}
  final Widget? description;

  /// {@template Alert.textDirection}
  /// The text direction for the alert's content, overrides the default
  /// direction if specified. Can be set to [TextDirection.ltr] or
  /// [TextDirection.rtl].
  /// {@endtemplate}
  final TextDirection? textDirection;

  /// {@template Alert.decoration}
  /// Custom decoration for the alert, merged with theme defaults if provided.
  /// Allows customization of border, padding, and other visual properties.
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template Alert.iconPadding}
  /// Padding around the icon, defaults to right padding of 12 if not specified.
  /// Controls the spacing between the icon and adjacent content.
  /// {@endtemplate}
  final EdgeInsetsGeometry? iconPadding;

  /// {@template Alert.iconColor}
  /// Color of the icon, overrides theme default if provided.
  /// Applied to the [IconTheme] if [icon] is not null.
  /// {@endtemplate}
  final Color? iconColor;

  /// {@template Alert.iconSize}
  /// Size of the icon, overrides theme default if provided.
  ///
  /// Applied to the [IconTheme] if [icon] is not null.
  /// Fallbacks to 16 if not specified.
  /// {@endtemplate}
  final double? iconSize;

  /// {@template Alert.titleStyle}
  /// Style for the title text, overrides theme default if provided.
  /// Controls font size, weight, color, and other text properties of the
  /// [title].
  /// {@endtemplate}
  final TextStyle? titleStyle;

  /// {@template Alert.descriptionStyle}
  /// Style for the description text, overrides theme default if provided.
  /// Controls font size, weight, color, and other text properties of the
  /// [description].
  /// {@endtemplate}
  final TextStyle? descriptionStyle;

  /// {@template Alert.gap}
  /// The vertical gap between the title and the description, shadcn's
  /// `gap-0.5`. Defaults to the theme's value.
  /// {@endtemplate}
  final double? gap;

  /// {@template Alert.mainAxisAlignment}
  /// Main axis alignment for the alert's content, defaults to start if not
  /// specified. Controls horizontal arrangement of icon and text content within
  /// the [Row].
  /// {@endtemplate}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@template Alert.crossAxisAlignment}
  /// Cross axis alignment for the alert's content, defaults to start if not
  /// specified. Controls vertical alignment of icon and text content within the
  /// [Row].
  /// {@endtemplate}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@template Alert.top}
  /// An optional widget to display at the top of the alert, above the main
  /// content. This can be used to add additional information or controls.
  /// {@endtemplate}
  final Widget? top;

  /// {@template Alert.bottom}
  /// An optional widget to display at the bottom of the alert, below the main
  /// content. This can be used to add additional information or controls.
  /// {@endtemplate}
  final Widget? bottom;

  /// {@template Alert.leading}
  /// An optional widget to display at the leading edge of the alert, before the
  /// main content. This can be used to add additional information or controls.
  /// {@endtemplate}
  final Widget? leading;

  /// {@template Alert.trailing}
  /// An optional widget to display at the trailing edge of the alert, after the
  /// main content. This can be used to add additional information or controls.
  /// {@endtemplate}
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveAlertTheme = variant == AlertVariant.primary
        ? theme.primaryAlertTheme
        : theme.destructiveAlertTheme;

    final effectiveIconPadding =
        iconPadding ??
        effectiveAlertTheme.iconPadding ??
        const EdgeInsetsDirectional.only(end: 12);

    final defaultDecoration = FinesseDecoration(
      border: FinesseBorder.all(
        color: theme.colorScheme.border,
        radius: theme.radius,
        padding: const EdgeInsets.all(16),
      ),
    );

    final effectiveDecoration = defaultDecoration
        .merge(effectiveAlertTheme.decoration)
        .merge(decoration);

    final effectiveIconColor =
        iconColor ??
        effectiveAlertTheme.iconColor ??
        theme.colorScheme.foreground;

    final effectiveIconSize = iconSize ?? effectiveAlertTheme.iconSize;

    final effectiveIcon = icon != null
        ? Padding(
            padding: effectiveIconPadding,
            child: IconTheme.merge(
              data: IconThemeData(
                color: effectiveIconColor,
                size: effectiveIconSize,
              ),
              child: icon!,
            ),
          )
        : null;

    final effectiveTitleStyle = theme.textTheme.p
        .copyWith(
          color: theme.colorScheme.foreground,
          fontWeight: FontWeight.w500,
        )
        .merge(effectiveAlertTheme.titleStyle)
        .merge(titleStyle);

    final effectiveDescriptionStyle =
        descriptionStyle ??
        effectiveAlertTheme.descriptionStyle ??
        theme.textTheme.muted;

    final effectiveGap = gap ?? effectiveAlertTheme.gap ?? 2.0;

    final effectiveMainAxisAlignment =
        mainAxisAlignment ??
        effectiveAlertTheme.mainAxisAlignment ??
        MainAxisAlignment.start;

    final effectiveCrossAxisAlignment =
        crossAxisAlignment ??
        effectiveAlertTheme.crossAxisAlignment ??
        CrossAxisAlignment.start;

    return Decorator(
      decoration: effectiveDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ?top,
          Row(
            crossAxisAlignment: effectiveCrossAxisAlignment,
            mainAxisAlignment: effectiveMainAxisAlignment,
            textDirection: textDirection,
            children: [
              ?leading,
              ?effectiveIcon,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: effectiveGap,
                  children: [
                    if (title != null)
                      DefaultTextStyle(
                        style: effectiveTitleStyle,
                        child: title!,
                      ),
                    if (description != null)
                      DefaultTextStyle(
                        style: effectiveDescriptionStyle,
                        child: description!,
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          ?bottom,
        ],
      ),
    );
  }
}
