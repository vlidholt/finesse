import 'dart:async';
import 'dart:math' as math;

import 'package:finesse/src/components/context_menu.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// One action behind a row of [SwipeActions].
///
/// ```dart
/// SwipeAction(
///   icon: const PhosphorIcon(PhosphorIconsRegular.trash),
///   label: 'Delete',
///   destructive: true,
///   onPressed: () async {
///     await inbox.delete(message);
///     return true; // the row leaves
///   },
/// )
/// ```
@immutable
class SwipeAction {
  /// Creates an action.
  const SwipeAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.destructive = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// The action's icon, drawn over its [label].
  final Widget icon;

  /// The action's name: under the icon, in the context menu, and what
  /// assistive technology calls it.
  final String label;

  /// Runs the action. Return true when the row is gone as a result — a
  /// deleted message, an archived thread — and it slides out and closes
  /// the gap; return false and it slides shut. A future keeps the row open
  /// until it completes, which is the place to ask "are you sure?".
  final FutureOr<bool> Function() onPressed;

  /// Whether the action cannot be undone: it takes the destructive colour.
  final bool destructive;

  /// The fill of the action. Defaults to the scheme's destructive colour
  /// for a [destructive] action and to its secondary colour otherwise.
  final Color? backgroundColor;

  /// The colour of the icon and label. Defaults to the foreground that
  /// goes with the fill.
  final Color? foregroundColor;
}

/// A row with actions behind it, uncovered by swiping it sideways: archive
/// or delete a message, mark a notification read.
///
/// ```dart
/// SwipeActions(
///   trailing: [
///     SwipeAction(
///       icon: const PhosphorIcon(PhosphorIconsRegular.trash),
///       label: 'Delete',
///       destructive: true,
///       onPressed: () => _delete(message),
///     ),
///     SwipeAction(
///       icon: const PhosphorIcon(PhosphorIconsRegular.archive),
///       label: 'Archive',
///       onPressed: () => _archive(message),
///     ),
///   ],
///   onRemoved: () => setState(() => messages.remove(message)),
///   child: ListTile(title: Text(message.subject), onTap: _open),
/// )
/// ```
///
/// With a finger, a stylus or a trackpad the row follows a horizontal drag
/// and uncovers [leading] actions at its start or [trailing] ones at its
/// end. Let go past half of them and they stay open; a tap on one runs it.
/// With [fullSwipe], dragging on across most of the row stretches the
/// first action of that side over the others and letting go runs it.
///
/// A mouse does not drag rows. With [contextMenu] the same actions are a
/// menu on a secondary click and on the keyboard's menu key (or Shift+F10)
/// while the focus is in the row; assistive technology gets every action
/// as a custom action of the row either way.
///
/// When an action reports that the row is gone it slides out, the gap
/// closes, and [onRemoved] is called: take the item out of your list
/// there.
///
/// The first of a side's actions is the one at the outer edge. In a
/// right-to-left layout the sides swap with the text. A drag that starts in
/// the first 20 logical pixels of the screen's leading edge is left alone
/// while the route can be popped: that edge belongs to the back swipe. Put
/// a [SwipeActionsScope] around a list to keep one row open at a time.
class SwipeActions extends StatefulWidget {
  /// Creates a row with swipe actions behind [child].
  const SwipeActions({
    required this.child,
    this.leading = const [],
    this.trailing = const [],
    this.fullSwipe = true,
    this.enabled = true,
    this.contextMenu = true,
    this.actionExtent,
    this.onOpened,
    this.onClosed,
    this.onRemoved,
    super.key,
  });

  /// The row.
  final Widget child;

  /// The actions at the start of the row, uncovered by swiping towards the
  /// end. The first is outermost.
  final List<SwipeAction> leading;

  /// The actions at the end of the row, uncovered by swiping towards the
  /// start. The first is outermost.
  final List<SwipeAction> trailing;

  /// Whether swiping across most of the row runs the first action of that
  /// side.
  final bool fullSwipe;

  /// Whether the row can be swiped and its menu opened.
  final bool enabled;

  /// Whether a secondary click and the menu key show the actions as a
  /// context menu.
  final bool contextMenu;

  /// The width of one action while its side is open. Defaults to 76,
  /// scaled with the theme's spacing step and the text scale.
  final double? actionExtent;

