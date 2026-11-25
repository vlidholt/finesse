import 'dart:ui';

import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/components/select.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// A single-choice [Select] that takes part in a `FinesseForm`, with a
/// label, a description and validation.
///
/// For a field that holds several values, use [SelectMultipleFormField].
class SelectFormField<T> extends FinesseFormField<T> {
  /// Creates a select form field, like [Select.new].
  ///
  /// [variant] is [SelectVariant.primary], the default, or
  /// [SelectVariant.search]; [SelectFormField.withSearch] is the shortcut for
  /// the second.
  SelectFormField({
    super.id,
    super.key,
    super.onSaved,
    super.label,
    super.error,
    super.description,
    super.onChanged,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    super.initialValue,
    super.focusNode,
    super.validator,
    super.forceErrorText,

    /// {@macro Select.variant}
    SelectVariant variant = SelectVariant.primary,

    /// {@macro Select.selectedOptionBuilder}
    SelectedOptionBuilder<T>? selectedOptionBuilder,

    /// {@macro Select.options}
    Iterable<Widget>? options,

    /// The builder for the options of the [Select].
    Widget? Function(BuildContext, int)? optionsBuilder,

    /// {@macro Select.onSearchChanged}
    ValueChanged<String>? onSearchChanged,

    /// {@macro Select.placeholder}
    Widget? placeholder,

    /// {@macro Select.closeOnTapOutside}
    bool closeOnTapOutside = true,

    /// {@macro Select.minWidth}
    double? minWidth,

    /// {@macro Select.maxWidth}
    double? maxWidth,

    /// {@macro Select.maxHeight}
    double? maxHeight,

    /// {@macro Select.decoration}
    FinesseDecoration? decoration,

    /// {@macro Select.trailing}
    Widget? trailing,

    /// {@macro Select.padding}
    EdgeInsetsGeometry? padding,

    /// {@macro Select.optionsPadding}
    EdgeInsetsGeometry? optionsPadding,

    /// {@macro Select.showScrollToTopChevron}
    bool? showScrollToTopChevron,

    /// {@macro Select.showScrollToBottomChevron}
    bool? showScrollToBottomChevron,

    /// {@macro Select.scrollController}
    ScrollController? scrollController,

    /// {@macro Select.anchor}
    AnchorBase? anchor,

    /// {@macro Popover.filter}
    ImageFilter? filter,

    /// {@macro Select.searchDivider}
    Widget? searchDivider,

    /// {@macro Select.searchInputLeading}
    Widget? searchInputLeading,

    /// {@macro Select.searchPlaceholder}
    Widget? searchPlaceholder,

    /// {@macro Select.searchPadding}
    EdgeInsetsGeometry? searchPadding,

    /// {@macro Select.search}
    Widget? search,

    /// {@macro Select.clearSearchOnClose}
    bool? clearSearchOnClose,

    /// {@macro Select.controller}
    PopoverController? controller,

    /// {@macro Select.header}
    Widget? header,

    /// {@macro Select.footer}
    Widget? footer,

    /// {@macro Select.allowDeselection}
    bool allowDeselection = false,

    /// {@macro Select.closeOnSelect}
    bool closeOnSelect = true,

    /// {@macro Select.itemCount}
    int? itemCount,

    /// {@macro Select.shrinkWrap}
    bool? shrinkWrap,

    /// {@macro Select.ensureSelectedVisible}
    bool? ensureSelectedVisible,

    /// {@macro Select.searchFocusNode}
    FocusNode? searchFocusNode,

    /// {@macro Select.onSearchSubmitted}
    ValueChanged<String>? onSearchSubmitted,

    /// {@macro Select.onTap}
    VoidCallback? onTap,
  }) : assert(
         variant == SelectVariant.primary || variant == SelectVariant.search,
         '''The variant is not supported. Use primary or search or use SelectMultipleFormField instead.''',
       ),
       super(
         decorationBuilder: (context) =>
             (Theme.of(context).selectTheme.decoration ??
                     const FinesseDecoration())
                 .merge(decoration),
         builder: (state) {
           state as SelectFormFieldState<T>;

           return Select<T>(
             variant: variant,
             options: options,
             optionsBuilder: optionsBuilder,
             selectedOptionBuilder: selectedOptionBuilder,
             focusNode: state.focusNode,
             placeholder: placeholder,
             value: state.value,
             onChanged: state.didChange,
             enabled: state.enabled,
             closeOnTapOutside: closeOnTapOutside,
             anchor: anchor,
             minWidth: minWidth,
             maxWidth: maxWidth,
             maxHeight: maxHeight,
             decoration: state.decoration,
             trailing: trailing,
             padding: padding,
             optionsPadding: optionsPadding,
             showScrollToTopChevron: showScrollToTopChevron,
             showScrollToBottomChevron: showScrollToBottomChevron,
             scrollController: scrollController,
             filter: filter,
             onSearchChanged: onSearchChanged,
             searchDivider: searchDivider,
             searchInputLeading: searchInputLeading,
             searchPlaceholder: searchPlaceholder,
             searchPadding: searchPadding,
             search: search,
             clearSearchOnClose: clearSearchOnClose,
             controller: controller,
             header: header,
             footer: footer,
             allowDeselection: allowDeselection,
             closeOnSelect: closeOnSelect,
             itemCount: itemCount,
             shrinkWrap: shrinkWrap,
             ensureSelectedVisible: ensureSelectedVisible,
             searchFocusNode: searchFocusNode,
             onSearchSubmitted: onSearchSubmitted,
             onTap: onTap,
           );
         },
       );

