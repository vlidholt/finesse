import 'dart:math' as math;

import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A list whose rows can be dragged into a new order: a playlist, a set of
/// priorities, the fields of a form.
///
/// ```dart
/// ReorderableListView(
///   onReorder: (from, to) => setState(() {
///     tracks.insert(to, tracks.removeAt(from));
///   }),
///   children: [
///     for (final track in tracks)
///       ListTile(
///         key: ValueKey(track.id),
///         title: Text(track.title),
///         trailing: const ReorderableDragHandle(),
///       ),
///   ],
/// )
/// ```
///
/// Every row needs a key that stays with its item. The list is controlled:
/// [onReorder] reports a move and the parent reorders its data. **`to` is
/// the row's final index** — the index it has once it has been taken out
/// and put back — so `list.insert(to, list.removeAt(from))` is the whole
/// job, with no "minus one when moving down" to remember, unlike Flutter's
/// own reorderable list.
///
/// A finger picks a row up by pressing and holding anywhere on it
/// ([longPressToDrag]), or at once by its [ReorderableDragHandle]. A mouse
/// drags by the handle, which shows while the pointer is over its row. The
/// row lifts off the list as a card does on a `Board` — a little larger,
/// with the board's shadow — the others make room, and the list scrolls
/// when the row is held near an edge.
///
/// From the keyboard, a focused handle picks its row up with Space or
/// Enter; the arrow keys move it, Space or Enter drops it and Escape puts
/// it back. Each step is announced. Assistive technology also gets "Move
/// up", "Move down", "Move to top" and "Move to bottom" as actions of every
/// row.
///
/// A row keeps its state — a text field's text, a switch's animation —
/// when it is moved.
class ReorderableListView extends StatefulWidget {
  /// Creates a reorderable list of [children], each with a key.
  ReorderableListView({
    required List<Widget> children,
    required this.onReorder,
    this.onReorderStart,
    this.onReorderEnd,
    this.longPressToDrag = true,
    this.enabled = true,
    this.padding,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.itemSemanticLabel,
    super.key,
  }) : assert(
         children.every((child) => child.key != null),
         'Every row of a ReorderableListView needs a key.',
       ),
       itemCount = children.length,
       itemBuilder = ((context, index) => children[index]);

  /// Creates a reorderable list whose rows are built as they scroll into
  /// view. Each built row needs a key.
  const ReorderableListView.builder({
    required this.itemCount,
    required this.itemBuilder,
    required this.onReorder,
    this.onReorderStart,
    this.onReorderEnd,
    this.longPressToDrag = true,
    this.enabled = true,
    this.padding,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.itemSemanticLabel,
    super.key,
  });

  /// The number of rows.
  final int itemCount;

  /// Builds the row at an index. The widget it returns has a key that
  /// identifies the item, not the position.
  final IndexedWidgetBuilder itemBuilder;

  /// Called when a row has been moved from index `from` to index `to`,
  /// where `to` is its index in the list once the move is done. Reorder
  /// the data to match: `list.insert(to, list.removeAt(from))`.
  final void Function(int from, int to) onReorder;

  /// Called with a row's index when it is picked up.
  final ValueChanged<int>? onReorderStart;

  /// Called with a row's index when it is put down, moved or not.
  final ValueChanged<int>? onReorderEnd;

  /// Whether a touch that is held on a row picks it up. Turn it off for
  /// rows that have a long press of their own; they are then dragged by
  /// their [ReorderableDragHandle] alone.
  final bool longPressToDrag;

  /// Whether rows can be moved at all.
  final bool enabled;

  /// The padding around the rows, inside the scroll view.
  final EdgeInsetsGeometry? padding;

  /// The scroll controller of the list.
  final ScrollController? controller;

  /// Whether this is the primary scroll view of its route.
  final bool? primary;

  /// How the list scrolls.
  final ScrollPhysics? physics;

  /// Whether the list is as tall as its rows instead of filling its
  /// parent: for a short list inside a scrolling page.
  final bool shrinkWrap;

  /// What assistive technology calls the row at an index in announcements
  /// ("Introduction, position 2 of 5"). Without it only the position is
  /// announced.
  final String Function(int index)? itemSemanticLabel;

