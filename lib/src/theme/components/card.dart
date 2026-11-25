import 'package:finesse/src/utils/border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'card.g.theme.dart';

/// {@template CardTheme}
/// Theme for the `Card` widget.
/// {@endtemplate}
@themeGen
@immutable
class CardTheme with _$CardTheme {
  /// {@macro CardTheme}
  const CardTheme({
    bool canMerge = true,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.border,
    this.shadows,
    this.width,
    this.height,
    this.rowMainAxisAlignment,
    this.rowCrossAxisAlignment,
    this.columnMainAxisAlignment,
    this.columnCrossAxisAlignment,
    this.rowMainAxisSize,
    this.columnMainAxisSize,
    this.clipBehavior,
    this.titleStyle,
    this.descriptionStyle,
    this.gap,
    this.sectionGap,
    this.blur,
    this.saturation,
    this.pressScale,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Card.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Card.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Card.borderRadius}
  final BorderRadius? borderRadius;

  /// {@macro Card.border}
  final FinesseBorder? border;

  /// {@macro Card.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Card.width}
  final double? width;

  /// {@macro Card.height}
  final double? height;

  /// {@macro Card.rowMainAxisAlignment}
  final MainAxisAlignment? rowMainAxisAlignment;

  /// {@macro Card.rowCrossAxisAlignment}
  final CrossAxisAlignment? rowCrossAxisAlignment;

  /// {@macro Card.columnMainAxisAlignment}
  final MainAxisAlignment? columnMainAxisAlignment;

  /// {@macro Card.columnCrossAxisAlignment}
  final CrossAxisAlignment? columnCrossAxisAlignment;

  /// {@macro Card.rowMainAxisSize}
  final MainAxisSize? rowMainAxisSize;

  /// {@macro Card.columnMainAxisSize}
  final MainAxisSize? columnMainAxisSize;

  /// {@macro Card.clipBehavior}
  final Clip? clipBehavior;

  /// {@macro Card.titleStyle}
  final TextStyle? titleStyle;

  /// {@macro Card.descriptionStyle}
  final TextStyle? descriptionStyle;

  /// {@macro Card.gap}
  final double? gap;

  /// The space between a card's sections — header, content and footer —
  /// shadcn's `gap-(--card-spacing)`. [gap] stays the small gap between the
  /// title and its description. Null falls back to [gap].
  final double? sectionGap;

  /// The sigma of the backdrop blur behind a translucent card; 0 for none.
  final double? blur;

  /// How much a blurred card saturates its backdrop; 1 leaves it alone.
  final double? saturation;

  /// The scale of a pressable card while it is pressed; a paint-time
  /// transform that springs back on release. Defaults to the theme's
  /// `Motion.surfacePressScale`; 1 disables it.
  final double? pressScale;

  /// Linearly interpolates between [a] and [b] by [t].
  static CardTheme? lerp(
    CardTheme? a,
    CardTheme? b,
    double t,
  ) => _$CardTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is CardTheme &&
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(shadows: shadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(shadows ?? const []),
  );
}
