import 'dart:ui';

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/calendar.dart';
import 'package:finesse/src/components/date_picker.dart';
import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A [DatePicker] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
class DatePickerFormField extends FinesseFormField<DateTime> {
  /// Creates a form field that picks a single date.
  DatePickerFormField({
    super.id,
    super.key,
    super.onSaved,
    super.forceErrorText,
    super.label,
    super.error,
    super.description,

    /// {@macro Calendar.onChanged}
    super.onChanged,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,

    /// The focus node of the trigger button, unless [buttonFocusNode] is
    /// given: what a failed validation focuses.
    super.focusNode,
    super.validator,
    super.initialValue,
    super.toValueTransformer,
    super.fromValueTransformer,

    /// {@macro DatePicker.placeholder}
    Widget? placeholder,

    /// {@macro DatePicker.popoverController}
    PopoverController? popoverController,

    /// {@macro DatePicker.closeOnSelection}
    bool? closeOnSelection,

    /// {@macro DatePicker.formatDate}
    String Function(DateTime)? formatDate,

    /// {@macro DatePicker.allowDeselection}
    bool? allowDeselection,

    /// {@macro DatePicker.header}
    Widget? header,

    /// {@macro DatePicker.footer}
    Widget? footer,

    /// {@macro Popover.groupId}
    Object? groupId,

    /// {@macro DatePicker.calendarDecoration}
    FinesseDecoration? calendarDecoration,

    /// {@macro Popover.padding}
    EdgeInsetsGeometry? popoverPadding,

    /// {@macro Calendar.multipleSelected}
    List<DateTime>? multipleSelected,

    /// {@macro Calendar.showOutsideDays}
    bool? showOutsideDays,

    /// {@macro Calendar.initialMonth}
    DateTime? initialMonth,

    /// {@macro Calendar.formatMonthYear}
    String Function(DateTime date)? formatMonthYear,

    /// {@macro Calendar.formatMonth}
    String Function(DateTime date)? formatMonth,

    /// {@macro Calendar.formatYear}
    String Function(DateTime date)? formatYear,

    /// {@macro Calendar.formatWeekday}
    String Function(DateTime date)? formatWeekday,

    /// {@macro Calendar.showWeekNumbers}
    bool? showWeekNumbers,

    /// {@macro Calendar.weekStartsOn}
    int? weekStartsOn,

    /// {@macro Calendar.fixedWeeks}
    bool? fixedWeeks,

    /// {@macro Calendar.hideWeekdayNames}
    bool? hideWeekdayNames,

    /// {@macro Calendar.numberOfMonths}
    int numberOfMonths = 1,

    /// {@macro Calendar.fromMonth}
    DateTime? fromMonth,

    /// {@macro Calendar.toMonth}
    DateTime? toMonth,

    /// {@macro Calendar.onMonthChanged}
    ValueChanged<DateTime>? onMonthChanged,

    /// {@macro Calendar.reverseMonths}
    bool reverseMonths = false,

    /// {@macro Calendar.min}
    int? min,

    /// {@macro Calendar.max}
    int? max,

    /// {@macro Calendar.selectableDayPredicate}
    bool Function(DateTime day)? selectableDayPredicate,

    /// {@macro Calendar.captionLayout}
    CalendarCaptionLayout? captionLayout,

    /// {@macro Calendar.hideNavigation}
    bool? hideNavigation,

    /// {@macro Calendar.yearSelectorMinWidth}
    double? yearSelectorMinWidth,

    /// {@macro Calendar.monthSelectorMinWidth}
    double? monthSelectorMinWidth,

    /// {@macro Calendar.yearSelectorPadding}
    EdgeInsetsGeometry? yearSelectorPadding,

    /// {@macro Calendar.monthSelectorPadding}
    EdgeInsetsGeometry? monthSelectorPadding,

    /// {@macro Calendar.navigationButtonSize}
    double? navigationButtonSize,

    /// {@macro Calendar.navigationButtonIconSize}
    double? navigationButtonIconSize,

    /// {@macro Calendar.backNavigationButtonIconData}
    IconData? backNavigationButtonIconData,

    /// {@macro Calendar.forwardNavigationButtonIconData}
    IconData? forwardNavigationButtonIconData,

    /// {@macro Calendar.navigationButtonPadding}
    EdgeInsetsGeometry? navigationButtonPadding,

    /// {@macro Calendar.navigationButtonDisabledOpacity}
    double? navigationButtonDisabledOpacity,

    /// {@macro Calendar.spacingBetweenMonths}
    double? spacingBetweenMonths,

    /// {@macro Calendar.runSpacingBetweenMonths}
    double? runSpacingBetweenMonths,

    /// {@macro Calendar.monthConstraints}
    BoxConstraints? monthConstraints,

    /// {@macro Calendar.headerHeight}
    double? calendarHeaderHeight,

    /// {@macro Calendar.headerPadding}
    EdgeInsetsGeometry? calendarHeaderPadding,

    /// {@macro Calendar.captionLayoutGap}
    double? captionLayoutGap,

    /// {@macro Calendar.headerTextStyle}
    TextStyle? calendarHeaderTextStyle,

    /// {@macro Calendar.weekdaysPadding}
    EdgeInsets? weekdaysPadding,

    /// {@macro Calendar.weekdaysTextStyle}
    TextStyle? weekdaysTextStyle,

    /// {@macro Calendar.weekdaysTextAlign}
    TextAlign? weekdaysTextAlign,

    /// {@macro Calendar.weekNumbersHeaderText}
    String? weekNumbersHeaderText,

    /// {@macro Calendar.weekNumbersHeaderTextStyle}
    TextStyle? weekNumbersHeaderTextStyle,

    /// {@macro Calendar.weekNumbersTextStyle}
    TextStyle? weekNumbersTextStyle,

    /// {@macro Calendar.weekNumbersTextAlign}
    TextAlign? weekNumbersTextAlign,

    /// {@macro Calendar.dayButtonSize}
    double? dayButtonSize,

    /// {@macro Calendar.dayButtonOutsideMonthOpacity}
    double? dayButtonOutsideMonthOpacity,

    /// {@macro Calendar.dayButtonPadding}
    EdgeInsetsGeometry? dayButtonPadding,

    /// {@macro Calendar.dayButtonDecoration}
    FinesseDecoration? dayButtonDecoration,

    /// {@macro Calendar.selectedDayButtonTextStyle}
    TextStyle? selectedDayButtonTextStyle,

    /// {@macro Calendar.dayButtonTextStyle}
    TextStyle? dayButtonTextStyle,

    /// {@macro Calendar.dayButtonVariant}
    ButtonVariant? dayButtonVariant,

    /// {@macro Calendar.selectedDayButtonVariant}
    ButtonVariant? selectedDayButtonVariant,

    /// {@macro Calendar.todayButtonVariant}
    ButtonVariant? todayButtonVariant,

    /// {@macro Calendar.gridMainAxisSpacing}
    double? gridMainAxisSpacing,

    /// {@macro Calendar.gridCrossAxisSpacing}
    double? gridCrossAxisSpacing,

    /// {@macro Calendar.dayButtonOutsideMonthTextStyle}
    TextStyle? dayButtonOutsideMonthTextStyle,

    /// {@macro Calendar.dayButtonOutsideMonthVariant}
    ButtonVariant? dayButtonOutsideMonthVariant,

    /// {@macro Calendar.selectedDayButtonOutsideMonthVariant}
    ButtonVariant? selectedDayButtonOutsideMonthVariant,

    // ---
    // POPOVER
    // ---

    /// {@macro Popover.closeOnTapOutside}
    bool closeOnTapOutside = true,

    ///{@macro Popover.anchor}
    AnchorBase? anchor,

    /// {@macro Popover.effects}
    List<Effect<dynamic>>? effects,

    /// {@macro Popover.shadows}
    List<BoxShadow>? shadows,

    /// {@macro Popover.decoration}
    FinesseDecoration? popoverDecoration,

    /// {@macro Popover.filter}
    ImageFilter? filter,

    /// {@macro MouseArea.groupId}
    Object? areaGroupId,

    /// {@macro Popover.useSameGroupIdForChild}
    bool useSameGroupIdForChild = true,

    // ---
    // BUTTON
    // ---

    /// {@macro Button.onPressed}
    VoidCallback? onPressed,

    /// {@macro Button.onLongPress}
    VoidCallback? onLongPress,

    /// {@macro Button.leading}
    Widget? leading,

    /// {@macro Button.trailing}
    Widget? trailing,

    /// {@macro DatePicker.iconData}
    IconData? iconData,

    /// {@macro Button.child}
    Widget? buttonChild,

    /// {@macro Button.variant}
    ButtonVariant? buttonVariant,

    /// {@macro Button.size}
    ButtonSize? size,

    /// {@macro Button.cursor}
    MouseCursor? cursor,

    /// {@macro Button.width}
    double? width,

    /// {@macro Button.height}
    double? height,

    /// {@macro Button.padding}
    EdgeInsetsGeometry? buttonPadding,

    /// {@macro Button.backgroundColor}
    Color? backgroundColor,

    /// {@macro Button.hoverBackgroundColor}
    Color? hoverBackgroundColor,

    /// {@macro Button.foregroundColor}
    Color? foregroundColor,

    /// {@macro Button.hoverForegroundColor}
    Color? hoverForegroundColor,

    /// {@macro Button.autofocus}
    bool autofocus = false,

    /// {@macro Button.focusNode}
    FocusNode? buttonFocusNode,

    /// {@macro Button.pressedBackgroundColor}
    Color? pressedBackgroundColor,

    /// {@macro Button.pressedForegroundColor}
    Color? pressedForegroundColor,

    /// {@macro Button.shadows}
    List<BoxShadow>? buttonShadows,

    /// {@macro Button.gradient}
    Gradient? gradient,

    /// {@macro Button.textDecoration}
    TextDecoration? textDecoration,

    /// {@macro Button.hoverTextDecoration}
    TextDecoration? hoverTextDecoration,

    /// {@macro Button.decoration}
    FinesseDecoration? buttonDecoration,

    /// {@macro Button.statesController}
    WidgetStatesController? statesController,

    /// {@macro Button.gap}
    double? gap,

    /// {@macro Button.mainAxisAlignment}
    MainAxisAlignment? mainAxisAlignment,

    /// {@macro Button.crossAxisAlignment}
    CrossAxisAlignment? crossAxisAlignment,

    /// {@macro Button.hoverStrategies}
    HoverStrategies? hoverStrategies,

    /// {@macro Button.onHoverChange}
    ValueChanged<bool>? onHoverChange,

    /// {@macro Button.onTapDown}
    ValueChanged<TapDownDetails>? onTapDown,

    /// {@macro Button.onTapUp}
    ValueChanged<TapUpDetails>? onTapUp,

    /// {@macro Button.onTapCancel}
    VoidCallback? onTapCancel,

    /// {@macro Button.onSecondaryTapDown}
    ValueChanged<TapDownDetails>? onSecondaryTapDown,

    /// {@macro Button.onSecondaryTapUp}
    ValueChanged<TapUpDetails>? onSecondaryTapUp,

    /// {@macro Button.onSecondaryTapCancel}
    VoidCallback? onSecondaryTapCancel,

    /// {@macro Button.onLongPressStart}
    ValueChanged<LongPressStartDetails>? onLongPressStart,

    /// {@macro Button.onLongPressCancel}
    VoidCallback? onLongPressCancel,

    /// {@macro Button.onLongPressUp}
    VoidCallback? onLongPressUp,

    /// {@macro Button.onLongPressDown}
    ValueChanged<LongPressDownDetails>? onLongPressDown,

    /// {@macro Button.onLongPressEnd}
    ValueChanged<LongPressEndDetails>? onLongPressEnd,

    /// {@macro Button.onDoubleTap}
    VoidCallback? onDoubleTap,

    /// {@macro Button.onDoubleTapDown}
    ValueChanged<TapDownDetails>? onDoubleTapDown,

    /// {@macro Button.onDoubleTapCancel}
    VoidCallback? onDoubleTapCancel,

    /// {@macro Button.longPressDuration}
    Duration? longPressDuration,

    /// {@macro Button.textDirection}
    TextDirection? textDirection,

    /// {@macro Button.onFocusChange}
    ValueChanged<bool>? onFocusChange,

    /// {@macro Button.expands}
    bool? expands,

    /// {@macro Button.textStyle}
    TextStyle? buttonTextStyle,
  }) : super(
         builder: (state) {
           state as DatePickerFormFieldState;
           return DatePicker(
             onChanged: state.didChange,
             enabled: state.enabled,
             leading: leading,
             trailing: trailing,
             decoration: state.decoration,
             selected: state.value,
             popoverController: popoverController,
             closeOnSelection: closeOnSelection,
             formatDate: formatDate,
             allowDeselection: allowDeselection,
             header: header,
             footer: footer,
             groupId: groupId,
             calendarDecoration: calendarDecoration,
             popoverPadding: popoverPadding,
             multipleSelected: multipleSelected,
             showOutsideDays: showOutsideDays,
             initialMonth: initialMonth,
             formatMonthYear: formatMonthYear,
             formatMonth: formatMonth,
             formatYear: formatYear,
             formatWeekday: formatWeekday,
             showWeekNumbers: showWeekNumbers,
             weekStartsOn: weekStartsOn,
             fixedWeeks: fixedWeeks,
             hideWeekdayNames: hideWeekdayNames,
             numberOfMonths: numberOfMonths,
             fromMonth: fromMonth,
             toMonth: toMonth,
             onMonthChanged: onMonthChanged,
             reverseMonths: reverseMonths,
             min: min,
             max: max,
             selectableDayPredicate: selectableDayPredicate,
             captionLayout: captionLayout,
             hideNavigation: hideNavigation,
             yearSelectorMinWidth: yearSelectorMinWidth,
             monthSelectorMinWidth: monthSelectorMinWidth,
             yearSelectorPadding: yearSelectorPadding,
             monthSelectorPadding: monthSelectorPadding,
             navigationButtonSize: navigationButtonSize,
             navigationButtonIconSize: navigationButtonIconSize,
             backNavigationButtonIconData: backNavigationButtonIconData,
             forwardNavigationButtonIconData: forwardNavigationButtonIconData,
             navigationButtonPadding: navigationButtonPadding,
             navigationButtonDisabledOpacity: navigationButtonDisabledOpacity,
             spacingBetweenMonths: spacingBetweenMonths,
             runSpacingBetweenMonths: runSpacingBetweenMonths,
             monthConstraints: monthConstraints,
             calendarHeaderHeight: calendarHeaderHeight,
             calendarHeaderPadding: calendarHeaderPadding,
             captionLayoutGap: captionLayoutGap,
             calendarHeaderTextStyle: calendarHeaderTextStyle,
             weekdaysPadding: weekdaysPadding,
             weekdaysTextStyle: weekdaysTextStyle,
             weekdaysTextAlign: weekdaysTextAlign,
             weekNumbersHeaderText: weekNumbersHeaderText,
             weekNumbersHeaderTextStyle: weekNumbersHeaderTextStyle,
             weekNumbersTextStyle: weekNumbersTextStyle,
             weekNumbersTextAlign: weekNumbersTextAlign,
             dayButtonSize: dayButtonSize,
             dayButtonOutsideMonthOpacity: dayButtonOutsideMonthOpacity,
             dayButtonPadding: dayButtonPadding,
             dayButtonDecoration: dayButtonDecoration,
             selectedDayButtonTextStyle: selectedDayButtonTextStyle,
             dayButtonTextStyle: dayButtonTextStyle,
             dayButtonVariant: dayButtonVariant,
             selectedDayButtonVariant: selectedDayButtonVariant,
             todayButtonVariant: todayButtonVariant,
             gridMainAxisSpacing: gridMainAxisSpacing,
             gridCrossAxisSpacing: gridCrossAxisSpacing,
             dayButtonOutsideMonthTextStyle: dayButtonOutsideMonthTextStyle,
             dayButtonOutsideMonthVariant: dayButtonOutsideMonthVariant,
             selectedDayButtonOutsideMonthVariant:
                 selectedDayButtonOutsideMonthVariant,
             closeOnTapOutside: closeOnTapOutside,
             anchor: anchor,
             effects: effects,
             shadows: shadows,
             popoverDecoration: popoverDecoration,
             filter: filter,
             areaGroupId: areaGroupId,
             useSameGroupIdForChild: useSameGroupIdForChild,
             onPressed: onPressed,
             onLongPress: onLongPress,
             iconData: iconData,
             buttonChild: buttonChild,
             buttonVariant: buttonVariant,
             size: size,
             cursor: cursor,
             width: width,
             height: height,
             buttonPadding: buttonPadding,
             backgroundColor: backgroundColor,
             hoverBackgroundColor: hoverBackgroundColor,
             foregroundColor: foregroundColor,
             hoverForegroundColor: hoverForegroundColor,
             autofocus: autofocus,
             buttonFocusNode: buttonFocusNode ?? state.focusNode,
             pressedBackgroundColor: pressedBackgroundColor,
             pressedForegroundColor: pressedForegroundColor,
             buttonShadows: buttonShadows,
             gradient: gradient,
             textDecoration: textDecoration,
             hoverTextDecoration: hoverTextDecoration,
             buttonDecoration: buttonDecoration,
             statesController: statesController,
             gap: gap,
             mainAxisAlignment: mainAxisAlignment,
             crossAxisAlignment: crossAxisAlignment,
             hoverStrategies: hoverStrategies,
             onHoverChange: onHoverChange,
             onTapDown: onTapDown,
             onTapUp: onTapUp,
             onTapCancel: onTapCancel,
             onSecondaryTapDown: onSecondaryTapDown,
             onSecondaryTapUp: onSecondaryTapUp,
             onSecondaryTapCancel: onSecondaryTapCancel,
             onLongPressStart: onLongPressStart,
             onLongPressCancel: onLongPressCancel,
             onLongPressUp: onLongPressUp,
             onLongPressDown: onLongPressDown,
             onLongPressEnd: onLongPressEnd,
             onDoubleTap: onDoubleTap,
             onDoubleTapDown: onDoubleTapDown,
             onDoubleTapCancel: onDoubleTapCancel,
             longPressDuration: longPressDuration,
             textDirection: textDirection,
             onFocusChange: onFocusChange,
             placeholder: placeholder,
             expands: expands,
             buttonTextStyle: buttonTextStyle,
           );
         },
       );

  @override
  FinesseFormFieldState<DatePickerFormField, DateTime> createState() =>
      DatePickerFormFieldState();
}

/// The state of a [DatePickerFormField].
class DatePickerFormFieldState
    extends FinesseFormFieldState<DatePickerFormField, DateTime> {}
