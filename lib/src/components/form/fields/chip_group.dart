import 'package:finesse/src/components/chip.dart';
import 'package:finesse/src/components/chip_group.dart';
import 'package:finesse/src/components/form/field.dart';
import 'package:flutter/widgets.dart';

/// A [ChipGroup] that takes part in a `FinesseForm`, with a label, a
/// description and validation. Its value is the set of chosen values.
///
/// ```dart
/// ChipGroupFormField<String>(
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
class ChipGroupFormField<T> extends FinesseFormField<Set<T>> {
  /// Creates a chip group form field.
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
    super.focusNode,

    /// The chips, in order.
    required List<ChipGroupItem<T>> items,

    /// The values chosen at first. Defaults to none.
    Set<T> initialValue = const {},

    /// Returns an error message for the chosen values, or null when they
    /// are valid.
    String? Function(Set<T> values)? validator,

    /// Called with the new set when a chip is tapped.
    ValueChanged<Set<T>>? onChanged,

    /// Whether more than one chip can be chosen at a time.
    bool multiple = true,

    /// Whether the set may be left empty.
    bool allowEmpty = true,

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
           final state = field as _ChipGroupFormFieldState<T>;
           return ChipGroup<T>(
             items: items,
             values: state.value ?? <T>{},
             onChanged: state.enabled ? state.didChange : null,
             multiple: multiple,
             allowEmpty: allowEmpty,
             wrap: wrap,
             showCheckmark: showCheckmark,
             variant: variant,
             alignment: alignment,
             semanticLabel: semanticLabel,
           );
         },
       );

  @override
  FinesseFormFieldState<ChipGroupFormField<T>, Set<T>> createState() =>
      _ChipGroupFormFieldState<T>();
}

/// The state of a [ChipGroupFormField].
class _ChipGroupFormFieldState<T>
    extends FinesseFormFieldState<ChipGroupFormField<T>, Set<T>> {}
