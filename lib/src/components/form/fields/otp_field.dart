import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/otp_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// An [OtpField] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
///
/// The form field holds the value: it starts from `initialValue`, and
/// `reset()` or `didChange` on its state changes what the slots show.
class OtpFormField extends FinesseFormField<String> {
  /// Creates a one-time password form field with [maxLength] characters.
  OtpFormField({
    super.id,
    super.key,
    super.onSaved,
    super.forceErrorText,

    /// Returns an error message for the value, or null when it is valid.
    /// The value has all `maxLength` characters, a space for an empty slot.
    String? Function(String)? validator,

    /// {@macro OtpField.initialValue}
    super.initialValue,

    /// {@macro OtpField.enabled}
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    super.label,
    super.error,
    super.description,

    /// {@macro OtpField.onChanged}
    void Function(String)? onChanged,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.readOnly,

    /// {@macro OtpField.maxLength}
    required int maxLength,

    /// {@macro OtpField.gap}
    double? gap,

    /// {@macro OtpField.children}
    required List<Widget> children,

    /// {@macro OtpField.jumpToNextWhenFilled}
    bool jumpToNextWhenFilled = true,

    /// {@macro OtpField.inputFormatters}
    List<TextInputFormatter>? inputFormatters,

    /// {@macro OtpField.keyboardType}
    TextInputType? keyboardType,

    /// {@macro OtpField.autofillHints}
    Iterable<String> autofillHints = const [AutofillHints.oneTimeCode],

    /// {@macro OtpField.onCompleted}
    ValueChanged<String>? onCompleted,
  }) : super(
         validator: validator == null
             ? null
             : (v) => validator((v ?? '').padRight(maxLength)),
         onChanged: onChanged == null
             ? null
             : (v) => onChanged((v ?? '').padRight(maxLength)),
         builder: (state) {
           state as OtpFormFieldState;
           return OtpField(
             enabled: state.enabled,
             keyboardType: keyboardType,
             inputFormatters: inputFormatters,
             gap: gap,
             maxLength: maxLength,
             jumpToNextWhenFilled: jumpToNextWhenFilled,
             autofillHints: autofillHints,
             onChanged: state.didChange,
             onCompleted: onCompleted,
             // The form field's state holds the value, so that a reset or
             // a value set through the form reaches the slots.
             value: state.value ?? '',
             children: children,
           );
         },
       );

  @override
  FinesseFormFieldState<OtpFormField, String> createState() =>
      OtpFormFieldState();
}

/// The state of a [OtpFormField].
class OtpFormFieldState extends FinesseFormFieldState<OtpFormField, String> {}