  /// Called when a side comes to rest open.
  final VoidCallback? onOpened;

  /// Called when the row comes to rest closed after having been open.
  final VoidCallback? onClosed;

  /// Called when an action has removed the row and the gap has closed:
  /// drop the item from the list here. Until the parent does, the row
  /// stays in the tree with no height.
  final VoidCallback? onRemoved;

  @override
  State<SwipeActions> createState() => _SwipeActionsState();
}

class _SwipeActionsState extends State<SwipeActions>
    with TickerProviderStateMixin {
  /// How far from the screen's leading edge a drag has to begin to be this
  /// row's rather than the route's back swipe.
  static const _backSwipeEdge = 20.0;

  /// The row's horizontal shift in logical pixels: positive to the right.
  late final _shift = SpringController(vsync: this, tolerance: .05);

  /// How far the first action has spread over the others, 0 to 1.
  late final _spread = SpringController(vsync: this);

  /// How much of the row's height is left, 1 to 0, while it is removed.
  late final _height = SpringController(vsync: this, value: 1);

  late final _frame = Listenable.merge([_shift.animation, _spread.animation]);

  final _menu = FinesseContextMenuController();

  /// Which action of the uncovered side spreads over the others: the first
  /// on a full swipe, the one that removed the row otherwise.
  int _spreadIndex = 0;

  double _dragStart = 0;
  bool _dragTouch = true;
  bool _open = false;
  bool _fullArmed = false;
  bool _busy = false;
  bool _removing = false;
  ScrollPosition? _scrollPosition;
  _SwipeActionsScopeState? _scope;

  bool get _ltr => Directionality.of(context) == TextDirection.ltr;

  /// The actions uncovered when the row is shifted to the right.
  List<SwipeAction> get _leftActions => _ltr ? widget.leading : widget.trailing;

  /// The actions uncovered when the row is shifted to the left.
  List<SwipeAction> get _rightActions =>
      _ltr ? widget.trailing : widget.leading;

  List<SwipeAction> _actionsFor(double shift) =>
      shift > 0 ? _leftActions : _rightActions;

  double get _actionExtent {
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return widget.actionExtent ??
        76 * theme.spacing.step / 4 * math.max(1, math.min(scale, 1.5));
  }

  double _openExtent(double shift) => _actionsFor(shift).length * _actionExtent;

  double get _rowWidth {
    final box = context.findRenderObject();
    return box is RenderBox && box.hasSize ? box.size.width : 0;
  }

  /// How far the row has to be shifted for a full swipe.
  double _fullExtent(double shift) =>
      math.max(_rowWidth * .6, _openExtent(shift) + 48);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = _SwipeActionsScopeMarker.maybeOf(context);
  }

  @override
  void didUpdateWidget(SwipeActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && oldWidget.enabled) _close(animate: false);
  }

  @override
  void dispose() {
    _scope?._release(this);
    _stopWatchingScroll();
    _shift.dispose();
    _spread.dispose();
    _height.dispose();
    _menu.dispose();
    super.dispose();
  }

  // --- Open and closed ------------------------------------------------------

  void _watchScroll() {
    final position = Scrollable.maybeOf(context)?.position;
    if (position == null || position.axis != Axis.vertical) return;
    _scrollPosition = position
      ..isScrollingNotifier.addListener(_onScrollingChanged);
  }

  void _stopWatchingScroll() {
    _scrollPosition?.isScrollingNotifier.removeListener(_onScrollingChanged);
    _scrollPosition = null;
  }

  void _onScrollingChanged() {
    if (_scrollPosition?.isScrollingNotifier.value ?? false) _close();
  }

  void _setOpen(bool open) {
    if (_open == open) return;
    setState(() => _open = open);
    if (open) {
      _watchScroll();
      widget.onOpened?.call();
    } else {
      _stopWatchingScroll();
      widget.onClosed?.call();
    }
  }

  /// Slides the row shut.
  void _close({bool animate = true, double? velocity}) {
    if (_removing) return;
    _fullArmed = false;
    final motion = Motion.of(context);
    _spread.animateTo(
      0,
      spring: animate ? motion.snappy : MotionSpring.instant,
    );
    _shift.animateTo(
      0,
      spring: animate ? motion.snappy : MotionSpring.instant,
      velocity: velocity,
    );
    _setOpen(false);
    _scope?._release(this);
  }

  void _settleOpen(double side, {double? velocity}) {
    final motion = Motion.of(context);
    _spread.animateTo(0, spring: motion.snappy);
    _shift.animateTo(
      side.sign * _openExtent(side),
      spring: motion.snappy,
      velocity: velocity,
    );
    _setOpen(true);
  }

  // --- The drag ------------------------------------------------------------

  bool _allowPointer(PointerEvent event) {
    if (!widget.enabled || _busy || _removing) return false;
    if (widget.leading.isEmpty && widget.trailing.isEmpty) return false;
    // The leading edge of the screen is the back swipe's while there is
    // somewhere to go back to.
    if (ModalRoute.of(context)?.canPop ?? false) {
      final width = MediaQuery.sizeOf(context).width;
      final fromLeadingEdge = _ltr
          ? event.position.dx
          : width - event.position.dx;
      if (fromLeadingEdge < _backSwipeEdge) return false;
    }
    return true;
  }

  /// Whether a drag in [direction] (positive to the right) has anything to
  /// do: an open row can always be dragged shut, a closed one only towards
  /// a side that has actions. Anything else is left to whatever scrolls
  /// horizontally around the row.
  bool _canDrag(double direction) {
    final shift = _shift.value;
    if (shift > 0 && direction < 0) return true;
    if (shift < 0 && direction > 0) return true;
    return direction > 0 ? _leftActions.isNotEmpty : _rightActions.isNotEmpty;
  }

  void _onDragStart(DragStartDetails details) {
    _dragTouch = switch (details.kind) {
      PointerDeviceKind.mouse || PointerDeviceKind.trackpad => false,
      _ => true,
    };
    _scope?._claim(this);
    _shift.stop();
    _dragStart = _shift.value;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragStart += details.primaryDelta ?? 0;
    var shift = _dragStart;
    // No actions on that side: the row does not go there.
    if (shift > 0 && _leftActions.isEmpty) shift = 0;
    if (shift < 0 && _rightActions.isEmpty) shift = 0;
    final open = _openExtent(shift);
    final width = _rowWidth;
    if (widget.fullSwipe) {
      shift = shift.clamp(-width, width);
    } else if (shift.abs() > open) {
      // Past the actions the row gives less and less.
      final over = shift.abs() - open;
      shift = shift.sign * (open + _actionExtent * (1 - 1 / (1 + over / 80)));
    }
    _shift.jumpTo(shift);

    final armed = widget.fullSwipe && shift.abs() >= _fullExtent(shift);
    if (armed != _fullArmed) {
      _fullArmed = armed;
      _spreadIndex = 0;
      if (armed && _dragTouch) HapticFeedback.mediumImpact();
      _spread.animateTo(armed ? 1 : 0, spring: Motion.of(context).snappy);
    }
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shift = _shift.value;
    if (shift == 0) return _close(animate: false);
    if (_fullArmed) {
      unawaited(_run(_actionsFor(shift).first));
      return;
    }
    // Where a flick would carry the row decides, not only where it is.
    final projected = shift + velocity * .15;
    final sameSide = projected.sign == shift.sign;
    if (sameSide && projected.abs() > _openExtent(shift) / 2) {
      _settleOpen(shift, velocity: velocity);
    } else {
      _close(velocity: velocity);
    }
  }

  // --- Running an action ----------------------------------------------------

  Future<void> _run(SwipeAction action) async {
    if (_busy || _removing) return;
    _busy = true;
    var remove = false;
    try {
      remove = await action.onPressed();
    } finally {
      _busy = false;
    }
    if (!mounted) return;
    if (remove) {
      await _remove(action);
    } else {
      _close();
    }
  }

  Future<void> _remove(SwipeAction action) async {
    final motion = Motion.of(context);
    _stopWatchingScroll();
    _scope?._release(this);
    // Out the way it was going. From shut (the menu, a screen reader), away
    // from the side the action is on, so that its colour follows the row
    // out.
    final shift = _shift.value;
    final direction = shift != 0
        ? shift.sign
        : (_leftActions.contains(action) ? 1.0 : -1.0);
    final width = _rowWidth;
    final index = _actionsFor(direction).indexOf(action);
    setState(() {
      _removing = true;
      _spreadIndex = math.max(0, index);
    });
    try {
      unawaited(_spread.animateTo(1, spring: motion.snappy));
      await _shift.animateTo(direction * width, spring: motion.snappy).orCancel;
      await _height.animateTo(0, spring: motion.smooth).orCancel;
    } on TickerCanceled {
      return;
    }
    if (mounted) widget.onRemoved?.call();
  }

  // --- Keyboard and menu ----------------------------------------------------

  List<SwipeAction> get _allActions => [...widget.leading, ...widget.trailing];

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !_menuAvailable) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final menuKey =
        key == LogicalKeyboardKey.contextMenu ||
        (key == LogicalKeyboardKey.f10 &&
            HardwareKeyboard.instance.isShiftPressed);
    if (!menuKey) return KeyEventResult.ignored;
    final box = context.findRenderObject()! as RenderBox;
    _menu.showAt(box.localToGlobal(box.size.center(Offset.zero)));
    return KeyEventResult.handled;
  }

  bool get _menuAvailable =>
      widget.enabled &&
      widget.contextMenu &&
      !_removing &&
      (widget.leading.isNotEmpty || widget.trailing.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final actions = _allActions;

    Widget row = RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        _SwipeRecognizer:
            GestureRecognizerFactoryWithHandlers<_SwipeRecognizer>(
              () => _SwipeRecognizer(debugOwner: this),
              (recognizer) => recognizer
                ..allowPointer = _allowPointer
                ..canDrag = _canDrag
                ..gestureSettings = MediaQuery.maybeGestureSettingsOf(context)
                ..onStart = _onDragStart
                ..onUpdate = _onDragUpdate
                ..onEnd = _onDragEnd
                ..onCancel = () => _onDragEnd(DragEndDetails()),
            ),
      },
      child: AnimatedBuilder(
        animation: _frame,
        builder: (context, child) {
          final shift = _shift.value;
          return ClipRect(
            // Nothing is clipped while the row is where it belongs.
            clipBehavior: shift == 0 ? Clip.none : Clip.hardEdge,
            child: Stack(
              children: [
                if (shift != 0)
                  Positioned.fill(
                    child: _ActionStrip(
                      actions: _actionsFor(shift),
                      onLeft: shift > 0,
                      // A spring may carry the row a hair past its own
                      // width; the strip is never wider than the row.
                      extent: math.min(shift.abs(), _rowWidth),
                      spread: _spread.value.clamp(0.0, 1.0),
                      spreadIndex: _spreadIndex,
                      interactive: _open && !_busy && !_removing,
                      onPressed: _run,
                    ),
                  ),
                Transform.translate(
                  key: const ValueKey(_Slot.row),
                  offset: Offset(shift, 0),
                  child: child,
                ),
              ],
            ),
          );
        },
        // An open row closes on a tap instead of acting on it.
        child: GestureDetector(
          behavior: _open
              ? HitTestBehavior.opaque
              : HitTestBehavior.deferToChild,
          onTap: _open ? _close : null,
          child: AbsorbPointer(absorbing: _open, child: widget.child),
        ),
      ),
    );

    row = TapRegion(
      enabled: _open,
      onTapOutside: (_) => _close(),
      child: row,
    );

    row = AnimatedBuilder(
      animation: _height.animation,
      builder: (context, child) =>
          _Collapse(factor: _height.value.clamp(0.0, 1.0), child: child),
      child: row,
    );

    // The same wrappers whether or not there is anything to offer, so the
    // row keeps its state when actions come and go.
    final offered = widget.enabled && !_removing
        ? actions
        : const <SwipeAction>[];
    row = Semantics(
      customSemanticsActions: offered.isEmpty
          ? null
          : {
              for (final action in offered)
                CustomSemanticsAction(label: action.label): () =>
                    unawaited(_run(action)),
            },
      child: row,
    );

    if (!widget.contextMenu) return row;

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: ContextMenuRegion(
        controller: _menu,
        // A mouse only: a finger swipes, and a long press is the row's.
        supportedDevices: const {PointerDeviceKind.mouse},
        longPressEnabled: false,
        tapEnabled: false,
        hitTestBehavior: HitTestBehavior.translucent,
        items: [
          for (final action in offered)
            MenuItem(
              leading: action.icon,
              destructive: action.destructive,
              onPressed: () => unawaited(_run(action)),
              child: Text(action.label),
            ),
        ],
        child: row,
      ),
    );
  }
}

