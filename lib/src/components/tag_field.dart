import 'dart:async';
import 'dart:math' as math;

import 'package:finesse/src/components/autocomplete.dart';
import 'package:finesse/src/components/chip.dart';
import 'package:finesse/src/components/decorator.dart';
import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/components/text_field.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/entrance.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A field that holds a list of tags: typed text becomes a tag on Enter or
/// on a separator, and each tag can be removed again.
///
/// It is controlled: [values] is what it shows and [onChanged] reports the
/// list the user wants.
///
/// ```dart
/// TagField<String>(
///   values: topics,
///   placeholder: const Text('Add a topic'),
///   labelBuilder: (context, topic) => Text(topic),
///   onChanged: (value) => setState(() => topics = value),
/// )
/// ```
///
/// ## Adding
///
/// Enter, any of the [separators] — also in pasted text, so a pasted
/// comma-separated list becomes that many tags — and leaving the field
/// each turn what was typed into a tag. [parse] says which tag a text
/// stands for; it may refuse by returning null. A tag the field already
/// holds is not added twice, and nothing is added past [maxTags].
///
/// With an [optionsBuilder] the field suggests tags under itself as an
/// `Autocomplete` does: arrow keys move the highlight and Enter takes it.
///
/// ## Removing
///
/// Each tag has a remove button. From the keyboard, Backspace in an empty
/// input marks the last tag and Backspace again removes it; the left and
/// right arrows move the mark along the tags, and Delete removes the
/// marked one too.
///
/// The field grows downwards as tags wrap onto further lines. Its outline
/// and height are the theme's text field's and its tags take their look
/// from the theme's chips.
class TagField<T extends Object> extends StatefulWidget {
  /// Creates a tag field.
  const TagField({
    super.key,
    required this.values,
    required this.onChanged,
    required this.labelBuilder,
    this.parse,
    this.displayStringForTag,
    this.separators = const [','],
    this.optionsBuilder,
    this.optionBuilder,
    this.maxTags,
    this.placeholder,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.decoration,
    this.semanticLabel,
  });

  /// The tags, in order.
  final List<T> values;

  /// Called with the new list when a tag is added or removed. Null
  /// disables the field.
  final ValueChanged<List<T>>? onChanged;

  /// Builds the label of a tag.
  final Widget Function(BuildContext context, T tag) labelBuilder;

  /// Turns typed text into a tag, or returns null to refuse it. Without
  /// one, the text itself is the tag when `T` is `String`, and only
  /// suggested options can be added otherwise.
  final T? Function(String text)? parse;

  /// The tag as words, for assistive technology ("Remove design") and for
  /// what a suggested option reads without an [optionBuilder]. Defaults to
  /// the tag's `toString`.
  final String Function(T tag)? displayStringForTag;

  /// The texts that end a tag while typing, besides Enter.
  final List<String> separators;

  /// Suggests tags for what is typed, like `Autocomplete.optionsBuilder`.
  /// Tags the field already holds are left out of the list.
  final AutocompleteOptionsBuilder<T>? optionsBuilder;

  /// Builds the row of a suggested option. Defaults to its display string.
  final Widget Function(BuildContext context, T option)? optionBuilder;

  /// The most tags the field takes. Null is no limit.
  final int? maxTags;

  /// Shown while the field has no tags and no text.
  final Widget? placeholder;

  /// Whether the field can be used.
  final bool enabled;

  /// Whether the field takes the focus when it is first built.
  final bool autofocus;

  /// The focus node of the input. One is created when null.
  final FocusNode? focusNode;

  /// Merged over the theme's text field decoration.
  final FinesseDecoration? decoration;

  /// What assistive technology calls the field.
  final String? semanticLabel;

  @override
  State<TagField<T>> createState() => _TagFieldState<T>();
}

class _TagFieldState<T extends Object> extends State<TagField<T>> {
  final _controller = TextEditingController();
  FocusNode? _ownFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  final _popover = PopoverController();
  final _group = Object();

  /// The tag the keyboard has marked, if any.
  int? _marked;

  /// The tags added by the user since the field was built.
  final _fresh = <T>{};
  bool _focused = false;

