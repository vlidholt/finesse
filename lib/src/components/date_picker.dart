import 'dart:ui';

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/calendar.dart';
import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/extensions/date_time.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart' as intl;

/// Variants available for the [DatePicker] widget.
enum DatePickerVariant {
  /// Picks one date.
  single,

  /// Picks a start date and an end date.
  range,
}

/// A customizable date picker widget with a button and popover calendar.
///
/// The [DatePicker] widget combines a button with a popover calendar,
/// allowing users to select a single date or a date range. It supports
/// extensive customization for both the button and calendar, integrating with
/// [Theme] for consistent styling. Use named constructors like
/// [DatePicker.range] for range selection or [DatePicker.raw] for full
/// control.
class DatePicker extends StatefulWidget {
  /// Creates a single-date picker widget with a button and popover calendar.
  const DatePicker({
    super.key,
    this.placeholder,
    this.popoverController,
    this.selected,
    this.closeOnSelection,
    this.formatDate,
    this.allowDeselection,
    this.header,
    this.footer,
    this.groupId,
    this.calendarDecoration,
    this.popoverPadding,
    this.multipleSelected,
    this.onChanged,
    this.showOutsideDays,
    this.initialMonth,
    this.formatMonthYear,
    this.formatMonth,
    this.formatYear,
    this.formatWeekday,
    this.showWeekNumbers,
    this.weekStartsOn,
    this.fixedWeeks,
    this.hideWeekdayNames,
    this.numberOfMonths = 1,
    this.fromMonth,
    this.toMonth,
    this.onMonthChanged,
    this.reverseMonths = false,
    this.min,
    this.max,
    this.selectableDayPredicate,
    this.onRangeChanged,
    this.captionLayout,
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
    this.calendarHeaderHeight,
    this.calendarHeaderPadding,
    this.captionLayoutGap,
    this.calendarHeaderTextStyle,
    this.weekdaysPadding,
    this.weekdaysTextStyle,
    this.weekdaysTextAlign,
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
    this.dayButtonTextStyle,
    this.dayButtonVariant,
    this.selectedDayButtonVariant,
    this.insideRangeDayButtonVariant,
    this.todayButtonVariant,
    this.gridMainAxisSpacing,
    this.gridCrossAxisSpacing,
    this.dayButtonOutsideMonthTextStyle,
    this.dayButtonOutsideMonthVariant,
    this.selectedDayButtonOutsideMonthVariant,
    this.closeOnTapOutside = true,
    this.focusNode,
    this.anchor,
    this.effects,
    this.shadows,
    this.popoverDecoration,
    this.filter,
    this.areaGroupId,
    this.useSameGroupIdForChild = true,
    this.onPressed,
    this.onLongPress,
    this.leading,
    this.buttonChild,
    this.buttonVariant,
    this.size,
    this.cursor,
    this.width,
    this.height,
    this.buttonPadding,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.autofocus = false,
    this.buttonFocusNode,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.buttonShadows,
    this.gradient,
    this.textDecoration,
    this.hoverTextDecoration,
    this.buttonDecoration,
    this.enabled = true,
    this.statesController,
    this.gap,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.hoverStrategies,
    this.onHoverChange,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onLongPressStart,
    this.onLongPressCancel,
    this.onLongPressUp,
    this.onLongPressDown,
    this.onLongPressEnd,
    this.onDoubleTap,
    this.onDoubleTapDown,
    this.onDoubleTapCancel,
    this.longPressDuration,
    this.textDirection,
    this.onFocusChange,
    this.iconData,
    this.expands,
    this.popoverReverseDuration,
    this.buttonTextStyle,
    this.trailing,
  }) : variant = DatePickerVariant.single,
       formatDateRange = null,
       selectedRange = null;

