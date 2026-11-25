import 'package:finesse/src/components/button_group.dart';
import 'package:finesse/src/components/spinner.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/raw_components/focusable.dart';
import 'package:finesse/src/theme/components/button.dart';
import 'package:finesse/src/theme/components/button_sizes.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/activation_keys.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:finesse/src/utils/motion_color.dart';
import 'package:finesse/src/utils/pop_in.dart';
import 'package:finesse/src/utils/separated_iterable.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:finesse/src/utils/text_scaled_height.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Variants available for the [Button] widget.
enum ButtonVariant {
  /// Filled with the primary colour. The default.
  primary,

  /// In the destructive colour, for actions such as delete.
  destructive,

  /// A button with a border.
  outline,

  /// Filled with the secondary colour.
  secondary,

  /// No fill and no border until hovered.
  ghost,

  /// Looks like a text link, underlined on hover.
  link,
}

/// Size options available for the [Button] widget.
///
/// Maps onto shadcn/ui's `size` prop: [regular] is `default`, plus `sm`, `lg`
/// and `icon`.
///
/// The concrete metrics for each size come from `ButtonSizesTheme`.
enum ButtonSize {
  /// The default size, shadcn's `default`.
  regular,

  /// A smaller, denser button.
  sm,

  /// A larger button.
  lg,

  /// A square button sized for a single icon, matching
  /// `<Button size="icon">`.
  ///
  /// This is the size `IconButton` uses by default.
  icon,
}

/// A highly customizable button widget with variant and size options.
///
/// The [Button] widget provides a flexible button with multiple styling
/// variants (primary, destructive, outline, secondary, ghost, link) and sizes
/// (regular, small, large).
/// It supports rich interaction states (hover, press, focus) and can include leading/trailing
/// widgets alongside text. Use named constructors for specific variants or
/// [Button.raw] for full control.
class Button extends StatefulWidget {
  /// Creates a primary variant button widget.
  const Button({
    super.key,
    this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.size,
    this.iconSize,
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
    this.textDecoration,
    this.hoverTextDecoration,
    this.decoration,
    this.enabled = true,
    this.loading = false,
    this.onLongPress,
    this.statesController,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
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
    this.textDirection,
    this.gap,
    this.onFocusChange,
    this.pressedOffset,
    this.pressAnimationDuration,
    this.pressScale,
    this.transitionDuration,
    this.expands,
    this.textStyle,
    this.canRequestFocus,
  }) : variant = ButtonVariant.primary;

  /// Creates a button widget with a specified [variant], allowing full control
  /// over configuration.
  const Button.raw({
    super.key,
    required this.variant,
    this.size,
    this.iconSize,
    this.child,
    this.leading,
    this.trailing,
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
    this.textDecoration,
    this.hoverTextDecoration,
    this.decoration,
    this.enabled = true,
    this.loading = false,
    this.onLongPress,
    this.statesController,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
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
    this.textDirection,
    this.gap,
    this.onFocusChange,
    this.pressedOffset,
    this.pressAnimationDuration,
    this.pressScale = 1,
    this.transitionDuration,
    this.expands,
    this.textStyle,
    this.canRequestFocus,
  });

  /// Creates a destructive variant button widget, typically for warning or
  /// error actions.
  const Button.destructive({
    super.key,
    this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.size,
    this.iconSize,
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
    this.textDecoration,
    this.hoverTextDecoration,
    this.decoration,
    this.enabled = true,
    this.loading = false,
    this.onLongPress,
    this.statesController,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
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
    this.textDirection,
    this.gap,
    this.onFocusChange,
    this.pressedOffset,
    this.pressAnimationDuration,
    this.pressScale,
    this.transitionDuration,
    this.expands,
    this.textStyle,
    this.canRequestFocus,
  }) : variant = ButtonVariant.destructive;

  /// Creates an outline variant button widget, typically with a bordered
  /// appearance.
  const Button.outline({
    super.key,
    this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.size,
    this.iconSize,
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
    this.textDecoration,
    this.hoverTextDecoration,
    this.decoration,
    this.enabled = true,
    this.loading = false,
    this.onLongPress,
    this.statesController,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
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
    this.textDirection,
    this.gap,
    this.onFocusChange,
    this.pressedOffset,
    this.pressAnimationDuration,
    this.pressScale,
    this.transitionDuration,
    this.expands,
    this.textStyle,
    this.canRequestFocus,
  }) : variant = ButtonVariant.outline;

  /// Creates a secondary variant button widget, typically for less prominent
  /// actions.
  const Button.secondary({
    super.key,
    this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.size,
    this.iconSize,
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
    this.textDecoration,
    this.hoverTextDecoration,
    this.decoration,
    this.enabled = true,
    this.loading = false,
    this.onLongPress,
    this.statesController,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
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
    this.textDirection,
    this.gap,
    this.onFocusChange,
    this.pressedOffset,
    this.pressAnimationDuration,
    this.pressScale,
    this.transitionDuration,
    this.expands,
    this.textStyle,
    this.canRequestFocus,
  }) : variant = ButtonVariant.secondary;

