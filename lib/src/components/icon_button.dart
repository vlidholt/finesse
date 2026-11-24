import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/theme/components/button.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// A customizable icon-only button widget with variant styling.
///
/// The [IconButton] widget is a specialized version of [Button]
/// designed for icon-only use cases, offering multiple styling variants
/// (primary, destructive, outline, secondary, ghost). It supports rich
/// interaction states and integrates with [Theme] for consistent
/// appearance. Use named constructors like [IconButton.destructive] for
/// specific variants or [IconButton.raw] for full control.
///
/// shadcn/ui itself has no separate component — it is `<Button size="icon">`,
/// and `Button(size: ButtonSize.icon, child: Icon(...))` is exactly
/// that. This adds the square sizes for the `sm`/`lg` steps (which shadcn
/// spells `size-icon-sm` / `size-icon-lg`) and the semantic label an
/// icon-only control needs, so prefer it when the button holds only an icon.
class IconButton extends StatelessWidget {
  /// Creates a primary variant icon button widget.
  const IconButton({
    super.key,
    required this.icon,
    this.iconSize,
    this.size,
    this.semanticLabel,
    this.onPressed,
    this.cursor,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.autofocus = false,
    this.focusNode,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.shadows,
    this.gradient,
    this.decoration,
    this.enabled = true,
    this.onLongPress,
    this.statesController,
    this.hoverStrategies,
    this.onHoverChange,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onLongPressStart,
    this.onLongPressCancel,
    this.onLongPressUp,
    this.onLongPressDown,
    this.onLongPressEnd,
    this.onDoubleTap,
    this.onDoubleTapDown,
    this.onDoubleTapCancel,
    this.longPressDuration,
    this.onFocusChange,
  }) : variant = ButtonVariant.primary;

  /// Creates an icon button widget with a specified [variant], offering full
  /// customization.
  const IconButton.raw({
    super.key,
    required this.variant,
    required this.icon,
    this.iconSize,
    this.size,
    this.semanticLabel,
    this.onPressed,
    this.cursor,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.shadows,
    this.gradient,
    this.decoration,
    this.enabled = true,
    this.onLongPress,
    this.statesController,
    this.hoverStrategies,
    this.onHoverChange,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onLongPressStart,
    this.onLongPressCancel,
    this.onLongPressUp,
    this.onLongPressDown,
    this.onLongPressEnd,
    this.onDoubleTap,
    this.onDoubleTapDown,
    this.onDoubleTapCancel,
    this.longPressDuration,
  }) : assert(
         variant != ButtonVariant.link,
         "IconButton doesn't support the link variant",
       );

  /// Creates a destructive variant icon button widget, typically for warning or
  /// error actions.
  const IconButton.destructive({
    super.key,
    required this.icon,
    this.iconSize,
    this.size,
    this.semanticLabel,
    this.onPressed,
    this.cursor,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.shadows,
    this.gradient,
    this.decoration,
    this.enabled = true,
    this.onLongPress,
    this.statesController,
    this.hoverStrategies,
    this.onHoverChange,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onLongPressStart,
    this.onLongPressCancel,
    this.onLongPressUp,
    this.onLongPressDown,
    this.onLongPressEnd,
    this.onDoubleTap,
    this.onDoubleTapDown,
    this.onDoubleTapCancel,
    this.longPressDuration,
  }) : variant = ButtonVariant.destructive;

  /// Creates an outline variant icon button widget, typically with a bordered
  /// appearance.
  const IconButton.outline({
    super.key,
    required this.icon,
    this.iconSize,
    this.size,
    this.semanticLabel,
    this.onPressed,
    this.cursor,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.autofocus = false,
    this.focusNode,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.shadows,
    this.gradient,
    this.decoration,
    this.enabled = true,
    this.onLongPress,
    this.statesController,
    this.hoverStrategies,
    this.onHoverChange,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onLongPressStart,
    this.onLongPressCancel,
    this.onLongPressUp,
    this.onLongPressDown,
    this.onLongPressEnd,
    this.onDoubleTap,
    this.onDoubleTapDown,
    this.onDoubleTapCancel,
    this.longPressDuration,
    this.onFocusChange,
  }) : variant = ButtonVariant.outline;

  /// Creates a secondary variant icon button widget, typically for less
  /// prominent actions.
  const IconButton.secondary({
    super.key,
    required this.icon,
    this.iconSize,
    this.size,
    this.semanticLabel,
    this.onPressed,
    this.cursor,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.autofocus = false,
    this.focusNode,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.shadows,
    this.gradient,
    this.decoration,
    this.enabled = true,
    this.onLongPress,
    this.statesController,
    this.hoverStrategies,
    this.onHoverChange,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onLongPressStart,
    this.onLongPressCancel,
    this.onLongPressUp,
    this.onLongPressDown,
    this.onLongPressEnd,
    this.onDoubleTap,
    this.onDoubleTapDown,
    this.onDoubleTapCancel,
    this.longPressDuration,
    this.onFocusChange,
  }) : variant = ButtonVariant.secondary;