  /// Creates a date range picker widget with a button and popover calendar.
  const DatePicker.range({
    super.key,
    this.popoverController,
    this.placeholder,
    DateTimeRange? selected,
    this.formatDateRange,
    this.closeOnSelection,
    this.allowDeselection,
    this.header,
    this.footer,
    this.groupId,
    this.calendarDecoration,
    this.popoverPadding,
    this.multipleSelected,
    this.onChanged,
    this.showOutsideDays,
    this.initialMonth,
    this.formatMonthYear,
    this.formatMonth,
    this.formatYear,
    this.formatWeekday,
    this.showWeekNumbers,
    this.weekStartsOn,
    this.fixedWeeks,
    this.hideWeekdayNames,
    this.numberOfMonths = 1,
    this.fromMonth,
    this.toMonth,
    this.onMonthChanged,
    this.reverseMonths = false,
    this.min,
    this.max,
    this.selectableDayPredicate,
    this.onRangeChanged,
    this.captionLayout,
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
    this.calendarHeaderHeight,
    this.calendarHeaderPadding,
    this.captionLayoutGap,
    this.calendarHeaderTextStyle,
    this.weekdaysPadding,
    this.weekdaysTextStyle,
    this.weekdaysTextAlign,
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
    this.dayButtonTextStyle,
    this.dayButtonVariant,
    this.selectedDayButtonVariant,
    this.insideRangeDayButtonVariant,
    this.todayButtonVariant,
    this.gridMainAxisSpacing,
    this.gridCrossAxisSpacing,
    this.dayButtonOutsideMonthTextStyle,
    this.dayButtonOutsideMonthVariant,
    this.selectedDayButtonOutsideMonthVariant,
    this.closeOnTapOutside = true,
    this.focusNode,
    this.anchor,
    this.effects,
    this.shadows,
    this.popoverDecoration,
    this.filter,
    this.areaGroupId,
    this.useSameGroupIdForChild = true,
    this.onPressed,
    this.onLongPress,
    this.leading,
    this.buttonChild,
    this.buttonVariant,
    this.size,
    this.cursor,
    this.width,
    this.height,
    this.buttonPadding,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.autofocus = false,
    this.buttonFocusNode,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.buttonShadows,
    this.gradient,
    this.textDecoration,
    this.hoverTextDecoration,
    this.buttonDecoration,
    this.enabled = true,
    this.statesController,
    this.gap,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.hoverStrategies,
    this.onHoverChange,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onLongPressStart,
    this.onLongPressCancel,
    this.onLongPressUp,
    this.onLongPressDown,
    this.onLongPressEnd,
    this.onDoubleTap,
    this.onDoubleTapDown,
    this.onDoubleTapCancel,
    this.longPressDuration,
    this.textDirection,
    this.onFocusChange,
    this.iconData,
    this.expands,
    this.popoverReverseDuration,
    this.buttonTextStyle,
    this.trailing,
  }) : variant = DatePickerVariant.range,
       selected = null,
       formatDate = null,
       selectedRange = selected;

  /// Creates a date picker widget with a specified [variant], offering full
  /// customization.
  const DatePicker.raw({
    super.key,
    required this.variant,
    this.popoverController,
    this.selected,
    this.closeOnSelection,
    this.formatDate,
    this.allowDeselection,
    this.selectedRange,
    this.header,
    this.footer,
    this.groupId,
    this.calendarDecoration,
    this.popoverPadding,
    this.multipleSelected,
    this.onChanged,
    this.showOutsideDays,
    this.initialMonth,
    this.formatMonthYear,
    this.formatMonth,
    this.formatYear,
    this.formatWeekday,
    this.showWeekNumbers,
    this.weekStartsOn,
    this.fixedWeeks,
    this.hideWeekdayNames,
    this.numberOfMonths = 1,
    this.fromMonth,
    this.toMonth,
    this.onMonthChanged,
    this.reverseMonths = false,
    this.min,
    this.max,
    this.selectableDayPredicate,
    this.onRangeChanged,
    this.captionLayout,
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
    this.calendarHeaderHeight,
    this.calendarHeaderPadding,
    this.captionLayoutGap,
    this.calendarHeaderTextStyle,
    this.weekdaysPadding,
    this.weekdaysTextStyle,
    this.weekdaysTextAlign,
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
    this.dayButtonTextStyle,
    this.dayButtonVariant,
    this.selectedDayButtonVariant,
    this.insideRangeDayButtonVariant,
    this.todayButtonVariant,
    this.gridMainAxisSpacing,
    this.gridCrossAxisSpacing,
    this.dayButtonOutsideMonthTextStyle,
    this.dayButtonOutsideMonthVariant,
    this.selectedDayButtonOutsideMonthVariant,
    this.closeOnTapOutside = true,
    this.focusNode,
    this.anchor,
    this.effects,
    this.shadows,
    this.popoverDecoration,
    this.filter,
    this.areaGroupId,
    this.useSameGroupIdForChild = true,
    this.onPressed,
    this.onLongPress,
    this.leading,
    this.buttonChild,
    this.buttonVariant,
    this.size,
    this.cursor,
    this.width,
    this.height,
    this.buttonPadding,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.autofocus = false,
    this.buttonFocusNode,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.buttonShadows,
    this.gradient,
    this.textDecoration,
    this.hoverTextDecoration,
    this.buttonDecoration,
    this.enabled = true,
    this.statesController,
    this.gap,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.hoverStrategies,
    this.onHoverChange,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onLongPressStart,
    this.onLongPressCancel,
    this.onLongPressUp,
    this.onLongPressDown,
    this.onLongPressEnd,
    this.onDoubleTap,
    this.onDoubleTapDown,
    this.onDoubleTapCancel,
    this.longPressDuration,
    this.textDirection,
    this.onFocusChange,
    this.iconData,
    this.formatDateRange,
    this.placeholder,
    this.expands,
    this.popoverReverseDuration,
    this.buttonTextStyle,
    this.trailing,
  });

