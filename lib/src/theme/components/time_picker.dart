import 'package:finesse/src/components/time_picker.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'time_picker.g.theme.dart';

/// {@template TimePickerTheme}
/// Theme for the `TimePicker` widget.
/// {@endtemplate}
@themeGen
@immutable
class TimePickerTheme with _$TimePickerTheme {
  /// {@macro TimePickerTheme}
  const TimePickerTheme({
    bool canMerge = true,
    this.axis,
    this.spacing,
    this.runSpacing,
    this.jumpToNextFieldWhenFilled,
    this.alignment,
    this.runAlignment,
    this.crossAxisAlignment,
    this.initialDayPeriod,
    this.periodHeight,
    this.periodMinWidth,
    this.gap,
    this.style,
    this.placeholderStyle,
    this.labelStyle,
    this.fieldWidth,
    this.fieldPadding,
    this.fieldDecoration,
    this.periodDecoration,
    this.hourLabel,
    this.minuteLabel,
    this.secondLabel,
    this.hourPlaceholder,
    this.minutePlaceholder,
    this.secondPlaceholder,
    this.periodLabel,
    this.periodPlaceholder,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro TimePicker.axis}
  final Axis? axis;

  /// {@macro TimePicker.spacing}
  final double? spacing;

  /// {@macro TimePicker.runSpacing}
  final double? runSpacing;

  /// {@macro TimePicker.jumpToNextFieldWhenFilled}
  final bool? jumpToNextFieldWhenFilled;

  /// {@macro TimePicker.alignment}
  final WrapAlignment? alignment;

  /// {@macro TimePicker.runAlignment}
  final WrapAlignment? runAlignment;

  /// {@macro TimePicker.crossAxisAlignment}
  final WrapCrossAlignment? crossAxisAlignment;

  /// {@macro TimePicker.initialDayPeriod}
  final DayPeriod? initialDayPeriod;

  /// {@macro TimePicker.periodHeight}
  final double? periodHeight;

  /// {@macro TimePicker.periodMinWidth}
  final double? periodMinWidth;

  /// {@macro TimePicker.gap}
  final double? gap;

  /// {@macro TimePicker.style}
  final TextStyle? style;

  /// {@macro TimePicker.placeholderStyle}
  final TextStyle? placeholderStyle;

  /// {@macro TimePicker.labelStyle}
  final TextStyle? labelStyle;

  /// {@macro TimePicker.fieldWidth}
  final double? fieldWidth;

  /// {@macro TimePicker.fieldPadding}
  final EdgeInsetsGeometry? fieldPadding;

  /// {@macro TimePicker.fieldDecoration}
  final FinesseDecoration? fieldDecoration;

  /// {@macro TimePicker.periodDecoration}
  final FinesseDecoration? periodDecoration;

  /// {@macro TimePicker.hourLabel}
  final Widget? hourLabel;

  /// {@macro TimePicker.minuteLabel}
  final Widget? minuteLabel;

  /// {@macro TimePicker.secondLabel}
  final Widget? secondLabel;

  /// {@macro TimePicker.periodLabel}
  final Widget? periodLabel;

  /// {@macro TimePicker.hourPlaceholder}
  final Widget? hourPlaceholder;

  /// {@macro TimePicker.minutePlaceholder}
  final Widget? minutePlaceholder;

  /// {@macro TimePicker.secondPlaceholder}
  final Widget? secondPlaceholder;

  /// {@macro TimePicker.periodPlaceholder}
  final Widget? periodPlaceholder;

  /// Linearly interpolates between [a] and [b] by [t].
  static TimePickerTheme? lerp(
    TimePickerTheme? a,
    TimePickerTheme? b,
    double t,
  ) => _$TimePickerTheme.lerp(a, b, t);
}
