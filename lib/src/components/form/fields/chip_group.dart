import 'package:finesse/src/components/chip.dart';
import 'package:finesse/src/components/chip_group.dart';
import 'package:finesse/src/components/form/field.dart';
import 'package:flutter/widgets.dart';

/// A [ChipGroup] that takes part in a `FinesseForm`, with a label, a
/// description and validation. Its value is the chosen value, or null. For
/// a set of values, use [ChipGroupMultipleFormField].
///
/// ```dart
/// ChipGroupFormField<String>(
///   id: 'level',
///   label: const Text('Level'),
///   items: const [
///     ChipGroupItem(value: 'junior', label: Text('Junior')),
///     ChipGroupItem(value: 'senior', label: Text('Senior')),
///   ],
///   validator: (level) => level == null ? 'Pick a level' : null,
/// )
/// ```
///
/// A failed validation moves the focus to the group's first chip.
class ChipGroupFormField<T> extends FinesseFormField<T> {
  /// Creates a chip group form field that holds one value.
  ChipGroupFormField({
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
    super.initialValue,
    super.validator,
    super.onChanged,

    /// The chips, in order.
    required List<ChipGroupItem<T>> items,

    /// Whether the chosen chip can be unchosen.
    bool allowDeselection = true,

    /// Whether the chips wrap onto further rows; false keeps them on one
    /// row that scrolls.
    bool wrap = true,

    /// Whether a chosen chip shows a check. Defaults to the theme's.
    bool? showCheckmark,

    /// How the chips are outlined.
    ChipVariant variant = ChipVariant.outline,

    /// How the chips of a row are placed in a group that wraps.
    WrapAlignment alignment = WrapAlignment.start,

    /// What the group chooses, for assistive technology.
    String? semanticLabel,
  }) : super(
         builder: (field) {
           final state = field as _ChipGroupFormFieldState<T>;
           return ChipGroup<T>(
             items: items,
             value: state.value,
             onChanged: state.enabled ? state.didChange : null,
             allowDeselection: allowDeselection,
             wrap: wrap,
             showCheckmark: showCheckmark,
             variant: variant,
             alignment: alignment,
             semanticLabel: semanticLabel,
           );
         },
       );

  @override
  FinesseFormFieldState<ChipGroupFormField<T>, T> createState() =>
      _ChipGroupFormFieldState<T>();
}

/// The state of a [ChipGroupFormField].
class _ChipGroupFormFieldState<T>
    extends FinesseFormFieldState<ChipGroupFormField<T>, T> {}

/// A [ChipGroup.multiple] that takes part in a `FinesseForm`, with a
/// label, a description and validation. Its value is the set of chosen
/// values.
///
/// ```dart
/// ChipGroupMultipleFormField<String>(
///   id: 'interests',
///   label: const Text('Interests'),
///   items: const [
///     ChipGroupItem(value: 'design', label: Text('Design')),
///     ChipGroupItem(value: 'data', label: Text('Data')),
///     ChipGroupItem(value: 'mobile', label: Text('Mobile')),
///   ],
///   validator: (chosen) => chosen.isEmpty ? 'Pick at least one' : null,
/// )
/// ```
///
/// A failed validation moves the focus to the group's first chip.
class ChipGroupMultipleFormField<T> extends FinesseFormField<Set<T>> {
  /// Creates a chip group form field that holds a set of values.
  ChipGroupMultipleFormField({
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

    /// The chips, in order.
    required List<ChipGroupItem<T>> items,

    /// The values chosen at first. Defaults to none.
    Set<T> initialValue = const {},

    /// Returns an error message for the chosen values, or null when they
    /// are valid.
    String? Function(Set<T> values)? validator,

    /// Called with the new set when a chip is tapped.
    ValueChanged<Set<T>>? onChanged,

    /// Whether the set may be left empty.
    bool allowDeselection = true,

    /// Whether the chips wrap onto further rows; false keeps them on one
    /// row that scrolls.
    bool wrap = true,

    /// Whether a chosen chip shows a check. Defaults to the theme's.
    bool? showCheckmark,

    /// How the chips are outlined.
    ChipVariant variant = ChipVariant.outline,

    /// How the chips of a row are placed in a group that wraps.
    WrapAlignment alignment = WrapAlignment.start,

    /// What the group chooses, for assistive technology.
    String? semanticLabel,
  }) : super(
         initialValue: initialValue,
         validator: validator == null
             ? null
             : (values) => validator(values ?? const {}),
         onChanged: onChanged == null
             ? null
             : (values) => onChanged(values ?? const {}),
         builder: (field) {
           final state = field as _ChipGroupMultipleFormFieldState<T>;
           return ChipGroup<T>.multiple(
             items: items,
             values: state.value ?? <T>{},
             onValuesChanged: state.enabled ? state.didChange : null,
             allowDeselection: allowDeselection,
             wrap: wrap,
             showCheckmark: showCheckmark,
             variant: variant,
             alignment: alignment,
             semanticLabel: semanticLabel,
           );
         },
       );

  @override
  FinesseFormFieldState<ChipGroupMultipleFormField<T>, Set<T>> createState() =>
      _ChipGroupMultipleFormFieldState<T>();
}

/// The state of a [ChipGroupMultipleFormField].
class _ChipGroupMultipleFormFieldState<T>
    extends FinesseFormFieldState<ChipGroupMultipleFormField<T>, Set<T>> {}
