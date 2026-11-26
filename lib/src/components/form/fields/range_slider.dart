import 'package:flutter/widgets.dart';
import 'package:una/src/components/form/field.dart';
import 'package:una/src/components/slider.dart';

/// A [RangeSlider] that takes part in a `UnaForm`, with a label, a
/// description and validation. Its value is one number per thumb, in
/// ascending order.
///
/// ```dart
/// RangeSliderFormField(
///   id: 'price',
///   label: const Text('Price'),
///   max: 500,
///   initialValue: const [80, 240],
///   validator: (range) =>
///       range.last - range.first < 20 ? 'Widen the range a little' : null,
/// )
/// ```
///
/// A failed validation moves the focus to the slider's first thumb.
class RangeSliderFormField extends UnaFormField<List<double>> {
  /// Creates a range slider form field.
  RangeSliderFormField({
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

    /// The values the field starts with, one per thumb in ascending order.
    required List<double> initialValue,

    /// Returns an error message for the values, or null when they are
    /// valid.
    String? Function(List<double> values)? validator,

    /// Called with the new values as a thumb moves.
    ValueChanged<List<double>>? onChanged,

    /// The least value. Defaults to the theme's, which is 0.
    double? min,

    /// The greatest value. Defaults to the theme's, which is 1.
    double? max,

    /// The number of steps the slider snaps to.
    int? divisions,

    /// Whether the steps are marked on the track.
    bool showDivisionMarks = true,

    /// When a thumb's value shows in a bubble above it.
    SliderValueIndicator valueIndicator = SliderValueIndicator.never,

    /// Turns a value into the text of the bubble.
    String Function(double value)? valueLabel,

    /// The slider's accessible name.
    String? semanticLabel,

    /// Called when a drag starts.
    ValueChanged<List<double>>? onChangeStart,

    /// Called when a drag ends.
    ValueChanged<List<double>>? onChangeEnd,
  }) : super(
         initialValue: initialValue,
         validator: validator == null
             ? null
             : (values) => validator(values ?? initialValue),
         onChanged: onChanged == null
             ? null
             : (values) => onChanged(values ?? initialValue),
         builder: (field) {
           final state = field as _RangeSliderFormFieldState;
           return RangeSlider(
             values: state.value ?? initialValue,
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
  UnaFormFieldState<RangeSliderFormField, List<double>> createState() =>
      _RangeSliderFormFieldState();
}

/// The state of a [RangeSliderFormField].
class _RangeSliderFormFieldState
    extends UnaFormFieldState<RangeSliderFormField, List<double>> {}
