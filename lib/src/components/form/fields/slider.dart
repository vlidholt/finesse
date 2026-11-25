import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/slider.dart';
import 'package:flutter/widgets.dart';

/// A [Slider] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
///
/// A failed validation moves the focus to the slider's thumb.
class SliderFormField extends FinesseFormField<double> {
  /// Creates a slider form field.
  SliderFormField({
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
    super.focusNode,

    /// Returns an error message for the value, or null when it is valid.
    String? Function(double value)? validator,

    /// Called with the new value as the slider moves.
    ValueChanged<double>? onChanged,

    /// The value the field starts with. Defaults to [min].
    super.initialValue,

    /// The least value. Defaults to the theme's, which is 0.
    double? min,

    /// The greatest value. Defaults to the theme's, which is 1.
    double? max,

    /// The number of steps the slider snaps to.
    int? divisions,

    /// Whether the steps are marked on the track.
    bool showDivisionMarks = true,

    /// When the value shows in a bubble above the thumb.
    SliderValueIndicator valueIndicator = SliderValueIndicator.never,

    /// Turns the value into the text of the bubble.
    String Function(double value)? valueLabel,

    /// The slider's accessible name.
    String? semanticLabel,

    /// Called when a drag starts.
    ValueChanged<double>? onChangeStart,

    /// Called when a drag ends.
    ValueChanged<double>? onChangeEnd,
  }) : super(
         validator: validator == null
             ? null
             : (value) => value == null ? null : validator(value),
         onChanged: onChanged == null
             ? null
             : (value) {
                 if (value != null) onChanged(value);
               },
         builder: (state) {
           state as SliderFormFieldState;
           return Slider(
             value: state.value ?? min ?? 0,
             onChanged: state.didChange,
             enabled: state.enabled,
             focusNode: state.focusNode,
             min: min,
             max: max,
             divisions: divisions,
             showDivisionMarks: showDivisionMarks,
             valueIndicator: valueIndicator,
             valueLabel: valueLabel,
             semanticLabel: semanticLabel,
             onChangeStart: onChangeStart,
             onChangeEnd: onChangeEnd,
           );
         },
       );

  @override
  FinesseFormFieldState<SliderFormField, double> createState() =>
      SliderFormFieldState();
}

/// The state of a [SliderFormField].
class SliderFormFieldState
    extends FinesseFormFieldState<SliderFormField, double> {}
