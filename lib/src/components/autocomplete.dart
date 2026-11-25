import 'dart:async';

import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/components/text_field.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A text field that suggests completions under itself as the user types.
///
/// The text stays free: an option is a shortcut to a value, not the only
/// way to give one. Where the value has to be one of a list, use
/// `Select.withSearch` instead.
///
/// ```dart
/// Autocomplete<String>(
///   placeholder: const Text('City'),
///   optionsBuilder: (value) {
///     final query = value.text.toLowerCase();
///     if (query.isEmpty) return const [];
///     return cities.where((city) => city.toLowerCase().startsWith(query));
///   },
///   onSelected: (city) => setState(() => destination = city),
/// )
/// ```
///
/// [optionsBuilder] may answer at once or with a future. A builder that
/// answers at once is asked on every change; one that has answered with a
/// future is asked again only once typing has paused for [debounce], and an
/// answer that arrives after a newer question is dropped.
///
/// ## Keyboard
///
/// The focus never leaves the field. Arrow down and up move a highlight
/// through the options, Enter takes the highlighted one — with none
/// highlighted it submits the text as typed — and Escape closes the list.
/// Tab moves on to the next field.
///
/// ## Options of any type
///
/// [displayStringForOption] says what an option puts in the field, and
/// [optionBuilder] what its row shows:
///
/// ```dart
/// Autocomplete<Person>(
///   optionsBuilder: (value) => directory.search(value.text),
///   displayStringForOption: (person) => person.name,
///   optionBuilder: (context, person) => Row(
///     children: [
///       Avatar(person.photo),
///       const Gap.sm(),
///       Text(person.name),
///     ],
///   ),
///   onSelected: invite,
/// )
/// ```
///
/// The list is the menu surface a `Select` opens — glass in the default
/// style — as wide as the field, below it or above when there is more room
/// there, on a phone as on a desktop. Its rows take their look from
/// `ThemeData.selectOptionTheme`.
class Autocomplete<T extends Object> extends StatefulWidget {
  /// Creates a field that suggests the options [optionsBuilder] returns.
  const Autocomplete({
    super.key,
    required this.optionsBuilder,
    this.displayStringForOption,
    this.onSelected,
    this.optionBuilder,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.placeholder,
    this.leading,
    this.trailing,
    this.emptyBuilder,
    this.loadingBuilder,
    this.onChanged,
    this.onSubmitted,
    this.debounce = const Duration(milliseconds: 200),
    this.maxOptionsHeight,
    this.openOnFocus = false,
    this.autoHighlight = false,
    this.clearable = false,
    this.autofocus = false,
    this.enabled = true,
    this.textInputAction,
    this.decoration,
  }) : assert(
         initialValue == null || controller == null,
         'Pass either an initialValue or a controller, not both.',
       );

  /// Returns the options for what is in the field. Called when the text
  /// changes — and when the field gains the focus, with [openOnFocus] — and
  /// may return a future.
  final AutocompleteOptionsBuilder<T> optionsBuilder;

  /// What an option puts in the field when it is chosen, and what its row
  /// reads without an [optionBuilder]. Defaults to the option's `toString`.
  final String Function(T option)? displayStringForOption;

  /// Called when the user chooses an option.
  final ValueChanged<T>? onSelected;

  /// Builds the content of an option's row. Defaults to its display string
  /// on one line.
  final Widget Function(BuildContext context, T option)? optionBuilder;

  /// Controls the text. One is created when null.
  final TextEditingController? controller;

  /// The text the field starts with, when it has no [controller].
  final String? initialValue;

  /// The focus node of the field. One is created when null.
  final FocusNode? focusNode;

  /// Shown while the field is empty.
  final Widget? placeholder;

  /// A widget at the start of the field.
  final Widget? leading;

  /// A widget at the end of the field.
  final Widget? trailing;

  /// Builds what the list shows when [optionsBuilder] found nothing for a
  /// non-empty text. Without one, the list closes.
  final WidgetBuilder? emptyBuilder;

  /// Builds what the list shows while a future from [optionsBuilder] is
  /// awaited and there are no earlier options to keep showing. Without one,
  /// the list stays as it was until the answer arrives.
  final WidgetBuilder? loadingBuilder;

  /// Called when the text changes: as the user types, and with the chosen
  /// option's display string when one is chosen.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text as typed.
  final ValueChanged<String>? onSubmitted;

  /// How long typing must have paused before an [optionsBuilder] that
  /// answers with futures is asked again. A builder that answers at once is
  /// asked on every change.
  final Duration debounce;

  /// The most height the list takes before it scrolls. Defaults to the
  /// theme's `SelectTheme.maxHeight`.
  final double? maxOptionsHeight;

  /// Whether the options are asked for as soon as the field has the focus,
  /// before anything is typed. Defaults to false.
  final bool openOnFocus;