  /// Creates a select form field with a search input, like
  /// [Select.withSearch].
  SelectFormField.withSearch({
    super.id,
    super.key,
    super.onSaved,
    super.label,
    super.error,
    super.description,
    super.onChanged,
    super.forceErrorText,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    super.initialValue,
    super.focusNode,
    super.validator,
    SelectedOptionBuilder<T>? selectedOptionBuilder,
    Iterable<Widget>? options,

    /// The builder for the options of the [Select].
    Widget? Function(BuildContext, int)? optionsBuilder,
    ValueChanged<String>? onSearchChanged,
    Widget? placeholder,
    bool closeOnTapOutside = true,
    double? minWidth,
    double? maxWidth,
    double? maxHeight,
    FinesseDecoration? decoration,
    Widget? trailing,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? optionsPadding,
    bool? showScrollToTopChevron,
    bool? showScrollToBottomChevron,
    ScrollController? scrollController,
    AnchorBase? anchor,

    /// {@macro Popover.filter}
    ImageFilter? filter,
    Widget? searchDivider,
    Widget? searchInputLeading,
    Widget? searchPlaceholder,
    EdgeInsetsGeometry? searchPadding,
    Widget? search,
    bool? clearSearchOnClose,
    PopoverController? controller,

    /// {@macro Select.header}
    Widget? header,

    /// {@macro Select.footer}
    Widget? footer,
    bool allowDeselection = false,
    bool closeOnSelect = true,

    /// {@macro Select.itemCount}
    int? itemCount,

    /// {@macro Select.shrinkWrap}
    bool? shrinkWrap,

    /// {@macro Select.ensureSelectedVisible}
    bool? ensureSelectedVisible,

    /// {@macro Select.searchFocusNode}
    FocusNode? searchFocusNode,

    /// {@macro Select.onSearchSubmitted}
    ValueChanged<String>? onSearchSubmitted,

    /// {@macro Select.onTap}
    VoidCallback? onTap,
  }) : super(
         decorationBuilder: (context) =>
             (Theme.of(context).selectTheme.decoration ??
                     const FinesseDecoration())
                 .merge(decoration),
         builder: (state) {
           state as SelectFormFieldState<T>;

           return Select<T>.withSearch(
             options: options,
             allowDeselection: allowDeselection,
             optionsBuilder: optionsBuilder,
             selectedOptionBuilder: selectedOptionBuilder,
             focusNode: state.focusNode,
             placeholder: placeholder,
             value: state.value,
             onChanged: state.didChange,
             enabled: state.enabled,
             closeOnTapOutside: closeOnTapOutside,
             anchor: anchor,
             minWidth: minWidth,
             maxWidth: maxWidth,
             maxHeight: maxHeight,
             decoration: state.decoration,
             trailing: trailing,
             padding: padding,
             optionsPadding: optionsPadding,
             showScrollToTopChevron: showScrollToTopChevron,
             showScrollToBottomChevron: showScrollToBottomChevron,
             scrollController: scrollController,
             filter: filter,
             onSearchChanged: onSearchChanged,
             searchDivider: searchDivider,
             searchInputLeading: searchInputLeading,
             searchPlaceholder: searchPlaceholder,
             searchPadding: searchPadding,
             search: search,
             clearSearchOnClose: clearSearchOnClose,
             controller: controller,
             header: header,
             footer: footer,
             closeOnSelect: closeOnSelect,
             itemCount: itemCount,
             shrinkWrap: shrinkWrap,
             ensureSelectedVisible: ensureSelectedVisible,
             searchFocusNode: searchFocusNode,
             onSearchSubmitted: onSearchSubmitted,
             onTap: onTap,
           );
         },
       );

  @override
  FinesseFormFieldState<SelectFormField<T>, T> createState() =>
      SelectFormFieldState<T>();
}

