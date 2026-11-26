import 'package:flutter/widgets.dart';
import 'package:una/src/components/button.dart';
import 'package:una/src/components/calendar.dart';
import 'package:una/src/components/date_picker.dart';
import 'package:una/src/components/form/field.dart';
import 'package:una/src/components/picker.dart';
import 'package:una/src/theme/components/calendar.dart';

/// A [DateRangePicker] that takes part in a `UnaForm`, with a label, a
/// description and validation.
///
/// A failed validation moves the focus to the picker's button.
class DateRangePickerFormField extends UnaFormField<DateTimeRange> {
  /// Creates a form field that picks a range of dates.
  DateRangePickerFormField({
    super.id,
    super.key,
    super.onSaved,
    super.forceErrorText,
    super.label,
    super.error,
    super.description,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    super.validator,
    super.focusNode,

    /// Called with the chosen range, or null when it is cleared.
    super.onChanged,

    /// The range the field starts with.
    super.initialValue,

    /// The earliest day that can be chosen.
    DateTime? min,

    /// The latest day that can be chosen.
    DateTime? max,

    /// The shortest range accepted, in days after its first day.
    int? minDays,

    /// The longest range accepted, in days after its first day.
    int? maxDays,

    /// Whether the picker opens a popover or a sheet.
    PickerPresentation presentation = PickerPresentation.auto,

    /// Whether the popover closes once the range has both its days.
    bool? closeOnSelection,

    /// Whether the range can be cleared.
    bool? allowDeselection,

    /// Shown in the button while there is no range.
    Widget? placeholder,

    /// The title of the sheet.
    Widget? title,

    /// Turns the range into the button's text.
    String Function(DateTimeRange range)? formatDateRange,

    /// The widget before the range.
    Widget? leading,

    /// A widget after the range.
    Widget? trailing,

    /// The look of the button.
    ButtonVariant? variant,

    /// The size of the button.
    ButtonSize? size,

    /// The width of the button.
    double? width,

    /// Whether the button fills the width it is given.
    bool expands = false,

    /// How many months the calendar shows side by side.
    int numberOfMonths = 1,

    /// Returns whether a day can be chosen.
    bool Function(DateTime day)? selectableDayPredicate,

    /// The first day of the week: 1 is Monday, 7 is Sunday.
    int? weekStartsOn,

    /// Whether the calendar shows week numbers.
    bool? showWeekNumbers,

    /// How the calendar's caption names the month.
    CalendarCaptionLayout? captionLayout,

    /// Values that replace the theme's `CalendarTheme` for this picker.
    CalendarTheme? calendarTheme,
  }) : super(
         builder: (state) {
           state as _DateRangePickerFormFieldState;
           return DateRangePicker(
             value: state.value,
             onChanged: state.enabled ? state.didChange : null,
             focusNode: state.focusNode,
             min: min,
             max: max,
             minDays: minDays,
             maxDays: maxDays,
             presentation: presentation,
             closeOnSelection: closeOnSelection,
             allowDeselection: allowDeselection,
             placeholder: placeholder,
             title: title,
             formatDateRange: formatDateRange,
             leading: leading,
             trailing: trailing,
             variant: variant,
             size: size,
             width: width,
             expands: expands,
             numberOfMonths: numberOfMonths,
             selectableDayPredicate: selectableDayPredicate,
             weekStartsOn: weekStartsOn,
             showWeekNumbers: showWeekNumbers,
             captionLayout: captionLayout,
             calendarTheme: calendarTheme,
           );
         },
       );

  @override
  UnaFormFieldState<DateRangePickerFormField, DateTimeRange> createState() =>
      _DateRangePickerFormFieldState();
}

/// The state of a [DateRangePickerFormField].
class _DateRangePickerFormFieldState
    extends UnaFormFieldState<DateRangePickerFormField, DateTimeRange> {}
