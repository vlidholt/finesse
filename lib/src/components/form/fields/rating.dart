import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/rating.dart';
import 'package:flutter/widgets.dart';

/// A [Rating] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
///
/// ```dart
/// RatingFormField(
///   id: 'stars',
///   label: const Text('How was your stay?'),
///   validator: (stars) => stars == 0 ? 'Give it a rating' : null,
/// )
/// ```
///
/// A failed validation moves the focus to the stars.
class RatingFormField extends FinesseFormField<double> {
  /// Creates a rating form field.
  RatingFormField({
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

    /// The rating the field starts with. Defaults to none.
    double initialValue = 0,

    /// Returns an error message for the rating, or null when it is valid.
    String? Function(double value)? validator,

    /// Called with the new rating.
    ValueChanged<double>? onChanged,

    /// The number of stars.
    int count = 5,

    /// Whether half a star can be given.
    bool allowHalf = false,

    /// The icon of an empty star.
    Widget? icon,

    /// The icon of a full star.
    Widget? selectedIcon,

    /// The size of a star.
    double? size,

    /// The colour of the full stars.
    Color? color,

    /// What is being rated, for assistive technology.
    String? semanticLabel,
  }) : super(
         initialValue: initialValue,
         validator: validator == null ? null : (value) => validator(value ?? 0),
         onChanged: onChanged == null ? null : (value) => onChanged(value ?? 0),
         builder: (field) {
           final state = field as _RatingFormFieldState;
           return Align(
             alignment: AlignmentDirectional.centerStart,
             widthFactor: 1,
             heightFactor: 1,
             child: Rating(
               value: state.value ?? 0,
               onChanged: state.enabled ? state.didChange : null,
               focusNode: state.focusNode,
               count: count,
               allowHalf: allowHalf,
               icon: icon,
               selectedIcon: selectedIcon,
               size: size,
               color: color,
               semanticLabel: semanticLabel,
             ),
           );
         },
       );

  @override
  FinesseFormFieldState<RatingFormField, double> createState() =>
      _RatingFormFieldState();
}

/// The state of a [RatingFormField].
class _RatingFormFieldState
    extends FinesseFormFieldState<RatingFormField, double> {}