  /// Creates a ghost variant icon button widget, typically with minimal
  /// styling.
  const IconButton.ghost({
    super.key,
    required this.icon,
    this.iconSize,
    this.size,
    this.semanticLabel,
    this.onPressed,
    this.cursor,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.autofocus = false,
    this.focusNode,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.shadows,
    this.gradient,
    this.decoration,
    this.enabled = true,
    this.onLongPress,
    this.statesController,
    this.hoverStrategies,
    this.onHoverChange,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onLongPressStart,
    this.onLongPressCancel,
    this.onLongPressUp,
    this.onLongPressDown,
    this.onLongPressEnd,
    this.onDoubleTap,
    this.onDoubleTapDown,
    this.onDoubleTapCancel,
    this.longPressDuration,
    this.onFocusChange,
  }) : variant = ButtonVariant.ghost;

  /// {@macro Button.variant}
  final ButtonVariant variant;

  /// {@macro Button.onPressed}
  final VoidCallback? onPressed;

  /// {@macro Button.onLongPress}
  final VoidCallback? onLongPress;

  /// {@template IconButton.icon}
  /// The icon widget displayed within the button.
  /// Typically an [Icon], required to define the button’s content.
  /// {@endtemplate}
  final Widget icon;

  /// {@template IconButton.iconSize}
  /// The size of the icon within the button.
  /// Defaults to the [IconThemeData.size] if not specified.
  /// {@endtemplate}
  final double? iconSize;

  /// {@template IconButton.size}
  /// The button size to resolve metrics from.
  ///
  /// Defaults to [ButtonSize.icon] — the square icon size matching
  /// shadcn/ui's `<Button size="icon">`. Pass [ButtonSize.sm] or
  /// [ButtonSize.lg] for the smaller/larger icon buttons.
  /// {@endtemplate}
  final ButtonSize? size;

  /// {@template IconButton.semanticLabel}
  /// The accessible name announced by screen readers.
  ///
  /// An icon-only button has no text for assistive technology to read, so
  /// this should almost always be provided — it is the equivalent of the
  /// `sr-only` span shadcn/ui puts inside `<Button size="icon">`.
  /// {@endtemplate}
  final String? semanticLabel;

  /// {@macro Button.cursor}
  final MouseCursor? cursor;

  /// {@macro Button.width}
  final double? width;

  /// {@macro Button.height}
  final double? height;

  /// {@macro Button.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Button.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Button.hoverBackgroundColor}
  final Color? hoverBackgroundColor;

  /// {@macro Button.foregroundColor}
  final Color? foregroundColor;

  /// {@macro Button.hoverForegroundColor}
  final Color? hoverForegroundColor;

  /// {@macro Button.autofocus}
  final bool autofocus;

  /// {@macro Button.focusNode}
  final FocusNode? focusNode;

  /// {@macro Button.pressedBackgroundColor}
  final Color? pressedBackgroundColor;

  /// {@macro Button.pressedForegroundColor}
  final Color? pressedForegroundColor;

  /// {@macro Button.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Button.gradient}
  final Gradient? gradient;

  /// {@macro Button.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Button.enabled}
  final bool enabled;

  /// {@macro Button.statesController}
  final WidgetStatesController? statesController;

  /// {@macro Button.hoverStrategies}
  final HoverStrategies? hoverStrategies;

  /// {@macro Button.onHoverChange}
  final ValueChanged<bool>? onHoverChange;

  /// {@macro Button.onTapDown}
  final ValueChanged<TapDownDetails>? onTapDown;

  /// {@macro Button.onTapUp}
  final ValueChanged<TapUpDetails>? onTapUp;

  /// {@macro Button.onTapCancel}
  final VoidCallback? onTapCancel;

  /// {@macro Button.onSecondaryTapDown}
  final ValueChanged<TapDownDetails>? onSecondaryTapDown;

  /// {@macro Button.onSecondaryTapUp}
  final ValueChanged<TapUpDetails>? onSecondaryTapUp;

  /// {@macro Button.onSecondaryTapCancel}
  final VoidCallback? onSecondaryTapCancel;

  /// {@macro Button.onLongPressStart}
  final ValueChanged<LongPressStartDetails>? onLongPressStart;

  /// {@macro Button.onLongPressCancel}
  final VoidCallback? onLongPressCancel;

  /// {@macro Button.onLongPressUp}
  final VoidCallback? onLongPressUp;

  /// {@macro Button.onLongPressDown}
  final ValueChanged<LongPressDownDetails>? onLongPressDown;

  /// {@macro Button.onLongPressEnd}
  final ValueChanged<LongPressEndDetails>? onLongPressEnd;

