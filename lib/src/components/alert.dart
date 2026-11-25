import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/decorator.dart';
import 'package:finesse/src/components/icon_button.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/theme/components/alert.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/components/layout.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/expand_reveal.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/widgets.dart';

/// Variants available for the [Alert] widget.
enum AlertVariant {
  /// The default alert, in the foreground colour.
  primary,

  /// An alert in the destructive colour, for errors.
  destructive,

  /// Something worked: a check, on a wash of the scheme's `success`.
  success,

  /// Something needs attention: a warning sign, on a wash of the scheme's
  /// `warning`.
  warning,

  /// Something worth knowing: an info mark, on a wash of the scheme's
  /// `tint`.
  info,
}

/// A message set into the page: a callout with a title, a description and
/// an icon.
///
/// ```dart
/// Alert(
///   variant: AlertVariant.success,
///   title: const Text('Payment received'),
///   description: const Text('A receipt is on its way to your inbox.'),
///   onDismissed: () => setState(() => _showReceipt = false),
/// )
/// ```
///
/// [variant] picks the look. [AlertVariant.primary] and
/// [AlertVariant.destructive] are shadcn's and show an [icon] only when
/// given one; [AlertVariant.success], [AlertVariant.warning] and
/// [AlertVariant.info] are tinted with the scheme's `success`, `warning` and
/// `tint` and bring an icon of their own.
///
/// With [onDismissed] the alert has a close button. Pressing it folds the
/// alert away and then calls [onDismissed], for the parent to stop building
/// it. Under a `Scaffold`'s app bar that is a banner.
class Alert extends StatefulWidget {
  /// Creates an alert; [variant] defaults to [AlertVariant.primary].
  const Alert({
    super.key,
    this.variant = AlertVariant.primary,
    this.onDismissed,
    this.icon,
    this.title,
    this.description,
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

  /// Creates a destructive variant alert widget, typically used for error or
  /// warning messages.
  const Alert.destructive({
    super.key,
    this.onDismissed,
    this.icon,
    this.title,
    this.description,
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

  /// {@template Alert.variant}
  /// The look of the alert; see [AlertVariant].
  /// {@endtemplate}
  final AlertVariant variant;

  /// Called after the alert has been closed with its close button and has
  /// folded away. The alert then takes no room, but is still in the tree:
  /// stop building it here.
  ///
  /// Null, the default, shows no close button.
  final VoidCallback? onDismissed;

  /// {@template Alert.icon}
  /// The alert's icon. The success, warning and info variants show one of
  /// their own when this is null; the others show none.
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
  State<Alert> createState() => _AlertState();
}

class _AlertState extends State<Alert> {
  /// Whether the close button was pressed and the alert is folding away.
  bool _dismissing = false;

  /// The tint of a success, warning or info alert: its accent, and the
  /// opaque fill it is washed with.
  (Color accent, Color fill)? _tintOf(ThemeData theme, AlertTheme alertTheme) {
    final scheme = theme.colorScheme;
    final card = alertTheme.decoration?.color ?? scheme.card;
    Color wash(Color color) =>
        Color.alphaBlend(color.withValues(alpha: color.a * .1), card);
    return switch (widget.variant) {
      AlertVariant.primary || AlertVariant.destructive => null,
      AlertVariant.success => (
        alertTheme.successColor ?? scheme.success,
        alertTheme.successBackgroundColor ??
            Color.alphaBlend(scheme.successMuted, card),
      ),
      AlertVariant.warning => (
        alertTheme.warningColor ?? scheme.warning,
        alertTheme.warningBackgroundColor ?? wash(scheme.warning),
      ),
      AlertVariant.info => (
        alertTheme.infoColor ?? scheme.tint,
        alertTheme.infoBackgroundColor ?? wash(scheme.tint),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variant = widget.variant;

    // The tinted variants are the primary alert in another colour: they
    // share its metrics and its type.
    final effectiveAlertTheme = variant == AlertVariant.destructive
        ? theme.destructiveAlertTheme
        : theme.primaryAlertTheme;
    final tint = _tintOf(theme, effectiveAlertTheme);

    final effectiveIconPadding =
        widget.iconPadding ??
        effectiveAlertTheme.iconPadding ??
        const EdgeInsetsDirectional.only(end: 12);

    final defaultDecoration = FinesseDecoration(
      border: FinesseBorder.all(
        color: theme.colorScheme.border,
        borderRadius: theme.radius,
        padding: const EdgeInsets.all(16),
      ),
    );

    var themeDecoration = defaultDecoration.merge(
      effectiveAlertTheme.decoration,
    );
    if (tint != null) {
      // The outline takes a little of the accent, so the alert has an edge
      // on a card of its own colour.
      final edge = FinesseBorderSide(
        color: tint.$1.withValues(alpha: tint.$1.a * .3),
      );
      final border = themeDecoration.border;
      themeDecoration = themeDecoration.copyWith(
        color: tint.$2,
        border: border?.copyWith(
          top: border.top?.merge(edge),
          right: border.right?.merge(edge),
          bottom: border.bottom?.merge(edge),
          // A style's accent bar down the start edge takes the accent whole.
          left: theme.style.alertAccentBar
              ? border.left?.merge(FinesseBorderSide(color: tint.$1))
              : border.left?.merge(edge),
        ),
      );
    }
    final effectiveDecoration = themeDecoration.merge(widget.decoration);

    final effectiveIconColor =
        widget.iconColor ??
        tint?.$1 ??
        effectiveAlertTheme.iconColor ??
        theme.colorScheme.foreground;

    final effectiveIconSize = widget.iconSize ?? effectiveAlertTheme.iconSize;

    final icon =
        widget.icon ??
        switch (variant) {
          AlertVariant.primary || AlertVariant.destructive => null,
          AlertVariant.success => const PhosphorIcon(
            PhosphorIconsFill.checkCircle,
          ),
          AlertVariant.warning => const PhosphorIcon(PhosphorIconsFill.warning),
          AlertVariant.info => const PhosphorIcon(PhosphorIconsFill.info),
        };
    final effectiveIcon = icon != null
        ? Padding(
            padding: effectiveIconPadding,
            child: IconTheme.merge(
              data: IconThemeData(
                color: effectiveIconColor,
                size: effectiveIconSize,
              ),
              child: icon,
            ),
          )
        : null;

    final effectiveTitleStyle = theme.textTheme.p
        .copyWith(
          color: theme.colorScheme.foreground,
          fontWeight: FontWeight.w500,
        )
        .merge(effectiveAlertTheme.titleStyle)
        .merge(widget.titleStyle);

    final effectiveDescriptionStyle =
        widget.descriptionStyle ??
        effectiveAlertTheme.descriptionStyle ??
        theme.textTheme.muted;

    final effectiveGap = widget.gap ?? effectiveAlertTheme.gap ?? 2.0;

    final effectiveMainAxisAlignment =
        widget.mainAxisAlignment ??
        effectiveAlertTheme.mainAxisAlignment ??
        MainAxisAlignment.start;

    final effectiveCrossAxisAlignment =
        widget.crossAxisAlignment ??
        effectiveAlertTheme.crossAxisAlignment ??
        CrossAxisAlignment.start;

    final title = widget.title;
    final description = widget.description;
    final dismissible = widget.onDismissed != null;

    final Widget alert = Decorator(
      decoration: effectiveDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ?widget.top,
          Row(
            crossAxisAlignment: effectiveCrossAxisAlignment,
            mainAxisAlignment: effectiveMainAxisAlignment,
            children: [
              ?widget.leading,
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
                        child: title,
                      ),
                    if (description != null)
                      DefaultTextStyle(
                        style: effectiveDescriptionStyle,
                        child: description,
                      ),
                  ],
                ),
              ),
              ?widget.trailing,
              if (dismissible)
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: theme.layoutTheme.gap(GapSize.sm),
                  ),
                  // Pulled into the alert's padding: the button's own box
                  // is larger than its glyph.
                  child: Transform.translate(
                    offset: Offset(
                      Directionality.of(context) == TextDirection.rtl ? -4 : 4,
                      -4,
                    ),
                    child: IconButton.ghost(
                      size: ButtonSize.sm,
                      tooltip: FinesseLocalizations.of(context).alert.dismiss,
                      foregroundColor: effectiveDescriptionStyle.color,
                      enabled: !_dismissing,
                      onPressed: () => setState(() => _dismissing = true),
                      icon: const PhosphorIcon(PhosphorIconsRegular.x),
                    ),
                  ),
                ),
            ],
          ),
          ?widget.bottom,
        ],
      ),
    );
    if (!dismissible) return alert;

    final motion = Motion.of(context);
    return SpringBuilder(
      value: _dismissing ? 0 : 1,
      spring: motion.smooth,
      onEnd: () {
        if (_dismissing) widget.onDismissed?.call();
      },
      builder: (context, t, child) => ExpandReveal(
        factor: t,
        travel: motion.overlayTravel,
        child: child!,
      ),
      child: alert,
    );
  }
}
