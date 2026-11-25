import 'dart:ui';

import 'package:finesse/src/liquid_glass/liquid_glass_theme.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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
    this.liquidGlass,
    this.shadows,
    this.textStyle,
    this.padding,
    this.decoration,
    this.anchor,
    this.filter,
    this.showArrow,
    this.arrowSize,
    this.arrowRadius,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// Whether popovers, menus, a select's list and `Surface` draw with
  /// Liquid Glass, over
  /// `ThemeData.liquidGlass.mode`; null follows the theme.
  final LiquidGlassMode? liquidGlass;

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

  /// {@macro Popover.textStyle}
  final TextStyle? textStyle;

  /// {@macro Popover.showArrow}
  final bool? showArrow;

  /// The edge length of the arrow's square, which is turned 45° and sunk
  /// into the popover's edge: the tip stands about half of this proud of
  /// it. 14 in the built-in styles, a step up from the tooltip's
  /// `size-2.5`.
  final double? arrowSize;

  /// The corner radius of the arrow's tip, `rounded-[2px]` — zero in the
  /// square styles.
  final double? arrowRadius;

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
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(shadows: shadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(shadows ?? const []),
  );
}
