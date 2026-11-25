import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/toggle.dart';
import 'package:flutter/widgets.dart';

/// A [ToggleGroup] that takes part in a `FinesseForm`, with a label, a
/// description and validation. Its value is the set of selected values.
///
/// ```dart
/// ToggleGroupFormField<String>(
///   id: 'days',
///   label: const Text('Delivery days'),
///   multiple: true,
///   validator: (days) => days.isEmpty ? 'Pick at least one day' : null,
///   children: const [
///     ToggleGroupItem(value: 'mon', child: Text('Mon')),
///     ToggleGroupItem(value: 'wed', child: Text('Wed')),
///     ToggleGroupItem(value: 'fri', child: Text('Fri')),
///   ],
/// )
/// ```
class ToggleGroupFormField<T> extends FinesseFormField<Set<T>> {
  /// Creates a toggle group form field.
  ToggleGroupFormField({
    super.id,
    super.key,
    super.onSaved,
    super.forceErrorText,
    super.label,
    super.error,
    super.description,
    void Function(Set<T>)? onChanged,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    super.focusNode,

    /// The items of the group.
    required List<ToggleGroupItem<T>> children,

    /// The values selected at first. Defaults to none.
    Set<T> initialValue = const {},

    /// Whether any number of items can be selected, rather than one.
    bool multiple = false,

    /// Whether tapping the selected item of a single-selection group clears
    /// it.
    bool allowDeselection = true,

    /// Returns an error message for the selection, or null when it is
    /// valid.
    String? Function(Set<T>)? validator,

    /// The visual style of the toggles.
    ToggleVariant toggleVariant = ToggleVariant.primary,

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
           final state = field as _ToggleGroupFormFieldState<T>;
           final values = state.value ?? <T>{};
           // The label names the group for assistive technology.
           final group = multiple
               ? ToggleGroup<T>.multiple(
                   values: values,
                   onChanged: state.didChange,
                   enabled: state.enabled,
                   toggleVariant: toggleVariant,
                   gap: gap,
                   axis: axis,
                   children: children,
                 )
               : ToggleGroup<T>(
                   values: values,
                   onChanged: state.didChange,
                   allowDeselection: allowDeselection,
                   enabled: state.enabled,
                   toggleVariant: toggleVariant,
                   gap: gap,
                   axis: axis,
                   children: children,
                 );
           return Align(
             alignment: AlignmentDirectional.centerStart,
             widthFactor: 1,
             heightFactor: 1,
             child: group,
           );
         },
       );

  @override
  FinesseFormFieldState<ToggleGroupFormField<T>, Set<T>> createState() =>
      _ToggleGroupFormFieldState<T>();
}

/// The state of a [ToggleGroupFormField].
class _ToggleGroupFormFieldState<T>
    extends FinesseFormFieldState<ToggleGroupFormField<T>, Set<T>> {}
