import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'tooltip.g.theme.dart';

/// {@template TooltipTheme}
/// Theme for the `Tooltip` widget.
/// {@endtemplate}
@themeGen
@immutable
class TooltipTheme with _$TooltipTheme {
  /// {@macro TooltipTheme}
  const TooltipTheme({
    bool canMerge = true,
    this.waitDuration,
    this.showDuration,
    this.effects,
    this.padding,
    this.decoration,
    this.anchor,
    this.hoverStrategies,
    this.longPressDuration,
    this.duration,
    this.reverseDuration,
    this.textStyle,
    this.maxWidth,
    this.showArrow,
    this.arrowSize,
    this.arrowRadius,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Tooltip.waitDuration}
  final Duration? waitDuration;

  /// {@macro Tooltip.showDuration}
  final Duration? showDuration;

  /// {@macro Tooltip.effects}
  final List<Effect<dynamic>>? effects;

  /// {@macro Tooltip.anchor}
  final AnchorBase? anchor;

  /// {@macro Tooltip.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Tooltip.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Tooltip.hoverStrategies}
  final HoverStrategies? hoverStrategies;

  /// {@macro Tooltip.longPressDuration}
  final Duration? longPressDuration;

  /// {@macro Tooltip.duration}
  final Duration? duration;

  /// {@macro Tooltip.reverseDuration}
  final Duration? reverseDuration;

  /// The text style of the tooltip's content, `text-xs` on the inverted
  /// surface's `text-background`.
  final TextStyle? textStyle;

  /// The widest the tooltip may grow, `max-w-xs`.
  final double? maxWidth;

  /// {@macro Tooltip.showArrow}
  final bool? showArrow;

  /// The edge length of the arrow's rotated square, `size-2.5`.
  final double? arrowSize;

  /// The corner radius of the arrow's tip, `rounded-[2px]` — zero in the
  /// square styles.
  final double? arrowRadius;

  /// Linearly interpolates between [a] and [b] by [t].
  static TooltipTheme? lerp(
    TooltipTheme? a,
    TooltipTheme? b,
    double t,
  ) => _$TooltipTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is TooltipTheme &&
      listEquals(effects, other.effects) &&
      super == other.copyWith(effects: effects);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(effects ?? const []),
  );
}
