import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'toggle.g.theme.dart';

/// {@template ToggleTheme}
/// How a `Toggle` looks: its colours off, on and hovered, its decoration
/// and its metrics.
///
/// `ThemeData` holds one per variant (`toggleTheme`, `outlineToggleTheme`),
/// and `Toggle.style` takes one to restyle a single toggle: it is merged
/// over the variant's theme, so only the fields that are set change
/// anything.
/// {@endtemplate}
@themeGen
@immutable
class ToggleTheme with _$ToggleTheme {
  /// {@macro ToggleTheme}
  const ToggleTheme({
    bool canMerge = true,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.selectedBackgroundColor,
    this.selectedHoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.selectedForegroundColor,
    this.padding,
    this.decoration,
    this.textStyle,
    this.gap,
    this.height,
    this.width,
    this.iconSize,
    this.pressScale,
    this.transitionDuration,
    this.indicatorSpring,
    this.indicatorStretch,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The fill when off. Null paints none.
  final Color? backgroundColor;

  /// The fill when off and hovered or held.
  final Color? hoverBackgroundColor;

  /// The fill when on.
  final Color? selectedBackgroundColor;

  /// The fill when on and hovered or held.
  final Color? selectedHoverBackgroundColor;

  /// The colour of the label and icons when off.
  final Color? foregroundColor;

  /// The colour of the label and icons when off and hovered or held.
  final Color? hoverForegroundColor;

  /// The colour of the label and icons when on.
  final Color? selectedForegroundColor;

  /// The padding inside the toggle.
  final EdgeInsetsGeometry? padding;

  /// The border, corners and focus treatment. A style override is merged
  /// into the variant's.
  final FinesseDecoration? decoration;

  /// The text style of the label. A style override is merged into the
  /// variant's.
  final TextStyle? textStyle;

  /// The gap between the leading icon and the label.
  final double? gap;

  /// The height of the toggle. It is a floor once text is scaled up.
  final double? height;

  /// A fixed width. Null, the default, is as wide as the content.
  final double? width;

  /// The size of the toggle's icons. Defaults to 16.
  final double? iconSize;

  /// The scale of the toggle while it is pressed; a paint-time transform.
  /// Defaults to the theme's `Motion.pressScale`; 1 disables it.
  final double? pressScale;

  /// How long the fill and foreground colours take to change between
  /// states. Defaults to the theme's `Motion.fast`.
  final Duration? transitionDuration;

  /// The spring the selection travels with between the items of a
  /// single-selection `ToggleGroup`. Defaults to the theme's `Motion.snappy`;
  /// `MotionSpring.instant` moves it at once.
  final MotionSpring? indicatorSpring;

  /// How far the travelling selection of a `ToggleGroup` stretches; see
  /// `MovingIndicator.stretch`. Defaults to the theme's
  /// `Motion.indicatorStretch`.
  final double? indicatorStretch;

  /// Linearly interpolates between [a] and [b] by [t].
  static ToggleTheme? lerp(
    ToggleTheme? a,
    ToggleTheme? b,
    double t,
  ) => _$ToggleTheme.lerp(a, b, t);
}