  List<T> _options = const [];
  int _question = 0;
  final _highlight = ValueNotifier<({int? index, bool byKeyboard})>((
    index: null,
    byKeyboard: false,
  ));

  bool get _enabled => widget.enabled && widget.onChanged != null;

  bool get _full =>
      widget.maxTags != null && widget.values.length >= widget.maxTags!;

  String _display(T tag) =>
      widget.displayStringForTag?.call(tag) ?? tag.toString();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(TagField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }
    if (_marked != null && _marked! >= widget.values.length) {
      _marked = widget.values.isEmpty ? null : widget.values.length - 1;
    }
  }

  @override
  void dispose() {
    (widget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChanged);
    _ownFocusNode?.dispose();
    _controller.dispose();
    _popover.dispose();
    _highlight.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    final focused = _focusNode.hasFocus;
    if (focused == _focused) return;
    setState(() {
      _focused = focused;
      if (!focused) _marked = null;
    });
    if (!focused) {
      // What was typed is not lost by leaving the field.
      _commitText(_controller.text);
      _popover.close();
    }
  }

  void _announce(String message) {
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
    );
  }

  // --- Adding and removing -----------------------------------------------

  T? _parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final parse = widget.parse;
    if (parse != null) return parse(trimmed);
    final Object candidate = trimmed;
    return candidate is T ? candidate : null;
  }

  /// Adds [tags] that are new, up to the limit, and says whether any was.
  bool _add(Iterable<T> tags) {
    if (!_enabled) return false;
    final next = List<T>.of(widget.values);
    final added = <T>[];
    for (final tag in tags) {
      if (widget.maxTags != null && next.length >= widget.maxTags!) break;
      if (next.contains(tag)) continue;
      next.add(tag);
      added.add(tag);
    }
    if (added.isEmpty) return false;
    _fresh.addAll(added);
    widget.onChanged!(next);
    _announce(
      FinesseLocalizations.of(
        context,
      ).tagField.added(tag: added.map(_display).join(', ')),
    );
    return true;
  }

  /// Turns [text] into a tag and empties the input.
  void _commitText(String text) {
    final tag = _parse(text);
    if (tag != null) _add([tag]);
    if (_controller.text.isNotEmpty) _controller.clear();
    _closeOptions();
  }

  void _remove(int index) {
    if (!_enabled || index < 0 || index >= widget.values.length) return;
    final removed = widget.values[index];
    final next = List<T>.of(widget.values)..removeAt(index);
    _fresh.remove(removed);
    setState(() {
      // The mark stays on a neighbour, so Backspace can go on removing.
      if (_marked != null) {
        _marked = next.isEmpty ? null : (index - 1).clamp(0, next.length - 1);
      }
    });
    widget.onChanged!(next);
    _announce(
      FinesseLocalizations.of(
        context,
      ).tagField.removed(tag: _display(removed)),
    );
    if (_focusNode.canRequestFocus) _focusNode.requestFocus();
  }

  void _onTyped(String text) {
    if (_marked != null) setState(() => _marked = null);
    for (final separator in widget.separators) {
      if (separator.isEmpty || !text.contains(separator)) continue;
      // Typed or pasted: every piece that ends in a separator is a tag,
      // and the rest stays in the input.
      var rest = text;
      for (final other in widget.separators) {
        if (other.isNotEmpty) rest = rest.replaceAll(other, separator);
      }
      final pieces = rest.split(separator);
      final tail = pieces.removeLast();
      _add([for (final piece in pieces) ?_parse(piece)]);
      _controller.value = TextEditingValue(
        text: tail,
        selection: TextSelection.collapsed(offset: tail.length),
      );
      _askOptions();
      return;
    }
    _askOptions();
  }

  // --- Suggestions -------------------------------------------------------

  Future<void> _askOptions() async {
    final builder = widget.optionsBuilder;
    if (builder == null) return;
    final question = ++_question;
    final answer = await builder(_controller.value);
    if (!mounted || question != _question) return;
    final options = [
      for (final option in answer)
        if (!widget.values.contains(option)) option,
    ];
    setState(() => _options = options);
    _highlight.value = (index: null, byKeyboard: false);
    _popover.setOpen(_focused && options.isNotEmpty && !_full);
  }

  void _closeOptions() {
    _question++;
    _popover.close();
    if (_options.isNotEmpty) setState(() => _options = const []);
    _highlight.value = (index: null, byKeyboard: false);
  }

  void _pick(T option) {
    _add([option]);
    _controller.clear();
    _closeOptions();
  }

  // --- Keys --------------------------------------------------------------

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || !_enabled) return KeyEventResult.ignored;
    final key = event.logicalKey;

    if (_popover.isOpen && _options.isNotEmpty) {
      final down = key == LogicalKeyboardKey.arrowDown;
      if (down || key == LogicalKeyboardKey.arrowUp) {
        final count = _options.length;
        final current = _highlight.value.index;
        final next = current == null
            ? (down ? 0 : count - 1)
            : (current + (down ? 1 : -1) + count) % count;
        _highlight.value = (index: next, byKeyboard: true);
        return KeyEventResult.handled;
      }
      final index = _highlight.value.index;
      if ((key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.numpadEnter) &&
          index != null &&
          index < _options.length) {
        _pick(_options[index]);
        return KeyEventResult.handled;
      }
    }

    final selection = _controller.selection;
    final atStart =
        _controller.text.isEmpty ||
        (selection.isCollapsed && selection.baseOffset <= 0);
    final count = widget.values.length;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final back = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    final forward = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final marked = _marked;

    if (key == LogicalKeyboardKey.backspace) {
      if (_controller.text.isNotEmpty || count == 0) {
        return KeyEventResult.ignored;
      }
      if (marked == null) {
        _mark(count - 1);
      } else {
        _remove(marked);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.delete && marked != null) {
      _remove(marked);
      return KeyEventResult.handled;
    }
    if (key == back && atStart && count > 0) {
      if (marked == null) {
        _mark(count - 1);
      } else if (marked > 0) {
        _mark(marked - 1);
      }
      return KeyEventResult.handled;
    }
    if (key == forward && marked != null) {
      // Past the last tag is the input again.
      _mark(marked + 1 < count ? marked + 1 : null);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape && marked != null) {
      _mark(null);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _mark(int? index) {
    if (index == _marked) return;
    setState(() => _marked = index);
    if (index != null) {
      _announce(_display(widget.values[index]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fieldTheme = theme.textFieldTheme;
    final chip = theme.chipTheme;
    final direction = Directionality.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final fieldHeight = fieldTheme.constraints?.minHeight ?? 36;
    final borderWidth = fieldTheme.decoration?.border?.top?.width ?? 1;
    final base =
        (fieldTheme.padding ??
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
            .resolve(direction);
    // A tag is a small chip that leaves the field its height: with one
    // line of tags the field is exactly as tall as a text field.
    final inner = fieldHeight - 2 * borderWidth;
    final restingTagHeight = math.min(chip.height ?? 24, inner - 8);
    // A style height is a floor once text is scaled: the tag grows with it.
    final tagHeight = restingTagHeight * (scale > 1 ? scale : 1);
    final inset = ((inner - restingTagHeight) / 2).clamp(2.0, 12.0);
    final gap = inset.clamp(4.0, 6.0);
    // A tag is smaller than a chip, and so is its padding.
    final chipPadding =
        (chip.padding ?? const EdgeInsets.symmetric(horizontal: 10)).resolve(
          direction,
        );
    final tagPadding = EdgeInsets.symmetric(
      horizontal: chipPadding.left * .8,
    );
    final decoration = (fieldTheme.decoration ?? const FinesseDecoration())
        .merge(widget.decoration);
    final hasTags = widget.values.isNotEmpty;

    final input = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        groupId: _group,
        autofocus: widget.autofocus,
        enabled: _enabled,
        readOnly: _full,
        // The outline is the whole field's, drawn around the tags too.
        decoration: FinesseDecoration.none,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minHeight: tagHeight),
        placeholder: hasTags ? null : widget.placeholder,
        showCursor: _marked == null && !_full ? null : false,
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.done,
        onChanged: _onTyped,
        onSubmitted: (text) {
          _commitText(text);
          // Enter adds a tag and stays for the next one.
          if (_focusNode.canRequestFocus) _focusNode.requestFocus();
        },
        onTap: () {
          if (_marked != null) setState(() => _marked = null);
        },
        onTapAlwaysCalled: true,
      ),
    );

    final content = Padding(
      padding: EdgeInsetsDirectional.only(
        // The first tag sits as far from the side as from the top; with no
        // tags the text starts where a text field's does.
        start: hasTags
            ? inset
            : (direction == TextDirection.ltr ? base.left : base.right),
        end: hasTags
            ? inset
            : (direction == TextDirection.ltr ? base.right : base.left),
        top: inset,
        bottom: inset,
      ),
      child: Wrap(
        spacing: gap,
        runSpacing: gap,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final (index, tag) in widget.values.indexed)
            // The field is the one Tab stop and the keyboard removes tags
            // from it: the crosses are for a pointer, and for assistive
            // technology, which meets "Remove design" as a button beside
            // the tag.
            ExcludeFocus(
              key: ValueKey(tag),
              child: Entrance(
                // Only a tag the user just added arrives; the ones the
                // field was built with are simply there.
                appear: _fresh.contains(tag),
                spring: Motion.of(context).snappy,
                child: Semantics(
                  container: true,
                  child: Chip(
                    variant: ChipVariant.soft,
                    height: tagHeight,
                    padding: tagPadding,
                    // The marked tag is the one Backspace removes next.
                    selected: _marked == index,
                    onDeleted: () => _remove(index),
                    deleteSemanticLabel: FinesseLocalizations.of(
                      context,
                    ).tagField.remove(tag: _display(tag)),
                    enabled: _enabled,
                    label: widget.labelBuilder(context, tag),
                  ),
                ),
              ),
            ),
          if (hasTags)
            // As wide as what is typed, and never too narrow to tap: it
            // wraps onto a line of its own when the tags leave no room.
            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: _full ? 0 : 40),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 2),
                  child: input,
                ),
              ),
            )
          else
            input,
        ],
      ),
    );

    final field = Opacity(
      opacity: _enabled ? 1 : theme.disabledOpacity,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        // Anywhere in the field is the input.
        onTap: _enabled ? _focusNode.requestFocus : null,
        child: MouseRegion(
          cursor: _enabled ? SystemMouseCursors.text : MouseCursor.defer,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: fieldHeight),
            child: Decorator(
              decoration: decoration,
              focused: _focused,
              child: content,
            ),
          ),
        ),
      ),
    );

    final labelled = Semantics(
      container: true,
      label: widget.semanticLabel,
      child: field,
    );
    if (widget.optionsBuilder == null) return labelled;

    final select = theme.selectTheme;
    final optionTheme = theme.selectOptionTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final border =
            select.popoverDecoration?.border ??
            theme.popoverTheme.decoration?.border;
        final sides = (border?.left?.width ?? 0) + (border?.right?.width ?? 0);
        final width = constraints.maxWidth.isFinite
            ? (constraints.maxWidth - sides).clamp(0.0, double.infinity)
            : null;
        return Popover(
          controller: _popover,
          requestFocus: false,
          groupId: _group,
          padding: EdgeInsets.zero,
          anchor: select.anchor,
          decoration: select.popoverDecoration,
          shadows: select.shadows,
          filter: select.filter,
          builder: (context) => ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: width ?? 0,
              maxWidth: width ?? double.infinity,
              maxHeight: select.maxHeight ?? 384,
            ),
            child: ExcludeFocus(
              child: DefaultTextStyle(
                style:
                    optionTheme.textStyle ??
                    theme.textTheme.muted.fallback(
                      color: theme.colorScheme.popoverForeground,
                    ),
                child: SingleChildScrollView(
                  padding: select.optionsPadding ?? const EdgeInsets.all(4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (index, option) in _options.indexed)
                        AutocompleteOptionRow(
                          index: index,
                          highlight: _highlight,
                          onSelected: () => _pick(option),
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
                ),
              ),
            ),
          ),
          child: labelled,
        );
      },
    );
  }
}
