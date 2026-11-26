import 'package:flutter/widgets.dart';
import 'package:una/src/components/form/field.dart';
import 'package:una/src/components/tag_field.dart';
import 'package:una/src/theme/components/decorator.dart';
import 'package:una/src/theme/theme.dart';

/// A [TagField] that takes part in a `UnaForm`, with a label, a
/// description and validation. Its value is the list of tags.
///
/// ```dart
/// TagFormField<String>(
///   id: 'skills',
///   label: const Text('Skills'),
///   labelBuilder: (context, skill) => Text(skill),
///   maxTags: 8,
///   validator: (skills) => skills.isEmpty ? 'Add at least one' : null,
/// )
/// ```
class TagFormField<T extends Object> extends UnaFormField<List<T>> {
  /// Creates a tag form field.
  TagFormField({
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

    /// Builds the label of a tag.
    required Widget Function(BuildContext context, T tag) labelBuilder,

    /// The tags the field starts with. Defaults to none.
    List<T> initialValue = const [],

    /// Returns an error message for the tags, or null when they are valid.
    String? Function(List<T> tags)? validator,

    /// Called with the new list when a tag is added or removed.
    ValueChanged<List<T>>? onChanged,

    /// Turns typed text into a tag, or returns null to refuse it.
    T? Function(String text)? parse,

    /// The tag as words, for assistive technology and suggested options.
    String Function(T tag)? displayStringForTag,

    /// The texts that end a tag while typing, besides Enter.
    List<String> separators = const [','],

    /// Suggests tags for what is typed.
    AutocompleteOptionsBuilder<T>? optionsBuilder,

    /// Builds the row of a suggested option.
    Widget Function(BuildContext context, T option)? optionBuilder,

    /// The most tags the field takes.
    int? maxTags,

    /// Shown while the field has no tags and no text.
    Widget? placeholder,

    /// Whether the field takes the focus when it is first built.
    bool autofocus = false,

    /// Merged over the theme's text field decoration.
    UnaDecoration? decoration,

    /// What assistive technology calls the field.
    String? semanticLabel,
  }) : super(
         initialValue: initialValue,
         validator: validator == null
             ? null
             : (tags) => validator(tags ?? const []),
         onChanged: onChanged == null
             ? null
             : (tags) => onChanged(tags ?? const []),
         decorationBuilder: (context) =>
             (Theme.of(context).textFieldTheme.decoration ??
                     const UnaDecoration())
                 .merge(decoration),
         builder: (field) {
           final state = field as _TagFormFieldState<T>;
           return TagField<T>(
             values: state.value ?? <T>[],
             onChanged: state.enabled ? state.didChange : null,
             labelBuilder: labelBuilder,
             parse: parse,
             displayStringForTag: displayStringForTag,
             separators: separators,
             optionsBuilder: optionsBuilder,
             optionBuilder: optionBuilder,
             maxTags: maxTags,
             placeholder: placeholder,
             enabled: state.enabled,
             autofocus: autofocus,
             focusNode: state.focusNode,
             decoration: state.decoration,
             semanticLabel: semanticLabel,
           );
         },
       );

  @override
  UnaFormFieldState<TagFormField<T>, List<T>> createState() =>
      _TagFormFieldState<T>();
}

/// The state of a [TagFormField].
class _TagFormFieldState<T extends Object>
    extends UnaFormFieldState<TagFormField<T>, List<T>> {}
