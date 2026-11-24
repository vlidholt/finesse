import 'dart:async';

import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// {@template HoverCard}
/// Shows a card of supplementary content when the pointer rests on its
/// [child]: who is behind a name, where a link leads, what a term means.
/// shadcn/ui's `HoverCard`.
///
/// The card is a `Popover` that nobody has to open:
///
/// * **A mouse** opens it by resting on the child for [openDelay] and
///   closes it [closeDelay] after leaving. Child and card are one hover
///   region, so the pointer can travel into the card — to select its text
///   or follow a link in it — without the card going away.
/// * **The keyboard** opens it by moving the focus to the child, or into
///   it, and closes it by moving on. The card never takes the focus; Tab
///   reaches its controls after the child's. Escape closes it.
/// * **A finger** opens it with a long press. There it stays until a tap
///   outside.
///
/// What the card shows is for looking something up, not for getting
/// something done: whatever it offers has to be reachable some other way,
/// since a card that opens on hover is easy to miss. For a panel the user
/// opens on purpose, use a `Popover`; for a line of text naming a control,
/// a `Tooltip`.
///
/// ```dart
/// HoverCard(
///   builder: (context) => const SizedBox(
///     width: 260,
///     child: Text('Maya Lindqvist designs type at Strand.'),
///   ),
///   child: const Text('@maya'),
/// )
/// ```
/// {@endtemplate}
class HoverCard extends StatefulWidget {
  /// {@macro HoverCard}
  const HoverCard({
    super.key,
    required this.child,
    required this.builder,
    this.openDelay = const Duration(milliseconds: 600),
    this.closeDelay = const Duration(milliseconds: 200),
    this.anchor,
    this.showArrow,
    this.padding,
    this.enabled = true,
    this.onOpenChanged,
  });

  /// The widget the card belongs to: a name, a link, an avatar.
  final Widget child;

  /// Builds the content of the card. It is laid out at its own size; give
  /// it a width.
  final WidgetBuilder builder;

  /// How long the pointer or the focus has to rest on [child] before the
  /// card opens. Long enough that a pointer on its way somewhere else
  /// opens nothing. A long press opens the card at once.
  final Duration openDelay;

  /// How long the card stays after the pointer or the focus has left both
  /// [child] and the card: the time there is to cross the gap between
  /// them.
  final Duration closeDelay;

  /// Where the card goes. Defaults to the popover theme's anchor: under
  /// the child, centred, and above it where there is no room below.
  final AnchorBase? anchor;

  /// Whether the card has an arrow pointing at [child]. Defaults to the
  /// popover theme's, and then to false. See `Popover.showArrow`.
  final bool? showArrow;

  /// The space between the edge of the card and its content. Defaults to
  /// the popover theme's padding.
  final EdgeInsetsGeometry? padding;

  /// Whether the card can open. A card that is open closes when this
  /// becomes false.
  final bool enabled;

  /// Called when the card opens and when it closes.
  final ValueChanged<bool>? onOpenChanged;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  final _controller = PopoverController();

  /// Around child and card: it has the focus while either does.
  final _focusNode = FocusNode(
    debugLabel: 'HoverCard',
    canRequestFocus: false,
    skipTraversal: true,
  );

  Timer? _openTimer;
  Timer? _closeTimer;

  bool _overChild = false;
  bool _overCard = false;

  /// Whether the keyboard put the focus in the child or the card.
  bool _focused = false;

  /// Whether a long press opened the card. Nothing is resting on it then,
  /// so nothing leaving closes it: a tap outside does.
  bool _held = false;

  bool _wasOpen = false;
  bool _listeningForEscape = false;

