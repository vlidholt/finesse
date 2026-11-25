import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/time_field.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';

/// A [TimeField] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
///
/// The form's value is the time once every field that shows is filled, and
/// null before. A failed validation moves the focus to the first field.
class TimeFormField extends FinesseFormField<TimeOfDay> {
  /// Creates a time form field.
  TimeFormField({
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

    /// Called with the time once every field that shows is filled, and on
    /// each change after that.
    super.onChanged,

    /// The time the field starts with.
    super.initialValue,

    /// Whether the hours run from 0 to 23, with no day period.
    bool? use24HourFormat,

    /// Whether the hours field shows.
    bool showHours = true,

    /// Whether the minutes field shows.
    bool showMinutes = true,

    /// Whether the seconds field shows.
    bool showSeconds = false,

    /// Whether each field has its name above it.
    bool showLabels = true,

    /// The earliest time that can be entered.
    TimeOfDay? min,

    /// The latest time that can be entered.
    TimeOfDay? max,

    /// A widget before the fields.
    Widget? leading,

    /// A widget after the fields.
    Widget? trailing,

    /// The decoration of each field, merged over the theme's.
    FinesseDecoration? decoration,

    /// {@macro KeyboardToolbar.toolbarBuilder}
    WidgetBuilder? keyboardToolbarBuilder,
  }) : super(
         decorationBuilder: (context) => decoration,
         builder: (state) {
           state as _TimeFormFieldState;
           return TimeField(
             // A reset writes the initial value back into the fields.
             key: ValueKey(state._generation),
             initialValue: state.value,
             onChanged: state.didChange,
             enabled: state.enabled,
             focusNode: state.focusNode,
             use24HourFormat: use24HourFormat,
             showHours: showHours,
             showMinutes: showMinutes,
             showSeconds: showSeconds,
             showLabels: showLabels,
             min: min,
             max: max,
             leading: leading,
             trailing: trailing,
             decoration: state.decoration,
             keyboardToolbarBuilder: keyboardToolbarBuilder,
           );
         },
       );

  @override
  FinesseFormFieldState<TimeFormField, TimeOfDay> createState() =>
      _TimeFormFieldState();
}

/// The state of a [TimeFormField].
class _TimeFormFieldState
    extends FinesseFormFieldState<TimeFormField, TimeOfDay> {
  int _generation = 0;

  @override
  void reset() {
    _generation++;
    super.reset();
  }
}
