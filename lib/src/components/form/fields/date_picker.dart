import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/calendar.dart';
import 'package:finesse/src/components/date_picker.dart';
import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/picker.dart';
import 'package:finesse/src/theme/components/calendar.dart';
import 'package:flutter/widgets.dart';

/// A [DatePicker] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
///
/// A failed validation moves the focus to the picker's button.
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
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    super.validator,
    super.focusNode,

    /// Called with the chosen day, or null when the date is cleared.
    super.onChanged,

    /// The date the field starts with.
    super.initialValue,

    /// The earliest day that can be chosen.
    DateTime? min,

    /// The latest day that can be chosen.
    DateTime? max,

    /// Whether the picker opens a popover or a sheet.
    PickerPresentation presentation = PickerPresentation.auto,

    /// Whether the date is chosen on a calendar or on wheels.
    DatePickerMode mode = DatePickerMode.calendar,

    /// Whether choosing a day closes the picker.
    bool? closeOnSelection,

    /// Whether the date can be cleared.
    bool? allowDeselection,

    /// Shown in the button while there is no date.
    Widget? placeholder,

    /// The title of the sheet.
    Widget? title,

    /// Turns the date into the button's text.
    String Function(DateTime date)? formatDate,

    /// The widget before the date.
    Widget? leading,

    /// A widget after the date.
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
           state as _DatePickerFormFieldState;
           return DatePicker(
             value: state.value,
             onChanged: state.enabled ? state.didChange : null,
             focusNode: state.focusNode,
             min: min,
             max: max,
             presentation: presentation,
             mode: mode,
             closeOnSelection: closeOnSelection,
             allowDeselection: allowDeselection,
             placeholder: placeholder,
             title: title,
             formatDate: formatDate,
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
  FinesseFormFieldState<DatePickerFormField, DateTime> createState() =>
      _DatePickerFormFieldState();
}

/// The state of a [DatePickerFormField].
class _DatePickerFormFieldState
    extends FinesseFormFieldState<DatePickerFormField, DateTime> {}
