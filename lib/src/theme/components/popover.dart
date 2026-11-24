import 'dart:ui';

import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'popover.g.theme.dart';

/// {@template PopoverTheme}
/// Theme for the `Popover` widget.
/// {@endtemplate}
@themeGen
@immutable
class PopoverTheme with _$PopoverTheme {
  /// {@macro PopoverTheme}
  const PopoverTheme({
    bool canMerge = true,
    this.effects,
    this.shadows,
    this.reverseDuration,
    this.textStyle,
    this.padding,
    this.decoration,
    this.anchor,
    this.filter,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Popover.effects}
  final List<Effect<dynamic>>? effects;

  /// {@macro Popover.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Popover.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Popover.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Popover.anchor}
  final AnchorBase? anchor;

  /// {@macro Popover.filter}
  final ImageFilter? filter;

  /// {@macro Popover.reverseDuration}
  final Duration? reverseDuration;

  /// {@macro Popover.textStyle}
  final TextStyle? textStyle;

  /// Linearly interpolates between [a] and [b] by [t].
  static PopoverTheme? lerp(
    PopoverTheme? a,
    PopoverTheme? b,
    double t,
  ) => _$PopoverTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is PopoverTheme &&
      listEquals(effects, other.effects) &&
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(effects: effects, shadows: shadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(effects ?? const []),
    Object.hashAll(shadows ?? const []),
  );
}
