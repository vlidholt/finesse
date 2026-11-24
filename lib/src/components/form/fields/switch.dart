import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/switch.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// A [Switch] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
class SwitchFormField extends FinesseFormField<bool> {
  /// Creates a switch form field.
  SwitchFormField({
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

    /// Whether the switch starts on.
    required bool initialValue,

    /// {@macro Switch.decoration}
    FinesseDecoration? decoration,
    super.focusNode,

    /// Returns an error message for the value, or null when it is valid.
    String? Function(bool)? validator,

    /// {@macro Switch.thumbColor}
    Color? thumbColor,

    /// {@macro Switch.uncheckedTrackColor}
    Color? uncheckedTrackColor,

    /// {@macro Switch.checkedTrackColor}
    Color? checkedTrackColor,

    /// {@macro Switch.width}
    double? width,

    /// {@macro Switch.margin}
    double? margin,

    /// {@macro Switch.duration}
    Duration? duration,

    /// {@macro Switch.label}
    Widget? inputLabel,

    /// {@macro Switch.sublabel}
    Widget? inputSublabel,

    /// {@macro Switch.padding}
    EdgeInsetsGeometry? padding,

    /// {@macro Switch.direction}
    TextDirection? direction,
  }) : super(
         initialValue: initialValue,
         onChanged: (!enabled || onChanged == null)
             ? null
             : (v) => onChanged(v ?? false),
         validator: validator == null
             ? null
             : (v) {
                 return validator(v ?? false);
               },
         decorationBuilder: (context) =>
             (Theme.of(context).switchTheme.decoration ??
                     const FinesseDecoration())
                 .merge(decoration),
         builder: (state) {
           state as SwitchFormFieldState;

           return Switch(
             value: state.value!,
             onChanged: state.didChange,
             enabled: state.enabled,
             focusNode: state.focusNode,
             decoration: state.decoration,
             duration: duration,
             label: inputLabel,
             sublabel: inputSublabel,
             padding: padding,
             direction: direction,
             width: width,
             margin: margin,
             thumbColor: thumbColor,
             uncheckedTrackColor: uncheckedTrackColor,
             checkedTrackColor: checkedTrackColor,
           );
         },
       );

  @override
  FinesseFormFieldState<SwitchFormField, bool> createState() =>
      SwitchFormFieldState();
}

/// The state of a [SwitchFormField].
class SwitchFormFieldState
    extends FinesseFormFieldState<SwitchFormField, bool> {}
