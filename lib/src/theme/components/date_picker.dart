import 'dart:ui';

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/calendar.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'date_picker.g.theme.dart';

/// {@template DatePickerTheme}
/// Theme for the `DatePicker` widget.
/// {@endtemplate}
@themeGen
@immutable
class DatePickerTheme with _$DatePickerTheme {
  /// {@macro DatePickerTheme}
  const DatePickerTheme({
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
    this.calendarDecoration,
    this.spacingBetweenMonths,
    this.runSpacingBetweenMonths,
    this.monthConstraints,
    this.calendarHeaderHeight,
    this.calendarHeaderPadding,
    this.captionLayoutGap,
    this.calendarHeaderTextStyle,
    this.weekdaysPadding,
    this.weekNumbersHeaderText,
    this.weekNumbersHeaderTextStyle,
    this.weekNumbersTextStyle,
    this.weekNumbersTextAlign,
    this.dayButtonSize,
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
    this.effects,
    this.shadows,
    this.popoverPadding,
    this.popoverDecoration,
    this.anchor,
    this.filter,
    this.cursor,
    this.size,
    this.buttonVariant,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.buttonShadows,
    this.gradient,
    this.textDecoration,
    this.hoverTextDecoration,
    this.buttonDecoration,
    this.width,
    this.height,
    this.longPressDuration,
    this.hoverStrategies,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.textDirection,
    this.gap,
    this.formatDate,
    this.formatDateRange,
    this.buttonPadding,
    this.iconData,
    this.expands,
    this.popoverReverseDuration,
    this.buttonTextStyle,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro DatePicker.formatDate}
  final String Function(DateTime)? formatDate;

  /// {@macro DatePicker.formatDateRange}
  final String Function(DateTimeRange)? formatDateRange;

  /// {@macro DatePicker.iconData}
  final IconData? iconData;

  // ---
  // CALENDAR
  // ---

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
  final FinesseDecoration? calendarDecoration;

  /// {@macro Calendar.spacingBetweenMonths}
  final double? spacingBetweenMonths;

  /// {@macro Calendar.runSpacingBetweenMonths}
  final double? runSpacingBetweenMonths;

  /// {@macro Calendar.monthConstraints}
  final BoxConstraints? monthConstraints;

  /// {@macro Calendar.headerHeight}
  final double? calendarHeaderHeight;

  /// {@macro Calendar.headerPadding}
  final EdgeInsetsGeometry? calendarHeaderPadding;

  /// {@macro Calendar.captionLayoutGap}
  final double? captionLayoutGap;

  /// {@macro Calendar.headerTextStyle}
  final TextStyle? calendarHeaderTextStyle;

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

  /// {@macro Calendar.showWeekNumbers}
  final bool? showWeekNumbers;

  /// {@macro Calendar.weekStartsOn}
  final int? weekStartsOn;

  /// {@macro Calendar.fixedWeeks}
  final bool? fixedWeeks;

  /// {@macro Calendar.allowDeselection}
  final bool? allowDeselection;

  // ---
  // POPOVER
  // ---

  /// {@macro Popover.effects}
  final List<Effect<dynamic>>? effects;

  /// {@macro Popover.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Popover.padding}
  final EdgeInsetsGeometry? popoverPadding;

  /// {@macro Popover.decoration}
  final FinesseDecoration? popoverDecoration;

  /// {@macro Popover.anchor}
  final AnchorBase? anchor;

  /// {@macro Popover.filter}
  final ImageFilter? filter;

  /// {@macro Popover.reverseDuration}
  final Duration? popoverReverseDuration;

  // ---
  // BUTTON
  // ---

  /// {@macro Button.cursor}
  final MouseCursor? cursor;

  /// {@macro Button.size}
  final ButtonSize? size;

  /// {@macro Button.variant}
  final ButtonVariant? buttonVariant;

  /// {@macro Button.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Button.hoverBackgroundColor}
  final Color? hoverBackgroundColor;

  /// {@macro Button.foregroundColor}
  final Color? foregroundColor;

  /// {@macro Button.hoverForegroundColor}
  final Color? hoverForegroundColor;

  /// {@macro Button.pressedBackgroundColor}
  final Color? pressedBackgroundColor;

  /// {@macro Button.pressedForegroundColor}
  final Color? pressedForegroundColor;

  /// {@macro Button.shadows}
  final List<BoxShadow>? buttonShadows;

  /// {@macro Button.gradient}
  final Gradient? gradient;

  /// {@macro Button.textDecoration}
  final TextDecoration? textDecoration;

  /// {@macro Button.hoverTextDecoration}
  final TextDecoration? hoverTextDecoration;

  /// {@macro Button.decoration}
  final FinesseDecoration? buttonDecoration;

  /// {@macro Button.width}
  final double? width;

  /// {@macro Button.height}
  final double? height;

  /// {@macro Button.longPressDuration}
  final Duration? longPressDuration;

  /// {@macro Button.hoverStrategies}
  final HoverStrategies? hoverStrategies;

  /// {@macro Button.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@macro Button.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro Button.textDirection}
  final TextDirection? textDirection;

  /// {@macro Button.gap}
  final double? gap;

  /// {@macro Button.padding}
  final EdgeInsetsGeometry? buttonPadding;

  /// {@macro Button.expands}
  final bool? expands;

  /// {@macro Button.textStyle}
  final TextStyle? buttonTextStyle;

  /// Linearly interpolates between [a] and [b] by [t].
  static DatePickerTheme? lerp(
    DatePickerTheme? a,
    DatePickerTheme? b,
    double t,
  ) => _$DatePickerTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is DatePickerTheme &&
      listEquals(effects, other.effects) &&
      listEquals(shadows, other.shadows) &&
      listEquals(buttonShadows, other.buttonShadows) &&
      super ==
          other.copyWith(
            effects: effects,
            shadows: shadows,
            buttonShadows: buttonShadows,
          );

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(effects ?? const []),
    Object.hashAll(shadows ?? const []),
    Object.hashAll(buttonShadows ?? const []),
  );
}
