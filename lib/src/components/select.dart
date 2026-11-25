import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/disabled.dart';
import 'package:finesse/src/components/divider.dart';
import 'package:finesse/src/components/picker.dart';
import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/components/sheet.dart';
import 'package:finesse/src/components/text_field.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/raw_components/focusable.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/components/layout.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/arrow_key_focus.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/dismiss_shortcut.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:finesse/src/utils/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Builder for the selected option widget in [Select].
typedef SelectedOptionBuilder<T> =
    Widget Function(
      BuildContext context,
      T value,
    );

/// Defines the different variants of the [Select] widget.
enum SelectVariant {
  /// Selects one option. Used by [Select.new].
  primary,

  /// Selects one option and shows a search field. Used by
  /// [Select.withSearch].
  search,

  /// Selects many options. Used by [Select.multiple].
  multiple,

  /// Selects many options and shows a search field. Used by
  /// [Select.multipleWithSearch].
  multipleWithSearch,
}

/// A customizable select dropdown widget with various variants and options.
///
/// It supports single and multiple selection, search functionality, and
/// extensive customization through various properties.
class Select<T> extends StatefulWidget {
  /// Creates a select that holds one value.
  ///
  /// [variant] is [SelectVariant.primary], the default, or
  /// [SelectVariant.search], which adds a search field and needs [search]
  /// or [onSearchChanged]; [Select.withSearch] is the shortcut for it. For
  /// several values, use [Select.multiple].
  const Select({
    super.key,
    this.variant = SelectVariant.primary,
    this.selectedOptionBuilder,
    this.options,
    this.optionsBuilder,
    this.controller,
    this.enabled = true,
    this.presentation = PickerPresentation.auto,
    this.title,
    this.placeholder,
    this.placeholderStyle,
    this.value,
    this.initialValue,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.closeOnTapOutside = true,
    this.minWidth,
    this.maxWidth,
    this.maxHeight,
    this.minHeight,
    this.decoration,
    this.trailing,
    this.padding,
    this.optionsPadding,
    this.showScrollToBottomChevron,
    this.showScrollToTopChevron,
    this.scrollController,
    this.anchor,
    this.effects,
    this.shadows,
    this.filter,
    this.header,
    this.footer,
    this.closeOnSelect = true,
    this.allowDeselection = false,
    this.groupId,
    this.itemCount,
    this.shrinkWrap,
    this.popoverReverseDuration,
    this.ensureSelectedVisible,
    this.onPressed,
    this.onSearchChanged,
    this.searchDivider,
    this.searchInputLeading,
    this.searchPlaceholder,
    this.searchPadding,
    this.search,
    this.clearSearchOnClose,
    this.searchFocusNode,
    this.onSearchSubmitted,
  }) : values = null,
       initialValues = const {},
       onValuesChanged = null,
       selectedOptionsBuilder = null,
       assert(
         variant == SelectVariant.primary || variant == SelectVariant.search,
         'Select() holds one value: use Select.multiple for the multiple '
         'variants',
       ),
       assert(
         options != null || optionsBuilder != null,
         'Either options or optionsBuilder must be provided',
       ),
       assert(
         variant != SelectVariant.search ||
             search != null ||
             onSearchChanged != null,
         'Either search or onSearchChanged must be provided for the search '
         'variant',
       );

  /// Creates a [Select] with the search variant.
  const Select.withSearch({
    super.key,
    this.options,
    this.optionsBuilder,
    this.selectedOptionBuilder,
    this.onSearchChanged,
    this.onChanged,
    this.controller,
    this.searchDivider,
    this.searchInputLeading,
    this.searchPlaceholder,
    this.searchPadding,
    this.search,
    this.clearSearchOnClose,
    this.enabled = true,
    this.presentation = PickerPresentation.auto,
    this.title,
    this.placeholder,
    this.placeholderStyle,
    this.value,
    this.initialValue,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.closeOnTapOutside = true,
    this.minWidth,
    this.maxWidth,
    this.maxHeight,
    this.minHeight,
    this.decoration,
    this.trailing,
    this.padding,
    this.optionsPadding,
    this.showScrollToBottomChevron,
    this.showScrollToTopChevron,
    this.scrollController,
    this.anchor,
    this.effects,
    this.shadows,
    this.filter,
    this.header,
    this.footer,
    this.closeOnSelect = true,
    this.allowDeselection = false,
    this.groupId,
    this.itemCount,
    this.shrinkWrap,
    this.popoverReverseDuration,
    this.ensureSelectedVisible,
    this.searchFocusNode,
    this.onSearchSubmitted,
    this.onPressed,
  }) : variant = SelectVariant.search,
       selectedOptionsBuilder = null,
       onValuesChanged = null,
       values = null,
       initialValues = const {},
       assert(
         options != null || optionsBuilder != null,
         'Either options or optionsBuilder must be provided',
       ),
       assert(
         search != null || onSearchChanged != null,
         'Either search or onSearchChanged must be provided',
       );

  /// Creates a select that holds several values.
  ///
  /// [variant] is [SelectVariant.multiple], the default, or
  /// [SelectVariant.multipleWithSearch], which adds a search field and
  /// needs [search] or [onSearchChanged]; [Select.multipleWithSearch] is the
  /// shortcut for it.
  const Select.multiple({
    super.key,
    this.variant = SelectVariant.multiple,
    this.options,
    this.optionsBuilder,
    this.selectedOptionsBuilder,
    this.controller,
    this.enabled = true,
    this.presentation = PickerPresentation.auto,
    this.title,
    this.placeholder,
    this.placeholderStyle,
    this.values,
    this.initialValues = const {},
    ValueChanged<Set<T>>? onChanged,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.closeOnTapOutside = true,
    this.minWidth,
    this.maxWidth,
    this.maxHeight,
    this.minHeight,
    this.decoration,
    this.trailing,
    this.padding,
    this.optionsPadding,
    this.showScrollToBottomChevron,
    this.showScrollToTopChevron,
    this.scrollController,
    this.anchor,
    this.effects,
    this.shadows,
    this.filter,
    this.header,
    this.footer,
    this.allowDeselection = true,
    this.closeOnSelect = true,
    this.groupId,
    this.itemCount,
    this.shrinkWrap,
    this.popoverReverseDuration,
    this.ensureSelectedVisible,
    this.onPressed,
    this.onSearchChanged,
    this.searchDivider,
    this.searchInputLeading,
    this.searchPlaceholder,
    this.searchPadding,
    this.search,
    this.clearSearchOnClose,
    this.searchFocusNode,
    this.onSearchSubmitted,
  }) : value = null,
       initialValue = null,
       selectedOptionBuilder = null,
       onChanged = null,
       onValuesChanged = onChanged,
       assert(
         variant == SelectVariant.multiple ||
             variant == SelectVariant.multipleWithSearch,
         'Select.multiple holds several values: use Select() for the single '
         'variants',
       ),
       assert(
         options != null || optionsBuilder != null,
         'Either options or optionsBuilder must be provided',
       ),
       assert(
         variant != SelectVariant.multipleWithSearch ||
             search != null ||
             onSearchChanged != null,
         'Either search or onSearchChanged must be provided for the search '
         'variant',
       );

