import 'package:flutter/widgets.dart';
import 'package:una/src/utils/focus_visibility.dart';

/// Builds a widget from the focus state of a [Focusable].
///
/// [focused] is true while the node has focus (and, with
/// [Focusable.visibleOnly], while the focus is shown). [child] is the
/// [Focusable.child], passed through so it does not rebuild.
typedef FocusWidgetBuilder = Widget Function(
  BuildContext context,
  bool focused,
  Widget? child,
);

/// A [Focus] widget that rebuilds its [builder] when the focus changes.
class Focusable extends StatefulWidget {
  /// Creates a focusable widget.
  const Focusable({
    super.key,
    required this.builder,
    this.focusNode,
    this.canRequestFocus = true,
    this.autofocus = false,
    this.child,
    this.onFocusChange,
    this.onKeyEvent,
    this.skipTraversal,
    this.descendantsAreFocusable,
    this.descendantsAreTraversable,
    this.includeSemantics = true,
    this.visibleOnly = false,
    this.debugLabel,
  });

  /// Whether the node can take focus. Defaults to true.
  final bool canRequestFocus;

  /// Whether to take focus when first built, if nothing else has focus.
  /// Defaults to false.
  final bool autofocus;

  /// The focus node to use. When null, the widget creates its own.
  final FocusNode? focusNode;

  /// Builds the content with the current focus state.
  final FocusWidgetBuilder builder;

  /// A widget passed to [builder] that does not depend on the focus state.
  final Widget? child;

  /// Called with the new focus state each time it changes.
  final ValueChanged<bool>? onFocusChange;

  /// Handles key events while the node has focus. See [Focus.onKeyEvent].
  final FocusOnKeyEventCallback? onKeyEvent;

  /// Whether focus traversal skips the node. See [Focus.skipTraversal].
  final bool? skipTraversal;

  /// Whether the descendants can take focus. See
  /// [Focus.descendantsAreFocusable].
  final bool? descendantsAreFocusable;

  /// Whether focus traversal can reach the descendants. See
  /// [Focus.descendantsAreTraversable].
  final bool? descendantsAreTraversable;

  /// Whether the node adds focus semantics. Defaults to true.
  final bool includeSemantics;

  /// Whether [builder] is told the node is focused only while the focus
  /// manager shows focus: after a key, and not after a click, as CSS's
  /// `:focus-visible` does (see `FocusVisibility`).
  ///
  /// For a control a click operates (a select's trigger, a checkbox, a
  /// switch), whose ring would otherwise stay on after the click that
  /// chose — and after a click elsewhere, since a click on nothing does
  /// not move the focus. A text field shows its focus either way.
  /// [onFocusChange] still reports the focus itself.
  final bool visibleOnly;

  /// A label for the focus node in debug output.
  final String? debugLabel;

  @override
  State<Focusable> createState() => _FocusableState();
}

class _FocusableState extends State<Focusable> {
  FocusNode? _internal;

  final isFocused = ValueNotifier(false);

  FocusNode get focusNode => widget.focusNode ?? _internal!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) _internal = FocusNode();
    isFocused
      ..value = focusNode.hasFocus
      ..addListener(onFocusChange);
    _syncListening();
  }

  bool get _shown =>
      !widget.visibleOnly ||
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  void _onHighlightMode(FocusHighlightMode mode) {
    if (mounted && isFocused.value) setState(() {});
  }

  bool _listening = false;

  void _syncListening() {
    if (widget.visibleOnly == _listening) return;
    _listening = widget.visibleOnly;
    if (_listening) {
      FocusVisibility.ensureInstalled();
      FocusManager.instance.addHighlightModeListener(_onHighlightMode);
    } else {
      FocusManager.instance.removeHighlightModeListener(_onHighlightMode);
    }
  }

  @override
  void didUpdateWidget(Focusable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncListening();
  }

  @override
  void dispose() {
    if (_listening) {
      FocusManager.instance.removeHighlightModeListener(_onHighlightMode);
    }
    isFocused.removeListener(onFocusChange);
    _internal?.dispose();
    isFocused.dispose();
    super.dispose();
  }

  void onFocusChange() {
    widget.onFocusChange?.call(isFocused.value);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      canRequestFocus: widget.canRequestFocus,
      onFocusChange: (value) => isFocused.value = value,
      focusNode: focusNode,
      onKeyEvent: widget.onKeyEvent,
      skipTraversal: widget.skipTraversal,
      descendantsAreFocusable: widget.descendantsAreFocusable,
      descendantsAreTraversable: widget.descendantsAreTraversable,
      includeSemantics: widget.includeSemantics,
      debugLabel: widget.debugLabel,
      child: ValueListenableBuilder(
        valueListenable: isFocused,
        builder: (context, value, child) =>
            widget.builder(context, value && _shown, child),
        child: widget.child,
      ),
    );
  }
}
