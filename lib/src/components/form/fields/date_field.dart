import 'package:flutter/widgets.dart';
import 'package:una/src/components/date_field.dart';
import 'package:una/src/components/form/field.dart';
import 'package:una/src/components/picker.dart';
import 'package:una/src/theme/components/decorator.dart';

/// A [DateField] that takes part in a `UnaForm`, with a label, a
/// description and validation.
///
/// ```dart
/// DateFormField(
///   id: 'born',
///   label: const Text('Date of birth'),
///   max: DateTime.now(),
///   validator: (date) => date == null ? 'Enter your date of birth' : null,
/// )
/// ```
///
/// The form's value is the date once the three fields spell one, and null
/// before. A failed validation moves the focus to the first field.
class DateFormField extends UnaFormField<DateTime> {
  /// Creates a date form field.
  DateFormField({
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

    /// Called with the date once every field is filled, on each change
    /// after that, and with null when the fields stop spelling a date.
    super.onChanged,

    /// The date the field starts with.
    super.initialValue,

    /// The earliest date that can be entered.
    DateTime? min,

    /// The latest date that can be entered.
    DateTime? max,

    /// Whether each field has its name above it. Off by default here: the
    /// form field has a label of its own.
    bool showLabels = false,

    /// Whether a button after the fields opens a calendar.
    bool showCalendarButton = true,

    /// How the calendar of the button is presented.
    PickerPresentation presentation = PickerPresentation.auto,

    /// A widget before the fields.
    Widget? leading,

    /// A widget after the fields and the calendar button.
    Widget? trailing,

    /// The decoration of each field, merged over the theme's.
    UnaDecoration? decoration,

    /// {@macro KeyboardToolbar.toolbarBuilder}
    WidgetBuilder? keyboardToolbarBuilder,
  }) : super(
         decorationBuilder: (context) => decoration,
         builder: (state) {
           state as _DateFormFieldState;
           return Align(
             alignment: AlignmentDirectional.centerStart,
             widthFactor: 1,
             heightFactor: 1,
             child: DateField(
               // A reset writes the initial value back into the fields,
               // even over a half-typed date the form holds as null.
               key: ValueKey(state._generation),
               value: state.value,
               onChanged: state.didChange,
               enabled: state.enabled,
               focusNode: state.focusNode,
               min: min,
               max: max,
               showLabels: showLabels,
               showCalendarButton: showCalendarButton,
               presentation: presentation,
               leading: leading,
               trailing: trailing,
               decoration: state.decoration,
               keyboardToolbarBuilder: keyboardToolbarBuilder,
             ),
           );
         },
       );

  @override
  UnaFormFieldState<DateFormField, DateTime> createState() =>
      _DateFormFieldState();
}

/// The state of a [DateFormField].
class _DateFormFieldState extends UnaFormFieldState<DateFormField, DateTime> {
  int _generation = 0;

  @override
  void reset() {
    _generation++;
    super.reset();
  }
}
