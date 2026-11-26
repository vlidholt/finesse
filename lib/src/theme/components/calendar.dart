import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';
import 'package:una/src/components/button.dart';
import 'package:una/src/components/calendar.dart';
import 'package:una/src/theme/components/decorator.dart';

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
    this.showNavigation,
    this.yearSelectorMinWidth,
    this.monthSelectorMinWidth,
    this.yearSelectorPadding,
    this.monthSelectorPadding,
    this.navigationButtonSize,
    this.navigationButtonIconSize,
    this.backNavigationButtonIcon,
    this.forwardNavigationButtonIcon,
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
    this.dayButtonBorderRadius,
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
    this.showWeekdayNames,
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

  /// Whether to show the navigation buttons, defaults to true.
  final bool? showNavigation;

  /// The minimum width of the year selector, defaults to 64
  final double? yearSelectorMinWidth;

  /// The minimum width of the month selector, defaults to 64
  final double? monthSelectorMinWidth;

  /// The padding of the year selector, defaults to
  /// `EdgeInsets.symmetric(horizontal: 8, vertical: 4)`
  final EdgeInsetsGeometry? yearSelectorPadding;

  /// The padding of the month selector, defaults to
  /// `EdgeInsets.symmetric(horizontal: 8, vertical: 4)`
  final EdgeInsetsGeometry? monthSelectorPadding;

  /// The navigation button size, defaults to 28
  final double? navigationButtonSize;

  /// The navigation button icon size, defaults to 16
  final double? navigationButtonIconSize;

  /// The icon of the back navigation button, drawn at
  /// [navigationButtonIconSize]. Null, the default, is a caret that points
  /// towards the start: left in a left-to-right layout, right in a
  /// right-to-left one. An icon given here is drawn as it is in both.
  ///
  /// A theme is compared on every rebuild, so a widget given here has to be
  /// a constant.
  final Widget? backNavigationButtonIcon;

  /// The icon of the forward navigation button, drawn at
  /// [navigationButtonIconSize]. Null, the default, is a caret that points
  /// towards the end: right in a left-to-right layout, left in a
  /// right-to-left one. An icon given here is drawn as it is in both.
  ///
  /// A theme is compared on every rebuild, so a widget given here has to be
  /// a constant.
  final Widget? forwardNavigationButtonIcon;

  /// The padding of the navigation button, defaults to [EdgeInsets.zero]
  final EdgeInsetsGeometry? navigationButtonPadding;

  /// The opacity of the navigation button when disabled, defaults to .5
  final double? navigationButtonDisabledOpacity;

  /// The decoration of the calendar, defaults to
  /// ```dart
  /// UnaDecoration(
  ///   border: UnaBorder.all(
  ///     borderRadius: radius,
  ///     padding: const EdgeInsets.all(12),
  ///     color: colorScheme.border
  ///   ),
  /// )
  /// ```
  final UnaDecoration? decoration;

  /// The spacing between months, defaults to 16
  final double? spacingBetweenMonths;

  /// The run spacing between months, defaults to 16
  final double? runSpacingBetweenMonths;

  /// The month constraints, defaults to `BoxConstraints(maxWidth: 252)`
  /// or `BoxConstraints(maxWidth: 310)` depending on the [showNavigation] and
  /// [captionLayout] values.
  final BoxConstraints? monthConstraints;

  /// The height of the header, defaults to 38
  final double? headerHeight;

  /// The padding of the header, defaults to `EdgeInsets.only(bottom: 16)`
  final EdgeInsetsGeometry? headerPadding;

  /// The gap between the caption layout elements, defaults to 8
  final double? captionLayoutGap;

  /// The text style of the header, defaults to `effectiveTextTheme.small`
  final TextStyle? headerTextStyle;

  /// The padding of the weekdays, defaults to `EdgeInsets.only(bottom: 8)`
  final EdgeInsetsGeometry? weekdaysPadding;

  /// The text style of the weekdays, defaults to
  /// `textTheme.muted.copyWith(fontSize: 12.8)`
  final TextStyle? weekdaysTextStyle;

  /// The text align of the weekdays, defaults to [TextAlign.center]
  final TextAlign? weekdaysTextAlign;

  /// The header text of the week numbers, defaults to `#`
  final String? weekNumbersHeaderText;

  /// The header text style of the week numbers, defaults to
  /// `textTheme.muted.copyWith(fontSize: 12.8)`
  final TextStyle? weekNumbersHeaderTextStyle;

  /// The text style of the week numbers, defaults to
  /// `textTheme.muted.copyWith(fontSize: 12.8)`
  final TextStyle? weekNumbersTextStyle;

  /// The text align of the week numbers, defaults to [TextAlign.center]
  final TextAlign? weekNumbersTextAlign;

  /// The size of the day buttons, defaults to 36
  final double? dayButtonSize;

  /// The corner radius of day cells and of the month/year dropdown triggers,
  /// shadcn's `--cell-radius`. Its own knob because the styles keep it apart
  /// from the button radius (`vega` buttons are `lg`, its cells `md`).
  final BorderRadius? dayButtonBorderRadius;

  /// The minimum height of the month/year dropdown triggers,
  /// `.cn-calendar-caption-label`'s `h-8`. Without it the triggers would take
  /// the select theme's field height, which is taller than a calendar row.
  final double? selectorMinHeight;

  /// The opacity of the day buttons outside the month, defaults to .5
  final double? dayButtonOutsideMonthOpacity;

  /// The padding of the day buttons, defaults to [EdgeInsets.zero]
  final EdgeInsetsGeometry? dayButtonPadding;

  /// The decoration of the day buttons, defaults to
  /// ```dart
  /// UnaDecoration(
  ///   secondaryBorder:
  ///       const UnaBorder(padding: EdgeInsets.zero),
  ///   border: isInRange &&
  ///           !isFirstDateInRange &&
  ///           !isLastDateInRange
  ///       ? isFirstOfRow
  ///           ? UnaBorder(
  ///               borderRadius: BorderRadius.only(
  ///                 topLeft: theme.radius.topLeft,
  ///                 bottomLeft: theme.radius.bottomLeft,
  ///               ),
  ///             )
  ///           : isLastOfRow
  ///               ? UnaBorder(
  ///                   borderRadius: BorderRadius.only(
  ///                     topRight: theme.radius.topRight,
  ///                     bottomRight:
  ///                         theme.radius.bottomRight,
  ///                   ),
  ///                 )
  ///               : const UnaBorder(
  ///                   borderRadius: BorderRadius.zero,
  ///                 )
  ///       : null,
  ///    secondaryFocusedBorder: UnaBorder.all(
  ///       offset: 2,
  ///       color: theme.colorScheme.ring.withValues(alpha: .5),
  ///     ),
  ///   ),
  /// ```
  final UnaDecoration? dayButtonDecoration;

  /// The text style of the selected day button, defaults to
  /// ```dart
  /// textTheme.small.copyWith(
  ///   fontWeight: FontWeight.normal,
  ///   color: colorScheme.primaryForeground,
  /// )
  /// ```
  final TextStyle? selectedDayButtonTextStyle;

  /// The text style of the inside range day button, defaults to
  /// ```dart
  /// textTheme.small.copyWith(
  ///   color: colorScheme.foreground,
  /// )
  /// ```
  final TextStyle? insideRangeDayButtonTextStyle;

  /// The text style of the day button, defaults to
  /// ```dart
  /// textTheme.small.copyWith(
  ///   fontWeight: FontWeight.normal,
  ///   color: colorScheme.foreground,
  /// )
  /// ```
  final TextStyle? dayButtonTextStyle;

  /// The variant of the day button, defaults to [ButtonVariant.ghost]
  final ButtonVariant? dayButtonVariant;

  /// The variant of the selected day button, defaults to
  /// [ButtonVariant.primary]
  final ButtonVariant? selectedDayButtonVariant;

  /// The variant of the inside range day button, defaults to
  /// [ButtonVariant.secondary]
  final ButtonVariant? insideRangeDayButtonVariant;

  /// The variant of the today button, defaults to [ButtonVariant.secondary]
  final ButtonVariant? todayButtonVariant;

  /// The main axis spacing of the grid, defaults to 8
  final double? gridMainAxisSpacing;

  /// The cross axis spacing of the grid, defaults to 0
  final double? gridCrossAxisSpacing;

  /// The text style of the day buttons outside the month, defaults to
  /// `textTheme.muted`
  final TextStyle? dayButtonOutsideMonthTextStyle;

  /// The variant of the day buttons outside the month, defaults to
  /// [ButtonVariant.ghost]
  final ButtonVariant? dayButtonOutsideMonthVariant;

  /// The variant of the selected day buttons outside the month, defaults to
  /// [ButtonVariant.secondary]
  final ButtonVariant? selectedDayButtonOutsideMonthVariant;

  /// The layout of the caption, defaults to [CalendarCaptionLayout.label].
  final CalendarCaptionLayout? captionLayout;

  /// Whether to show the month’s head with the weekday names, defaults to
  /// true.
  final bool? showWeekdayNames;

  /// Whether to show days outside the current month, defaults to true.
  final bool? showOutsideDays;

  /// The format to use for the month, defaults to 'LLLL y'.
  final String Function(DateTime date)? formatMonthYear;

  /// The format to use for the month, defaults to 'LLLL'.
  final String Function(DateTime date)? formatMonth;

  /// The format to use for the year, defaults to 'y'.
  final String Function(DateTime date)? formatYear;

  /// The format to use for the weekday, defaults to 'EE'.
  final String Function(DateTime date)? formatWeekday;

  /// The format to use for the month in dropdowns, defaults to 'MMM'.
  final String Function(DateTime date)? dropdownFormatMonth;

  /// The format to use for the year in dropdowns, defaults to 'y'.
  final String Function(DateTime date)? dropdownFormatYear;

  /// Whether to show week numbers, defaults to false.
  final bool? showWeekNumbers;

  /// Which day of the week is the first day of the week.
  ///
  /// In accordance with ISO 8601 a week starts with Monday, which
  /// has the value 1, while Sunday has the value 7. Defaults to 1 (Monday).
  final int? weekStartsOn;

  /// Display six weeks per months, regardless the month’s number of weeks.
  ///
  /// To use this [showOutsideDays] must be set to true.
  /// Defaults to false.
  final bool? fixedWeeks;

  /// Whether to allow deselection of the selected date, defaults to false.
  final bool? allowDeselection;

  /// Linearly interpolates between [a] and [b] by [t].
  static CalendarTheme? lerp(
    CalendarTheme? a,
    CalendarTheme? b,
    double t,
  ) => _$CalendarTheme.lerp(a, b, t);
}
