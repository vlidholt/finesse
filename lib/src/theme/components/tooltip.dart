import 'dart:ui' show ImageFilter;

import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
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
    this.padding,
    this.decoration,
    this.anchor,
    this.longPressDuration,
    this.textStyle,
    this.maxWidth,
    this.showArrow,
    this.arrowSize,
    this.arrowRadius,
    this.filter,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Tooltip.waitDuration}
  final Duration? waitDuration;

  /// {@macro Tooltip.showDuration}
  final Duration? showDuration;

  /// {@macro Tooltip.anchor}
  final AnchorBase? anchor;

  /// {@macro Tooltip.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Tooltip.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Tooltip.longPressDuration}
  final Duration? longPressDuration;

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

  /// {@macro Tooltip.filter}
  final ImageFilter? filter;

  /// Linearly interpolates between [a] and [b] by [t].
  static TooltipTheme? lerp(
    TooltipTheme? a,
    TooltipTheme? b,
    double t,
  ) => _$TooltipTheme.lerp(a, b, t);
}
