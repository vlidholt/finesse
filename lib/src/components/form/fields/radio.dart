import 'package:flutter/widgets.dart';
import 'package:una/src/components/form/field.dart';
import 'package:una/src/components/radio.dart';
import 'package:una/src/theme/components/decorator.dart';
import 'package:una/src/theme/theme.dart';

/// A [UnaRadioGroup] that takes part in a `UnaForm`, with a label, a
/// description and validation.
class RadioGroupFormField<T> extends UnaFormField<T> {
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

    /// {@macro UnaRadioGroup.items}
    Iterable<Widget>? items,

    /// {@macro UnaRadioGroup.child}
    Widget? child,

    /// {@macro UnaRadioGroup.axis}
    Axis? axis,

    /// {@macro UnaRadioGroup.spacing}
    double? spacing,

    /// {@macro UnaRadioGroup.runSpacing}
    double? runSpacing,

    /// {@macro UnaRadioGroup.alignment}
    WrapAlignment? alignment,

    /// {@macro UnaRadioGroup.runAlignment}
    WrapAlignment? runAlignment,

    /// {@macro UnaRadioGroup.crossAxisAlignment}
    WrapCrossAlignment? crossAxisAlignment,
  }) : assert(
         (items == null) != (child == null),
         'Give a radio group either items or a child.',
       ),
       super(
         decorationBuilder: (context) =>
             Theme.of(context).radioTheme.decoration ?? const UnaDecoration(),
         builder: (state) {
           state as _RadioGroupFormFieldState<T>;
           return UnaRadioGroup<T>(
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
  UnaFormFieldState<RadioGroupFormField<T>, T> createState() =>
      _RadioGroupFormFieldState<T>();
}

/// The state of a [RadioGroupFormField].
class _RadioGroupFormFieldState<T>
    extends UnaFormFieldState<RadioGroupFormField<T>, T> {
  int _generation = 0;

  @override
  void reset() {
    _generation++;
    super.reset();
  }
}
