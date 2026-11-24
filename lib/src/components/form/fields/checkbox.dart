import 'package:finesse/src/components/checkbox.dart';
import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// A [Checkbox] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
class CheckboxFormField extends FinesseFormField<bool> {
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
    FinesseDecoration? decoration,

    /// Returns an error message for the value, or null when it is valid.
    String? Function(bool)? validator,

    /// {@macro Checkbox.size}
    double? size,

    /// {@macro Checkbox.duration}
    Duration? duration,

    /// {@macro Checkbox.icon}
    Widget? icon,

    /// {@macro Checkbox.color}
    Color? color,

    /// {@macro Checkbox.label}
    Widget? inputLabel,

    /// {@macro Checkbox.sublabel}
    Widget? inputSublabel,

    /// {@macro Checkbox.padding}
    EdgeInsetsGeometry? padding,

    /// {@macro Checkbox.direction}
    TextDirection? direction,

    /// {@macro Checkbox.crossAxisAlignment}
    CrossAxisAlignment? crossAxisAlignment,

    /// {@macro Checkbox.checkboxPadding}
    EdgeInsetsGeometry? checkboxPadding,
  }) : super(
         onChanged: onChanged == null ? null : (v) => onChanged(v ?? false),
         validator: validator == null ? null : (v) => validator(v ?? false),
         decorationBuilder: (context) =>
             (Theme.of(context).checkboxTheme.decoration ??
                     const FinesseDecoration())
                 .merge(decoration),
         builder: (state) {
           state as CheckboxFormFieldState;
           return Checkbox(
             value: state.value!,
             onChanged: state.didChange,
             enabled: state.enabled,
             focusNode: state.focusNode,
             size: size,
             duration: duration,
             icon: icon,
             color: color,
             label: inputLabel,
             sublabel: inputSublabel,
             padding: padding,
             direction: direction,
             decoration: state.decoration,
             crossAxisAlignment: crossAxisAlignment,
             checkboxPadding: checkboxPadding,
           );
         },
       );

  @override
  FinesseFormFieldState<CheckboxFormField, bool> createState() =>
      CheckboxFormFieldState();
}

/// The state of a [CheckboxFormField].
class CheckboxFormFieldState
    extends FinesseFormFieldState<CheckboxFormField, bool> {}
