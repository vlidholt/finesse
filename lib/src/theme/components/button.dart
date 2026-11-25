import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/theme/components/button_sizes.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'button.g.theme.dart';

/// The theme for Button.
///
/// Use this class to override some properties to all buttons in just one place.
@themeGen
@immutable
class ButtonTheme with _$ButtonTheme {
  /// Creates a [ButtonTheme].
  const ButtonTheme({
    bool canMerge = true,
    this.mouseCursor,
    this.size,
    this.sizesTheme,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.shadows,
    this.gradient,
    this.textDecoration,
    this.hoverTextDecoration,
    this.decoration,
    this.width,
    this.height,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.longPressDuration,
    this.hoverStrategies,
    this.gap,
    this.expands,
    this.pressedOffset,
    this.pressAnimationDuration,
    this.pressScale,
    this.transitionDuration,
    this.textStyle,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Button.mouseCursor}
  final MouseCursor? mouseCursor;

  /// {@macro Button.size}
  final ButtonSize? size;

  /// {@macro ButtonSizesTheme}
  final ButtonSizesTheme? sizesTheme;

  /// {@macro Button.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Button.hoverBackgroundColor}
  final Color? hoverBackgroundColor;

  /// {@macro Button.foregroundColor}
  final Color? foregroundColor;

  /// {@macro Button.hoverForegroundColor}
  final Color? hoverForegroundColor;

  /// {@macro Button.pressedBackgroundColor}
  final Color? pressedBackgroundColor;

  /// {@macro Button.pressedForegroundColor}
  final Color? pressedForegroundColor;

  /// {@macro Button.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Button.gradient}
  final Gradient? gradient;

  /// {@macro Button.textDecoration}
  final TextDecoration? textDecoration;

  /// {@macro Button.hoverTextDecoration}
  final TextDecoration? hoverTextDecoration;

  /// {@macro Button.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Button.width}
  final double? width;

  /// {@macro Button.height}
  final double? height;

  /// {@macro Button.longPressDuration}
  final Duration? longPressDuration;

  /// {@macro Button.hoverStrategies}
  final HoverStrategies? hoverStrategies;

  /// {@macro Button.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@macro Button.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro Button.gap}
  final double? gap;

  /// {@macro Button.expands}
  final bool? expands;

  /// {@template ButtonTheme.pressedOffset}
  /// How far the button shifts while pressed.
  ///
  /// shadcn/ui nudges a button down by one pixel on `:active`
  /// (`active:translate-y-px`); this is the same effect. Defaults to
  /// `Offset(0, 1)`. Use [Offset.zero] to disable it.
  /// {@endtemplate}
  final Offset? pressedOffset;

  /// {@template ButtonTheme.pressAnimationDuration}
  /// How long the [pressedOffset] shift takes, defaults to 100ms.
  /// {@endtemplate}
  final Duration? pressAnimationDuration;

  /// {@template ButtonTheme.pressScale}
  /// The scale of the button while it is pressed: a paint-time transform that
  /// springs back on release and never changes the layout. Defaults to the
  /// theme's `Motion.pressScale`; 1 disables it.
  /// {@endtemplate}
  final double? pressScale;

  /// {@template ButtonTheme.transitionDuration}
  /// How long the background and foreground colours take to change between
  /// the idle, hovered and pressed states. Defaults to the theme's
  /// `Motion.fast`; `Duration.zero` changes them at once.
  /// {@endtemplate}
  final Duration? transitionDuration;

  /// {@macro Button.textStyle}
  final TextStyle? textStyle;

  /// Linearly interpolates between [a] and [b] by [t].
  static ButtonTheme? lerp(
    ButtonTheme? a,
    ButtonTheme? b,
    double t,
  ) {
    return _$ButtonTheme.lerp(a, b, t);
  }

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is ButtonTheme &&
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(shadows: shadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(shadows ?? const []),
  );
}