  /// Creates a ghost variant button widget, typically with minimal styling.
  const Button.ghost({
    super.key,
    this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.size,
    this.iconSize,
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
    this.textDecoration,
    this.hoverTextDecoration,
    this.decoration,
    this.enabled = true,
    this.loading = false,
    this.onLongPress,
    this.statesController,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
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
    this.textDirection,
    this.gap,
    this.onFocusChange,
    this.pressedOffset,
    this.pressAnimationDuration,
    this.pressScale,
    this.transitionDuration,
    this.expands,
    this.textStyle,
    this.canRequestFocus,
  }) : variant = ButtonVariant.ghost;

  /// Creates a link variant button widget, styled like a hyperlink.
  const Button.link({
    super.key,
    required this.child,
    this.onPressed,
    this.size,
    this.iconSize,
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
    this.textDecoration,
    this.hoverTextDecoration,
    this.decoration,
    this.enabled = true,
    this.loading = false,
    this.onLongPress,
    this.statesController,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
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
    this.textDirection,
    this.gap,
    this.onFocusChange,
    this.pressedOffset,
    this.pressAnimationDuration,
    this.pressScale,
    this.transitionDuration,
    this.expands,
    this.leading,
    this.trailing,
    this.textStyle,
    this.canRequestFocus,
  }) : variant = ButtonVariant.link;

  /// {@template Button.onPressed}
  /// The callback invoked when the button is tapped.
  /// {@endtemplate}
  final VoidCallback? onPressed;

  /// {@template Button.onLongPress}
  /// The callback invoked when the button is long-pressed, adding long-press
  /// functionality if provided. Controlled by [longPressDuration] for timing.
  /// {@endtemplate}
  final VoidCallback? onLongPress;

  /// {@template Button.leading}
  /// The widget displayed before the main [child], typically an icon or small
  /// graphic. Positioned according to [mainAxisAlignment] and [textDirection].
  /// {@endtemplate}
  final Widget? leading;

  /// {@template Button.child}
  /// The main content widget of the button, typically a [Text] widget.
  /// Styled with the foreground color and theme text styles.
  /// {@endtemplate}
  final Widget? child;

  /// {@template Button.trailing}
  /// The widget displayed after the main [child], typically an icon or small
  /// graphic. Positioned according to [mainAxisAlignment] and [textDirection].
  /// {@endtemplate}
  final Widget? trailing;

  /// {@template Button.variant}
  /// The variant of the button, one of [ButtonVariant] options (primary,
  /// destructive, etc.). Determines the visual style applied through the
  /// [Theme].
  /// {@endtemplate}
  final ButtonVariant variant;

  /// {@template Button.size}
  /// The size of the button, one of [ButtonSize] options (regular, sm, lg).
  /// Affects dimensions and padding unless overridden by [width], [height], or
  /// [padding].
  /// {@endtemplate}
  final ButtonSize? size;

  /// {@template Button.iconSize}
  /// The size handed to icons in the button that do not set one themselves.
  ///
  /// Defaults to the size's `iconSize` in `ButtonSizesTheme`, shadcn's
  /// `[&_svg:not([class*='size-'])]:size-4`. An [Icon] with an explicit
  /// `size` is left alone either way.
  /// {@endtemplate}
  final double? iconSize;

  /// {@template Button.cursor}
  /// The mouse cursor displayed over the button, overriding the theme default
  /// if specified. Typically [SystemMouseCursors.click] when enabled.
  /// {@endtemplate}
  final MouseCursor? cursor;

  /// {@template Button.width}
  /// The explicit minimum width of the button, overriding size-based defaults.
  /// If null, it falls back to theme or size-specific minimums. When set to 0,
  /// or a value smaller than the child's width the button's width will be
  /// determined by its child.
  /// {@endtemplate}
  final double? width;

  /// {@template Button.height}
  /// The explicit minimum height of the button, overriding size-based defaults.
  /// If null, it falls back to theme or size-specific minimums. When set to 0,
  /// or a value smaller than the child's height the button's height will be
  /// determined by its child.
  /// {@endtemplate}
  final double? height;

  /// {@template Button.padding}
  /// Padding around the button's content, overriding size-based defaults
  /// if specified. Controls internal spacing within the button.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Button.backgroundColor}
  /// The background color of the button when not hovered or pressed, overriding
  /// the theme default if provided. Changes based on [variant] if not
  /// explicitly set.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Button.hoverBackgroundColor}
  /// The background color of the button when hovered, overriding the theme
  /// default if provided.
  /// Applied during mouse hover for visual feedback.
  /// {@endtemplate}
  final Color? hoverBackgroundColor;

  /// {@template Button.foregroundColor}
  /// The color of the button's content (e.g., text, icons) when not hovered or
  /// pressed.
  /// Overrides the theme default if provided; required in theme if not set.
  /// {@endtemplate}
  final Color? foregroundColor;

  /// {@template Button.hoverForegroundColor}
  /// The color of the button's content when hovered, overriding the theme
  /// default if provided.
  /// Applied during mouse hover for visual feedback.
  /// {@endtemplate}
  final Color? hoverForegroundColor;