/// The keys of the row's stack: the row keeps its element when the action
/// strip is put in before it.
enum _Slot { row }

/// A horizontal drag that only competes for a direction the row can go in,
/// so a row with nothing on one side leaves that swipe to a page view or a
/// horizontal list around it.
class _SwipeRecognizer extends HorizontalDragGestureRecognizer {
  _SwipeRecognizer({super.debugOwner})
    : super(
        supportedDevices: const {
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.invertedStylus,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.unknown,
        },
      );

  bool Function(PointerEvent event) allowPointer = _always;
  bool Function(double direction) canDrag = _any;

  static bool _always(PointerEvent event) => true;
  static bool _any(double direction) => true;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      allowPointer(event) && super.isPointerAllowed(event);

  @override
  bool isPointerPanZoomAllowed(PointerPanZoomStartEvent event) =>
      allowPointer(event) && super.isPointerPanZoomAllowed(event);

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) =>
      super.hasSufficientGlobalDistanceToAccept(
        pointerDeviceKind,
        deviceTouchSlop,
      ) &&
      canDrag(globalDistanceMoved);
}

/// The actions uncovered on one side, sharing the uncovered width.
class _ActionStrip extends StatelessWidget {
  const _ActionStrip({
    required this.actions,
    required this.onLeft,
    required this.extent,
    required this.spread,
    required this.spreadIndex,
    required this.interactive,
    required this.onPressed,
  });

