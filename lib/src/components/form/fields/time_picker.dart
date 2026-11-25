import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/picker.dart';
import 'package:finesse/src/components/time_field.dart';
import 'package:finesse/src/components/time_picker.dart';
import 'package:flutter/widgets.dart';

/// A [TimePicker] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
///
/// A failed validation moves the focus to the picker's button.
class TimePickerFormField extends FinesseFormField<TimeOfDay> {
  /// Creates a time picker form field.
  TimePickerFormField({
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

    /// Called with the chosen time, or null when it is cleared.
    super.onChanged,

    /// The time the field starts with.
    super.initialValue,

    /// The step between two rows of the minutes wheel.
    int minuteInterval = 1,

    /// The earliest time that can be chosen.
    TimeOfDay? min,

    /// The latest time that can be chosen.
    TimeOfDay? max,

    /// Whether seconds are shown and chosen too.
    bool showSeconds = false,

    /// Whether the hours run from 0 to 23, with no day period.
    bool? use24HourFormat,

    /// Whether the picker opens a popover or a sheet.
    PickerPresentation presentation = PickerPresentation.auto,

    /// Shown in the button while there is no time.
    Widget? placeholder,

    /// The title of the sheet.
    Widget? title,

    /// Turns the time into the button's text.
    String Function(TimeOfDay time)? formatTime,

    /// Whether the sheet offers to clear the time.
    bool allowClear = false,

    /// The widget before the time.
    Widget? leading,

    /// A widget after the time.
    Widget? trailing,

    /// The look of the button.
    ButtonVariant? variant,

    /// The size of the button.
    ButtonSize? size,

    /// The width of the button.
    double? width,

    /// Whether the button fills the width it is given.
    bool expands = false,
  }) : super(
         builder: (state) {
           state as TimePickerFormFieldState;
           return TimePicker(
             value: state.value,
             onChanged: state.enabled ? state.didChange : null,
             focusNode: state.focusNode,
             minuteInterval: minuteInterval,
             min: min,
             max: max,
             showSeconds: showSeconds,
             use24HourFormat: use24HourFormat,
             presentation: presentation,
             placeholder: placeholder,
             title: title,
             formatTime: formatTime,
             allowClear: allowClear,
             leading: leading,
             trailing: trailing,
             variant: variant,
             size: size,
             width: width,
             expands: expands,
           );
         },
       );

  @override
  FinesseFormFieldState<TimePickerFormField, TimeOfDay> createState() =>
      TimePickerFormFieldState();
}

/// The state of a [TimePickerFormField].
class TimePickerFormFieldState
    extends FinesseFormFieldState<TimePickerFormField, TimeOfDay> {}
