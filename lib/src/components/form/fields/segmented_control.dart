import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/segmented_control.dart';
import 'package:flutter/widgets.dart';

/// A [SegmentedControl] as a field of a `FinesseForm`: it holds its value,
/// validates, saves and resets with the form, and shows the field's label,
/// description and error around the control.
///
/// ```dart
/// SegmentedControlFormField<Plan>(
///   id: 'plan',
///   label: const Text('Billing period'),
///   initialValue: Plan.monthly,
///   segments: const [
///     Segment(value: Plan.monthly, label: Text('Monthly')),
///     Segment(value: Plan.yearly, label: Text('Yearly')),
///   ],
///   validator: (plan) => plan == null ? 'Choose a period' : null,
/// )
/// ```
///
/// With no [initialValue] no segment is chosen until the user picks one.
class SegmentedControlFormField<T> extends FinesseFormField<T> {
  /// Creates a segmented control form field.
  SegmentedControlFormField({
    required List<Segment<T>> segments,
    super.id,
    super.key,
    super.onSaved,
    super.forceErrorText,
    super.label,
    super.error,
    super.description,
    ValueChanged<T>? onChanged,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    super.initialValue,
    super.validator,

    /// Whether the segments share the width of the field.
    bool expand = false,
  }) : super(
         onChanged: onChanged == null
             ? null
             : (value) {
                 if (value is T) onChanged(value);
               },
         builder: (state) => SegmentedControl<T>(
           segments: segments,
           value: state.value,
           expand: expand,
           enabled: state.widget.enabled,
           onChanged: state.didChange,
         ),
       );

  @override
  FinesseFormFieldState<SegmentedControlFormField<T>, T> createState() =>
      _SegmentedControlFormFieldState<T>();
}

/// The state of a [SegmentedControlFormField].
class _SegmentedControlFormFieldState<T>
    extends FinesseFormFieldState<SegmentedControlFormField<T>, T> {}
