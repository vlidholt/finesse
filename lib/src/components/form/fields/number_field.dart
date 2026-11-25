import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/number_field.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show NumberFormat;

/// A [NumberField] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
///
/// ```dart
/// NumberFormField(
///   id: 'guests',
///   label: const Text('Guests'),
///   initialValue: 2,
///   min: 1,
///   max: 12,
///   validator: (value) => value == null ? 'Say how many' : null,
/// )
/// ```
class NumberFormField extends FinesseFormField<num> {
  /// Creates a number form field.
  NumberFormField({
    super.id,
    super.key,
    super.onSaved,
    super.forceErrorText,
    super.label,
    super.error,
    super.description,
    super.onChanged,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    super.initialValue,
    super.focusNode,
    super.validator,

    /// The least the value may be.
    num? min,

    /// The most the value may be.
    num? max,

    /// How much one step changes the value.
    num step = 1,

    /// How much a large step — Shift with an arrow, Page Up, Page Down —
    /// changes the value. Defaults to ten times the step.
    num? largeStep,

    /// How many decimals the value keeps.
    int decimalDigits = 0,

    /// Writes the number, and reads it back from what was typed.
    NumberFormat? format,

    /// Whether the number is typed into a field or only stepped.
    NumberFieldVariant variant = NumberFieldVariant.field,

    /// Shown while the field is empty.
    Widget? placeholder,

    /// A widget at the start of the field.
    Widget? leading,

    /// Whether the value can be read but not changed.
    bool readOnly = false,

    /// Merged over the theme's text field decoration.
    FinesseDecoration? decoration,

    /// What assistive technology calls the field.
    String? semanticLabel,
  }) : super(
         decorationBuilder: (context) =>
             (Theme.of(context).textFieldTheme.decoration ??
                     const FinesseDecoration())
                 .merge(decoration),
         builder: (state) {
           state as _NumberFormFieldState;
           return NumberField(
             value: state.value,
             onChanged: state.enabled ? state.didChange : null,
             min: min,
             max: max,
             step: step,
             largeStep: largeStep,
             decimalDigits: decimalDigits,
             format: format,
             variant: variant,
             placeholder: placeholder,
             leading: leading,
             readOnly: readOnly,
             enabled: state.enabled,
             focusNode: state.focusNode,
             decoration: state.decoration,
             semanticLabel: semanticLabel,
           );
         },
       );

  @override
  FinesseFormFieldState<NumberFormField, num> createState() =>
      _NumberFormFieldState();
}

/// The state of a [NumberFormField].
class _NumberFormFieldState
    extends FinesseFormFieldState<NumberFormField, num> {}
