import 'package:flutter/widgets.dart';
import 'package:una/src/components/checkbox.dart';
import 'package:una/src/components/control_affinity.dart';
import 'package:una/src/components/form/field.dart';
import 'package:una/src/theme/components/decorator.dart';
import 'package:una/src/theme/theme.dart';

/// A [Checkbox] that takes part in a `UnaForm`, with a label, a
/// description and validation.
class CheckboxFormField extends UnaFormField<bool> {
  /// Creates a checkbox form field.
  CheckboxFormField({
    super.id,
    super.key,
    super.onSaved,
    super.forceErrorText,
    super.label,
    super.error,
    super.description,
    void Function(bool)? onChanged,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    required bool super.initialValue,
    super.focusNode,

    /// {@macro Checkbox.decoration}
    UnaDecoration? decoration,

    /// Returns an error message for the value, or null when it is valid.
    String? Function(bool)? validator,

    /// {@macro Checkbox.size}
    double? size,

    /// {@macro Checkbox.icon}
    Widget? icon,

    /// {@macro Checkbox.color}
    Color? color,

    /// {@macro Checkbox.label}
    Widget? inputLabel,

    /// {@macro Checkbox.description}
    Widget? inputDescription,

    /// {@macro Checkbox.padding}
    EdgeInsetsGeometry? padding,

    /// {@macro Checkbox.controlAffinity}
    ControlAffinity controlAffinity = ControlAffinity.leading,

    /// {@macro Checkbox.crossAxisAlignment}
    CrossAxisAlignment? crossAxisAlignment,

    /// {@macro Checkbox.checkboxPadding}
    EdgeInsetsGeometry? checkboxPadding,
  }) : super(
         onChanged: onChanged == null ? null : (v) => onChanged(v ?? false),
         validator: validator == null ? null : (v) => validator(v ?? false),
         decorationBuilder: (context) =>
             (Theme.of(context).checkboxTheme.decoration ??
                     const UnaDecoration())
                 .merge(decoration),
         builder: (state) {
           state as _CheckboxFormFieldState;
           return Checkbox(
             value: state.value ?? false,
             onChanged: state.didChange,
             enabled: state.enabled,
             focusNode: state.focusNode,
             size: size,
             icon: icon,
             color: color,
             label: inputLabel,
             description: inputDescription,
             padding: padding,
             controlAffinity: controlAffinity,
             decoration: state.decoration,
             crossAxisAlignment: crossAxisAlignment,
             checkboxPadding: checkboxPadding,
           );
         },
       );

  @override
  UnaFormFieldState<CheckboxFormField, bool> createState() =>
      _CheckboxFormFieldState();
}

/// The state of a [CheckboxFormField].
class _CheckboxFormFieldState
    extends UnaFormFieldState<CheckboxFormField, bool> {}