  @override
  State<ReorderableListView> createState() => _ReorderableListViewState();
}

class _ReorderableListViewState extends State<ReorderableListView> {
  /// One key per row's own key, so that a row is moved in the tree — with
  /// its state and its focus — when its index changes or it is lifted into
  /// the overlay.
  final _itemKeys = <Key, GlobalKey>{};

  /// The row the keyboard has picked up, where it was and where it is. The
  /// index is kept here, not read from the row: two keys can arrive within
  /// one frame, before the row has been rebuilt at its new place.
  Key? _heldKey;
  int? _heldOrigin;
  int? _heldIndex;

  /// The pointer a drag handle has just taken, so the row under the handle
  /// does not also start its press-and-hold drag for it.
  int _handlePointer = -1;

  /// Whether the drag under way is a finger's: only that one gets haptics.
  bool _touch = false;

  GlobalKey _keyFor(Key key) =>
      _itemKeys.putIfAbsent(key, () => GlobalKey(debugLabel: '$key'));

  void _announce(String message) {
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
    );
  }

  String _position(int index) {
    final position = FinesseLocalizations.of(context).reorder.position(
      position: index + 1,
      count: widget.itemCount,
    );
    final label = widget.itemSemanticLabel?.call(index);
    return label == null ? position : '$label, $position';
  }

  // --- Pointer drags --------------------------------------------------------

  /// The index of the row a pointer is dragging.
  int? _dragFrom;

  void _onDragStart(int index) {
    _dropHeld(announce: false);
    _dragFrom = index;
    if (_touch) HapticFeedback.mediumImpact();
    widget.onReorderStart?.call(index);
  }

  void _onDragEnd(int index) {
    if (_touch) HapticFeedback.lightImpact();
    // Like the reorder itself, reported as where the row ends up.
    final from = _dragFrom ?? index;
    _dragFrom = null;
    widget.onReorderEnd?.call(index > from ? index - 1 : index);
  }

  /// The framework reports the index to insert at *before* the row is
  /// taken out; this turns it into where the row ends up.
  void _onFrameworkReorder(int oldIndex, int newIndex) {
    final to = newIndex > oldIndex ? newIndex - 1 : newIndex;
    if (to == oldIndex) return;
    widget.onReorder(oldIndex, to);
  }

  // --- Keyboard and assistive technology ------------------------------------

  bool _isHeld(Key key) => _heldKey == key;

  void _pickUp(Key key, int index) {
    setState(() {
      _heldKey = key;
      _heldOrigin = index;
      _heldIndex = index;
    });
    widget.onReorderStart?.call(index);
    _announce(FinesseLocalizations.of(context).reorder.pickedUp);
  }

  void _dropHeld({bool announce = true}) {
    if (_heldKey == null) return;
    final index = _heldIndex;
    setState(() {
      _heldKey = null;
      _heldOrigin = null;
      _heldIndex = null;
    });
    if (index != null) {
      widget.onReorderEnd?.call(index);
      if (announce) {
        _announce(
          FinesseLocalizations.of(context).reorder.dropped(
            position: index + 1,
            count: widget.itemCount,
          ),
        );
      }
    }
  }

  void _cancelHeld() {
    final origin = _heldOrigin;
    final index = _heldIndex;
    if (_heldKey == null || origin == null || index == null) return;
    setState(() {
      _heldKey = null;
      _heldOrigin = null;
      _heldIndex = null;
    });
    if (origin != index) widget.onReorder(index, origin);
    widget.onReorderEnd?.call(origin);
    _announce(FinesseLocalizations.of(context).reorder.cancelled);
  }

  /// Moves the row at [index] to [to] and says where it is now.
  void _moveTo(int index, int to) {
    final target = to.clamp(0, widget.itemCount - 1);
    if (target == index) return;
    if (_heldIndex == index) _heldIndex = target;
    widget.onReorder(index, target);
    _announce(_position(target));
  }

  /// Moves the row the keyboard holds by [delta] rows, or to an end.
  void _moveHeld({int? delta, int? to}) {
    final index = _heldIndex;
    if (index == null) return;
    _moveTo(index, to ?? index + delta!);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => _touch = switch (event.kind) {
        PointerDeviceKind.mouse || PointerDeviceKind.trackpad => false,
        _ => true,
      },
      child: ReorderableList(
        itemCount: widget.itemCount,
        padding: widget.padding,
        controller: widget.controller,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        // `onReorderItem`, which does the arithmetic above itself, does not
        // exist on the oldest Flutter this package supports.
        // ignore: deprecated_member_use
        onReorder: _onFrameworkReorder,
        onReorderStart: _onDragStart,
        onReorderEnd: _onDragEnd,
        proxyDecorator: _decorateProxy,
        itemBuilder: (context, index) {
          final item = widget.itemBuilder(context, index);
          final key = item.key;
          assert(
            key != null,
            'Every row of a ReorderableListView needs a key.',
          );
          return _ReorderableRow(
            key: key,
            index: index,
            list: this,
            child: KeyedSubtree(key: _keyFor(key!), child: item),
          );
        },
      ),
    );
  }

  /// The row in the air: the board's lift, growing in as the row leaves
  /// the list and back as it lands.
  Widget _decorateProxy(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => _Lifted(
        amount: Curves.easeOutCubic.transform(animation.value.clamp(0.0, 1.0)),
        child: child!,
      ),
      child: child,
    );
  }
}