  /// {@template Button.autofocus}
  /// Whether the button should automatically receive focus when the widget is
  /// built. Defaults to false; managed by [focusNode].
  /// {@endtemplate}
  final bool autofocus;

  /// {@template Button.focusNode}
  /// The focus node for keyboard navigation, created internally if not
  /// provided. Enables focus handling and shortcuts like Enter key activation.
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// {@template Button.pressedBackgroundColor}
  /// The background color of the button when pressed, overriding the theme
  /// default if provided. Applied during tap or long-press interactions.
  /// {@endtemplate}
  final Color? pressedBackgroundColor;

  /// {@template Button.pressedForegroundColor}
  /// The foreground color of the button when pressed, overriding the theme
  /// default if provided. Applied to content during tap or long-press
  /// interactions.
  /// {@endtemplate}
  final Color? pressedForegroundColor;

  /// {@template Button.shadows}
  /// The list of box shadows applied to the button, overriding the theme
  /// default if provided. Enhances visual depth and elevation.
  /// {@endtemplate}
  final List<BoxShadow>? shadows;

  /// {@template Button.gradient}
  /// The gradient applied to the button's background, overriding the theme
  /// default if provided. Supersedes [backgroundColor] if both are set.
  /// {@endtemplate}
  final Gradient? gradient;

  /// {@template Button.textDecoration}
  /// The text decoration applied to the button's text when not hovered,
  /// overriding the theme default if provided. E.g., [TextDecoration.underline]
  /// for styling.
  /// {@endtemplate}
  final TextDecoration? textDecoration;

  /// {@template Button.hoverTextDecoration}
  /// The text decoration applied to the button's text when hovered, overriding
  /// the theme default if provided. Applied during mouse hover for visual
  /// feedback.
  /// {@endtemplate}
  final TextDecoration? hoverTextDecoration;