  final List<SwipeAction> actions;
  final bool onLeft;
  final double extent;
  final double spread;
  final int spreadIndex;
  final bool interactive;
  final ValueChanged<SwipeAction> onPressed;

  @override
  Widget build(BuildContext context) {
    final count = actions.length;
    if (count == 0) return const SizedBox.shrink();
    // Equal shares, until one spreads over the rest.
    final share = extent / count;
    final wide = share + (extent - share) * spread;
    final other = count == 1 ? 0.0 : (extent - wide) / (count - 1);
    final widest = spreadIndex.clamp(0, count - 1);
    // The first action is outermost: at the left edge on the left side, at
    // the right edge on the right.
    final blocks = [
      for (var i = 0; i < count; i++)
        SizedBox(
          width: i == widest ? wide : other,
          child: _ActionBlock(
            action: actions[i],
            separated: i > 0,
            separatorOnLeft: onLeft,
            interactive: interactive,
            onPressed: () => onPressed(actions[i]),
          ),
        ),
    ];
    return ExcludeSemantics(
      excluding: !interactive,
      child: Align(
        alignment: onLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: SizedBox(
          width: extent,
          child: Row(
            textDirection: TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: onLeft ? blocks : blocks.reversed.toList(),
          ),
        ),
      ),
    );
  }
}

