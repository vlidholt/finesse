import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

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
    this.duration,
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

  /// {@macro Radio.duration}
  final Duration? duration;

  /// {@macro Radio.decoration}
  final FinesseDecoration? decoration;

  /// The decoration while selected, when it differs from [decoration]: the
  /// reference fills the circle with the primary (`data-checked:bg-primary
  /// data-checked:border-primary`) and draws a primary-foreground dot, so the
  /// selected radio cannot keep the unchecked outline. Null means "same as
  /// [decoration]".
  final FinesseDecoration? checkedDecoration;

  /// {@macro Radio.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Radio.circleSize}
  final double? circleSize;

  /// {@macro FinesseRadioGroup.axis}
  final Axis? axis;

  /// {@macro FinesseRadioGroup.spacing}
  final double? spacing;

  /// {@macro FinesseRadioGroup.runSpacing}
  final double? runSpacing;

  /// {@macro FinesseRadioGroup.alignment}
  final WrapAlignment? alignment;

  /// {@macro FinesseRadioGroup.runAlignment}
  final WrapAlignment? runAlignment;

  /// {@macro FinesseRadioGroup.crossAxisAlignment}
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