  /// Whether the first option is highlighted whenever the options change,
  /// so that Enter takes it. Defaults to false: Enter submits the text as
  /// typed until an option is highlighted with the arrow keys.
  final bool autoHighlight;

  /// {@macro TextField.clearable}
  final bool clearable;

  /// Whether the field takes the focus when it is first built.
  final bool autofocus;

  /// Whether the field can be used.
  final bool enabled;

  /// The action of the keyboard's action key.
  final TextInputAction? textInputAction;

  /// Merged over the theme's text field decoration.
  final FinesseDecoration? decoration;

  @override
  State<Autocomplete<T>> createState() => _AutocompleteState<T>();
}

class _AutocompleteState<T extends Object> extends State<Autocomplete<T>> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  final _popover = PopoverController();

  /// Field and list are one tap region: a press on the list is not a press
  /// outside the field, so the caret stays where it is.
  final _group = Object();

  List<T> _options = const [];

  /// Whether [_options] answers the text that is in the field now.
  bool _answered = false;
  bool _loading = false;

  /// Counts the questions asked, so a late answer can be told from the
  /// current one.
  int _question = 0;

  /// Whether the builder has ever answered with a future; from then on it
  /// is asked only after typing has paused.
  bool _asynchronous = false;
  Timer? _debounce;

  /// The text the options were last asked for. The controller also
  /// notifies when only the selection moves.
  String? _askedFor;

  /// Whether the user closed the list — Escape, a tap outside, choosing an
  /// option — and nothing has reopened it since.
  bool _dismissed = false;

  /// Whether a change of the text is this widget's own doing.
  bool _writing = false;

  /// The highlighted option, and whether the arrow keys put it there (then
  /// it is scrolled into view).
  final _highlight = ValueNotifier<({int? index, bool byKeyboard})>((
    index: null,
    byKeyboard: false,
  ));

  String _display(T option) =>
      widget.displayStringForOption?.call(option) ?? option.toString();

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownController = TextEditingController(text: widget.initialValue ?? '');
    }
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    _popover.addListener(_onPopoverChanged);
    _askedFor = _controller.text;
  }

  @override
  void didUpdateWidget(Autocomplete<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_onTextChanged);
      if (widget.controller != null) {
        _ownController?.dispose();
        _ownController = null;
      } else {
        _ownController = TextEditingController.fromValue(
          oldWidget.controller!.value,
        );
      }
      _controller.addListener(_onTextChanged);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    (widget.controller ?? _ownController)?.removeListener(_onTextChanged);
    (widget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChanged);
    _popover
      ..removeListener(_onPopoverChanged)
      ..dispose();
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    _highlight.dispose();
    super.dispose();
  }

  // --- Asking ------------------------------------------------------------

  void _onTextChanged() {
    final text = _controller.text;
    if (text == _askedFor) return;
    _askedFor = text;
    if (_writing) return;
    // Typing reopens a list that was closed.
    _dismissed = false;
    _schedule();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _dismissed = false;
      if (widget.openOnFocus && !_answered) _ask();
    } else {
      _debounce?.cancel();
    }
    _sync();
  }

  void _schedule() {
    _debounce?.cancel();
    _answered = false;
    if (_asynchronous && widget.debounce > Duration.zero) {
      _debounce = Timer(widget.debounce, _ask);
      _sync();
    } else {
      _ask();
    }
  }

  Future<void> _ask() async {
    final question = ++_question;
    final value = _controller.value;
    final FutureOr<Iterable<T>> answer;
    try {
      answer = widget.optionsBuilder(value);
    } on Object {
      _loading = false;
      _sync();
      rethrow;
    }
    if (answer is Future<Iterable<T>>) {
      _asynchronous = true;
      setState(() => _loading = true);
      _sync();
      final Iterable<T> options;
      try {
        options = await answer;
      } on Object {
        if (mounted && question == _question) {
          setState(() => _loading = false);
          _sync();
        }
        rethrow;
      }
      // Dropped: the field has moved on, or is gone.
      if (!mounted || question != _question) return;
      _receive(options);
    } else {
      _receive(answer);
    }
  }

  void _receive(Iterable<T> options) {
    final list = List<T>.of(options);
    final changed = list.length != _options.length || !_answered;
    setState(() {
      _options = list;
      _answered = true;
      _loading = false;
    });
    _highlight.value = (
      index: widget.autoHighlight && list.isNotEmpty ? 0 : null,
      byKeyboard: false,
    );
    _sync();
    if (changed && _focusNode.hasFocus && _controller.text.isNotEmpty) {
      _announceCount(list.length);
    }
  }

  void _announceCount(int count) {
    final l = FinesseLocalizations.of(context);
    final message = switch (count) {
      0 => l.autocomplete.noResults,
      1 => l.autocomplete.oneResult,
      _ => l.autocomplete.results(count: count),
    };
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
    );
  }

  // --- Open and closed ---------------------------------------------------

  /// What the list has to show at the moment, if anything.
  _Panel? get _panel {
    if (_options.isNotEmpty) return _Panel.options;
    if (_loading && widget.loadingBuilder != null) return _Panel.loading;
    if (_answered &&
        widget.emptyBuilder != null &&
        _controller.text.isNotEmpty) {
      return _Panel.empty;
    }
    return null;
  }

  bool get _wantsOpen =>
      widget.enabled && _focusNode.hasFocus && !_dismissed && _panel != null;

  /// Whether [_sync] is changing the popover, as opposed to the user.
  bool _syncing = false;

  void _sync() {
    if (!mounted) return;
    _syncing = true;
    _popover.setOpen(_wantsOpen);
    _syncing = false;
  }

  void _onPopoverChanged() {
    // Closed from outside: Escape, or a tap elsewhere.
    if (!_syncing && !_popover.isOpen) _dismissed = true;
  }

  void _reopen() {
    if (!_dismissed) return;
    _dismissed = false;
    if (!_answered && !_loading) {
      _ask();
    } else {
      _sync();
    }
  }

  // --- Choosing ----------------------------------------------------------

  void _select(T option) {
    final text = _display(option);
    _writing = true;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _writing = false;
    _dismissed = true;
    // The options were for the old text.
    _answered = false;
    _question++;
    _debounce?.cancel();
    setState(() {
      _options = const [];
      _loading = false;
    });
    _highlight.value = (index: null, byKeyboard: false);
    _sync();
    widget.onChanged?.call(text);
    widget.onSelected?.call(option);
  }

  void _move(int by) {
    if (_options.isEmpty) return;
    final current = _highlight.value.index;
    final count = _options.length;
    final next = current == null
        ? (by > 0 ? 0 : count - 1)
        : (current + by) % count;
    _highlight.value = (
      index: next < 0 ? next + count : next,
      byKeyboard: true,
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final down = key == LogicalKeyboardKey.arrowDown;
    final up = key == LogicalKeyboardKey.arrowUp;
    if (down || up) {
      if (!_popover.isOpen) {
        // Closed with options to show: the arrows bring it back.
        if (!_dismissed || !widget.enabled) return KeyEventResult.ignored;
        _reopen();
        return _popover.isOpen
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      }
      if (_panel != _Panel.options) return KeyEventResult.ignored;
      _move(down ? 1 : -1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      final index = _highlight.value.index;
      if (!_popover.isOpen || index == null || index >= _options.length) {
        return KeyEventResult.ignored;
      }
      _select(_options[index]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// The keyboard's action key, on a platform where Enter is not a key
  /// event: it takes the highlighted option like Enter does.
  void _onSubmitted(String text) {
    final index = _highlight.value.index;
    if (_popover.isOpen && index != null && index < _options.length) {
      _select(_options[index]);
      return;
    }
    widget.onSubmitted?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final select = theme.selectTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // As wide as the field, which fills the width it is given.
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : null;
        return Popover(
          controller: _popover,
          // The caret stays in the field.
          requestFocus: false,
          groupId: _group,
          padding: EdgeInsets.zero,
          anchor: select.anchor,
          decoration: select.popoverDecoration,
          shadows: select.shadows,
          filter: select.filter,
          popover: (context) => _buildPanel(context, width),
          child: Focus(
            // Above the field's own node, so the keys are heard before the
            // field's default handling of them.
            canRequestFocus: false,
            skipTraversal: true,
            onKeyEvent: _onKey,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              groupId: _group,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              decoration: widget.decoration,
              placeholder: widget.placeholder,
              leading: widget.leading,
              trailing: widget.trailing,
              clearable: widget.clearable,
              textInputAction: widget.textInputAction,
              // The field's own suggestions would cover the list.
              autocorrect: false,
              enableSuggestions: false,
              onChanged: widget.onChanged,
              onSubmitted: _onSubmitted,
              // A tap brings back a list closed by a tap outside, which on
              // a touch screen leaves the focus where it was.
              onPressed: _reopen,
              onPressedAlwaysCalled: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPanel(BuildContext context, double? width) {
    final theme = Theme.of(context);
    final select = theme.selectTheme;
    final optionTheme = theme.selectOptionTheme;
    final maxHeight = widget.maxOptionsHeight ?? select.maxHeight ?? 384;
    // The surface draws its border around its content, so the content is
    // that much narrower than the field the surface lines up with.
    final border =
        select.popoverDecoration?.border ??
        theme.popoverTheme.decoration?.border;
    final borderWidth =
        (border?.left?.width ?? 0) + (border?.right?.width ?? 0);
    final contentWidth = width == null
        ? null
        : (width - borderWidth).clamp(0.0, double.infinity);
    final padding = select.optionsPadding ?? const EdgeInsets.all(4);
    final textStyle =
        optionTheme.textStyle ??
        theme.textTheme.muted.fallback(
          color: theme.colorScheme.popoverForeground,
        );

    final content = switch (_panel) {
      _Panel.options => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, option) in _options.indexed)
            AutocompleteOptionRow(
              index: index,
              highlight: _highlight,
              onSelected: () => _select(option),
              child:
                  widget.optionBuilder?.call(context, option) ??
                  Text(
                    _display(option),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
        ],
      ),
      _Panel.loading => widget.loadingBuilder!(context),
      _Panel.empty => widget.emptyBuilder!(context),
      // Closing: the last frame of the exit has nothing to show.
      null => const SizedBox.shrink(),
    };

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: contentWidth ?? 0,
        maxWidth: contentWidth ?? double.infinity,
        maxHeight: maxHeight,
      ),
      // The focus stays in the field: the rows are chosen with the arrow
      // keys and Enter, or with the pointer, and Tab goes on to whatever
      // follows the field rather than into the list.
      child: ExcludeFocus(
        child: DefaultTextStyle(
          style: textStyle,
          child: SingleChildScrollView(padding: padding, child: content),
        ),
      ),
    );
  }
}

enum _Panel { options, loading, empty }

/// One option of an `Autocomplete`'s list: a row in the look of a
/// `SelectOption`, highlighted while the pointer is over it or the arrow
/// keys are on it.
///
/// Internal: shared by `Autocomplete` and `TagField`, and not exported.
class AutocompleteOptionRow extends StatefulWidget {
  /// Creates the row of the option at [index].
  const AutocompleteOptionRow({
    required this.index,
    required this.highlight,
    required this.onSelected,
    required this.child,
    super.key,
  });

  /// The option's place in the list.
  final int index;

  /// The highlighted option of the list, and whether the arrow keys put it
  /// there — then the row scrolls itself into view.
  final ValueNotifier<({int? index, bool byKeyboard})> highlight;

  /// Called when the row is tapped.
  final VoidCallback onSelected;

  /// The row's content.
  final Widget child;

  @override
  State<AutocompleteOptionRow> createState() => _AutocompleteOptionRowState();
}

class _AutocompleteOptionRowState extends State<AutocompleteOptionRow> {
  bool _highlighted = false;

  @override
  void initState() {
    super.initState();
    widget.highlight.addListener(_onHighlightChanged);
    _highlighted = widget.highlight.value.index == widget.index;
  }

  @override
  void didUpdateWidget(AutocompleteOptionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlight != oldWidget.highlight) {
      oldWidget.highlight.removeListener(_onHighlightChanged);
      widget.highlight.addListener(_onHighlightChanged);
    }
    _highlighted = widget.highlight.value.index == widget.index;
  }

  @override
  void dispose() {
    widget.highlight.removeListener(_onHighlightChanged);
    super.dispose();
  }

  void _onHighlightChanged() {
    final value = widget.highlight.value;
    final highlighted = value.index == widget.index;
    if (highlighted == _highlighted) return;
    setState(() => _highlighted = highlighted);
    if (highlighted && value.byKeyboard) {
      // Walked to with the arrow keys: it has to be in view.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // Each is a no-op for a row already clear of that edge, so the
        // list moves only as far as it has to.
        Scrollable.ensureVisible(
          context,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
        Scrollable.ensureVisible(
          context,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        );
      });
    }
  }

  void _point() {
    if (_highlighted) return;
    widget.highlight.value = (index: widget.index, byKeyboard: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final option = theme.selectOptionTheme;
    final resting =
        option.textStyle ??
        theme.textTheme.muted.fallback(
          color: theme.colorScheme.popoverForeground,
        );
    final lit = option.selectedTextStyle ?? resting;
    return Semantics(
      button: true,
      selected: _highlighted,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        // On a move, not on entering: a list that scrolls under a resting
        // pointer must not drag the highlight along.
        onHover: (_) => _point(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _point(),
          onTap: widget.onSelected,
          // The highlight is the row's own fill, there or not: like a menu
          // row it neither fades nor travels.
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _highlighted
                  ? option.hoveredBackgroundColor ?? theme.colorScheme.accent
                  : option.backgroundColor,
              borderRadius: option.borderRadius ?? theme.radius,
            ),
            child: Padding(
              padding:
                  option.padding ??
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: _highlighted
                      ? option.selectedHoveredIconColor
                      : option.selectedIconColor,
                ),
                child: DefaultTextStyle.merge(
                  style: _highlighted ? lit : resting,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