class _ActionBlock extends StatelessWidget {
  const _ActionBlock({
    required this.action,
    required this.separated,
    required this.separatorOnLeft,
    required this.interactive,
    required this.onPressed,
  });

  final SwipeAction action;
  final bool separated;
  final bool separatorOnLeft;
  final bool interactive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background =
        action.backgroundColor ??
        (action.destructive ? scheme.destructive : scheme.secondary);
    final foreground =
        action.foregroundColor ??
        (action.destructive
            ? scheme.destructiveForeground
            : scheme.secondaryForeground);
    final labelStyle = theme.textTheme.caption.copyWith(
      color: foreground,
      fontWeight: FontWeight.w500,
    );

    return Pressable(
      onPressed: interactive ? onPressed : null,
      semanticLabel: action.label,
      // The whole block is the target and it does not shrink: it is flush
      // against its neighbours.
      pressScale: 1,
      builder: (context, states) {
        final pressed = states.contains(WidgetState.pressed);
        final hovered = states.contains(WidgetState.hovered);
        return FocusRing(
          visible: states.contains(WidgetState.focused),
          inset: true,
          child: AnimatedFill(
            color: pressed || hovered
                ? Color.alphaBlend(
                    foreground.withValues(alpha: pressed ? .16 : .08),
                    background,
                  )
                : background,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                border: separated
                    ? Border(
                        left: separatorOnLeft
                            ? BorderSide(
                                color: foreground.withValues(alpha: .16),
                              )
                            : BorderSide.none,
                        right: separatorOnLeft
                            ? BorderSide.none
                            : BorderSide(
                                color: foreground.withValues(alpha: .16),
                              ),
                      )
                    : null,
              ),
              child: ClipRect(
                child: OverflowBox(
                  minWidth: 0,
                  maxWidth: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.spacing.step * 2,
                    ),
                    child: IconTheme.merge(
                      data: IconThemeData(color: foreground, size: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: theme.spacing.step,
                        children: [
                          action.icon,
                          Text(
                            action.label,
                            style: labelStyle,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Keeps a share of its child's height, from the top, without changing how
/// the child is laid out: the gap a removed row leaves, closing.
class _Collapse extends SingleChildRenderObjectWidget {
  const _Collapse({required this.factor, super.child});

  final double factor;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCollapse(factor);

  @override
  void updateRenderObject(BuildContext context, _RenderCollapse renderObject) {
    renderObject.factor = factor;
  }
}

class _RenderCollapse extends RenderProxyBox {
  _RenderCollapse(this._factor);

  double get factor => _factor;
  double _factor;
  set factor(double value) {
    if (value == _factor) return;
    _factor = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      super.computeMinIntrinsicHeight(width) * _factor;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      super.computeMaxIntrinsicHeight(width) * _factor;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final size = super.computeDryLayout(constraints);
    return _factor >= 1 ? size : Size(size.width, size.height * _factor);
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    if (_factor >= 1) {
      child.layout(constraints, parentUsesSize: true);
      size = child.size;
      return;
    }
    // The child keeps the height it had; only what is reported shrinks.
    child.layout(
      constraints.copyWith(minHeight: 0),
      parentUsesSize: true,
    );
    size = constraints.constrainDimensions(
      child.size.width,
      child.size.height * _factor,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    if (_factor >= 1) {
      layer = null;
      context.paintChild(child, offset);
      return;
    }
    if (size.height <= 0) {
      layer = null;
      return;
    }
    layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      super.paint,
      oldLayer: layer as ClipRectLayer?,
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) =>
      _factor >= 1 && super.hitTest(result, position: position);
}

/// Keeps one row of [SwipeActions] open at a time among its descendants:
/// opening or dragging a row shuts the one that was open, and so does any
/// scrolling inside the scope.
///
/// ```dart
/// SwipeActionsScope(
///   child: ListView.builder(
///     itemCount: messages.length,
///     itemBuilder: (context, index) => SwipeActions(
///       trailing: _actionsFor(messages[index]),
///       child: MessageTile(messages[index]),
///     ),
///   ),
/// )
/// ```
///
/// Without a scope each row still closes when the vertical list it is in
/// scrolls; rows only do not know about each other.
class SwipeActionsScope extends StatefulWidget {
  /// Creates a scope around [child].
  const SwipeActionsScope({required this.child, super.key});

  /// The list, or whatever holds the rows.
  final Widget child;

  @override
  State<SwipeActionsScope> createState() => _SwipeActionsScopeState();
}

class _SwipeActionsScopeState extends State<SwipeActionsScope> {
  _SwipeActionsState? _current;

  void _claim(_SwipeActionsState row) {
    if (identical(_current, row)) return;
    final previous = _current;
    _current = row;
    if (previous != null && previous.mounted) previous._close();
  }

  void _release(_SwipeActionsState row) {
    if (identical(_current, row)) _current = null;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollStartNotification>(
      onNotification: (notification) {
        final current = _current;
        if (current != null && current.mounted) current._close();
        return false;
      },
      child: _SwipeActionsScopeMarker(state: this, child: widget.child),
    );
  }
}

class _SwipeActionsScopeMarker extends InheritedWidget {
  const _SwipeActionsScopeMarker({required this.state, required super.child});

  final _SwipeActionsScopeState state;

  static _SwipeActionsScopeState? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_SwipeActionsScopeMarker>()
      ?.state;

  @override
  bool updateShouldNotify(_SwipeActionsScopeMarker oldWidget) =>
      !identical(state, oldWidget.state);
}
