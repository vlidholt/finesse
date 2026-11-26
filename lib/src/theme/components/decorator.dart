import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';
import 'package:una/src/utils/border.dart';

part 'decorator.g.theme.dart';

/// {@template UnaDecoration}
/// The border, fill and label styling of a control, applied by `Decorator`.
///
/// A control has a primary border drawn on its edge and an optional secondary
/// border drawn outside it, which is how the focus ring is painted. Each has a
/// normal, focused and error form. The label, description and error fields
/// style the text around form fields.
/// {@endtemplate}
@themeGen
@immutable
class UnaDecoration with _$UnaDecoration {
  /// {@macro UnaDecoration}
  const UnaDecoration({
    bool canMerge = true,
    this.border,
    this.focusedBorder,
    this.errorBorder,
    this.secondaryBorder,
    this.secondaryFocusedBorder,
    this.secondaryErrorBorder,
    this.labelStyle,
    this.errorLabelStyle,
    this.errorStyle,
    this.descriptionStyle,
    this.labelPadding,
    this.descriptionPadding,
    this.errorPadding,
    this.fallbackToBorder,
    this.color,
    this.image,
    this.shadows,
    this.gradient,
    this.backgroundBlendMode,
    this.shape,
    this.hasError,
    this.fallbackToLabelStyle,
    this.disableSecondaryBorder,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// A decoration with no borders that replaces, rather than merges into, the
  /// decoration it is merged with.
  static const UnaDecoration none = UnaDecoration(
    canMerge: false,
    border: UnaBorder.none,
    focusedBorder: UnaBorder.none,
    errorBorder: UnaBorder.none,
    secondaryBorder: UnaBorder.none,
    secondaryFocusedBorder: UnaBorder.none,
    secondaryErrorBorder: UnaBorder.none,
  );

  /// The text style of a field's label.
  final TextStyle? labelStyle;

  /// The text style of a field's label while the field has an error. See
  /// [fallbackToLabelStyle].
  final TextStyle? errorLabelStyle;

  /// The border drawn on the control's edge.
  final UnaBorder? border;

  /// The border drawn on the control's edge while it has focus.
  final UnaBorder? focusedBorder;

  /// The border drawn on the control's edge while [hasError] is true.
  final UnaBorder? errorBorder;

  /// The border drawn outside the control, such as shadcn's `ring-*`.
  final UnaBorder? secondaryBorder;

  /// The outer border while the control has focus. This is the focus ring.
  final UnaBorder? secondaryFocusedBorder;

  /// The outer border while [hasError] is true.
  final UnaBorder? secondaryErrorBorder;

  /// The text style of a field's error message.
  final TextStyle? errorStyle;

  /// The text style of a field's description.
  final TextStyle? descriptionStyle;

  /// The padding around a field's label. Defaults to 8 below it.
  final EdgeInsetsGeometry? labelPadding;

  /// The padding around a field's description. Defaults to 8 above it.
  final EdgeInsetsGeometry? descriptionPadding;

  /// The padding around a field's error message. Defaults to 8 above it.
  final EdgeInsetsGeometry? errorPadding;

  /// The fill colour of the control.
  final Color? color;

  /// An image painted inside the control.
  final DecorationImage? image;

  /// The shadows painted outside the control.
  ///
  /// They are clipped to the area outside the control's outline, as CSS does.
  final List<BoxShadow>? shadows;

  /// A gradient painted inside the control, instead of [color].
  final Gradient? gradient;

  /// The blend mode of [color] or [gradient] with the content behind the
  /// control.
  final BlendMode? backgroundBlendMode;

  /// The shape of the control. Defaults to [BoxShape.rectangle].
  final BoxShape? shape;

  /// Whether the control shows its error borders and error label style.
  /// Defaults to false.
  final bool? hasError;

  /// Whether to skip the secondary borders. Defaults to
  /// `ThemeData.disableSecondaryBorder`.
  final bool? disableSecondaryBorder;

  /// Whether to fallback to the [border] if no [focusedBorder] or [errorBorder]
  /// is provided, defaults to true.
  ///
  /// This also affects the [secondaryBorder] with the same conditions.
  final bool? fallbackToBorder;

  /// Whether to fallback to the [labelStyle] if no [errorLabelStyle] is
  /// provided, defaults to true.
  final bool? fallbackToLabelStyle;

  /// Linearly interpolates between [a] and [b] by [t].
  static UnaDecoration? lerp(
    UnaDecoration? a,
    UnaDecoration? b,
    double t,
  ) => _$UnaDecoration.lerp(a, b, t);

  @override
  String toString() {
    return '''UnaDecoration(border: $border, focusedBorder: $focusedBorder, errorBorder: $errorBorder, secondaryBorder: $secondaryBorder, secondaryFocusedBorder: $secondaryFocusedBorder, secondaryErrorBorder: $secondaryErrorBorder, labelStyle: $labelStyle, errorLabelStyle: $errorLabelStyle, errorStyle: $errorStyle, descriptionStyle: $descriptionStyle, labelPadding: $labelPadding, descriptionPadding: $descriptionPadding, errorPadding: $errorPadding, fallbackToBorder: $fallbackToBorder, color: $color, image: $image, shadows: $shadows, gradient: $gradient, backgroundBlendMode: $backgroundBlendMode, shape: $shape, hasError: $hasError, fallbackToLabelStyle: $fallbackToLabelStyle, disableSecondaryBorder: $disableSecondaryBorder)''';
  }

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is UnaDecoration &&
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(shadows: shadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(shadows ?? const []),
  );
}