/// A row of the list: what its handle and its semantics need to know.
class _ReorderableRow extends StatefulWidget {
  const _ReorderableRow({
    required this.index,
    required this.list,
    required this.child,
    super.key,
  });

  final int index;
  final _ReorderableListViewState list;
  final Widget child;

  @override
  State<_ReorderableRow> createState() => _ReorderableRowState();
}

class _ReorderableRowState extends State<_ReorderableRow> {
  bool _hovered = false;

  Key get _itemKey => widget.key!;

  @override
  Widget build(BuildContext context) {
    final list = widget.list;
    final index = widget.index;
    final count = list.widget.itemCount;
    final enabled = list.widget.enabled;
    final held = list._isHeld(_itemKey);
    final strings = FinesseLocalizations.of(context).reorder;
    // The copy of a dragged row is built in the overlay, outside the list:
    // it shows its grip, which is what was grabbed.
    final inTheAir = SliverReorderableList.maybeOf(context) == null;

    Widget row = _RowScope(
      index: index,
      itemKey: _itemKey,
      list: list,
      hovered: _hovered || inTheAir,
      held: held,
      enabled: enabled,
      child: widget.child,
    );

    // Held by the keyboard, the row is lifted where it stands.
    row = SpringBuilder(
      value: held ? 1 : 0,
      spring: Motion.of(context).snappy,
      builder: (context, t, child) =>
          _Lifted(amount: t.clamp(0.0, 1.0), child: child!),
      child: row,
    );

    if (enabled) {
      row = Semantics(
        customSemanticsActions: {
          if (index > 0) ...{
            CustomSemanticsAction(label: strings.moveUp): () =>
                list._moveTo(index, index - 1),
            CustomSemanticsAction(label: strings.moveToTop): () =>
                list._moveTo(index, 0),
          },
          if (index < count - 1) ...{
            CustomSemanticsAction(label: strings.moveDown): () =>
                list._moveTo(index, index + 1),
            CustomSemanticsAction(label: strings.moveToBottom): () =>
                list._moveTo(index, count - 1),
          },
        },
        child: row,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: _TouchHoldToDrag(
        index: index,
        list: list,
        enabled: enabled && list.widget.longPressToDrag,
        child: row,
      ),
    );
  }
}

class _RowScope extends InheritedWidget {
  const _RowScope({
    required this.index,
    required this.itemKey,
    required this.list,
    required this.hovered,
    required this.held,
    required this.enabled,
    required super.child,
  });

  final int index;
  final Key itemKey;
  final _ReorderableListViewState list;
  final bool hovered;
  final bool held;
  final bool enabled;

  static _RowScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RowScope>();

  @override
  bool updateShouldNotify(_RowScope oldWidget) =>
      index != oldWidget.index ||
      itemKey != oldWidget.itemKey ||
      hovered != oldWidget.hovered ||
      held != oldWidget.held ||
      enabled != oldWidget.enabled;
}

/// Starts a drag of the row when a finger or a stylus is held on it. A
/// mouse is left alone: it has the handle, and its press is a click.
class _TouchHoldToDrag extends StatelessWidget {
  const _TouchHoldToDrag({
    required this.index,
    required this.list,
    required this.enabled,
    required this.child,
  });

