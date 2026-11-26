import 'package:flutter/widgets.dart';
import 'package:una/src/components/form/field.dart';
import 'package:una/src/components/segmented_control.dart';

/// A [SegmentedControl] as a field of a `UnaForm`: it holds its value,
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
class SegmentedControlFormField<T> extends UnaFormField<T> {
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
           enabled: (state as _SegmentedControlFormFieldState<T>).enabled,
           onChanged: state.didChange,
         ),
       );

  @override
  UnaFormFieldState<SegmentedControlFormField<T>, T> createState() =>
      _SegmentedControlFormFieldState<T>();
}

/// The state of a [SegmentedControlFormField].
class _SegmentedControlFormFieldState<T>
    extends UnaFormFieldState<SegmentedControlFormField<T>, T> {}