  /// Creates a [Select] with the multiple select and search variant.
  const Select.multipleWithSearch({
    super.key,
    this.options,
    this.optionsBuilder,
    this.onSearchChanged,
    this.selectedOptionsBuilder,
    ValueChanged<Set<T>>? onChanged,
    this.controller,
    this.searchDivider,
    this.searchInputLeading,
    this.searchPlaceholder,
    this.searchPadding,
    this.search,
    this.clearSearchOnClose,
    this.enabled = true,
    this.presentation = PickerPresentation.auto,
    this.title,
    this.placeholder,
    this.placeholderStyle,
    this.values,
    this.initialValues = const {},
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.closeOnTapOutside = true,
    this.minWidth,
    this.maxWidth,
    this.maxHeight,
    this.minHeight,
    this.decoration,
    this.trailing,
    this.padding,
    this.optionsPadding,
    this.showScrollToBottomChevron,
    this.showScrollToTopChevron,
    this.scrollController,
    this.anchor,
    this.effects,
    this.shadows,
    this.filter,
    this.header,
    this.footer,
    this.allowDeselection = true,
    this.closeOnSelect = true,
    this.groupId,
    this.itemCount,
    this.shrinkWrap,
    this.popoverReverseDuration,
    this.ensureSelectedVisible,
    this.searchFocusNode,
    this.onSearchSubmitted,
    this.onPressed,
  }) : variant = SelectVariant.multipleWithSearch,
       selectedOptionBuilder = null,
       onChanged = null,
       onValuesChanged = onChanged,
       value = null,
       initialValue = null,
       assert(
         options != null || optionsBuilder != null,
         'Either options or optionsBuilder must be provided',
       ),
       assert(
         search != null || onSearchChanged != null,
         'Either search or onSearchChanged must be provided',
       );

  /// {@template Select.value}
  /// The selected value of a single select, held by the parent: the select
  /// shows it and reports a choice through [onChanged] without changing by
  /// itself. Leave it null and give [initialValue] to let the select keep
  /// its own state.
  /// {@endtemplate}
  final T? value;

  /// {@template Select.values}
  /// The selected values of a multiple select, held by the parent. Leave
  /// them null and give [initialValues] to let the select keep its own
  /// state.
  /// {@endtemplate}
  final Set<T>? values;

  /// {@template Select.presentation}
  /// Whether the options open in a popover or in a bottom sheet.
  ///
  /// With [PickerPresentation.auto] the searchable and the multiple
  /// variants open a sheet on a phone — the search pinned at its top, rows
  /// at touch height, Done for a multiple choice — while a plain single
  /// select stays a popover everywhere, as a menu does.
  /// {@endtemplate}
  final PickerPresentation presentation;

  /// {@template Select.title}
  /// The title of the sheet. Defaults to the [placeholder].
  /// {@endtemplate}
  final Widget? title;

  /// {@template Select.onChanged}
  /// The callback that is called when the value of the [Select] changes.
  ///
  /// This is used for single selection [Select] variants.
  /// {@endtemplate}
  final ValueChanged<T?>? onChanged;

  /// {@template Select.onValuesChanged}
  /// The callback that is called when the values of the [Select] changes.
  /// Called only the variant is [Select.multiple].
  /// {@endtemplate}
  final ValueChanged<Set<T>>? onValuesChanged;

  /// {@template Select.allowDeselection}
  /// Whether the [Select] allows deselection, defaults to
  /// `false`.
  /// {@endtemplate}
  final bool allowDeselection;

  /// {@template Select.enabled}
  /// Whether the [Select] is enabled.
  ///
  /// When disabled, the select cannot be interacted with and visually appears
  /// disabled. Defaults to `true`.
  /// {@endtemplate}
  final bool enabled;

  /// {@template Select.initialValue}
  /// The initially selected value for single select [Select] variants.
  ///
  /// Defaults to `null`.
  /// {@endtemplate}
  final T? initialValue;

  /// {@template Select.initialValues}
  /// The initial values of the [Select], defaults to `[]`.
  /// {@endtemplate}
  final Set<T> initialValues;

  /// {@template Select.placeholder}
  /// The widget to display as a placeholder when no option is selected.
  ///
  /// Typically a [Text] widget prompting the user to make a selection.
  /// {@endtemplate}
  final Widget? placeholder;

  /// {@template Select.placeholderStyle}
  /// The text style to apply by default to the placeholder widget.
  /// If the placeholder contains a [Text] widget, this style will be merged
  /// with its existing style.
  /// {@endtemplate}
  final TextStyle? placeholderStyle;

  /// {@template Select.selectedOptionBuilder}
  /// Builds what the trigger shows for the selected value of a single
  /// select.
  ///
  /// Optional: without it the trigger shows the [SelectOption.label] of
  /// the selected option (found among [options], or once its option has
  /// been built), and failing that the value's `toString()`.
  /// {@endtemplate}
  final SelectedOptionBuilder<T>? selectedOptionBuilder;

  /// {@template Select.selectedOptionsBuilder}
  /// Builds what the trigger shows for the selected values of a multiple
  /// select.
  ///
  /// Optional: without it the trigger shows their labels (see
  /// [selectedOptionBuilder]), separated by commas.
  /// {@endtemplate}
  final SelectedOptionBuilder<List<T>>? selectedOptionsBuilder;

  /// {@template Select.options}
  /// An iterable of widgets representing the selectable options.
  ///
  /// Use this for a small, static set of options. For larger or dynamic lists,
  /// consider using [optionsBuilder] for better performance.
  ///
  /// Each widget in this iterable should typically be a [SelectOption] widget.
  /// {@endtemplate}
  final Iterable<Widget>? options;

  /// {@template Select.optionsBuilder}
  /// A builder function for creating options widgets on demand.
  ///
  /// This is efficient for large or dynamically generated lists of options, as
  /// it only builds options that are currently visible.
  ///
  /// The builder is called with the [BuildContext] and the index of the option
  /// to build. It should return a widget, typically a [SelectOption].
  ///
  /// NOTE: By using this builder, you must handle the width of the options
  /// yourself, because no intrinsic width calculation is performed.
  /// {@endtemplate}
  final Widget? Function(BuildContext, int)? optionsBuilder;

