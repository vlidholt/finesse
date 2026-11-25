import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'date_picker.g.theme.dart';

/// The theme of `DatePicker` and `DateRangePicker`: the button that shows
/// the date, and the popover or sheet it opens.
///
/// How the calendar inside looks is the theme's `CalendarTheme`; a picker's
/// `calendarTheme` overrides it for one picker.
@themeGen
@immutable
class DatePickerTheme with _$DatePickerTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const DatePickerTheme({
    bool canMerge = true,
    this.buttonVariant,
    this.width,
    this.popoverPadding,
    this.anchor,
    this.allowDeselection,
    this.closeOnSelection,
    this.sheetMaxWidth,
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

  /// Whether tapping the selected day clears the date.
  final bool? allowDeselection;

  /// Whether choosing a day closes the picker.
  final bool? closeOnSelection;

  /// The widest the content of the sheet is laid out, so that on a wide
  /// screen the calendar's cells stay a comfortable size.
  final double? sheetMaxWidth;

  /// How many rows of the wheels show in the sheet.
  final int? sheetWheelItems;

  /// Linearly interpolates between two themes.
  static DatePickerTheme? lerp(
    DatePickerTheme? a,
    DatePickerTheme? b,
    double t,
  ) => _$DatePickerTheme.lerp(a, b, t);
}