  bool get _wanted => _overChild || _overCard || _focused;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onOpenChanged);
  }

  @override
  void didUpdateWidget(HoverCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && oldWidget.enabled) _closeNow();
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _listenForEscape(false);
    _controller
      ..removeListener(_onOpenChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onOpenChanged() {
    final open = _controller.isOpen;
    if (open == _wasOpen) return;
    _wasOpen = open;
    _listenForEscape(open);
    if (!open) {
      // However it closed — the delay, Escape, a tap outside — it starts
      // from nothing next time. A card taken down under the pointer gets no
      // exit event.
      _openTimer?.cancel();
      _closeTimer?.cancel();
      _openTimer = _closeTimer = null;
      _overCard = false;
      _held = false;
    }
    widget.onOpenChanged?.call(open);
  }

  /// Opens after [HoverCard.openDelay], unless the reason to has gone by
  /// then.
  void _scheduleOpen() {
    _closeTimer?.cancel();
    _closeTimer = null;
    if (!widget.enabled || _controller.isOpen || _openTimer != null) return;
    if (widget.openDelay <= Duration.zero) return _controller.show();
    _openTimer = Timer(widget.openDelay, () {
      _openTimer = null;
      if (mounted && widget.enabled && _wanted) _controller.show();
    });
  }

  /// Closes after [HoverCard.closeDelay], unless the pointer or the focus
  /// has come back by then.
  void _scheduleClose() {
    _openTimer?.cancel();
    _openTimer = null;
    if (!_controller.isOpen || _held || _closeTimer != null) return;
    if (widget.closeDelay <= Duration.zero) return _controller.hide();
    _closeTimer = Timer(widget.closeDelay, () {
      _closeTimer = null;
      if (mounted && !_wanted && !_held) _controller.hide();
    });
  }

  void _closeNow() {
    _openTimer?.cancel();
    _openTimer = null;
    _controller.hide();
  }

  void _sync() => _wanted ? _scheduleOpen() : _scheduleClose();

  void _onFocusChange(bool hasFocus) {
    // A click focuses a button too, and would pin the card open for as
    // long as the button kept the focus. Only the keyboard's focus counts.
    _focused =
        hasFocus &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    _sync();
  }

  void _onLongPress() {
    if (!widget.enabled) return;
    _held = true;
    _closeTimer?.cancel();
    _closeTimer = null;
    _controller.show();
  }

  /// Escape, while the card is open and the focus is somewhere it cannot
  /// be heard from: opened by the pointer, the card has no part in the
  /// focus tree. With the focus in the child or the card, the popover's
  /// own binding closes it — after anything inside that wanted the key.
  void _listenForEscape(bool listen) {
    if (listen == _listeningForEscape) return;
    _listeningForEscape = listen;
    if (listen) {
      FocusManager.instance.addEarlyKeyEventHandler(_onKey);
    } else {
      FocusManager.instance.removeEarlyKeyEventHandler(_onKey);
    }
  }

  KeyEventResult _onKey(KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape ||
        !_controller.isOpen ||
        _focusNode.hasFocus) {
      return KeyEventResult.ignored;
    }
    _closeNow();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding =
        widget.padding ??
        theme.popoverTheme.padding ??
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    return Focus(
      focusNode: _focusNode,
      includeSemantics: false,
      onFocusChange: _onFocusChange,
      child: Popover(
        controller: _controller,
        // It assists the child; the caret and the focus stay where they
        // are.
        requestFocus: false,
        anchor: widget.anchor,
        showArrow: widget.showArrow,
        // Inside the hover region instead, so the whole card is one.
        padding: EdgeInsets.zero,
        popover: (context) => MouseRegion(
          onEnter: (_) {
            // Not a card that is already leaving.
            if (!_controller.isOpen) return;
            _overCard = true;
            _sync();
          },
          onExit: (_) {
            _overCard = false;
            _sync();
          },
          child: Semantics(
            container: true,
            onDismiss: _closeNow,
            child: Padding(
              padding: padding,
              child: Builder(builder: widget.builder),
            ),
          ),
        ),
        child: RawGestureDetector(
          // A long press, from a finger or a pen: a mouse hovers. It is
          // also what a screen reader offers on the child to show the
          // card.
          gestures: {
            LongPressGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                  LongPressGestureRecognizer
                >(
                  () => LongPressGestureRecognizer(
                    debugOwner: this,
                    supportedDevices: const {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.stylus,
                      PointerDeviceKind.invertedStylus,
                    },
                  ),
                  (recognizer) => recognizer.onLongPress = widget.enabled
                      ? _onLongPress
                      : null,
                ),
          },
          // A region that is not opaque reports a miss even when its child
          // was hit, which would hide the child from a detector around the
          // card. Deferring keeps the child's own hit test.
          child: MouseRegion(
            hitTestBehavior: HitTestBehavior.deferToChild,
            onEnter: (_) {
              _overChild = true;
              _sync();
            },
            onExit: (_) {
              _overChild = false;
              _sync();
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