  final _ReorderableListViewState list;
  final int index;
  final bool enabled;
  final Widget child;

  static const _devices = {
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.unknown,
  };

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: enabled
          ? (event) {
              if (!_devices.contains(event.kind)) return;
              // The handle under this pointer has already picked the row
              // up; a second recognizer would replace its drag.
              if (list._handlePointer == event.pointer) return;
              SliverReorderableList.maybeOf(context)?.startItemDragReorder(
                index: index,
                event: event,
                recognizer:
                    DelayedMultiDragGestureRecognizer(
                        debugOwner: this,
                        supportedDevices: _devices,
                      )
                      ..gestureSettings = MediaQuery.maybeGestureSettingsOf(
                        context,
                      ),
              );
            }
          : null,
      child: child,
    );
  }
}

/// The grip a row of a [ReorderableListView] is dragged by.
///
/// ```dart
/// ListTile(
///   key: ValueKey(track.id),
///   title: Text(track.title),
///   trailing: const ReorderableDragHandle(),
/// )
/// ```
///
/// A press on it picks the row up at once, with any pointer. Where a mouse
/// is connected the grip shows only while the pointer is over its row or
/// the grip has the focus; on a touch screen it is always there.
///
/// It is also the row's handle for the keyboard: focused, Space or Enter
/// picks the row up, the arrow keys move it, Space or Enter drops it and
/// Escape puts it back where it was.
///
/// By default it draws six dots; [child] replaces them. Outside a
/// reorderable list, and in the copy of a row that is being dragged, it is
/// only a picture.
class ReorderableDragHandle extends StatefulWidget {
  /// Creates a drag handle.
  const ReorderableDragHandle({this.child, super.key});

  /// The grip's picture. Defaults to six dots in the muted colour.
  final Widget? child;

  @override
  State<ReorderableDragHandle> createState() => _ReorderableDragHandleState();
}

class _ReorderableDragHandleState extends State<ReorderableDragHandle> {
  final _focusNode = FocusNode(debugLabel: 'ReorderableDragHandle');
  bool _focused = false;
  bool _mouse = false;

