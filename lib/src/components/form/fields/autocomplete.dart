import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/components/autocomplete.dart';
import 'package:una/src/components/form/field.dart';
import 'package:una/src/theme/components/decorator.dart';
import 'package:una/src/theme/theme.dart';

/// An [Autocomplete] that takes part in a `UnaForm`, with a label, a
/// description and validation. Its value is the text in the field, typed or
/// taken from an option.
///
/// ```dart
/// AutocompleteFormField<String>(
///   id: 'city',
///   label: const Text('City'),
///   optionsBuilder: (value) => cities.where(
///     (city) => city.toLowerCase().startsWith(value.text.toLowerCase()),
///   ),
///   validator: (text) =>
///       cities.contains(text) ? null : 'Pick a city from the list',
/// )
/// ```
class AutocompleteFormField<T extends Object> extends UnaFormField<String> {
  /// Creates an autocomplete form field.
  AutocompleteFormField({
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

    /// Returns the options for what is in the field; see
    /// [Autocomplete.optionsBuilder].
    required AutocompleteOptionsBuilder<T> optionsBuilder,

    /// The text the field starts with.
    String? initialValue,

    /// Returns an error message for the text, or null when it is valid.
    String? Function(String text)? validator,

    /// Called when the text changes: as the user types, and when an option
    /// is taken.
    ValueChanged<String>? onChanged,

    /// Called when the user chooses an option.
    ValueChanged<T>? onSelected,

    /// Called when the user submits the text as typed.
    ValueChanged<String>? onSubmitted,

    /// What an option puts in the field when it is chosen.
    String Function(T option)? displayStringForOption,

    /// Builds the content of an option's row.
    Widget Function(BuildContext context, T option)? optionBuilder,

    /// Builds what the list shows when nothing was found.
    WidgetBuilder? emptyBuilder,

    /// Builds what the list shows while options are awaited.
    WidgetBuilder? loadingBuilder,

    /// Shown while the field is empty.
    Widget? placeholder,

    /// A widget at the start of the field.
    Widget? leading,

    /// A widget at the end of the field.
    Widget? trailing,

    /// How long typing must have paused before a builder that answers with
    /// futures is asked again.
    Duration debounce = const Duration(milliseconds: 200),

    /// The most height the list takes before it scrolls.
    double? maxOptionsHeight,

    /// Whether the options are asked for as soon as the field has the
    /// focus.
    bool openOnFocus = false,

    /// Whether the first option is highlighted whenever the options change.
    bool autoHighlight = false,

    /// Whether the field shows a button that clears it.
    bool clearable = false,

    /// Whether the field takes the focus when it is first built.
    bool autofocus = false,

    /// The action of the keyboard's action key.
    TextInputAction? textInputAction,

    /// Merged over the theme's text field decoration.
    UnaDecoration? decoration,
  }) : super(
         initialValue: initialValue ?? '',
         validator: validator == null ? null : (text) => validator(text ?? ''),
         onChanged: onChanged == null ? null : (text) => onChanged(text ?? ''),
         decorationBuilder: (context) =>
             (Theme.of(context).textFieldTheme.decoration ??
                     const UnaDecoration())
                 .merge(decoration),
         builder: (field) {
           final state = field as _AutocompleteFormFieldState<T>;
           return Autocomplete<T>(
             optionsBuilder: optionsBuilder,
             controller: state.controller,
             focusNode: state.focusNode,
             onSelected: onSelected,
             onSubmitted: onSubmitted,
             displayStringForOption: displayStringForOption,
             optionBuilder: optionBuilder,
             emptyBuilder: emptyBuilder,
             loadingBuilder: loadingBuilder,
             placeholder: placeholder,
             leading: leading,
             trailing: trailing,
             debounce: debounce,
             maxOptionsHeight: maxOptionsHeight,
             openOnFocus: openOnFocus,
             autoHighlight: autoHighlight,
             clearable: clearable,
             autofocus: autofocus,
             enabled: state.enabled,
             textInputAction: textInputAction,
             decoration: state.decoration,
           );
         },
       );

  @override
  UnaFormFieldState<AutocompleteFormField<T>, String> createState() =>
      _AutocompleteFormFieldState<T>();
}

/// The state of an [AutocompleteFormField].
class _AutocompleteFormFieldState<T extends Object>
    extends UnaFormFieldState<AutocompleteFormField<T>, String> {
  /// The controller of the field's text.
  late final TextEditingController controller = TextEditingController(
    text: value,
  );

  @override
  void initState() {
    super.initState();
    controller.addListener(_onTextChanged);
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    if (controller.text != value) controller.text = value ?? '';
  }

  @override
  void reset() {
    super.reset();
    controller.text = initialValue ?? '';
  }

  @override
  void dispose() {
    controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (controller.text != value) didChange(controller.text);
  }
}
