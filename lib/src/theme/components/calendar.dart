import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/calendar.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'calendar.g.theme.dart';

/// {@template CalendarTheme}
/// Theme for the `Calendar` widget.
/// {@endtemplate}
@themeGen
@immutable
class CalendarTheme with _$CalendarTheme {
  /// {@macro CalendarTheme}
  const CalendarTheme({
    bool canMerge = true,
    this.hideNavigation,
    this.yearSelectorMinWidth,
    this.monthSelectorMinWidth,
    this.yearSelectorPadding,
    this.monthSelectorPadding,
    this.navigationButtonSize,
    this.navigationButtonIconSize,
    this.backNavigationButtonIconData,
    this.forwardNavigationButtonIconData,
    this.navigationButtonPadding,
    this.navigationButtonDisabledOpacity,
    this.decoration,
    this.spacingBetweenMonths,
    this.runSpacingBetweenMonths,
    this.monthConstraints,
    this.headerHeight,
    this.headerPadding,
    this.captionLayoutGap,
    this.headerTextStyle,
    this.weekdaysPadding,
    this.weekNumbersHeaderText,
    this.weekNumbersHeaderTextStyle,
    this.weekNumbersTextStyle,
    this.weekNumbersTextAlign,
    this.dayButtonSize,
    this.dayButtonRadius,
    this.selectorMinHeight,
    this.dayButtonOutsideMonthOpacity,
    this.dayButtonPadding,
    this.dayButtonDecoration,
    this.selectedDayButtonTextStyle,
    this.insideRangeDayButtonTextStyle,
    this.dayButtonOutsideMonthTextStyle,
    this.dayButtonOutsideMonthVariant,
    this.dayButtonTextStyle,
    this.dayButtonVariant,
    this.selectedDayButtonVariant,
    this.insideRangeDayButtonVariant,
    this.todayButtonVariant,
    this.weekdaysTextStyle,
    this.weekdaysTextAlign,
    this.gridMainAxisSpacing,
    this.gridCrossAxisSpacing,
    this.selectedDayButtonOutsideMonthVariant,
    this.captionLayout,
    this.hideWeekdayNames,
    this.showOutsideDays,
    this.formatMonthYear,
    this.formatMonth,
    this.formatYear,
    this.formatWeekday,
    this.showWeekNumbers,
    this.weekStartsOn,
    this.fixedWeeks,
    this.allowDeselection,
    this.dropdownFormatMonth,
    this.dropdownFormatYear,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Calendar.hideNavigation}
  final bool? hideNavigation;

  /// {@macro Calendar.yearSelectorMinWidth}
  final double? yearSelectorMinWidth;

  /// {@macro Calendar.monthSelectorMinWidth}
  final double? monthSelectorMinWidth;

  /// {@macro Calendar.yearSelectorPadding}
  final EdgeInsetsGeometry? yearSelectorPadding;

  /// {@macro Calendar.monthSelectorPadding}
  final EdgeInsetsGeometry? monthSelectorPadding;

  /// {@macro Calendar.navigationButtonSize}
  final double? navigationButtonSize;

  /// {@macro Calendar.navigationButtonIconSize}
  final double? navigationButtonIconSize;

  /// {@macro Calendar.backNavigationButtonIconData}
  final IconData? backNavigationButtonIconData;

  /// {@macro Calendar.forwardNavigationButtonIconData}
  final IconData? forwardNavigationButtonIconData;

  /// {@macro Calendar.navigationButtonPadding}
  final EdgeInsetsGeometry? navigationButtonPadding;

  /// {@macro Calendar.navigationButtonDisabledOpacity}
  final double? navigationButtonDisabledOpacity;

  /// {@macro Calendar.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Calendar.spacingBetweenMonths}
  final double? spacingBetweenMonths;

  /// {@macro Calendar.runSpacingBetweenMonths}
  final double? runSpacingBetweenMonths;

  /// {@macro Calendar.monthConstraints}
  final BoxConstraints? monthConstraints;

  /// {@macro Calendar.headerHeight}
  final double? headerHeight;

  /// {@macro Calendar.headerPadding}
  final EdgeInsetsGeometry? headerPadding;

  /// {@macro Calendar.captionLayoutGap}
  final double? captionLayoutGap;

  /// {@macro Calendar.headerTextStyle}
  final TextStyle? headerTextStyle;

  /// {@macro Calendar.weekdaysPadding}
  final EdgeInsetsGeometry? weekdaysPadding;

  /// {@macro Calendar.weekdaysTextStyle}
  final TextStyle? weekdaysTextStyle;

  /// {@macro Calendar.weekdaysTextAlign}
  final TextAlign? weekdaysTextAlign;

  /// {@macro Calendar.weekNumbersHeaderText}
  final String? weekNumbersHeaderText;

  /// {@macro Calendar.weekNumbersHeaderTextStyle}
  final TextStyle? weekNumbersHeaderTextStyle;

  /// {@macro Calendar.weekNumbersTextStyle}
  final TextStyle? weekNumbersTextStyle;

  /// {@macro Calendar.weekNumbersTextAlign}
  final TextAlign? weekNumbersTextAlign;

  /// {@macro Calendar.dayButtonSize}
  final double? dayButtonSize;

  /// The corner radius of day cells and of the month/year dropdown triggers,
  /// shadcn's `--cell-radius`. Its own knob because the styles keep it apart
  /// from the button radius (`vega` buttons are `lg`, its cells `md`).
  final BorderRadius? dayButtonRadius;

  /// The minimum height of the month/year dropdown triggers,
  /// `.cn-calendar-caption-label`'s `h-8`. Without it the triggers would take
  /// the select theme's field height, which is taller than a calendar row.
  final double? selectorMinHeight;

  /// {@macro Calendar.dayButtonOutsideMonthOpacity}
  final double? dayButtonOutsideMonthOpacity;

  /// {@macro Calendar.dayButtonPadding}
  final EdgeInsetsGeometry? dayButtonPadding;

  /// {@macro Calendar.dayButtonDecoration}
  final FinesseDecoration? dayButtonDecoration;

  /// {@macro Calendar.selectedDayButtonTextStyle}
  final TextStyle? selectedDayButtonTextStyle;

  /// {@macro Calendar.insideRangeDayButtonTextStyle}
  final TextStyle? insideRangeDayButtonTextStyle;

  /// {@macro Calendar.dayButtonTextStyle}
  final TextStyle? dayButtonTextStyle;

  /// {@macro Calendar.dayButtonVariant}
  final ButtonVariant? dayButtonVariant;

  /// {@macro Calendar.selectedDayButtonVariant}
  final ButtonVariant? selectedDayButtonVariant;

  /// {@macro Calendar.insideRangeDayButtonVariant}
  final ButtonVariant? insideRangeDayButtonVariant;

  /// {@macro Calendar.todayButtonVariant}
  final ButtonVariant? todayButtonVariant;

  /// {@macro Calendar.gridMainAxisSpacing}
  final double? gridMainAxisSpacing;

  /// {@macro Calendar.gridCrossAxisSpacing}
  final double? gridCrossAxisSpacing;

  /// {@macro Calendar.dayButtonOutsideMonthTextStyle}
  final TextStyle? dayButtonOutsideMonthTextStyle;

  /// {@macro Calendar.dayButtonOutsideMonthVariant}
  final ButtonVariant? dayButtonOutsideMonthVariant;

  /// {@macro Calendar.selectedDayButtonOutsideMonthVariant}
  final ButtonVariant? selectedDayButtonOutsideMonthVariant;

  /// {@macro Calendar.captionLayout}
  final CalendarCaptionLayout? captionLayout;

  /// {@macro Calendar.hideWeekdayNames}
  final bool? hideWeekdayNames;

  /// {@macro Calendar.showOutsideDays}
  final bool? showOutsideDays;

  /// {@macro Calendar.formatMonthYear}
  final String Function(DateTime date)? formatMonthYear;

  /// {@macro Calendar.formatMonth}
  final String Function(DateTime date)? formatMonth;

  /// {@macro Calendar.formatYear}
  final String Function(DateTime date)? formatYear;

  /// {@macro Calendar.formatWeekday}
  final String Function(DateTime date)? formatWeekday;

  /// {@macro Calendar.dropdownFormatMonth}
  final String Function(DateTime date)? dropdownFormatMonth;

  /// {@macro Calendar.dropdownFormatYear}
  final String Function(DateTime date)? dropdownFormatYear;

  /// {@macro Calendar.showWeekNumbers}
  final bool? showWeekNumbers;

  /// {@macro Calendar.weekStartsOn}
  final int? weekStartsOn;

  /// {@macro Calendar.fixedWeeks}
  final bool? fixedWeeks;

  /// {@macro Calendar.allowDeselection}
  final bool? allowDeselection;

  /// Linearly interpolates between [a] and [b] by [t].
  static CalendarTheme? lerp(
    CalendarTheme? a,
    CalendarTheme? b,
    double t,
  ) => _$CalendarTheme.lerp(a, b, t);
}