  /// {@template DatePicker.placeholder}
  /// The placeholder of the date picker, shown when no date is selected.
  /// {@endtemplate}
  final Widget? placeholder;

  /// {@template DatePicker.popoverController}
  /// The [PopoverController] to use.
  /// {@endtemplate}
  final PopoverController? popoverController;

  /// {@template DatePicker.selected}
  /// The selected date, defaults to `null`.
  /// {@endtemplate}
  final DateTime? selected;

  /// {@template DatePicker.selectedRange}
  /// The selected range, defaults to `null`.
  /// {@endtemplate}
  final DateTimeRange? selectedRange;

  /// {@template DatePicker.closeOnSelection}
  /// Whether to close the popover when a date is selected.
  /// Defaults to `true`.
  /// {@endtemplate}
  final bool? closeOnSelection;

  /// {@template DatePicker.formatDate}
  /// A function that formats the selected date.
  /// {@endtemplate}
  final String Function(DateTime)? formatDate;

  /// {@template DatePicker.formatDateRange}
  /// A function that formats the selected date range.
  /// {@endtemplate}
  final String Function(DateTimeRange)? formatDateRange;

  /// {@template DatePicker.allowDeselection}
  /// Whether to allow deselection of the selected date.
  /// {@endtemplate}
  final bool? allowDeselection;

  /// {@template DatePicker.variant}
  /// The variant of the date picker.
  /// {@endtemplate}
  final DatePickerVariant variant;

  /// {@template DatePicker.header}
  /// The header of the date picker.
  /// {@endtemplate}
  final Widget? header;

  /// {@template DatePicker.footer}
  /// The footer of the date picker.
  /// {@endtemplate}
  final Widget? footer;

  /// {@macro Popover.groupId}
  final Object? groupId;

  /// {@template DatePicker.calendarDecoration}
  /// The decoration of the calendar.
  /// Defaults to `FinesseDecoration.none`.
  /// {@endtemplate}
  final FinesseDecoration? calendarDecoration;

  /// {@macro Popover.padding}
  final EdgeInsetsGeometry? popoverPadding;

  /// {@macro Calendar.multipleSelected}
  final List<DateTime>? multipleSelected;

  /// {@macro Calendar.onChanged}
  final ValueChanged<DateTime?>? onChanged;

  /// {@macro Calendar.showOutsideDays}
  final bool? showOutsideDays;

  /// {@macro Calendar.initialMonth}
  final DateTime? initialMonth;

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

  /// {@macro Calendar.hideWeekdayNames}
  final bool? hideWeekdayNames;

  /// {@macro Calendar.numberOfMonths}
  final int numberOfMonths;

  /// {@macro Calendar.fromMonth}
  final DateTime? fromMonth;

  /// {@macro Calendar.toMonth}
  final DateTime? toMonth;

  /// {@macro Calendar.onMonthChanged}
  final ValueChanged<DateTime>? onMonthChanged;

  /// {@macro Calendar.reverseMonths}
  final bool reverseMonths;

  /// {@macro Calendar.min}
  final int? min;

  /// {@macro Calendar.max}
  final int? max;

  /// {@macro Calendar.selectableDayPredicate}
  final bool Function(DateTime day)? selectableDayPredicate;

  /// {@macro Calendar.onRangeChanged}
  final ValueChanged<DateTimeRange?>? onRangeChanged;

  /// {@macro Calendar.captionLayout}
  final CalendarCaptionLayout? captionLayout;

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