  /// {@template Select.focusNode}
  /// The focus node to control the focus state of the [Select].
  ///
  /// If null, a default [FocusNode] will be created internally.
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// {@template Widget.autofocus}
  /// Whether this widget should be focused when first shown.
  /// Defaults to `false`.
  /// {@endtemplate}
  final bool autofocus;

  /// {@template Widget.onFocusChange}
  /// Called when the focus state of this widget changes.
  /// {@endtemplate}
  final ValueChanged<bool>? onFocusChange;

  /// {@template Select.closeOnTapOutside}
  /// Whether to close the select popover when tapping outside of it.
  ///
  /// Defaults to `true`.
  /// {@endtemplate}
  final bool closeOnTapOutside;

  /// {@template Select.minWidth}
  /// The minimum width of the select input and popover.
  ///
  /// Defaults to `max(Select.defaultMinWidth, constraints.minWidth)`.
  /// The actual minimum width will be the maximum of this value and the
  /// intrinsic minimum width of the widget.
  /// {@endtemplate}
  final double? minWidth;

  /// {@template Select.maxWidth}
  /// The maximum width of the select input and popover.
  ///
  /// Defaults to `double.infinity`.
  /// {@endtemplate}
  final double? maxWidth;

  /// {@template Select.maxHeight}
  /// The maximum height of the select popover.
  ///
  /// Defaults to [Select.defaultMaxHeight].
  /// {@endtemplate}
  final double? maxHeight;

  /// {@template Select.minHeight}
  /// The minimum height of the select trigger, border included, so it lines
  /// up with the text field and button heights of the current style.
  ///
  /// Defaults to the theme's value, which the built-in styles pin to their
  /// field height.
  /// {@endtemplate}
  final double? minHeight;

  /// {@template Select.decoration}
  /// The visual decoration of the select input.
  ///
  /// Uses [FinesseDecoration] to define borders, colors, and more.
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template Select.trailing}
  /// The widget to display at the end of the select input, typically an icon.
  ///
  /// Defaults to a chevron-down icon.
  /// {@endtemplate}
  final Widget? trailing;

  /// {@template Select.padding}
  /// The padding around the content of the select input.
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 12, vertical: 8)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Select.optionsPadding}
  /// The padding around the options within the popover.
  ///
  /// Defaults to `EdgeInsets.all(4)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? optionsPadding;

  /// {@template Select.showScrollToTopChevron}
  /// Whether to display a chevron icon at the top of the popover when
  /// scrollable. Defaults to `true`.
  /// {@endtemplate}
  final bool? showScrollToTopChevron;

  /// {@template Select.showScrollToBottomChevron}
  /// Whether to display a chevron icon at the bottom of the popover when
  /// scrollable. Defaults to `true`.
  /// {@endtemplate}
  final bool? showScrollToBottomChevron;

  /// {@template Select.scrollController}
  /// The scroll controller for the options list in the popover.
  ///
  /// If null, a default [ScrollController] will be created internally.
  /// {@endtemplate}
  final ScrollController? scrollController;

  /// {@template Select.anchor}
  /// The anchor configuration for positioning the popover relative to the
  /// select input.
  ///
  /// Defaults to `AnchorAuto(offset: Offset(0, 4))`
  /// {@endtemplate}
  final AnchorBase? anchor;

  /// {@template Select.variant}
  /// The variant of the [Select] widget, determining its behavior and
  /// appearance.
  ///
  /// See [SelectVariant] for available variants. [Select.new] takes the two
  /// single ones and [Select.multiple] the two multiple ones.
  /// {@endtemplate}
  final SelectVariant variant;

  /// {@template Select.onSearchChanged}
  /// Callback function invoked when the search query changes in search-enabled
  /// [Select] variants.
  ///
  /// Provides the current search string as an argument.
  /// {@endtemplate}
  final ValueChanged<String>? onSearchChanged;

  /// {@template Select.searchDivider}
  /// Widget to display as a divider between the search input and the options
  /// list
  /// in search-enabled [Select] variants.
  ///
  /// Defaults to a Divider with height 1.
  /// {@endtemplate}
  final Widget? searchDivider;

  /// {@template Select.searchInputLeading}
  /// Widget to display at the leading edge of the search input field.
  ///
  /// Typically an icon, like a search icon.
  /// {@endtemplate}
  final Widget? searchInputLeading;

  /// {@template Select.searchPlaceholder}
  /// Placeholder text to display in the search input field when no query is
  /// entered.
  /// {@endtemplate}
  final Widget? searchPlaceholder;

  /// {@template Select.searchPadding}
  /// Padding around the search input field.
  ///
  /// Defaults to `EdgeInsets.all(12)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? searchPadding;

  /// {@template Select.search}
  /// A completely customizable search input widget.
  ///
  /// If provided, this widget will be used instead of the default [TextField]
  /// for search functionality.
  /// {@endtemplate}
  final Widget? search;

  /// {@template Select.clearSearchOnClose}
  /// Whether to clear the search input when the popover is closed.
  ///
  /// Defaults to `true`. Can be overridden by `ThemeData.selectTheme`.
  /// {@endtemplate}
  final bool? clearSearchOnClose;

  /// {@macro Popover.effects}
  final List<Effect<dynamic>>? effects;

  /// {@macro Popover.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Popover.filter}
  final ImageFilter? filter;

  /// {@template Select.controller}
  /// Opens and closes the options from outside, in a popover or a sheet.
  ///
  /// If null, a [PopoverController] is created internally.
  /// {@endtemplate}
  final PopoverController? controller;

  /// {@template Select.header}
  /// Widget to display at the top of the popover, above the options list.
  ///
  /// Useful for titles or additional information.
  /// {@endtemplate}
  final Widget? header;

  /// {@template Select.footer}
  /// Widget to display at the bottom of the popover, below the options list.
  ///
  /// Useful for actions or additional information.
  /// {@endtemplate}
  final Widget? footer;

  /// {@template Select.closeOnSelect}
  /// Whether to automatically close the popover when an option is selected.
  ///
  /// Defaults to `true`.
  /// {@endtemplate}
  final bool closeOnSelect;

  /// {@template Select.groupId}
  /// Group ID for the popover, used for managing popover visibility in groups.
  ///
  /// See [Popover.groupId] for more details.
  /// {@endtemplate}
  final Object? groupId;

  /// {@template Select.itemCount}
  /// The number of items to display when using [optionsBuilder].
  ///
  /// Required when using [optionsBuilder] to determine the scrollable extent.
  /// {@endtemplate}
  final int? itemCount;

  /// {@template Select.shrinkWrap}
  /// Whether the options list should shrink-wrap its content.
  ///
  /// Defaults to `false`. Set to `true` for smaller lists to reduce popover
  /// size.
  /// {@endtemplate}
  final bool? shrinkWrap;

  /// {@template Select.popoverReverseDuration}
  /// The duration of the popover's exit animation.
  ///
  /// Defaults to [Duration.zero ].
  /// {@endtemplate}
  final Duration? popoverReverseDuration;

  /// {@template Select.ensureSelectedVisible}
  /// Whether to automatically scroll the options list to ensure the selected
  /// option is visible when the popover opens.
  /// Defaults to true if the variant is [SelectVariant.primary] or
  /// [SelectVariant.search], false otherwise.
  /// {@endtemplate}
  final bool? ensureSelectedVisible;

  /// {@template Select.searchFocusNode}
  /// Focus node for the search input field in search-enabled variants.
  /// If null, a default [FocusNode] will be created internally.
  /// {@endtemplate}
  final FocusNode? searchFocusNode;

  /// {@template Select.onSearchSubmitted}
  /// Callback function invoked when the search query is submitted in
  /// search-enabled
  /// [Select] variants.
  /// Provides the current search string as an argument.
  /// {@endtemplate}
  final ValueChanged<String>? onSearchSubmitted;

  /// {@template Select.onPressed}
  /// Callback function invoked when the select input is pressed.
  ///
  /// If provided, this callback will be called instead of toggling the
  /// popover.
  /// {@endtemplate}
  final VoidCallback? onPressed;

  /// The minimum width of the trigger and the options when none is set:
  /// shadcn's `min-w-32`.
  static const double defaultMinWidth = 128;

  /// The maximum height of the options when none is set: shadcn's `max-h-96`.
  static const double defaultMaxHeight = 384;

  @override
  SelectState<T> createState() => SelectState();
}

