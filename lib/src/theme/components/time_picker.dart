import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'time_picker.g.theme.dart';

/// The theme of `TimePicker`: the button that shows a time, and the popover
/// it opens on a desktop.
@themeGen
@immutable
class TimePickerTheme with _$TimePickerTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const TimePickerTheme({
    bool canMerge = true,
    this.buttonVariant,
    this.width,
    this.popoverPadding,
    this.anchor,
    this.sheetWheelItems,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The look of the button.
  final ButtonVariant? buttonVariant;

  /// The width of the button; null makes it as wide as its content.
  final double? width;

  /// The padding inside the popover.
  final EdgeInsetsGeometry? popoverPadding;

  /// Where the popover sits against the button.
  final AnchorBase? anchor;

  /// How many rows of the wheels show in the sheet.
  final int? sheetWheelItems;

  /// Linearly interpolates between two themes.
  static TimePickerTheme? lerp(
    TimePickerTheme? a,
    TimePickerTheme? b,
    double t,
  ) => _$TimePickerTheme.lerp(a, b, t);
}
