import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';
import 'package:una/src/liquid_glass/liquid_glass_theme.dart';

part 'floating_action_button.g.theme.dart';

/// The theme of `FloatingActionButton`: every value the widget does not set
/// itself.
///
/// The sizes follow the form factor: a floating action button is a touch
/// target first, so it is larger on a phone.
@themeGen
@immutable
class FloatingActionButtonTheme with _$FloatingActionButtonTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const FloatingActionButtonTheme({
    bool canMerge = true,
    this.liquidGlass,
    this.size,
    this.sizeSm,
    this.sizeLg,
    this.iconSize,
    this.iconSizeSm,
    this.iconSizeLg,
    this.padding,
    this.gap,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.secondaryBackgroundColor,
    this.secondaryForegroundColor,
    this.glassForegroundColor,
    this.shadows,
    this.labelStyle,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// Whether the floating action button draws with Liquid Glass, over
  /// `ThemeData.liquidGlass.mode`; null follows the theme.
  final LiquidGlassMode? liquidGlass;

  /// The height of a regular button, and its width without a label.
  final double? size;

  /// The height of a small button, and its width without a label.
  final double? sizeSm;

  /// The height of a large button, and its width without a label.
  final double? sizeLg;

  /// The side of the icon in a regular button.
  final double? iconSize;

  /// The side of the icon in a small button.
  final double? iconSizeSm;

  /// The side of the icon in a large button.
  final double? iconSizeLg;

  /// The space at each end of a button with a label: before the icon and
  /// after the label.
  final double? padding;

  /// The gap between the icon and the label.
  final double? gap;

  /// The button's corners. A fully round radius makes a circle of a button
  /// without a label and a pill of one with.
  final BorderRadius? borderRadius;

  /// The fill of the primary variant.
  final Color? backgroundColor;

  /// The colour of the primary variant's icon and label.
  final Color? foregroundColor;

  /// The fill of the secondary variant.
  final Color? secondaryBackgroundColor;

  /// The colour of the secondary variant's icon and label.
  final Color? secondaryForegroundColor;

  /// The colour of the glass variant's icon and label. Its surface is the
  /// theme's strong glass.
  final Color? glassForegroundColor;

  /// The shadow that lifts the button off the page.
  final List<BoxShadow>? shadows;

  /// The style of the label.
  final TextStyle? labelStyle;

  /// Linearly interpolates between two themes.
  static FloatingActionButtonTheme? lerp(
    FloatingActionButtonTheme? a,
    FloatingActionButtonTheme? b,
    double t,
  ) => _$FloatingActionButtonTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the list by value, then let the
  // generated `==` compare everything else against a copy that shares it.
  @override
  bool operator ==(Object other) =>
      other is FloatingActionButtonTheme &&
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(shadows: shadows);

  // Equal themes must hash alike, and the list may differ in identity.
  @override
  int get hashCode =>
      Object.hash(runtimeType, Object.hashAll(shadows ?? const []));
}