  // ---
  // POPOVER
  // ---

  /// {@macro Popover.closeOnTapOutside}
  final bool closeOnTapOutside;

  /// {@macro Popover.focusNode}
  final FocusNode? focusNode;

  ///{@macro Popover.anchor}
  final AnchorBase? anchor;

  /// {@macro Popover.effects}
  final List<Effect<dynamic>>? effects;

  /// {@macro Popover.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Popover.decoration}
  final FinesseDecoration? popoverDecoration;

  /// {@macro Popover.filter}
  final ImageFilter? filter;

  /// {@macro MouseArea.groupId}
  final Object? areaGroupId;

  /// {@macro Popover.useSameGroupIdForChild}
  final bool useSameGroupIdForChild;

  /// {@macro Popover.reverseDuration}
  final Duration? popoverReverseDuration;

  // ---
  // BUTTON
  // ---

  /// {@macro Button.onPressed}
  final VoidCallback? onPressed;

  /// {@macro Button.onLongPress}
  final VoidCallback? onLongPress;

  /// {@macro Button.leading}
  final Widget? leading;

  /// {@macro Button.trailing}
  final Widget? trailing;

  /// {@template DatePicker.iconData}
  /// The icon of the date picker button, defaults to [PhosphorIconsRegular.calendarBlank].
  /// {@endtemplate}
  final IconData? iconData;

  /// {@macro Button.child}
  final Widget? buttonChild;

  /// {@macro Button.variant}
  final ButtonVariant? buttonVariant;

  /// {@macro Button.size}
  final ButtonSize? size;

  /// {@macro Button.cursor}
  final MouseCursor? cursor;

  /// {@macro Button.width}
  final double? width;

  /// {@macro Button.height}
  final double? height;

  /// {@macro Button.padding}
  final EdgeInsetsGeometry? buttonPadding;

  /// {@macro Button.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Button.hoverBackgroundColor}
  final Color? hoverBackgroundColor;

  /// {@macro Button.foregroundColor}
  final Color? foregroundColor;

  /// {@macro Button.hoverForegroundColor}
  final Color? hoverForegroundColor;

  /// {@macro Button.autofocus}
  final bool autofocus;

  /// {@macro Button.focusNode}
  final FocusNode? buttonFocusNode;

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

  /// {@macro Button.enabled}
  final bool enabled;

  /// {@macro Button.statesController}
  final WidgetStatesController? statesController;

  /// {@macro Button.gap}
  final double? gap;

  /// {@macro Button.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@macro Button.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro Button.hoverStrategies}
  final HoverStrategies? hoverStrategies;

  /// {@macro Button.onHoverChange}
  final ValueChanged<bool>? onHoverChange;

  /// {@macro Button.onTapDown}
  final ValueChanged<TapDownDetails>? onTapDown;

  /// {@macro Button.onTapUp}
  final ValueChanged<TapUpDetails>? onTapUp;

  /// {@macro Button.onTapCancel}
  final VoidCallback? onTapCancel;

  /// {@macro Button.onSecondaryTapDown}
  final ValueChanged<TapDownDetails>? onSecondaryTapDown;

  /// {@macro Button.onSecondaryTapUp}
  final ValueChanged<TapUpDetails>? onSecondaryTapUp;

  /// {@macro Button.onSecondaryTapCancel}
  final VoidCallback? onSecondaryTapCancel;

  /// {@macro Button.onLongPressStart}
  final ValueChanged<LongPressStartDetails>? onLongPressStart;

  /// {@macro Button.onLongPressCancel}
  final VoidCallback? onLongPressCancel;

  /// {@macro Button.onLongPressUp}
  final VoidCallback? onLongPressUp;

  /// {@macro Button.onLongPressDown}
  final ValueChanged<LongPressDownDetails>? onLongPressDown;

  /// {@macro Button.onLongPressEnd}
  final ValueChanged<LongPressEndDetails>? onLongPressEnd;

  /// {@macro Button.onDoubleTap}
  final VoidCallback? onDoubleTap;

  /// {@macro Button.onDoubleTapDown}
  final ValueChanged<TapDownDetails>? onDoubleTapDown;

  /// {@macro Button.onDoubleTapCancel}
  final VoidCallback? onDoubleTapCancel;

  /// {@macro Button.longPressDuration}
  final Duration? longPressDuration;

