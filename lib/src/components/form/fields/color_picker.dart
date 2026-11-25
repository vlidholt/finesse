import 'package:finesse/src/components/color_picker.dart';
import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/picker.dart';
import 'package:flutter/widgets.dart';

/// A [ColorPickerButton] that takes part in a `FinesseForm`, with a label,
/// a description and validation.
///
/// ```dart
/// ColorPickerFormField(
///   id: 'accent',
///   label: const Text('Accent colour'),
///   initialValue: const Color(0xFF0F766E),
///   swatches: brandColors,
/// )
/// ```
///
/// A failed validation moves the focus to the swatch.
class ColorPickerFormField extends FinesseFormField<Color> {
  /// Creates a colour picker form field.
  ColorPickerFormField({
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

    /// The colour the field starts with.
    required Color initialValue,

    /// Returns an error message for the colour, or null when it is valid.
    String? Function(Color color)? validator,

    /// Called with the chosen colour.
    ValueChanged<Color>? onChanged,

    /// Colours offered under the picker.
    List<Color>? swatches,

    /// Whether the opacity can be chosen too.
    bool showAlpha = false,

    /// Whether the picker opens in a popover, a sheet, or whichever suits
    /// the theme's form factor.
    PickerPresentation presentation = PickerPresentation.auto,

    /// The title of the sheet.
    Widget? title,

    /// The side of the swatch.
    double? size,

    /// What the colour is for, for assistive technology.
    String? semanticLabel,
  }) : super(
         initialValue: initialValue,
         validator: validator == null
             ? null
             : (color) => validator(color ?? initialValue),
         onChanged: onChanged == null
             ? null
             : (color) => onChanged(color ?? initialValue),
         builder: (field) {
           final state = field as _ColorPickerFormFieldState;
           return Align(
             alignment: AlignmentDirectional.centerStart,
             widthFactor: 1,
             heightFactor: 1,
             child: ColorPickerButton(
               value: state.value ?? initialValue,
               onChanged: state.enabled ? state.didChange : null,
               enabled: state.enabled,
               focusNode: state.focusNode,
               swatches: swatches,
               showAlpha: showAlpha,
               presentation: presentation,
               title: title,
               size: size,
               semanticLabel: semanticLabel,
             ),
           );
         },
       );

  @override
  FinesseFormFieldState<ColorPickerFormField, Color> createState() =>
      _ColorPickerFormFieldState();
}

/// The state of a [ColorPickerFormField].
class _ColorPickerFormFieldState
    extends FinesseFormFieldState<ColorPickerFormField, Color> {}
