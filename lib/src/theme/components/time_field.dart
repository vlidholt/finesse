import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'time_field.g.theme.dart';

/// The theme of `TimeField`: every value the widget does not set itself.
///
/// `DateField` takes its look from this theme as well, on purpose: the two
/// are siblings and sit side by side in a form, so their fields share one
/// text style, placeholder style, label style, decoration, padding, width,
/// gap and spacing, and `jumpToNextFieldWhenFilled`. The values about the
/// wrap the fields are laid out in ([axis], [alignment], [runAlignment],
/// [crossAxisAlignment]) and about the day period ([periodHeight],
/// [periodMinWidth], [periodDecoration]) are the time field's alone.
@themeGen
@immutable
class TimeFieldTheme with _$TimeFieldTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const TimeFieldTheme({
    bool canMerge = true,
    this.axis,
    this.spacing,
    this.runSpacing,
    this.jumpToNextFieldWhenFilled,
    this.alignment,
    this.runAlignment,
    this.crossAxisAlignment,
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
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The axis the fields are laid out along.
  final Axis? axis;

  /// The gap between two fields.
  final double? spacing;

  /// The gap between two runs of fields, when they wrap.
  final double? runSpacing;

  /// Whether the focus moves on to the next field once two digits are
  /// typed.
  final bool? jumpToNextFieldWhenFilled;

  /// How the fields are placed along the main axis.
  final WrapAlignment? alignment;

  /// How the runs are placed along the cross axis.
  final WrapAlignment? runAlignment;

  /// How the fields of one run are aligned with each other.
  final WrapCrossAlignment? crossAxisAlignment;

  /// The height of the day-period select.
  final double? periodHeight;

  /// The least width of the day-period select.
  final double? periodMinWidth;

  /// The gap between a field and the name above it.
  final double? gap;

  /// The style of the digits.
  final TextStyle? style;

  /// The style of the placeholder digits.
  final TextStyle? placeholderStyle;

  /// The style of the names above the fields.
  final TextStyle? labelStyle;

  /// The width of one number field, before the text scale.
  final double? fieldWidth;

  /// The padding inside a number field.
  final EdgeInsetsGeometry? fieldPadding;

  /// The decoration of a number field.
  final FinesseDecoration? fieldDecoration;

  /// The decoration of the day-period select.
  final FinesseDecoration? periodDecoration;

  /// Linearly interpolates between two themes.
  static TimeFieldTheme? lerp(
    TimeFieldTheme? a,
    TimeFieldTheme? b,
    double t,
  ) => _$TimeFieldTheme.lerp(a, b, t);
}