  /// {@macro Button.textDirection}
  final TextDirection? textDirection;

  /// {@macro Button.onFocusChange}
  final ValueChanged<bool>? onFocusChange;

  /// {@macro Button.expands}
  final bool? expands;

  /// {@macro Button.textStyle}
  final TextStyle? buttonTextStyle;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime? selected = widget.selected;
  late DateTimeRange? selectedRange = widget.selectedRange;
  final _groupId = UniqueKey();

  PopoverController? _popoverController;

  PopoverController get popoverController =>
      widget.popoverController ?? _popoverController!;

  @override
  void initState() {
    super.initState();
    if (widget.popoverController == null) {
      _popoverController = PopoverController();
    }
  }

  @override
  void didUpdateWidget(covariant DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      selected = widget.selected;
    }
    if (widget.selectedRange != oldWidget.selectedRange) {
      selectedRange = widget.selectedRange;
    }
  }

  @override
  void dispose() {
    _popoverController?.dispose();
    super.dispose();
  }

  String defaultDateFormat(DateTime date, Locale locale) {
    final ordinalDay = date.getOrdinalDay();
    final month = intl.DateFormat(
      'MMMM',
      locale.toLanguageTag(),
    ).format(date); // October
    final year = intl.DateFormat(
      'y',
      locale.toLanguageTag(),
    ).format(date); // 2024
    return '$month $ordinalDay, $year'; // October 1st, 2024
  }

  String defaultDateRangeFormat(DateTimeRange range, Locale locale) {
    if (range.start == null) return '';
    final buffer = StringBuffer();

    final start = intl.DateFormat.yMMMd(
      locale.toLanguageTag(),
    ).format(range.start!);
    buffer.write(start);

    if (range.end != null) {
      final end = intl.DateFormat.yMMMd(
        locale.toLanguageTag(),
      ).format(range.end!);
      buffer.write(' - $end');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isSelected = switch (widget.variant) {
      DatePickerVariant.single => selected != null,
      DatePickerVariant.range =>
        selectedRange != null && selectedRange!.start != null,
    };

    final locale = Localizations.localeOf(context);

    final effectiveFormatDate =
        widget.formatDate ??
        theme.datePickerTheme.formatDate ??
        (date) => defaultDateFormat(date, locale);

    final effectiveFormatDateRange =
        widget.formatDateRange ??
        theme.datePickerTheme.formatDateRange ??
        (range) => defaultDateRangeFormat(range, locale);

    final effectiveAllowDeselection =
        widget.allowDeselection ??
        theme.datePickerTheme.allowDeselection ??
        true;
    final effectiveCalendarDecoration =
        widget.calendarDecoration ??
        theme.datePickerTheme.calendarDecoration ??
        FinesseDecoration.none;

    final effectiveExpands =
        widget.expands ?? theme.datePickerTheme.expands ?? false;

    final effectiveGroupId = widget.groupId ?? _groupId;

    final effectiveButtonTextStyle =
        widget.buttonTextStyle ?? theme.datePickerTheme.buttonTextStyle;

    final defaultIcon = Icon(
      widget.iconData ??
          theme.datePickerTheme.iconData ??
          PhosphorIconsRegular.calendarBlank,
    );
    final effectiveLeading = widget.trailing == null || widget.leading != null
        ? IconTheme.merge(
            data: IconThemeData(
              size: 16,
              color: isSelected
                  ? theme.colorScheme.foreground
                  : theme.colorScheme.mutedForeground,
            ),
            child: widget.leading ?? defaultIcon,
          )
        : null;
    final effectiveTrailing = widget.trailing != null
        ? IconTheme.merge(
            data: IconThemeData(
              size: 16,
              color: isSelected
                  ? theme.colorScheme.foreground
                  : theme.colorScheme.mutedForeground,
            ),
            child: widget.trailing!,
          )
        : null;

    return Popover(
      controller: popoverController,
      groupId: effectiveGroupId,
      padding: widget.popoverPadding ?? theme.datePickerTheme.popoverPadding,
      focusNode: widget.focusNode,
      closeOnTapOutside: widget.closeOnTapOutside,
      anchor: widget.anchor ?? theme.datePickerTheme.anchor,
      effects: widget.effects ?? theme.datePickerTheme.effects,
      shadows: widget.shadows ?? theme.datePickerTheme.shadows,
      decoration:
          widget.popoverDecoration ?? theme.datePickerTheme.popoverDecoration,
      filter: widget.filter ?? theme.datePickerTheme.filter,
      areaGroupId: widget.areaGroupId,
      useSameGroupIdForChild: widget.useSameGroupIdForChild,
      reverseDuration:
          widget.popoverReverseDuration ??
          theme.datePickerTheme.popoverReverseDuration,
      popover: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.header != null) widget.header!,
            Calendar.raw(
              variant: switch (widget.variant) {
                DatePickerVariant.single => CalendarVariant.single,
                DatePickerVariant.range => CalendarVariant.range,
              },
              selected: selected,
              groupId: effectiveGroupId,
              selectedRange: selectedRange,
              allowDeselection: effectiveAllowDeselection,
              showOutsideDays:
                  widget.showOutsideDays ??
                  theme.datePickerTheme.showOutsideDays,
              decoration: effectiveCalendarDecoration,
              initialMonth: widget.initialMonth,
              formatMonthYear:
                  widget.formatMonthYear ??
                  theme.datePickerTheme.formatMonthYear,
              formatMonth:
                  widget.formatMonth ?? theme.datePickerTheme.formatMonth,
              formatYear: widget.formatYear ?? theme.datePickerTheme.formatYear,
              formatWeekday:
                  widget.formatWeekday ?? theme.datePickerTheme.formatWeekday,
              showWeekNumbers:
                  widget.showWeekNumbers ??
                  theme.datePickerTheme.showWeekNumbers,
              weekStartsOn:
                  widget.weekStartsOn ?? theme.datePickerTheme.weekStartsOn,
              fixedWeeks: widget.fixedWeeks ?? theme.datePickerTheme.fixedWeeks,
              hideWeekdayNames:
                  widget.hideWeekdayNames ??
                  theme.datePickerTheme.hideWeekdayNames,
              numberOfMonths: widget.numberOfMonths,
              fromMonth: widget.fromMonth,
              toMonth: widget.toMonth,
              onMonthChanged: widget.onMonthChanged,
              reverseMonths: widget.reverseMonths,
              min: widget.min,
              max: widget.max,
              selectableDayPredicate: widget.selectableDayPredicate,
              captionLayout:
                  widget.captionLayout ?? theme.datePickerTheme.captionLayout,
              hideNavigation:
                  widget.hideNavigation ?? theme.datePickerTheme.hideNavigation,
              yearSelectorMinWidth:
                  widget.yearSelectorMinWidth ??
                  theme.datePickerTheme.yearSelectorMinWidth,
              monthSelectorMinWidth:
                  widget.monthSelectorMinWidth ??
                  theme.datePickerTheme.monthSelectorMinWidth,
              yearSelectorPadding:
                  widget.yearSelectorPadding ??
                  theme.datePickerTheme.yearSelectorPadding,
              monthSelectorPadding:
                  widget.monthSelectorPadding ??
                  theme.datePickerTheme.monthSelectorPadding,
              navigationButtonSize:
                  widget.navigationButtonSize ??
                  theme.datePickerTheme.navigationButtonSize,
              navigationButtonIconSize:
                  widget.navigationButtonIconSize ??
                  theme.datePickerTheme.navigationButtonIconSize,
              backNavigationButtonIconData:
                  widget.backNavigationButtonIconData ??
                  theme.datePickerTheme.backNavigationButtonIconData,
              forwardNavigationButtonIconData:
                  widget.forwardNavigationButtonIconData ??
                  theme.datePickerTheme.forwardNavigationButtonIconData,
              navigationButtonPadding:
                  widget.navigationButtonPadding ??
                  theme.datePickerTheme.navigationButtonPadding,
              navigationButtonDisabledOpacity:
                  widget.navigationButtonDisabledOpacity ??
                  theme.datePickerTheme.navigationButtonDisabledOpacity,
              spacingBetweenMonths:
                  widget.spacingBetweenMonths ??
                  theme.datePickerTheme.spacingBetweenMonths,
              runSpacingBetweenMonths:
                  widget.runSpacingBetweenMonths ??
                  theme.datePickerTheme.runSpacingBetweenMonths,
              monthConstraints:
                  widget.monthConstraints ??
                  theme.datePickerTheme.monthConstraints,
              headerHeight:
                  widget.calendarHeaderHeight ??
                  theme.datePickerTheme.calendarHeaderHeight,
              headerPadding:
                  widget.calendarHeaderPadding ??
                  theme.datePickerTheme.calendarHeaderPadding,
              captionLayoutGap:
                  widget.captionLayoutGap ??
                  theme.datePickerTheme.captionLayoutGap,
              headerTextStyle:
                  widget.calendarHeaderTextStyle ??
                  theme.datePickerTheme.calendarHeaderTextStyle,
              weekdaysPadding:
                  widget.weekdaysPadding ??
                  theme.datePickerTheme.weekdaysPadding,
              weekdaysTextStyle:
                  widget.weekdaysTextStyle ??
                  theme.datePickerTheme.weekdaysTextStyle,
              weekdaysTextAlign:
                  widget.weekdaysTextAlign ??
                  theme.datePickerTheme.weekdaysTextAlign,
              weekNumbersHeaderText:
                  widget.weekNumbersHeaderText ??
                  theme.datePickerTheme.weekNumbersHeaderText,
              weekNumbersTextStyle:
                  widget.weekNumbersTextStyle ??
                  theme.datePickerTheme.weekNumbersTextStyle,
              weekNumbersTextAlign:
                  widget.weekNumbersTextAlign ??
                  theme.datePickerTheme.weekNumbersTextAlign,
              weekNumbersHeaderTextStyle:
                  widget.weekNumbersHeaderTextStyle ??
                  theme.datePickerTheme.weekNumbersHeaderTextStyle,
              dayButtonSize:
                  widget.dayButtonSize ?? theme.datePickerTheme.dayButtonSize,
              dayButtonOutsideMonthOpacity:
                  widget.dayButtonOutsideMonthOpacity ??
                  theme.datePickerTheme.dayButtonOutsideMonthOpacity,
              dayButtonPadding:
                  widget.dayButtonPadding ??
                  theme.datePickerTheme.dayButtonPadding,
              dayButtonDecoration:
                  widget.dayButtonDecoration ??
                  theme.datePickerTheme.dayButtonDecoration,
              dayButtonTextStyle:
                  widget.dayButtonTextStyle ??
                  theme.datePickerTheme.dayButtonTextStyle,
              dayButtonVariant:
                  widget.dayButtonVariant ??
                  theme.datePickerTheme.dayButtonVariant,
              dayButtonOutsideMonthVariant:
                  widget.dayButtonOutsideMonthVariant ??
                  theme.datePickerTheme.dayButtonOutsideMonthVariant,
              dayButtonOutsideMonthTextStyle:
                  widget.dayButtonOutsideMonthTextStyle ??
                  theme.datePickerTheme.dayButtonOutsideMonthTextStyle,
              selectedDayButtonVariant:
                  widget.selectedDayButtonVariant ??
                  theme.datePickerTheme.selectedDayButtonVariant,
              selectedDayButtonTextStyle:
                  widget.selectedDayButtonTextStyle ??
                  theme.datePickerTheme.selectedDayButtonTextStyle,
              selectedDayButtonOutsideMonthVariant:
                  widget.selectedDayButtonOutsideMonthVariant ??
                  theme.datePickerTheme.selectedDayButtonOutsideMonthVariant,
              insideRangeDayButtonVariant:
                  widget.insideRangeDayButtonVariant ??
                  theme.datePickerTheme.insideRangeDayButtonVariant,
              insideRangeDayButtonTextStyle:
                  widget.insideRangeDayButtonTextStyle ??
                  theme.datePickerTheme.insideRangeDayButtonTextStyle,
              todayButtonVariant:
                  widget.todayButtonVariant ??
                  theme.datePickerTheme.todayButtonVariant,
              gridMainAxisSpacing:
                  widget.gridMainAxisSpacing ??
                  theme.datePickerTheme.gridMainAxisSpacing,
              gridCrossAxisSpacing:
                  widget.gridCrossAxisSpacing ??
                  theme.datePickerTheme.gridCrossAxisSpacing,
              onChanged: (selected) {
                setState(() => this.selected = selected);
                if (true == widget.closeOnSelection) {
                  popoverController.hide();
                }
                widget.onChanged?.call(selected);
              },
              onRangeChanged: (range) {
                setState(() => selectedRange = range);
                if (true == widget.closeOnSelection &&
                    range?.start != null &&
                    range?.end != null) {
                  popoverController.hide();
                }
                widget.onRangeChanged?.call(range);
              },
              multipleSelected: widget.multipleSelected,
            ),
            if (widget.footer != null) widget.footer!,
          ],
        );
      },
      child: Button.raw(
        decoration:
            widget.buttonDecoration ?? theme.datePickerTheme.buttonDecoration,
        variant:
            widget.buttonVariant ??
            theme.datePickerTheme.buttonVariant ??
            ButtonVariant.outline,
        width: widget.width ?? theme.datePickerTheme.width ?? 276,
        mainAxisAlignment:
            widget.mainAxisAlignment ??
            theme.datePickerTheme.mainAxisAlignment ??
            MainAxisAlignment.start,
        leading: effectiveLeading,
        trailing: effectiveTrailing,
        onPressed:
            widget.onPressed ??
            () {
              popoverController.toggle();
            },
        onLongPress: widget.onLongPress,
        onTapUp: widget.onTapUp,
        onTapDown: widget.onTapDown,
        onTapCancel: widget.onTapCancel,
        onDoubleTap: widget.onDoubleTap,
        onHoverChange: widget.onHoverChange,
        onSecondaryTapDown: widget.onSecondaryTapDown,
        onLongPressUp: widget.onLongPressUp,
        onLongPressDown: widget.onLongPressDown,
        onLongPressEnd: widget.onLongPressEnd,
        onLongPressStart: widget.onLongPressStart,
        onLongPressCancel: widget.onLongPressCancel,
        onDoubleTapDown: widget.onDoubleTapDown,
        onFocusChange: widget.onFocusChange,
        onSecondaryTapUp: widget.onSecondaryTapUp,
        onSecondaryTapCancel: widget.onSecondaryTapCancel,
        onDoubleTapCancel: widget.onDoubleTapCancel,
        cursor: widget.cursor ?? theme.datePickerTheme.cursor,
        height: widget.height ?? theme.datePickerTheme.height,
        padding: widget.buttonPadding ?? theme.datePickerTheme.buttonPadding,
        backgroundColor:
            widget.backgroundColor ?? theme.datePickerTheme.backgroundColor,
        hoverBackgroundColor:
            widget.hoverBackgroundColor ??
            theme.datePickerTheme.hoverBackgroundColor,
        foregroundColor:
            widget.foregroundColor ?? theme.datePickerTheme.foregroundColor,
        hoverForegroundColor:
            widget.hoverForegroundColor ??
            theme.datePickerTheme.hoverForegroundColor,
        autofocus: widget.autofocus,
        focusNode: widget.buttonFocusNode,
        pressedBackgroundColor:
            widget.pressedBackgroundColor ??
            theme.datePickerTheme.pressedBackgroundColor,
        pressedForegroundColor:
            widget.pressedForegroundColor ??
            theme.datePickerTheme.pressedForegroundColor,
        shadows: widget.buttonShadows ?? theme.datePickerTheme.buttonShadows,
        gradient: widget.gradient ?? theme.datePickerTheme.gradient,
        textDecoration:
            widget.textDecoration ?? theme.datePickerTheme.textDecoration,
        hoverTextDecoration:
            widget.hoverTextDecoration ??
            theme.datePickerTheme.hoverTextDecoration,
        enabled: widget.enabled,
        gap: widget.gap ?? theme.datePickerTheme.gap,
        crossAxisAlignment:
            widget.crossAxisAlignment ??
            theme.datePickerTheme.crossAxisAlignment,
        longPressDuration:
            widget.longPressDuration ?? theme.datePickerTheme.longPressDuration,
        statesController: widget.statesController,
        hoverStrategies:
            widget.hoverStrategies ?? theme.datePickerTheme.hoverStrategies,
        textDirection: widget.textDirection,
        expands: effectiveExpands,
        textStyle: effectiveButtonTextStyle,
        child:
            widget.buttonChild ??
            (isSelected
                ? Text(
                    switch (widget.variant) {
                      DatePickerVariant.single => effectiveFormatDate(
                        selected!,
                      ),
                      DatePickerVariant.range => effectiveFormatDateRange(
                        selectedRange!,
                      ),
                    },
                    style: effectiveButtonTextStyle,
                  )
                : DefaultTextStyle(
                    style: theme.textTheme.muted.fallback(
                      color: theme.colorScheme.mutedForeground,
                    ),
                    child:
                        widget.placeholder ??
                        Text(
                          FinesseLocalizations.of(
                            context,
                          ).datePicker.selectDate,
                        ),
                  )),
      ),
    );
  }
}