  /// {@template Button.decoration}
  /// Custom decoration for the button, merged with theme defaults if provided.
  /// Allows advanced styling beyond basic colors and shadows.
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template Button.enabled}
  /// Whether the button is interactive, defaults to true.
  /// If false, the button is disabled, visually dimmed, and non-responsive.
  /// {@endtemplate}
  final bool enabled;

  /// {@template Button.loading}
  /// Whether the button's action is in progress.
  ///
  /// A loading button shows a spinner in the place of its [leading] widget
  /// or, when it has none, over its label, which keeps its room: the button
  /// is exactly as wide as it was. It ignores presses, by pointer and by
  /// keyboard, without dimming or giving up the focus, and assistive
  /// technology is told that it is busy.
  ///
  /// ```dart
  /// Button(
  ///   loading: _saving,
  ///   onPressed: _save,
  ///   child: const Text('Save'),
  /// )
  /// ```
  /// {@endtemplate}
  final bool loading;

  /// {@template Button.statesController}
  /// The controller that holds the button's interaction states
  /// ([WidgetState.hovered], [WidgetState.pressed], [WidgetState.focused] and
  /// [WidgetState.disabled]). If null, an internal controller is created.
  ///
  /// This is Flutter's own [WidgetStatesController], which changes its
  /// [WidgetStatesController.value] set in place before notifying: a listener
  /// that needs to know which state flipped has to keep its own copy of the
  /// states it last saw.
  /// {@endtemplate}
  final WidgetStatesController? statesController;

  /// {@template Button.gap}
  /// The gap between the button's items (e.g., [leading], [child], [trailing]).
  /// Defaults to 8 pixels if not specified.
  /// {@endtemplate}
  final double? gap;

  /// {@template Button.mainAxisAlignment}
  /// The main axis alignment of the button's content within its [Row].
  /// Defaults to [MainAxisAlignment.center] if not specified.
  /// {@endtemplate}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@template Button.crossAxisAlignment}
  /// The cross axis alignment of the button's content within its [Row].
  /// Defaults to [CrossAxisAlignment.center] if not specified.
  /// {@endtemplate}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@template Button.hoverStrategies}
  /// The strategies for handling hover behavior, overriding the theme default
  /// if provided. Controls how hover states are detected and applied.
  /// {@endtemplate}
  final HoverStrategies? hoverStrategies;

  /// {@template Button.onHoverChange}
  /// Callback invoked when the hover state changes, providing the new hover
  /// value. Complements internal hover state management.
  /// {@endtemplate}
  final ValueChanged<bool>? onHoverChange;

  /// {@template Button.onTapDown}
  /// Callback invoked when a tap begins, providing tap details.
  /// Triggers the pressed state visually.
  /// {@endtemplate}
  final ValueChanged<TapDownDetails>? onTapDown;

  /// {@template Button.onTapUp}
  /// Callback invoked when a tap ends, providing tap details.
  /// Ends the pressed state visually.
  /// {@endtemplate}
  final ValueChanged<TapUpDetails>? onTapUp;

  /// {@template Button.onTapCancel}
  /// Callback invoked when a tap is canceled.
  /// Resets the pressed state.
  /// {@endtemplate}
  final VoidCallback? onTapCancel;

  /// {@template Button.onSecondaryTapDown}
  /// Callback invoked when a secondary (e.g., right-click) tap begins,
  /// providing tap details. For advanced gesture handling.
  /// {@endtemplate}
  final ValueChanged<TapDownDetails>? onSecondaryTapDown;

  /// {@template Button.onSecondaryTapUp}
  /// Callback invoked when a secondary tap ends, providing tap details.
  /// For advanced gesture handling.
  /// {@endtemplate}
  final ValueChanged<TapUpDetails>? onSecondaryTapUp;

  /// {@template Button.onSecondaryTapCancel}
  /// Callback invoked when a secondary tap is canceled.
  /// For advanced gesture handling.
  /// {@endtemplate}
  final VoidCallback? onSecondaryTapCancel;

  /// {@template Button.onLongPressStart}
  /// Callback invoked when a long press begins, providing details.
  /// Part of long-press gesture handling.
  /// {@endtemplate}
  final ValueChanged<LongPressStartDetails>? onLongPressStart;

  /// {@template Button.onLongPressCancel}
  /// Callback invoked when a long press is canceled.
  /// Part of long-press gesture handling.
  /// {@endtemplate}
  final VoidCallback? onLongPressCancel;

  /// {@template Button.onLongPressUp}
  /// Callback invoked when a long press ends by lifting.
  /// Part of long-press gesture handling.
  /// {@endtemplate}
  final VoidCallback? onLongPressUp;

  /// {@template Button.onLongPressDown}
  /// Callback invoked when a long press is detected, providing details.
  /// Part of long-press gesture handling.
  /// {@endtemplate}
  final ValueChanged<LongPressDownDetails>? onLongPressDown;

  /// {@template Button.onLongPressEnd}
  /// Callback invoked when a long press ends, providing details.
  /// Part of long-press gesture handling.
  /// {@endtemplate}
  final ValueChanged<LongPressEndDetails>? onLongPressEnd;

  /// {@template Button.onDoubleTap}
  /// Callback invoked when a double tap occurs.
  /// For advanced gesture handling.
  /// {@endtemplate}
  final VoidCallback? onDoubleTap;

  /// {@template Button.onDoubleTapDown}
  /// Callback invoked when a double tap begins, providing details.
  /// For advanced gesture handling.
  /// {@endtemplate}
  final ValueChanged<TapDownDetails>? onDoubleTapDown;

  /// {@template Button.onDoubleTapCancel}
  /// Callback invoked when a double tap is canceled.
  /// For advanced gesture handling.
  /// {@endtemplate}
  final VoidCallback? onDoubleTapCancel;

  /// {@template Button.longPressDuration}
  /// The duration required to trigger a long press, overriding the theme
  /// default if provided. Controls the timing of [onLongPress] and related
  /// callbacks.
  /// {@endtemplate}
  final Duration? longPressDuration;

  /// {@template Button.textDirection}
  /// The text direction for the button's content, overriding the default if
  /// specified. Can be set to [TextDirection.ltr] or [TextDirection.rtl].
  /// {@endtemplate}
  final TextDirection? textDirection;

  /// {@template Button.onFocusChange}
  /// Callback invoked when the focus state changes, providing the new focus
  /// value. Complements internal focus state management.
  /// {@endtemplate}
  final ValueChanged<bool>? onFocusChange;

  /// {@macro ButtonTheme.pressedOffset}
  final Offset? pressedOffset;

  /// {@macro ButtonTheme.pressAnimationDuration}
  final Duration? pressAnimationDuration;

  /// {@macro ButtonTheme.pressScale}
  ///
  /// [Button.raw] is the base of rows and custom controls as well as of
  /// buttons, so it does not scale unless asked to: it defaults to 1. Pass
  /// `Motion.of(context).pressScale` for a raw button that should respond
  /// like the others, or null to follow the variant's theme.
  final double? pressScale;

  /// {@macro ButtonTheme.transitionDuration}
  ///
  /// A row that should take its highlight at once — a menu item — passes
  /// [Duration.zero].
  final Duration? transitionDuration;

  /// {@template Button.expands}
  /// Whether the [child] expands to fill available space along the main axis.
  /// Defaults to false if not specified.
  /// {@endtemplate}
  final bool? expands;

  /// {@template Button.textStyle}
  /// The text style applied to the button's [child] when it is a [Text] widget,
  /// overriding the theme default if provided.
  /// Allows customization of font size, weight, and other text properties.
  /// {@endtemplate}
  final TextStyle? textStyle;

  /// {@template Button.canRequestFocus}
  /// Whether the button can request focus.
  /// Defaults to true if [enabled] is true, false otherwise.
  /// {@endtemplate}
  final bool? canRequestFocus;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  WidgetStatesController? _statesController;
  FocusNode? _focusNode;

  WidgetStatesController get statesController =>
      widget.statesController ?? _statesController!;

  FocusNode get focusNode => widget.focusNode ?? _focusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.statesController == null) {
      _statesController = WidgetStatesController({
        if (!widget.enabled) WidgetState.disabled,
      });
    }
    if (widget.focusNode == null) _focusNode = FocusNode();
    // An external controller may already have listeners (e.g. a context-menu
    // item shares one with its trailing icon). Syncing disabled state here
    // would notify them during build, so defer to the first frame.
    if (widget.statesController != null && !widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          statesController.update(WidgetState.disabled, true);
        }
      });
    }
    focusNode.addListener(onFocusChange);
  }

  @override
  void didUpdateWidget(covariant Button oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      if (widget.statesController == null) {
        // Our own controller's only listener is the builder below us, which
        // may be marked dirty while we update.
        statesController.update(WidgetState.disabled, !widget.enabled);
      } else {
        // An external controller may have listeners elsewhere in the tree
        // (a menu item's trailing icon); notifying them now, mid-build, is
        // "setState() called during build". The button itself reads
        // widget.enabled, so it is correct this frame regardless.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            statesController.update(WidgetState.disabled, !widget.enabled);
          }
        });
      }
    }
    if (oldWidget.focusNode != null && widget.focusNode == null) {
      oldWidget.focusNode!.removeListener(onFocusChange);
      _focusNode?.dispose();
      _focusNode = FocusNode();
      focusNode.addListener(onFocusChange);
    }
  }

  @override
  void dispose() {
    _statesController?.dispose();
    focusNode.removeListener(onFocusChange);
    _focusNode?.dispose();
    super.dispose();
  }

  void onFocusChange() {
    statesController.update(WidgetState.focused, focusNode.hasFocus);
  }

  ButtonTheme buttonTheme(ThemeData theme) {
    return switch (widget.variant) {
      ButtonVariant.primary => theme.primaryButtonTheme,
      ButtonVariant.destructive => theme.destructiveButtonTheme,
      ButtonVariant.secondary => theme.secondaryButtonTheme,
      ButtonVariant.ghost => theme.ghostButtonTheme,
      ButtonVariant.outline => theme.outlineButtonTheme,
      ButtonVariant.link => theme.linkButtonTheme,
    };
  }

  ButtonSizeTheme sizeTheme(
    ThemeData theme,
    ButtonSize size,
  ) {
    switch (size) {
      case ButtonSize.sm:
        return buttonTheme(theme).sizesTheme?.sm ?? theme.buttonSizesTheme.sm!;
      case ButtonSize.lg:
        return buttonTheme(theme).sizesTheme?.lg ?? theme.buttonSizesTheme.lg!;
      case ButtonSize.icon:
        return buttonTheme(theme).sizesTheme?.icon ??
            theme.buttonSizesTheme.icon!;
      case ButtonSize.regular:
        return buttonTheme(theme).sizesTheme?.regular ??
            theme.buttonSizesTheme.regular!;
    }
  }

  double defaultHeightForSize(ThemeData theme, ButtonSize size) {
    return sizeTheme(theme, size).height;
  }

  double height(ThemeData theme) {
    if (widget.height != null) return widget.height!;
    if (buttonTheme(theme).height != null) {
      return buttonTheme(theme).height!;
    }
    if (widget.size != null) {
      return defaultHeightForSize(theme, widget.size!);
    }
    return defaultHeightForSize(
      theme,
      buttonTheme(theme).size ?? ButtonSize.regular,
    );
  }

  double? defaultWidthForSize(ThemeData theme, ButtonSize size) {
    return sizeTheme(theme, size).width;
  }

  double? width(ThemeData theme) {
    if (widget.width != null) return widget.width!;
    if (buttonTheme(theme).width != null) {
      return buttonTheme(theme).width!;
    }
    if (widget.size != null) {
      return defaultWidthForSize(theme, widget.size!);
    }
    return defaultWidthForSize(
      theme,
      buttonTheme(theme).size ?? ButtonSize.regular,
    );
  }

  EdgeInsetsGeometry defaultPaddingForSize(
    ThemeData theme,
    ButtonSize size,
  ) {
    return sizeTheme(theme, size).padding;
  }

  EdgeInsetsGeometry padding(ThemeData theme) {
    if (widget.padding != null) return widget.padding!;
    if (widget.size != null) {
      return defaultPaddingForSize(theme, widget.size!);
    }
    return defaultPaddingForSize(
      theme,
      buttonTheme(theme).size ?? ButtonSize.regular,
    );
  }

  /// The default size for icons in the label row, shadcn's
  /// `[&_svg:not([class*='size-'])]:size-4`.
  ///
  /// Only a default: an [Icon] carrying its own `size` still wins, which is
  /// what the reference's `:not([class*='size-'])` says.
  double? iconSize(ThemeData theme) {
    if (widget.iconSize != null) return widget.iconSize;
    return sizeTheme(
      theme,
      widget.size ?? buttonTheme(theme).size ?? ButtonSize.regular,
    ).iconSize;
  }

  Color? background(ThemeData theme) {
    return widget.backgroundColor ?? buttonTheme(theme).backgroundColor;
  }

  Color? hoverBackground(ThemeData theme) {
    return widget.hoverBackgroundColor ??
        buttonTheme(theme).hoverBackgroundColor;
  }

  Color foreground(ThemeData theme) {
    if (widget.foregroundColor != null) return widget.foregroundColor!;

    final btnThemeForegroundColor = buttonTheme(theme).foregroundColor;
    assert(
      btnThemeForegroundColor != null,
      'Button foregroundColor is null in ButtonTheme',
    );
    return buttonTheme(theme).foregroundColor!;
  }

  Color hoverForeground(ThemeData theme) {
    if (widget.hoverForegroundColor != null) {
      return widget.hoverForegroundColor!;
    }
    final btnThemeHoverForegroundColor = buttonTheme(
      theme,
    ).hoverForegroundColor;
    assert(
      btnThemeHoverForegroundColor != null,
      'Button hoverForegroundColor is null in ButtonTheme',
    );
    return buttonTheme(theme).hoverForegroundColor!;
  }

  Color pressedBackgroundColor(ThemeData theme) {
    return widget.pressedBackgroundColor ??
        buttonTheme(theme).pressedBackgroundColor!;
  }

  Color pressedForegroundColor(ThemeData theme) {
    return widget.pressedForegroundColor ??
        buttonTheme(theme).pressedForegroundColor!;
  }

  TextDecoration? textDecoration(
    ThemeData theme, {
    required bool hovered,
  }) {
    if (hovered) {
      return widget.hoverTextDecoration ??
          buttonTheme(theme).hoverTextDecoration;
    }
    return widget.textDecoration ?? buttonTheme(theme).textDecoration;
  }

  MouseCursor cursor(ThemeData theme) {
    if (widget.cursor != null) return widget.cursor!;
    return (widget.enabled
        ? buttonTheme(theme).cursor ?? SystemMouseCursors.click
        : MouseCursor.defer);
  }

  Gradient? gradient(ThemeData theme) {
    return widget.gradient ?? buttonTheme(theme).gradient;
  }

  List<BoxShadow>? shadows(ThemeData theme) {
    return widget.shadows ?? buttonTheme(theme).shadows;
  }

  // Counted for the press response: a click is usually down and up within
  // one frame, so the button is never built pressed at all.
  int _taps = 0;

  void onTap() {
    if (widget.onPressed == null || widget.loading) return;
    if (mounted) setState(() => _taps++);
    widget.onPressed!();
  }

  /// Whether the button has been built in its loading state. From then on
  /// the label keeps the wrapper the spinner is swapped in under, so it is
  /// not re-parented — and its state lost — each time loading ends.
  bool _hasLoaded = false;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final iconTheme = IconTheme.of(context);

    final hasPressedBackgroundColor =
        widget.pressedBackgroundColor != null ||
        buttonTheme(theme).pressedBackgroundColor != null;
    final hasPressedForegroundColor =
        widget.pressedForegroundColor != null ||
        buttonTheme(theme).pressedForegroundColor != null;

    var effectiveDecoration =
        (buttonTheme(theme).decoration ?? const FinesseDecoration()).merge(
          widget.decoration,
        );
    // In a `ButtonGroup` the corners and the edge towards a neighbour are
    // the group's to decide.
    final group = ButtonGroupScope.maybeOf(context);
    if (group != null) {
      effectiveDecoration = group.join(
        effectiveDecoration,
        Directionality.of(context),
        fallback: theme.decoration,
      );
    }

    final effectiveMainAxisAlignment =
        widget.mainAxisAlignment ??
        buttonTheme(theme).mainAxisAlignment ??
        MainAxisAlignment.center;

    final effectiveCrossAxisAlignment =
        widget.crossAxisAlignment ??
        buttonTheme(theme).crossAxisAlignment ??
        CrossAxisAlignment.center;

    final effectiveLongPressDuration =
        widget.longPressDuration ?? buttonTheme(theme).longPressDuration;

    final effectiveHoverStrategies =
        widget.hoverStrategies ??
        buttonTheme(theme).hoverStrategies ??
        theme.hoverStrategies;

    final effectiveTextDirection =
        widget.textDirection ?? buttonTheme(theme).textDirection;

    final effectiveGap = widget.gap ?? buttonTheme(theme).gap ?? 8;

    final effectiveExpands =
        widget.expands ?? buttonTheme(theme).expands ?? false;

    final effectiveCanRequestFocus = widget.canRequestFocus ?? widget.enabled;

    final effectiveTextStyle =
        widget.textStyle ??
        buttonTheme(theme).textStyle ??
        theme.textTheme.small;

    final effectiveWidth = width(theme) ?? 0;
    final effectiveHeight = height(theme);
    // The style height is the height at the platform's text size: a larger
    // text scale lets the button grow to keep its label whole, and at a
    // scale of 1 this is the height itself.
    final effectiveMaxHeight = textScaledMaxHeight(context, effectiveHeight);
    // Null keeps whatever the ambient IconTheme says, rather than falling
    // back to Flutter's 24 — but every shipped style sets one.
    final effectiveIconSize = iconSize(theme) ?? iconTheme.size;
    final motion = Motion.of(context);
    final effectivePressScale =
        widget.pressScale ?? buttonTheme(theme).pressScale ?? motion.pressScale;
    final effectiveTransitionDuration =
        widget.transitionDuration ??
        buttonTheme(theme).transitionDuration ??
        motion.fast;

    return CallbackShortcuts(
      bindings: {
        for (final trigger in activationKeys)
          trigger: () {
            if (!widget.enabled) return;
            onTap();
          },
      },
      child: ValueListenableBuilder(
        valueListenable: statesController,
        builder: (context, states, _) {
          final loading = widget.loading;
          final pressed = !loading && states.contains(WidgetState.pressed);
          final hovered = !loading && states.contains(WidgetState.hovered);
          final enabled =
              widget.enabled && !states.contains(WidgetState.disabled);

          final effectiveBackgroundColor = hasPressedBackgroundColor && pressed
              ? pressedBackgroundColor(theme)
              : hovered
              ? hoverBackground(theme)
              : background(theme);

          final effectiveForegroundColor = hasPressedForegroundColor && pressed
              ? pressedForegroundColor(theme)
              : hovered
              ? hoverForeground(theme)
              : foreground(theme);

          final updatedDecoration = effectiveDecoration.copyWith(
            color: effectiveBackgroundColor,
            gradient: gradient(theme),
            shadows: shadows(theme),
          );

          var child = widget.child;

          // A child that is already Flexible (or Expanded) brings its own
          // flex. Wrapping it in Expanded would put it under the Expanded
          // instead of directly under the Row, which Flutter rejects as an
          // incorrect use of ParentDataWidget.
          if (widget.child != null &&
              effectiveExpands &&
              widget.child is! Flexible) {
            child = Expanded(child: widget.child!);
          }

          // The spinner takes the place of the leading widget, or lies over
          // the label when there is none. What it replaces stays in the
          // layout, unseen, so the button does not change size.
          var leading = widget.leading;
          if (loading) _hasLoaded = true;
          if (_hasLoaded) {
            final spinnerSize = effectiveIconSize ?? 16;
            if (leading != null) {
              leading = _LoadingSwap(
                loading: loading,
                spinnerSize: spinnerSize,
                child: leading,
              );
            } else if (widget.child != null) {
              final swapped = _LoadingSwap(
                loading: loading,
                spinnerSize: spinnerSize,
                child: widget.child!,
              );
              child = child is Expanded ? Expanded(child: swapped) : swapped;
            }
          }

          // shadcn/ui nudges a button down a pixel while active
          // (`active:translate-y-px`), animated by its `transition-all`.
          final effectivePressedOffset =
              widget.pressedOffset ??
              buttonTheme(theme).pressedOffset ??
              const Offset(0, 1);
          final effectivePressDuration =
              widget.pressAnimationDuration ??
              buttonTheme(theme).pressAnimationDuration ??
              const Duration(milliseconds: 100);

          // Requires a real handler as well as the enabled state: a button
          // with no onPressed does nothing, so it should not appear to
          // depress. `enabled` here tracks Button.enabled, which is
          // independent of whether a callback was supplied.
          final depressed =
              pressed && enabled && !loading && widget.onPressed != null;

          Widget withForeground(Color? color, Widget? child) {
            return IconTheme(
              data: iconTheme.copyWith(
                color: color,
                size: effectiveIconSize,
              ),
              child: DefaultTextStyle(
                style: effectiveTextStyle.copyWith(
                  color: color,
                  decoration: textDecoration(
                    theme,
                    hovered: hovered,
                  ),
                  decorationColor: foreground(theme),
                  decorationStyle: TextDecorationStyle.solid,
                ),
                textAlign: TextAlign.center,
                child: child!,
              ),
            );
          }

          // The press is acknowledged by a scale, a paint-time transform:
          // the button's box, and so its height, never changes.
          return PressScale(
            pressed: depressed,
            taps: enabled && !loading ? _taps : 0,
            scale: effectivePressScale,
            child: AnimatedSlide(
              // AnimatedSlide takes a fraction of the child's size, so
              // convert the pixel offset once the height is known.
              offset: depressed
                  ? Offset(
                      effectivePressedOffset.dx / 100,
                      effectivePressedOffset.dy / effectiveHeight,
                    )
                  : Offset.zero,
              duration: effectivePressDuration,
              curve: Curves.easeOut,
              // Hover and press change the colours over a short fade
              // rather than at once. Each fade starts from the colour on
              // screen, so leaving mid-fade turns around without a flash.
              child: AnimatedColorBuilder(
                color: effectiveForegroundColor,
                duration: effectiveTransitionDuration,
                curve: motion.standard,
                builder: (context, color, child) =>
                    withForeground(color, child),
                child: Semantics(
                  container: true,
                  button: true,
                  focusable: enabled,
                  // Busy: there, and in the focus order, but not to be
                  // pressed. The spinner's label says why.
                  enabled: enabled && !loading,
                  child: Opacity(
                    opacity: enabled ? 1 : .5,
                    child: AbsorbPointer(
                      absorbing: !enabled,
                      child: Focusable(
                        canRequestFocus: effectiveCanRequestFocus,
                        autofocus: widget.autofocus,
                        focusNode: focusNode,
                        onFocusChange: widget.onFocusChange,
                        // The size constraints sit *outside* the decorator so
                        // the border — and the focus reserve of the
                        // no-secondary-border variant — is counted into the
                        // button's height, the way CSS `h-9` is border-box.
                        // Constraining inside made an outline button 2px
                        // taller than a primary one.
                        builder: (context, focused, child) => ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: effectiveWidth,
                            // When the width is 0 or null, maxWidth goes to
                            // infinity so the button sizes itself from its
                            // child.
                            maxWidth: effectiveWidth == 0
                                ? double.infinity
                                : effectiveWidth,
                            minHeight: effectiveHeight,
                            // When the height is 0, we set maxHeight to
                            // infinity to allow the button to size itself
                            // based on its child.
                            maxHeight: effectiveHeight == 0
                                ? double.infinity
                                : effectiveMaxHeight,
                          ),
                          child: AnimatedColorBuilder(
                            color: updatedDecoration.color,
                            duration: effectiveTransitionDuration,
                            curve: motion.standard,
                            builder: (context, color, child) => Decorator(
                              decoration: color == null
                                  ? updatedDecoration
                                  : updatedDecoration.copyWith(color: color),
                              focused: focused,
                              child: child,
                            ),
                            child: child,
                          ),
                        ),
                        child: FinesseGestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onHoverChange: (value) {
                            statesController.update(
                              WidgetState.hovered,
                              value,
                            );
                            widget.onHoverChange?.call(value);
                          },
                          hoverStrategies: effectiveHoverStrategies,
                          cursor: loading ? MouseCursor.defer : cursor(theme),
                          onLongPress: loading ? null : widget.onLongPress,
                          onTap: widget.onPressed == null || loading
                              ? null
                              : onTap,
                          onTapDown: (details) {
                            statesController.update(WidgetState.pressed, true);
                            widget.onTapDown?.call(details);
                          },
                          onTapUp: (details) {
                            statesController.update(
                              WidgetState.pressed,
                              false,
                            );
                            widget.onTapUp?.call(details);
                          },
                          onTapCancel: () {
                            statesController.update(
                              WidgetState.pressed,
                              false,
                            );
                            widget.onTapCancel?.call();
                          },
                          onSecondaryTapDown: (details) {
                            widget.onSecondaryTapDown?.call(details);
                          },
                          onSecondaryTapUp: (details) {
                            widget.onSecondaryTapUp?.call(details);
                          },
                          onSecondaryTapCancel: () {
                            widget.onSecondaryTapCancel?.call();
                          },
                          onDoubleTap: widget.onDoubleTap,
                          onDoubleTapDown: widget.onDoubleTapDown,
                          onDoubleTapCancel: widget.onDoubleTapCancel,
                          onLongPressCancel: widget.onLongPressCancel,
                          onLongPressEnd: widget.onLongPressEnd,
                          onLongPressUp: widget.onLongPressUp,
                          onLongPressDown: widget.onLongPressDown,
                          onLongPressStart: widget.onLongPressStart,
                          longPressDuration: effectiveLongPressDuration,
                          child: SelectionContainer.disabled(
                            child: Padding(
                              padding: padding(theme),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: effectiveCrossAxisAlignment,
                                mainAxisAlignment: effectiveMainAxisAlignment,
                                textDirection: effectiveTextDirection,
                                children: [
                                  ?leading,
                                  ?child,
                                  ?widget.trailing,
                                ].separatedBy(SizedBox(width: effectiveGap)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Shows a spinner in the place of [child] while [loading]: the child stays
/// in the layout, unseen, so nothing around it moves.
class _LoadingSwap extends StatefulWidget {
  const _LoadingSwap({
    required this.loading,
    required this.spinnerSize,
    required this.child,
  });

  final bool loading;
  final double spinnerSize;
  final Widget child;

  @override
  State<_LoadingSwap> createState() => _LoadingSwapState();
}

class _LoadingSwapState extends State<_LoadingSwap> {
  /// What is shown. It follows the widget, except that a swap created
  /// already loading — the button's first time — starts out not loading
  /// and turns in its first frame, so that time is animated like the rest.
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _loading = widget.loading);
      });
    }
  }

  @override
  void didUpdateWidget(_LoadingSwap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loading = widget.loading;
  }

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    return Stack(
      alignment: Alignment.center,
      // A spinner larger than a one-letter label still shows whole.
      clipBehavior: Clip.none,
      children: [
        AnimatedOpacity(
          opacity: _loading ? 0 : 1,
          duration: motion.fast,
          curve: motion.standard,
          child: widget.child,
        ),
        // Out of the tree when it is not showing: a spinner never rests.
        Positioned.fill(
          child: Center(
            child: PopIn(
              visible: _loading,
              child: Spinner(
                size: widget.spinnerSize,
                semanticLabel: FinesseLocalizations.of(context).button.loading,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