  /// {@macro Button.onDoubleTap}
  final VoidCallback? onDoubleTap;

  /// {@macro Button.onDoubleTapDown}
  final ValueChanged<TapDownDetails>? onDoubleTapDown;

  /// {@macro Button.onDoubleTapCancel}
  final VoidCallback? onDoubleTapCancel;

  /// {@macro Button.longPressDuration}
  final Duration? longPressDuration;

  /// {@macro Button.onFocusChange}
  final ValueChanged<bool>? onFocusChange;

  /// The button theme for [variant], read from [theme].
  ButtonTheme buttonTheme(ThemeData theme) {
    return switch (variant) {
      ButtonVariant.primary => theme.primaryButtonTheme,
      ButtonVariant.destructive => theme.destructiveButtonTheme,
      ButtonVariant.secondary => theme.secondaryButtonTheme,
      ButtonVariant.ghost => theme.ghostButtonTheme,
      ButtonVariant.outline => theme.outlineButtonTheme,
      ButtonVariant.link => theme.linkButtonTheme,
    };
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));

    final theme = Theme.of(context);

    final sizesTheme = buttonTheme(theme).sizesTheme;
    // The square sizes, not the text-button ones: shadcn sizes an icon
    // button's glyph independently of a text button's at the same step
    // (`.cn-button-size-icon-sm` keeps 16 where `.cn-button-size-sm` drops
    // to 14).
    final defaultSize = switch (size ?? ButtonSize.icon) {
      ButtonSize.icon => sizesTheme?.icon ?? theme.buttonSizesTheme.icon!,
      ButtonSize.sm =>
        sizesTheme?.iconSm ??
            theme.buttonSizesTheme.iconSm ??
            sizesTheme?.sm ??
            theme.buttonSizesTheme.sm!,
      ButtonSize.lg =>
        sizesTheme?.iconLg ??
            theme.buttonSizesTheme.iconLg ??
            sizesTheme?.lg ??
            theme.buttonSizesTheme.lg!,
      ButtonSize.regular =>
        sizesTheme?.regular ?? theme.buttonSizesTheme.regular!,
    };

    final effectivePadding = padding ?? defaultSize.padding;

    final effectiveHeight = height ?? defaultSize.height;
    // Only the `icon` size carries an explicit width. For sm/lg/regular fall
    // back to the height so an icon button stays square at every size.
    final effectiveWidth = width ?? defaultSize.width ?? effectiveHeight;

    // The style can round icon buttons differently from text buttons — a
    // circle beside a 10-point rectangle. The focus ring has to follow the
    // new radius or it stays a rounded square around a round button.
    var effectiveDecoration = decoration;
    final radiusToken = theme.style.iconButtonRadius;
    if (radiusToken != null && decoration == null) {
      effectiveDecoration = theme.buttonDecoration(
        radius: theme.radii.resolve(radiusToken),
      );
    }

    Widget button = Button.raw(
      variant: variant,
      width: effectiveWidth,
      height: effectiveHeight,
      padding: effectivePadding,
      iconSize: iconSize ?? defaultSize.iconSize,
      onPressed: onPressed,
      onLongPress: onLongPress,
      cursor: cursor,
      backgroundColor: backgroundColor,
      hoverBackgroundColor: hoverBackgroundColor,
      foregroundColor: foregroundColor,
      hoverForegroundColor: hoverForegroundColor,
      autofocus: autofocus,
      focusNode: focusNode,
      pressedBackgroundColor: pressedBackgroundColor,
      pressedForegroundColor: pressedForegroundColor,
      shadows: shadows,
      gradient: gradient,
      decoration: effectiveDecoration,
      enabled: enabled,
      statesController: statesController,
      hoverStrategies: hoverStrategies,
      onHoverChange: onHoverChange,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      onSecondaryTapDown: onSecondaryTapDown,
      onSecondaryTapUp: onSecondaryTapUp,
      onSecondaryTapCancel: onSecondaryTapCancel,
      onLongPressStart: onLongPressStart,
      onLongPressCancel: onLongPressCancel,
      onLongPressUp: onLongPressUp,
      onLongPressDown: onLongPressDown,
      onLongPressEnd: onLongPressEnd,
      onDoubleTap: onDoubleTap,
      onDoubleTapDown: onDoubleTapDown,
      onDoubleTapCancel: onDoubleTapCancel,
      longPressDuration: longPressDuration,
      onFocusChange: onFocusChange,
      // A raw button does not scale unless asked; an icon button is a
      // button, so it follows the variant's theme like the others.
      pressScale: null,
      child: icon,
    );

    if (semanticLabel != null) {
      // An icon-only button carries no text, so without this a screen reader
      // announces nothing at all.
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: enabled,
        container: true,
        child: ExcludeSemantics(child: button),
      );
    }

    return button;
  }
}