  @override
  void initState() {
    super.initState();
    final tracker = RendererBinding.instance.mouseTracker;
    _mouse = tracker.mouseIsConnected;
    tracker.addListener(_onMouseChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    RendererBinding.instance.mouseTracker.removeListener(_onMouseChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onMouseChanged() {
    final connected = RendererBinding.instance.mouseTracker.mouseIsConnected;
    if (connected != _mouse && mounted) setState(() => _mouse = connected);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) return;
    // Tabbing away from a held row puts it down where it is.
    final scope = _RowScope.maybeOf(context);
    if (scope != null && scope.list._isHeld(scope.itemKey)) {
      scope.list._dropHeld();
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final scope = _RowScope.maybeOf(context);
    if (scope == null || !scope.enabled || event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    final list = scope.list;
    final key = event.logicalKey;
    final activate =
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter;
    if (!list._isHeld(scope.itemKey)) {
      if (!activate || event is KeyRepeatEvent) return KeyEventResult.ignored;
      list._pickUp(scope.itemKey, scope.index);
      return KeyEventResult.handled;
    }
    if (activate) {
      if (event is! KeyRepeatEvent) list._dropHeld();
    } else if (key == LogicalKeyboardKey.escape) {
      list._cancelHeld();
    } else if (key == LogicalKeyboardKey.arrowUp) {
      list._moveHeld(delta: -1);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      list._moveHeld(delta: 1);
    } else if (key == LogicalKeyboardKey.home) {
      list._moveHeld(to: 0);
    } else if (key == LogicalKeyboardKey.end) {
      list._moveHeld(to: list.widget.itemCount - 1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = _RowScope.maybeOf(context);
    final active = scope != null && scope.enabled;
    final strings = FinesseLocalizations.of(context).reorder;
    final picture =
        widget.child ??
        PhosphorIcon(
          PhosphorIconsBold.dotsSixVertical,
          size: 18,
          color: theme.colorScheme.mutedForeground,
        );

    // Under a mouse the grip waits for the pointer; a finger cannot hover,
    // and the copy in the air shows what was grabbed.
    final shown =
        !_mouse || scope == null || scope.hovered || scope.held || _focused;

    return Semantics(
      // A node of its own: merged into its row it would be read as part of
      // the row's name.
      container: true,
      button: active,
      label: active ? strings.dragHandle : null,
      child: Focus(
        focusNode: _focusNode,
        canRequestFocus: active,
        onKeyEvent: _onKey,
        child: _FocusHighlight(
          node: _focusNode,
          onChanged: (value) {
            if (_focused != value) setState(() => _focused = value);
          },
          child: MouseRegion(
            cursor: active
                ? (scope.held
                      ? SystemMouseCursors.grabbing
                      : SystemMouseCursors.grab)
                : MouseCursor.defer,
            child: Listener(
              behavior: active
                  ? HitTestBehavior.opaque
                  : HitTestBehavior.deferToChild,
              onPointerDown: active
                  ? (event) {
                      scope.list._handlePointer = event.pointer;
                      SliverReorderableList.maybeOf(
                        context,
                      )?.startItemDragReorder(
                        index: scope.index,
                        event: event,
                        recognizer:
                            ImmediateMultiDragGestureRecognizer(
                                debugOwner: this,
                              )
                              ..gestureSettings =
                                  MediaQuery.maybeGestureSettingsOf(context),
                      );
                    }
                  : null,
              child: FocusRing(
                visible: _focused,
                borderRadius: theme.radii.md,
                child: AnimatedOpacity(
                  opacity: shown ? 1 : 0,
                  duration: Motion.of(context).fast,
                  curve: Motion.of(context).standard,
                  child: ConstrainedBox(
                    // Wide and tall enough to grab.
                    constraints: BoxConstraints(
                      minWidth: math.max(24, theme.spacing.step * 7),
                      minHeight: math.max(24, theme.spacing.step * 7),
                    ),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: picture,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reports whether [node] has the focus *and* the focus is being shown: a
/// ring for the keyboard, none for a click.
class _FocusHighlight extends StatefulWidget {
  const _FocusHighlight({
    required this.node,
    required this.onChanged,
    required this.child,
  });

  final FocusNode node;
  final ValueChanged<bool> onChanged;
  final Widget child;

  @override
  State<_FocusHighlight> createState() => _FocusHighlightState();
}

class _FocusHighlightState extends State<_FocusHighlight> {
  @override
  void initState() {
    super.initState();
    widget.node.addListener(_report);
    FocusManager.instance.addHighlightModeListener(_onMode);
  }

  @override
  void dispose() {
    widget.node.removeListener(_report);
    FocusManager.instance.removeHighlightModeListener(_onMode);
    super.dispose();
  }

  void _onMode(FocusHighlightMode mode) => _report();

  void _report() {
    if (!mounted) return;
    widget.onChanged(
      widget.node.hasPrimaryFocus &&
          FocusManager.instance.highlightMode == FocusHighlightMode.traditional,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// A row lifted off the list by [amount], 0 to 1: the board's lift — a
/// little larger, on the card's colour, under the board's shadow.
class _Lifted extends StatelessWidget {
  const _Lifted({required this.amount, required this.child});

  final double amount;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final board = theme.boardTheme;
    final motion = Motion.of(context);
    final scale = motion.reduced ? 1.0 : board.dragScale ?? 1.03;
    final radius = board.itemRadius ?? theme.radius;
    // The same widgets at rest and in the air, so the row keeps its state.
    return Transform.scale(
      scale: 1 + (scale - 1) * amount,
      child: DecoratedBox(
        decoration: amount <= 0
            ? const BoxDecoration()
            : ShadowDecoration.box(
                color: (board.itemColor ?? theme.colorScheme.card).withValues(
                  alpha: amount,
                ),
                borderRadius: radius,
                shadows:
                    BoxShadow.lerpList(
                      null,
                      board.dragShadows ?? theme.style.floatingShadow,
                      amount,
                    ) ??
                    const [],
              ),
        child: child,
      ),
    );
  }
}