/// The state of a [Select].
class SelectState<T> extends State<Select<T>> {
  /// The focus node created when [Select.focusNode] is null.
  @protected
  FocusNode? internalFocusNode;
  FocusNode? _internalSearchFocusNode;

  /// The selected values. A single select holds at most one.
  late final _selection = _Selection<T>({
    ...?_given,
    if (_given == null) ...{
      if (widget.initialValue is T) widget.initialValue as T,
      ...widget.initialValues,
    },
  });

  /// The selection the parent holds, or null when the select keeps its
  /// own.
  Set<T>? get _given {
    final values = widget.values;
    if (values != null) return values;
    final value = widget.value;
    return value is T ? {value} : null;
  }

  /// The selected values.
  Set<T> get selection => _selection.value;

  /// The labels of the options built so far, by value: what the trigger
  /// shows when it is given no builder.
  final _labels = <T, String>{};

  /// The label of the option for [value]: among [Select.options], or of an
  /// option that has been built; failing both, the value itself.
  String labelOf(T value) {
    final known = _labels[value];
    if (known != null) return known;
    for (final option in widget.options ?? const <Widget>[]) {
      if (option is SelectOption<T> &&
          option.value == value &&
          option.label != null) {
        return _labels[value] = option.label!;
      }
    }
    return '$value';
  }

  VoidCallback? _popoverControllerListener;

  PopoverController? _popoverController;

  /// The popover controller in use: [Select.controller], or an
  /// internal one when that is null.
  PopoverController get popoverController =>
      widget.controller ?? (_popoverController ??= PopoverController());

  VoidCallback? _scrollControllerListener;

  ScrollController? _scrollController;

  /// Whether the option list can scroll down, which shows the bottom chevron.
  @protected
  final showScrollToBottom = ValueNotifier(false);

  /// Whether the option list can scroll up, which shows the top chevron.
  @protected
  final showScrollToTop = ValueNotifier(false);

  /// Guards the post-frame callback that seeds [showScrollToTop] and
  /// [showScrollToBottom], so a rebuilt popover does not queue one per build.
  bool _scrollChevronSyncScheduled = false;

  /// Invalidation token for the chevron auto-scroll loop. Bumping it retires
  /// the running loop and any start still sitting in its opening delay.
  int _autoScrollToken = 0;

  /// Whether an auto-scroll loop currently owns [scrollController].
  ///
  /// Only one may run. A second `animateTo` on a scroll position disposes the
  /// first one's activity, and `DrivenScrollActivity.dispose` completes its
  /// future synchronously — so two loops cancel each other as microtasks with
  /// the offset never moving, and neither exit condition ever becomes true.
  /// Dart drains the whole microtask queue before returning to the embedder,
  /// so that chain freezes the app outright: no frames, no input, no resize.
  bool _autoScrolling = false;

  /// The focus node of the trigger: [Select.focusNode], or an internal one.
  FocusNode get focusNode => widget.focusNode ?? internalFocusNode!;

  /// The focus node of the search field: [Select.searchFocusNode], or an
  /// internal one.
  FocusNode get searchFocusNode =>
      widget.searchFocusNode ?? (_internalSearchFocusNode ??= FocusNode());

  /// The scroll controller of the option list: [Select.scrollController],
  /// or an internal one.
  ScrollController get scrollController =>
      widget.scrollController ?? _scrollController!;

  /// Whether to scroll the selected option into view when the popover opens.
  ///
  /// Uses [Select.ensureSelectedVisible] when set. Otherwise it is true
  /// for the single-selection variants and false for the multiple ones.
  bool get ensureSelectedVisible =>
      widget.ensureSelectedVisible ??
      (widget.variant == SelectVariant.primary ||
          widget.variant == SelectVariant.search);

  @override
  void initState() {
    super.initState();
    if (widget.scrollController == null) {
      _scrollController = ScrollController();
    }
    if (widget.focusNode == null) internalFocusNode = FocusNode();

    // react to the scroll position
    void scrollControllerListener() {
      if (!context.mounted) return;

      if (!scrollController.hasClients) return;
      showScrollToBottom.value =
          scrollController.offset < scrollController.position.maxScrollExtent;
      showScrollToTop.value = scrollController.offset > 0;
    }

    _scrollControllerListener = scrollControllerListener;
    scrollController.addListener(scrollControllerListener);

    if (isSearchVariant()) {
      void popoverListener() {
        if (!context.mounted) return;
        if (popoverController.isOpen) return;

        if (searchFocusNode.hasFocus) {
          searchFocusNode.unfocus();
        }
        final effectiveClearSearchOnClose =
            widget.clearSearchOnClose ??
            Theme.of(
              context,
              listen: false,
            ).selectTheme.clearSearchOnClose ??
            true;

        if (effectiveClearSearchOnClose) {
          widget.onSearchChanged?.call('');
        }
      }

      _popoverControllerListener = popoverListener;
      popoverController.addListener(popoverListener);
    }
  }

