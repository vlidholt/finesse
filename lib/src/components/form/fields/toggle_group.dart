import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/toggle.dart';
import 'package:flutter/widgets.dart';

/// A [ToggleGroup] that takes part in a `FinesseForm`, with a label, a
/// description and validation. Its value is the selected value, or null.
/// For a set of values, use [ToggleGroupMultipleFormField].
///
/// ```dart
/// ToggleGroupFormField<String>(
///   id: 'size',
///   label: const Text('Size'),
///   validator: (size) => size == null ? 'Pick a size' : null,
///   items: const [
///     ToggleGroupItem(value: 's', child: Text('S')),
///     ToggleGroupItem(value: 'm', child: Text('M')),
///     ToggleGroupItem(value: 'l', child: Text('L')),
///   ],
/// )
/// ```
class ToggleGroupFormField<T> extends FinesseFormField<T> {
  /// Creates a toggle group form field that holds one value.
  ToggleGroupFormField({
    super.id,
    super.key,
    super.onSaved,
    super.forceErrorText,
    super.label,
    super.error,
    super.description,
    super.onChanged,
    super.validator,
    super.initialValue,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,

    /// The items of the group.
    required List<ToggleGroupItem<T>> items,

    /// Whether tapping the selected item clears it.
    bool allowDeselection = true,

    /// The visual style of the toggles.
    ToggleVariant variant = ToggleVariant.primary,

    /// The gap between the items; 0 joins them into one bar.
    double? gap,

    /// The direction the items are laid out in.
    Axis axis = Axis.horizontal,
  }) : super(
         builder: (field) {
           final state = field as _ToggleGroupFormFieldState<T>;
           // The label names the group for assistive technology.
           return Align(
             alignment: AlignmentDirectional.centerStart,
             widthFactor: 1,
             heightFactor: 1,
             child: ToggleGroup<T>(
               value: state.value,
               onChanged: state.didChange,
               allowDeselection: allowDeselection,
               enabled: state.enabled,
               variant: variant,
               gap: gap,
               axis: axis,
               items: items,
             ),
           );
         },
       );

  @override
  FinesseFormFieldState<ToggleGroupFormField<T>, T> createState() =>
      _ToggleGroupFormFieldState<T>();
}

/// The state of a [ToggleGroupFormField].
class _ToggleGroupFormFieldState<T>
    extends FinesseFormFieldState<ToggleGroupFormField<T>, T> {}

/// A [ToggleGroup.multiple] that takes part in a `FinesseForm`, with a
/// label, a description and validation. Its value is the set of selected
/// values.
///
/// ```dart
/// ToggleGroupMultipleFormField<String>(
///   id: 'days',
///   label: const Text('Delivery days'),
///   validator: (days) => days.isEmpty ? 'Pick at least one day' : null,
///   items: const [
///     ToggleGroupItem(value: 'mon', child: Text('Mon')),
///     ToggleGroupItem(value: 'wed', child: Text('Wed')),
///     ToggleGroupItem(value: 'fri', child: Text('Fri')),
///   ],
/// )
/// ```
class ToggleGroupMultipleFormField<T> extends FinesseFormField<Set<T>> {
  /// Creates a toggle group form field that holds a set of values.
  ToggleGroupMultipleFormField({
    super.id,
    super.key,
    super.onSaved,
    super.forceErrorText,
    super.label,
    super.error,
    super.description,
    ValueChanged<Set<T>>? onChanged,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,

    /// The items of the group.
    required List<ToggleGroupItem<T>> items,

    /// The values selected at first. Defaults to none.
    Set<T> initialValue = const {},

    /// Whether the selection may become empty.
    bool allowDeselection = true,

    /// Returns an error message for the selection, or null when it is
    /// valid.
    String? Function(Set<T>)? validator,

    /// The visual style of the toggles.
    ToggleVariant variant = ToggleVariant.primary,

    /// The gap between the items; 0 joins them into one bar.
    double? gap,

    /// The direction the items are laid out in.
    Axis axis = Axis.horizontal,
  }) : super(
         initialValue: initialValue,
         onChanged: (!enabled || onChanged == null)
             ? null
             : (values) => onChanged(values ?? const {}),
         validator: validator == null
             ? null
             : (values) => validator(values ?? const {}),
         builder: (field) {
           final state = field as _ToggleGroupMultipleFormFieldState<T>;
           // The label names the group for assistive technology.
           return Align(
             alignment: AlignmentDirectional.centerStart,
             widthFactor: 1,
             heightFactor: 1,
             child: ToggleGroup<T>.multiple(
               values: state.value ?? <T>{},
               onValuesChanged: state.didChange,
               allowDeselection: allowDeselection,
               enabled: state.enabled,
               variant: variant,
               gap: gap,
               axis: axis,
               items: items,
             ),
           );
         },
       );

  @override
  FinesseFormFieldState<ToggleGroupMultipleFormField<T>, Set<T>>
  createState() => _ToggleGroupMultipleFormFieldState<T>();
}

/// The state of a [ToggleGroupMultipleFormField].
class _ToggleGroupMultipleFormFieldState<T>
    extends FinesseFormFieldState<ToggleGroupMultipleFormField<T>, Set<T>> {}