/// The state of a [SelectFormField].
class SelectFormFieldState<T>
    extends FinesseFormFieldState<SelectFormField<T>, T> {}

/// A multiple-choice [Select] that takes part in a `FinesseForm`, with a
/// label, a description and validation. Its value is the set of selected
/// options.
class SelectMultipleFormField<T> extends FinesseFormField<Set<T>> {
  /// Creates a multiple select form field, like [Select.multiple].
  ///
  /// [variant] is [SelectVariant.multiple], the default, or
  /// [SelectVariant.multipleWithSearch];
  /// [SelectMultipleFormField.withSearch] is the shortcut for the second.
  SelectMultipleFormField({
    super.id,
    super.key,
    super.onSaved,
    super.label,
    super.error,
    super.description,
    super.onChanged,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    super.initialValue,
    super.focusNode,
    super.validator,
    super.forceErrorText,

    /// {@macro Select.variant}
    SelectVariant variant = SelectVariant.multiple,

    /// {@macro Select.selectedOptionsBuilder}
    SelectedOptionBuilder<List<T>>? selectedOptionsBuilder,

    /// {@macro Select.options}
    Iterable<Widget>? options,

    /// The builder for the options of the [Select].
    Widget? Function(BuildContext, int)? optionsBuilder,

    /// {@macro Select.onSearchChanged}
    ValueChanged<String>? onSearchChanged,

    /// {@macro Select.placeholder}
    Widget? placeholder,

    /// {@macro Select.closeOnTapOutside}
    bool closeOnTapOutside = true,

    /// {@macro Select.minWidth}
    double? minWidth,

    /// {@macro Select.maxWidth}
    double? maxWidth,

    /// {@macro Select.maxHeight}
    double? maxHeight,

    /// {@macro Select.decoration}
    FinesseDecoration? decoration,

    /// {@macro Select.trailing}
    Widget? trailing,

    /// {@macro Select.padding}
    EdgeInsetsGeometry? padding,

    /// {@macro Select.optionsPadding}
    EdgeInsetsGeometry? optionsPadding,

    /// {@macro Select.showScrollToTopChevron}
    bool? showScrollToTopChevron,

    /// {@macro Select.showScrollToBottomChevron}
    bool? showScrollToBottomChevron,

    /// {@macro Select.scrollController}
    ScrollController? scrollController,

    /// {@macro Select.anchor}
    AnchorBase? anchor,

    /// {@macro Popover.filter}
    ImageFilter? filter,

    /// {@macro Select.searchDivider}
    Widget? searchDivider,

    /// {@macro Select.searchInputLeading}
    Widget? searchInputLeading,

    /// {@macro Select.searchPlaceholder}
    Widget? searchPlaceholder,

    /// {@macro Select.searchPadding}
    EdgeInsetsGeometry? searchPadding,

    /// {@macro Select.search}
    Widget? search,

    /// {@macro Select.clearSearchOnClose}
    bool? clearSearchOnClose,

    /// {@macro Select.controller}
    PopoverController? controller,

    /// {@macro Select.header}
    Widget? header,

    /// {@macro Select.footer}
    Widget? footer,

    /// {@macro Select.allowDeselection}
    bool allowDeselection = true,

    /// {@macro Select.closeOnSelect}
    bool closeOnSelect = true,

    /// {@macro Select.ensureSelectedVisible}
    bool? ensureSelectedVisible,

    /// {@macro Select.searchFocusNode}
    FocusNode? searchFocusNode,

    /// {@macro Select.onSearchSubmitted}
    ValueChanged<String>? onSearchSubmitted,

    /// {@macro Select.onTap}
    VoidCallback? onTap,
  }) : assert(
         variant == SelectVariant.multiple ||
             variant == SelectVariant.multipleWithSearch,
         '''The variant is not supported. Use multiple or multipleWithSearch or use SelectFormField instead.''',
       ),
       super(
         decorationBuilder: (context) =>
             (Theme.of(context).selectTheme.decoration ??
                     const FinesseDecoration())
                 .merge(decoration),
         builder: (state) {
           state as SelectMultipleFormFieldState<T>;

           return Select<T>.multiple(
             variant: variant,
             options: options,
             optionsBuilder: optionsBuilder,
             selectedOptionsBuilder: selectedOptionsBuilder,
             values: state.value ?? const {},
             onChanged: state.didChange,
             focusNode: state.focusNode,
             placeholder: placeholder,
             enabled: state.enabled,
             closeOnTapOutside: closeOnTapOutside,
             anchor: anchor,
             minWidth: minWidth,
             maxWidth: maxWidth,
             maxHeight: maxHeight,
             decoration: state.decoration,
             trailing: trailing,
             padding: padding,
             optionsPadding: optionsPadding,
             showScrollToTopChevron: showScrollToTopChevron,
             showScrollToBottomChevron: showScrollToBottomChevron,
             scrollController: scrollController,
             filter: filter,
             onSearchChanged: onSearchChanged,
             searchDivider: searchDivider,
             searchInputLeading: searchInputLeading,
             searchPlaceholder: searchPlaceholder,
             searchPadding: searchPadding,
             search: search,
             clearSearchOnClose: clearSearchOnClose,
             controller: controller,
             header: header,
             footer: footer,
             allowDeselection: allowDeselection,
             closeOnSelect: closeOnSelect,
             ensureSelectedVisible: ensureSelectedVisible,
             searchFocusNode: searchFocusNode,
             onSearchSubmitted: onSearchSubmitted,
             onTap: onTap,
           );
         },
       );