  /// Whether the variant shows a search field.
  bool isSearchVariant() {
    return widget.variant == SelectVariant.search ||
        widget.variant == SelectVariant.multipleWithSearch;
  }

  /// Opens or closes the popover, and focuses the search field when it opens.
  void desktopTogglePopover() {
    popoverController.toggle();
    if (popoverController.isOpen && isSearchVariant()) {
      searchFocusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(covariant Select<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    Set<T>? next;
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue is T) {
      next = {widget.initialValue as T};
    }
    if (widget.initialValues != oldWidget.initialValues) {
      next = {...widget.initialValues};
    }
    // What the parent holds comes last and wins; a value taken away is an
    // empty selection.
    if (widget.value != oldWidget.value) {
      next = {if (widget.value is T) widget.value as T};
    }
    if (!setEquals(widget.values, oldWidget.values) && widget.values != null) {
      next = {...widget.values!};
    }
    if (next != null && !setEquals(next, _selection.value)) {
      // This select's own subtree is being rebuilt with the new selection
      // as it is. A sheet is a route elsewhere in the tree and may not be
      // marked for a rebuild in the middle of this one: it hears after
      // the frame.
      _selection.replaceDuringBuild(next);
    }
  }

  @override
  void dispose() {
    stopAutoScroll();

    final popoverControllerListener = _popoverControllerListener;
    if (popoverControllerListener != null) {
      popoverController.removeListener(popoverControllerListener);
      _popoverControllerListener = null;
    }

    final scrollControllerListener = _scrollControllerListener;
    if (scrollControllerListener != null) {
      scrollController.removeListener(scrollControllerListener);
      _scrollControllerListener = null;
    }

    _internalSearchFocusNode?.dispose();
    _selection.dispose();
    _popoverController?.dispose();
    internalFocusNode?.dispose();
    _scrollController?.dispose();
    showScrollToBottom.dispose();
    showScrollToTop.dispose();
    super.dispose();
  }

  /// Starts scrolling the option list while a chevron is hovered.
  ///
  /// A no-op while a loop is already running, so hovering off and back on
  /// within the opening delay cannot leave two of them fighting over
  /// [scrollController]. See [_autoScrolling].
  void startAutoScroll({required bool toTop}) {
    if (_autoScrolling) return;
    _autoScrolling = true;
    final token = ++_autoScrollToken;
    unawaited(_autoScroll(toTop: toTop, token: token));
  }

  /// Retires the running loop, and any start still in its opening delay.
  void stopAutoScroll() => _autoScrollToken++;

  /// Whether the auto-scroll loop is running.
  @visibleForTesting
  bool get isAutoScrolling => _autoScrolling;

  Future<void> _autoScroll({required bool toTop, required int token}) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      while (mounted &&
          token == _autoScrollToken &&
          scrollController.hasClients) {
        final position = scrollController.position;
        final target = toTop
            ? max(position.pixels - 30, position.minScrollExtent)
            : min(position.pixels + 30, position.maxScrollExtent);
        // Already at the end: `animateTo` would resolve without moving.
        if (target == position.pixels) break;
        await scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 20),
          curve: Curves.easeInOutCubic,
        );
        // Yield to the event loop rather than only to the microtask queue.
        // `animateTo` resolves synchronously when its activity is cancelled,
        // and a loop that only ever awaits microtasks starves frames, input
        // and resize.
        await Future<void>.delayed(Duration.zero);
      }
    } finally {
      _autoScrolling = false;
    }
  }

  /// Selects [value], or removes it from the selection.
  ///
  /// Single-selection variants replace the selection. Multiple-selection
  /// variants add to it. A selected value is removed when
  /// [Select.allowDeselection] is true. Calls [Select.onChanged] or
  /// [Select.onValuesChanged] when the selection changes.
  void select(T value) {
    final isMultiSelection =
        widget.variant == SelectVariant.multiple ||
        widget.variant == SelectVariant.multipleWithSearch;

    final before = _selection.value;
    final next = isMultiSelection ? {...before} : <T>{};
    if (widget.allowDeselection && before.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }
    if (widget.closeOnSelect) {
      popoverController.close();
      focusNode.requestFocus();
    }
    if (setEquals(before, next)) return;
    // A select whose parent holds the selection waits to be handed it
    // back.
    if (_given == null) setState(() => _selection.value = next);
    if (isMultiSelection) {
      widget.onValuesChanged?.call(next);
    } else {
      widget.onChanged?.call(next.firstOrNull);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);

    final effectiveDecoration = theme.decoration
        .merge(theme.selectTheme.decoration)
        .merge(widget.decoration);

    final decorationHorizontalPadding =
        (effectiveDecoration.border?.padding?.horizontal ?? 0.0) +
        (effectiveDecoration.secondaryBorder?.padding?.horizontal ?? 0.0);

    final effectivePadding =
        widget.padding ??
        theme.selectTheme.padding ??
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    final effectiveShowScrollToTopChevron =
        widget.showScrollToTopChevron ??
        theme.selectTheme.showScrollToTopChevron ??
        true;

    final effectiveShowScrollToBottomChevron =
        widget.showScrollToBottomChevron ??
        theme.selectTheme.showScrollToBottomChevron ??
        true;

    final effectivePopoverReverseDuration =
        widget.popoverReverseDuration ??
        theme.selectTheme.popoverReverseDuration ??
        Duration.zero;

    final effectiveAnchor =
        widget.anchor ??
        theme.selectTheme.anchor ??
        const AnchorAuto(
          offset: Offset(0, 4),
          fallback: AnchorAuto(
            offset: Offset(0, -4),
            followerAnchor: Alignment.topCenter,
            targetAnchor: Alignment.topCenter,
          ),
        );

    final effectiveEffects = widget.effects ?? theme.selectTheme.effects;

    final effectiveShadows = widget.shadows ?? theme.selectTheme.shadows;

    final effectiveFilter = widget.filter ?? theme.selectTheme.filter;

    final isMultiSelect =
        widget.variant == SelectVariant.multiple ||
        widget.variant == SelectVariant.multipleWithSearch;

    // make effectiveText listen to controller changes
    final effectiveText = ListenableBuilder(
      listenable: _selection,
      builder: (context, child) {
        final Widget result;
        final TextStyle resultDefaultTextStyle;
        final selected = _selection.value;

        if (selected.isNotEmpty) {
          // The value shown in the trigger belongs to the *page*, not the
          // menu: `selectOptionTheme.selectedTextStyle` carries the menu
          // palette's highlight foreground, which is unreadable on the trigger
          // the moment menus are inverted or bold.
          resultDefaultTextStyle = theme.textTheme.muted.fallback(
            color: theme.colorScheme.foreground,
          );
          switch (isMultiSelect) {
            case true:
              result =
                  widget.selectedOptionsBuilder?.call(
                    context,
                    selected.toList(),
                  ) ??
                  Text(
                    selected.map(labelOf).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
            case false:
              result =
                  widget.selectedOptionBuilder?.call(
                    context,
                    selected.first,
                  ) ??
                  Text(
                    labelOf(selected.first),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
          }
        } else {
          assert(
            widget.placeholder != null,
            'placeholder must not be null when value is null',
          );
          resultDefaultTextStyle =
              widget.placeholderStyle ??
              theme.selectTheme.placeholderStyle ??
              theme.textTheme.muted.fallback(
                color: theme.colorScheme.foreground,
              );
          result = widget.placeholder!;
        }
        return DefaultTextStyle(style: resultDefaultTextStyle, child: result);
      },
    );

    // `cn-select-trigger-icon`: `text-muted-foreground size-4`.
    final effectiveTrailing =
        widget.trailing ??
        PhosphorIcon(
          PhosphorIconsRegular.caretDown,
          size: 16,
          color: theme.colorScheme.mutedForeground,
        );

    final effectiveMinWidth =
        widget.minWidth ?? theme.selectTheme.minWidth ?? Select.defaultMinWidth;
    final effectiveMaxWidth =
        widget.maxWidth ?? theme.selectTheme.maxWidth ?? double.infinity;
    final effectiveMaxHeight =
        widget.maxHeight ??
        theme.selectTheme.maxHeight ??
        Select.defaultMaxHeight;
    final effectiveMinHeight = widget.minHeight ?? theme.selectTheme.minHeight;
    final effectiveOptionsPadding =
        widget.optionsPadding ??
        theme.selectTheme.optionsPadding ??
        const EdgeInsets.all(4);

    // Everything rendered *inside* the options popover reads in the menu
    // palette, not the page's: an inverted menu keeps its own foreground.
    // The option rows' resting colour carries it.
    final menuForeground =
        theme.selectOptionTheme.textStyle?.color ??
        theme.colorScheme.popoverForeground;

    final search = switch (widget.variant) {
      SelectVariant.primary || SelectVariant.multiple => null,
      SelectVariant.search || SelectVariant.multipleWithSearch => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.search ??
              TextField(
                focusNode: searchFocusNode,
                leading: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PhosphorIcon(
                    PhosphorIconsRegular.magnifyingGlass,
                    size: 16,
                    color: menuForeground,
                  ),
                ),
                style: (theme.textFieldTheme.style ?? theme.textTheme.muted)
                    .copyWith(color: menuForeground),
                padding:
                    widget.searchPadding ??
                    theme.selectTheme.searchPadding ??
                    const EdgeInsets.all(12),
                placeholder: widget.searchPlaceholder,
                decoration: FinesseDecoration.none,
                onChanged: widget.onSearchChanged,
                onSubmitted: widget.onSearchSubmitted,
              ),
          widget.searchDivider ?? const Divider(margin: EdgeInsets.zero),
        ],
      ),
    };

    return ListenableBuilder(
      listenable: searchFocusNode,
      builder: (context, child) {
        return DismissShortcut(
          isActive: () => popoverController.isOpen,
          onDismiss: popoverController.close,
          child: CallbackShortcuts(
            bindings: searchFocusNode.hasFocus
                ? const {}
                : {
                    const SingleActivator(LogicalKeyboardKey.enter):
                        desktopTogglePopover,
                    const SingleActivator(LogicalKeyboardKey.space):
                        desktopTogglePopover,
                  },
            child: child!,
          ),
        );
      },
      child: FocusTraversalGroup(
        policy: WidgetOrderTraversalPolicy(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final calculatedMinWidth =
                max(effectiveMinWidth, constraints.minWidth) -
                decorationHorizontalPadding;

            final effectiveConstraints = BoxConstraints(
              minWidth: calculatedMinWidth,
              maxWidth: effectiveMaxWidth,
            );

            // Built lazily inside the `builder:` callback below rather than
            // here. This LayoutBuilder wraps the whole select — anchor
            // included — so it re-runs on every layout pass of the *closed*
            // select. `widget.options` is a lazy Iterable, so materialising it
            // eagerly meant constructing every option widget on each of those
            // passes. Calendar's year dropdown passes 201 options, each
            // building a DateFormat.
            Widget buildOptions({bool sheet = false}) {
              if (widget.options != null) {
                return SingleChildScrollView(
                  padding: effectiveOptionsPadding,
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: widget.options!.toList(),
                  ),
                );
              }
              return ListView.builder(
                padding: effectiveOptionsPadding,
                controller: scrollController,
                itemCount: widget.itemCount,
                // A sheet is as tall as a short list needs.
                shrinkWrap:
                    widget.shrinkWrap ??
                    (sheet && (widget.itemCount ?? 1000) <= 40),
                itemBuilder: (context, index) {
                  return widget.optionsBuilder?.call(context, index);
                },
              );
            }

            final Widget select = Disabled(
              disabled: !widget.enabled,
              child: Focusable(
                autofocus: widget.autofocus,
                onFocusChange: widget.onFocusChange,
                canRequestFocus: widget.enabled,
                focusNode: focusNode,
                builder: (context, focused, child) {
                  final decorated = Decorator(
                    focused: focused,
                    decoration: effectiveDecoration,
                    child: child,
                  );
                  if (effectiveMinHeight == null) return decorated;
                  // The reference pins the trigger's height (`h-9` and
                  // friends), border included, and centres the content in
                  // it. Constraining outside the decorator counts the
                  // border's implicit padding in, like CSS border-box.
                  return ConstrainedBox(
                    constraints: BoxConstraints(minHeight: effectiveMinHeight),
                    child: decorated,
                  );
                },
                child: FinesseGestureDetector(
                  mouseCursor: SystemMouseCursors.click,
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    if (widget.onPressed != null) {
                      widget.onPressed!();
                      return;
                    }
                    FocusScope.of(context).unfocus();
                    if (details.kind == PointerDeviceKind.touch) {
                      popoverController.toggle();
                    } else {
                      desktopTogglePopover();
                    }
                  },
                  child: ConstrainedBox(
                    constraints: effectiveConstraints,
                    child: Padding(
                      padding: effectivePadding,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(child: effectiveText),
                          effectiveTrailing,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );

            final scrollToTopChild = effectiveShowScrollToTopChevron
                ? ValueListenableBuilder(
                    valueListenable: showScrollToTop,
                    builder: (context, show, child) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: show
                            ? MouseRegion(
                                onEnter: (_) => startAutoScroll(toTop: true),
                                onExit: (_) => stopAutoScroll(),
                                child: Container(
                                  width: calculatedMinWidth,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: PhosphorIcon(
                                    PhosphorIconsRegular.caretUp,
                                    size: 16,
                                    color: menuForeground,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      );
                    },
                  )
                : null;

            final scrollToBottomChild = effectiveShowScrollToBottomChevron
                ? ValueListenableBuilder(
                    valueListenable: showScrollToBottom,
                    builder: (context, show, child) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: show
                            ? MouseRegion(
                                onEnter: (_) => startAutoScroll(toTop: false),
                                onExit: (_) => stopAutoScroll(),
                                child: Container(
                                  width: calculatedMinWidth,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: PhosphorIcon(
                                    PhosphorIconsRegular.caretDown,
                                    size: 16,
                                    color: menuForeground,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      );
                    },
                  )
                : null;

            return Provider(
              data: this as SelectState<dynamic>,
              notifyUpdate: (_) => true,
              child: PickerHost(
                // A plain single select is a menu, and stays one on a
                // phone; the others have a search field or need a Done.
                presentation:
                    widget.presentation == PickerPresentation.auto &&
                        widget.variant == SelectVariant.primary
                    ? PickerPresentation.popover
                    : widget.presentation,
                groupId: widget.groupId,
                popoverPadding: EdgeInsets.zero,
                controller: popoverController,
                anchor: effectiveAnchor,
                closeOnTapOutside: widget.closeOnTapOutside,
                effects: effectiveEffects,
                reverseDuration: effectivePopoverReverseDuration,
                shadows: effectiveShadows,
                filter: effectiveFilter,
                // The options surface is a menu, and menus can carry their
                // own palette; without this it would inherit the page
                // popover's decoration.
                decoration: theme.selectTheme.popoverDecoration,
                triggerBuilder: (_, _) => select,
                sheetBuilder: (sheetContext, close) => ListenableBuilder(
                  // The sheet is a route of its own: nothing rebuilds it
                  // when the selection changes but this.
                  listenable: _selection,
                  builder: (context, _) => Provider(
                    data: this as SelectState<dynamic>,
                    notifyUpdate: (_) => true,
                    child: _SelectSheetScope(
                      child: Sheet(
                        title: widget.title ?? widget.placeholder,
                        // The search stays put and the list scrolls.
                        scrollable: false,
                        constraints: BoxConstraints(
                          maxWidth: 560,
                          maxHeight: MediaQuery.sizeOf(context).height * .8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ?search,
                            ?widget.header,
                            Flexible(child: buildOptions(sheet: true)),
                            ?widget.footer,
                            if (isMultiSelect)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: theme.layoutTheme.gap(GapSize.md),
                                ),
                                child: Button(
                                  expands: true,
                                  onPressed: close,
                                  child: Text(
                                    FinesseLocalizations.of(
                                      context,
                                    ).datePicker.done,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                popoverBuilder: (_, _) {
                  // Seed showScrollToBottom/showScrollToTop once the popover
                  // has been laid out. Guarded: this builder can run many
                  // times per open, and an unguarded callback queued one
                  // closure per build.
                  if (!_scrollChevronSyncScheduled) {
                    _scrollChevronSyncScheduled = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollChevronSyncScheduled = false;
                      if (!mounted) return;
                      if (scrollController.hasClients) {
                        showScrollToBottom.value =
                            scrollController.offset <
                            scrollController.position.maxScrollExtent;
                        showScrollToTop.value = scrollController.offset > 0;
                      }
                    });
                  }

                  Widget effectiveColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (search != null) Flexible(child: search),
                      if (widget.header != null)
                        Flexible(child: widget.header!),
                      ?scrollToTopChild,
                      Flexible(child: buildOptions()),
                      ?scrollToBottomChild,
                      if (widget.footer != null)
                        Flexible(child: widget.footer!),
                    ],
                  );

                  if (widget.optionsBuilder == null) {
                    effectiveColumn = IntrinsicWidth(child: effectiveColumn);
                  }

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: effectiveMaxHeight,
                      minWidth: calculatedMinWidth,
                      maxWidth: effectiveMaxWidth,
                    ),
                    // The arrows walk the options wherever the app runs;
                    // the web's default shortcuts would scroll the page
                    // instead.
                    child: ArrowKeyFocus(child: effectiveColumn),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// An option in the list of a [Select].
///
/// Shows a check icon when selected and highlights on hover and focus.
/// Tapping it selects [value].
class SelectOption<T> extends StatefulWidget {
  /// Creates an option for [value] that shows [child].
  const SelectOption({
    super.key,
    required this.value,
    this.child,
    this.label,
    this.hoveredBackgroundColor,
    this.padding,
    this.selectedIcon,
    this.borderRadius,
    this.direction,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.textStyle,
    this.selectedTextStyle,
  }) : assert(
         child != null || label != null,
         'A SelectOption needs a child or a label.',
       );

  /// The value of the [SelectOption], it must be unique above the options.
  final T value;

  /// What the option shows. Defaults to its [label] as text.
  final Widget? child;

  /// The option as text: what the select's trigger shows for it when the
  /// select has no `selectedOptionBuilder`.
  final String? label;

  /// The background color of the [SelectOption] when hovered, defaults to
  /// `ThemeData.accent`.
  final Color? hoveredBackgroundColor;

  /// The padding of the [SelectOption], defaults to
  /// `EdgeInsets.symmetric(horizontal: 8, vertical: 6)`
  final EdgeInsetsGeometry? padding;

  /// The icon of the [SelectOption] when selected.
  final Widget? selectedIcon;

  /// The radius of the [SelectOption], defaults to `ThemeData.radius`.
  final BorderRadius? borderRadius;

  /// The background color of the [SelectOption], defaults to
  /// `ThemeData.selectOptionTheme.backgroundColor`.
  final Color? backgroundColor;

  /// The background color of the [SelectOption] when selected, defaults to
  /// `ThemeData.selectOptionTheme.selectedBackgroundColor`.
  final Color? selectedBackgroundColor;

  /// The text style of the [SelectOption], defaults to
  /// `ThemeData.selectOptionTheme.textStyle`.
  final TextStyle? textStyle;

  /// The text style of the [SelectOption] when selected, defaults to
  /// `ThemeData.selectOptionTheme.selectedTextStyle`.
  final TextStyle? selectedTextStyle;

  /// {@template SelectOption.direction}
  /// The direction of the ambient.
  /// {@endtemplate}
  final TextDirection? direction;

  @override
  State<SelectOption<T>> createState() => _OptionState<T>();
}

class _OptionState<T> extends State<SelectOption<T>> {
  final hovered = ValueNotifier(false);
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    final inherited = context.read<SelectState<dynamic>>() as SelectState<T>;
    final selected = inherited.selection.contains(widget.value);
    final label = widget.label;
    if (label != null) inherited._labels[widget.value] = label;
    if (selected && inherited.ensureSelectedVisible) {
      focusNode.requestFocus();
      // scroll to the selected option
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Scrollable.maybeOf(
          context,
        )?.position.ensureVisible(context.findRenderObject()!);
      });
    }
  }

  @override
  void dispose() {
    focusNode
      ..removeListener(onFocusChange)
      ..dispose();
    hovered.dispose();
    super.dispose();
  }

  void onFocusChange() {
    hovered.value = focusNode.hasFocus;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inheritedSelect =
        context.watch<SelectState<dynamic>>() as SelectState<T>;
    final selected = inheritedSelect.selection.contains(widget.value);
    final label = widget.label;
    if (label != null) inheritedSelect._labels[widget.value] = label;
    // In a sheet the options lie on the page's surface, not a menu's, and
    // are rows for a finger.
    final inSheet = _SelectSheetScope.isAround(context);

    final effectiveHoveredBackgroundColor =
        widget.hoveredBackgroundColor ??
        (inSheet
            ? theme.colorScheme.muted
            : theme.selectOptionTheme.hoveredBackgroundColor ??
                  theme.colorScheme.accent);

    final effectivePadding =
        widget.padding ??
        theme.selectOptionTheme.padding ??
        const EdgeInsets.symmetric(horizontal: 8, vertical: 6);

    final sheetTextStyle = theme.textTheme.p.copyWith(
      color: theme.colorScheme.foreground,
    );
    final effectiveTextStyle =
        widget.textStyle ??
        (inSheet
            ? sheetTextStyle
            : theme.selectOptionTheme.textStyle ??
                  theme.textTheme.muted.fallback(
                    color: theme.colorScheme.popoverForeground,
                  ));

    final effectiveSelectedTextStyle =
        widget.selectedTextStyle ??
        (inSheet
            ? sheetTextStyle
            : theme.selectOptionTheme.selectedTextStyle ??
                  theme.textTheme.muted.fallback(
                    color: theme.colorScheme.popoverForeground,
                  ));

    final effectiveSelectedBackgroundColor =
        widget.selectedBackgroundColor ??
        theme.selectOptionTheme.selectedBackgroundColor;

    final effectiveBackgroundColor =
        widget.backgroundColor ?? theme.selectOptionTheme.backgroundColor;

    final effectiveRadius =
        widget.borderRadius ??
        theme.selectOptionTheme.borderRadius ??
        theme.radius;

    final effectiveSelectedIconColor = inSheet
        ? theme.colorScheme.tint
        : theme.selectOptionTheme.selectedIconColor ??
              theme.colorScheme.popoverForeground;

    final effectiveSelectedHoveredIconColor = inSheet
        ? theme.colorScheme.tint
        : theme.selectOptionTheme.selectedHoveredIconColor ??
              theme.colorScheme.accentForeground;

    // No explicit colour here: the icon inherits it from the IconTheme below,
    // which follows the hover state — shadcn's
    // `focus:**:text-accent-foreground` recolours the indicator with the row.
    final effectiveSelectedIcon = Visibility.maintain(
      visible: selected,
      child:
          widget.selectedIcon ??
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: PhosphorIcon(PhosphorIconsRegular.check, size: 16),
          ),
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): () {
          inheritedSelect.select(widget.value);
        },
      },
      child: Focus(
        focusNode: focusNode,
        child: FinesseGestureDetector(
          behavior: HitTestBehavior.opaque,
          mouseCursor: SystemMouseCursors.click,
          onHover: (value) {
            hovered.value = value;
          },
          onTap: () => inheritedSelect.select(widget.value),
          child: ValueListenableBuilder(
            valueListenable: hovered,
            builder: (context, hovered, child) {
              // The highlight is this row's own fill, there or not: it
              // does not fade or travel between the options.
              final resolvedBackgroundColor = hovered
                  ? effectiveHoveredBackgroundColor
                  : selected
                  ? effectiveSelectedBackgroundColor
                  : effectiveBackgroundColor;

              // The label follows the *painted* background. A selected row
              // with no fill of its own (the reference marks selection with
              // the check alone) keeps the resting style — switching it to
              // the highlight's foreground would be unreadable the moment
              // the highlight is a strong colour.
              final highlighted =
                  hovered ||
                  (selected && effectiveSelectedBackgroundColor != null);

              return Container(
                padding: effectivePadding,
                // A touch target in a sheet: as tall as a control.
                constraints: inSheet
                    ? BoxConstraints(minHeight: theme.style.inputHeight)
                    : null,
                alignment: inSheet ? AlignmentDirectional.centerStart : null,
                decoration: BoxDecoration(
                  color: resolvedBackgroundColor,
                  borderRadius: effectiveRadius,
                ),
                // The icon theme mirrors the text: the check indicator and
                // any icons in the row follow the highlight's foreground
                // while it is painted.
                child: IconTheme.merge(
                  data: IconThemeData(
                    color: hovered
                        ? effectiveSelectedHoveredIconColor
                        : effectiveSelectedIconColor,
                  ),
                  child: DefaultTextStyle(
                    style: highlighted
                        ? effectiveSelectedTextStyle
                        : effectiveTextStyle,
                    child: child!,
                  ),
                ),
              );
            },
            child: Row(
              textDirection: widget.direction,
              children: [
                Expanded(child: widget.child ?? Text(widget.label!)),
                effectiveSelectedIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The selected values of a select: a set its listeners are told about.
class _Selection<T> extends ChangeNotifier implements ValueListenable<Set<T>> {
  _Selection(this._value);

  Set<T> _value;
  bool _disposed = false;

  @override
  Set<T> get value => _value;

  set value(Set<T> next) {
    _value = next;
    notifyListeners();
  }

  /// Replaces the set while widgets are being built, and tells the
  /// listeners once the frame is over.
  void replaceDuringBuild(Set<T> next) {
    _value = next;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Marks the options below it as lying in a sheet.
class _SelectSheetScope extends InheritedWidget {
  const _SelectSheetScope({required super.child});

  static bool isAround(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SelectSheetScope>() != null;

  @override
  bool updateShouldNotify(_SelectSheetScope oldWidget) => false;
}
