import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';
import 'package:una/src/theme/components/decorator.dart';

part 'radio.g.theme.dart';

/// {@template RadioTheme}
/// Theme for the `Radio` widget.
/// {@endtemplate}
@themeGen
@immutable
class RadioTheme with _$RadioTheme {
  /// {@macro RadioTheme}
  const RadioTheme({
    bool canMerge = true,
    this.color,
    this.decoration,
    this.checkedDecoration,
    this.size,
    this.padding,
    this.circleSize,
    this.axis,
    this.spacing,
    this.runSpacing,
    this.alignment,
    this.runAlignment,
    this.crossAxisAlignment,
    this.radioPadding,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Radio.color}
  final Color? color;

  /// {@macro Radio.size}
  final double? size;

  /// {@macro Radio.decoration}
  final UnaDecoration? decoration;

  /// The decoration while selected, when it differs from [decoration]: the
  /// reference fills the circle with the primary (`data-checked:bg-primary
  /// data-checked:border-primary`) and draws a primary-foreground dot, so the
  /// selected radio cannot keep the unchecked outline. Null means "same as
  /// [decoration]".
  final UnaDecoration? checkedDecoration;

  /// {@macro Radio.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Radio.circleSize}
  final double? circleSize;

  /// {@macro UnaRadioGroup.axis}
  final Axis? axis;

  /// {@macro UnaRadioGroup.spacing}
  final double? spacing;

  /// {@macro UnaRadioGroup.runSpacing}
  final double? runSpacing;

  /// {@macro UnaRadioGroup.alignment}
  final WrapAlignment? alignment;

  /// {@macro UnaRadioGroup.runAlignment}
  final WrapAlignment? runAlignment;

  /// {@macro UnaRadioGroup.crossAxisAlignment}
  final WrapCrossAlignment? crossAxisAlignment;

  /// {@macro Radio.radioPadding}
  final EdgeInsetsGeometry? radioPadding;

  /// Linearly interpolates between [a] and [b] by [t].
  static RadioTheme? lerp(
    RadioTheme? a,
    RadioTheme? b,
    double t,
  ) => _$RadioTheme.lerp(a, b, t);
}
