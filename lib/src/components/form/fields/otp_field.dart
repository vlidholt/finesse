import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/otp_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A [OtpField] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
class OtpFormField extends FinesseFormField<String> {
  /// Creates a one-time password form field with [maxLength] characters.
  OtpFormField({
    super.id,
    super.key,
    super.onSaved,
    super.forceErrorText,

    /// Returns an error message for the value, or null when it is valid.
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
  }) : super(
         validator: validator == null
             ? null
             : (v) => validator(v ?? ''.padRight(maxLength)),
         onChanged: onChanged == null
             ? null
             : (v) => onChanged(v ?? ''.padRight(maxLength)),
         builder: (state) {
           state as OtpFormFieldState;
           return OtpField(
             enabled: state.enabled,
             keyboardType: keyboardType,
             inputFormatters: inputFormatters,
             gap: gap,
             maxLength: maxLength,
             jumpToNextWhenFilled: jumpToNextWhenFilled,
             onChanged: state.didChange,
             initialValue: state.initialValue,
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

/// The old name of [OtpFormFieldState].
@Deprecated(
  'Use OtpFormFieldState. '
  'Will be removed in the next major version.',
)
typedef FormBuilderOtpFieldState = OtpFormFieldState;