  /// Creates a multiple select form field with a search input, like
  /// [Select.multipleWithSearch].
  SelectMultipleFormField.withSearch({
    super.id,
    super.key,
    super.onSaved,
    super.label,
    super.error,
    super.description,
    super.onChanged,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    super.initialValue,
    super.focusNode,
    super.validator,
    super.forceErrorText,
    SelectedOptionBuilder<List<T>>? selectedOptionsBuilder,
    Iterable<Widget>? options,

    /// The builder for the options of the [Select].
    Widget? Function(BuildContext, int)? optionsBuilder,
    ValueChanged<String>? onSearchChanged,
    Widget? placeholder,
    bool closeOnTapOutside = true,
    double? minWidth,
    double? maxWidth,
    double? maxHeight,
    FinesseDecoration? decoration,
    Widget? trailing,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? optionsPadding,
    bool? showScrollToTopChevron,
    bool? showScrollToBottomChevron,
    ScrollController? scrollController,
    AnchorBase? anchor,

    /// {@macro Popover.filter}
    ImageFilter? filter,
    Widget? searchDivider,
    Widget? searchInputLeading,
    Widget? searchPlaceholder,
    EdgeInsetsGeometry? searchPadding,
    Widget? search,
    bool? clearSearchOnClose,
    PopoverController? controller,

    /// {@macro Select.header}
    Widget? header,

    /// {@macro Select.footer}
    Widget? footer,
    bool closeOnSelect = true,

    /// {@macro Select.allowDeselection}
    bool allowDeselection = true,

    /// {@macro Select.ensureSelectedVisible}
    bool? ensureSelectedVisible,

    /// {@macro Select.searchFocusNode}
    FocusNode? searchFocusNode,

    /// {@macro Select.onSearchSubmitted}
    ValueChanged<String>? onSearchSubmitted,

    /// {@macro Select.onTap}
    VoidCallback? onTap,
  }) : super(
         decorationBuilder: (context) =>
             (Theme.of(context).selectTheme.decoration ??
                     const FinesseDecoration())
                 .merge(decoration),
         builder: (state) {
           state as SelectMultipleFormFieldState<T>;

           return Select<T>.multipleWithSearch(
             options: options,
             optionsBuilder: optionsBuilder,
             selectedOptionsBuilder: selectedOptionsBuilder,
             values: state.value ?? const {},
             onChanged: state.didChange,
             focusNode: state.focusNode,
             placeholder: placeholder,
             enabled: state.enabled,
             closeOnTapOutside: closeOnTapOutside,
             anchor: anchor,
             minWidth: minWidth,
             maxWidth: maxWidth,
             maxHeight: maxHeight,
             decoration: state.decoration,
             trailing: trailing,
             padding: padding,
             optionsPadding: optionsPadding,
             showScrollToTopChevron: showScrollToTopChevron,
             showScrollToBottomChevron: showScrollToBottomChevron,
             scrollController: scrollController,
             filter: filter,
             onSearchChanged: onSearchChanged,
             searchDivider: searchDivider,
             searchInputLeading: searchInputLeading,
             searchPlaceholder: searchPlaceholder,
             searchPadding: searchPadding,
             search: search,
             clearSearchOnClose: clearSearchOnClose,
             controller: controller,
             header: header,
             footer: footer,
             closeOnSelect: closeOnSelect,
             allowDeselection: allowDeselection,
             ensureSelectedVisible: ensureSelectedVisible,
             searchFocusNode: searchFocusNode,
             onSearchSubmitted: onSearchSubmitted,
             onTap: onTap,
           );
         },
       );

  @override
  FinesseFormFieldState<SelectMultipleFormField<T>, Set<T>> createState() =>
      SelectMultipleFormFieldState<T>();
}

/// The state of a [SelectMultipleFormField].
class SelectMultipleFormFieldState<T>
    extends FinesseFormFieldState<SelectMultipleFormField<T>, Set<T>> {}
