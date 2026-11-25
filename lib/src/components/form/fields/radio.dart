import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/radio.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// A [FinesseRadioGroup] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
class RadioGroupFormField<T> extends FinesseFormField<T> {
  /// Creates a radio group form field.
  RadioGroupFormField({
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
    super.validator,

    /// {@macro FinesseRadioGroup.items}
    Iterable<Widget>? items,

    /// {@macro FinesseRadioGroup.child}
    Widget? child,

    /// {@macro FinesseRadioGroup.axis}
    Axis? axis,

    /// {@macro FinesseRadioGroup.spacing}
    double? spacing,

    /// {@macro FinesseRadioGroup.runSpacing}
    double? runSpacing,

    /// {@macro FinesseRadioGroup.alignment}
    WrapAlignment? alignment,

    /// {@macro FinesseRadioGroup.runAlignment}
    WrapAlignment? runAlignment,

    /// {@macro FinesseRadioGroup.crossAxisAlignment}
    WrapCrossAlignment? crossAxisAlignment,
  }) : assert(
         (items == null) != (child == null),
         'Give a radio group either items or a child.',
       ),
       super(
         decorationBuilder: (context) =>
             Theme.of(context).radioTheme.decoration ??
             const FinesseDecoration(),
         builder: (state) {
           state as RadioGroupFormFieldState<T>;
           return FinesseRadioGroup<T>(
             items: items,
             // The form holds the value; a key remakes the group when a
             // reset clears it, since null means "uncontrolled" there.
             key: ValueKey(state._generation),
             value: state.value,
             onChanged: state.didChange,
             enabled: state.enabled,
             axis: axis,
             spacing: spacing,
             runSpacing: runSpacing,
             alignment: alignment,
             runAlignment: runAlignment,
             crossAxisAlignment: crossAxisAlignment,
             child: child,
           );
         },
       );

  @override
  FinesseFormFieldState<RadioGroupFormField<T>, T> createState() =>
      RadioGroupFormFieldState<T>();
}

/// The state of a [RadioGroupFormField].
class RadioGroupFormFieldState<T>
    extends FinesseFormFieldState<RadioGroupFormField<T>, T> {
  int _generation = 0;

  @override
  void reset() {
    _generation++;
    super.reset();
  }
}
