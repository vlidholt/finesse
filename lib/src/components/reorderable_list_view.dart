part of 'board.dart';

// A reorderable list is the board's machinery over one bare column: the
// same springs, the same neighbours making way in paint, the same lifted
// copy, landing, auto-scroll, keyboard moves and lazy-list bookkeeping.
// `_ListBoardState` is a `_BoardState` that builds a sliver instead of
// columns and words its announcements for a list; `_ListColumnState` is a
// `_BoardColumnState` that measures itself in the scroll view around it
// instead of one of its own. Nothing is copied from the board.
//
// haptics: the pick-up, each slot crossed and the drop are the board's own
// calls (`_startPointerDrag`, `_updateTarget` and `_endDrag` in
// board_state.dart). Whatever replaces `HapticFeedback` there reaches the
// list with it; there is nothing to connect here.

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
/// row lifts off the list as a card does on a [Board] — a little larger,
/// leaning into the movement, under the board's shadow — the others make
/// way on springs, the list scrolls when the row is held near an edge, and
/// on release the row flies to its place and lands. The look and the
/// springs are the board's: `BoardTheme.dragScale`, `dragTilt`,
/// `landScale`, `dragShadows`, `itemColor`, `itemBorderRadius` and its
/// springs.
///
/// From the keyboard, a focused handle picks its row up with Space or
/// Enter; the arrow keys, Home and End move it, Space or Enter drops it and
/// Escape puts it back. A row without a handle is itself the Tab stop.
/// Each step is announced. Assistive technology also gets "Move up", "Move
/// down", "Move to top" and "Move to bottom" as actions of every row.
///
/// A change the parent makes by itself — a sort, an insertion, a removal —
/// is animated too: the rows that stay glide to where they now belong.
///
/// A row keeps its state — a text field's text, a switch's animation —
/// when it is moved. The copy that follows the pointer is a second
/// instance built from the same widget, a picture of the row: it takes no
/// pointer, no focus and no part in the semantics tree.
///
/// See also:
///
///  * [ReorderableListView.builder], which builds rows as they scroll into
///    view.
///  * [SliverReorderableListView], the same list as a sliver.
///  * [Board], for moving items between several lists.
class ReorderableListView extends StatelessWidget {
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
       itemId = ((index) => children[index].key!),
       itemBuilder = ((context, index) => children[index]);

  /// Creates a reorderable list whose rows are built as they scroll into
  /// view.
  ///
  /// [itemId] says which item is at an index without building its row, so
  /// the rows themselves need no key:
  ///
  /// ```dart
  /// ReorderableListView.builder(
  ///   itemCount: tracks.length,
  ///   itemId: (index) => tracks[index].id,
  ///   itemBuilder: (context, index) => ListTile(
  ///     title: Text(tracks[index].title),
  ///     trailing: const ReorderableDragHandle(),
  ///   ),
  ///   onReorder: (from, to) => setState(() {
  ///     tracks.insert(to, tracks.removeAt(from));
  ///   }),
  /// )
  /// ```
  const ReorderableListView.builder({
    required this.itemCount,
    required this.itemId,
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

  /// What identifies the item at an index: something that stays with the
  /// item when it moves, compared with `==` and unique in the list. It is
  /// asked for every index whenever the list is rebuilt — that is how a
  /// change is noticed and animated — so it should be a lookup, not work.
  final Object Function(int index) itemId;

  /// Builds the row at an index. It is also called for the copy that
  /// follows the pointer.
  final IndexedWidgetBuilder itemBuilder;

  /// Called when a row has been moved from index `from` to index `to`,
  /// where `to` is its index in the list once the move is done. Reorder
  /// the data to match: `list.insert(to, list.removeAt(from))`.
  ///
  /// Until the data changes the row stays where it was, and it flies to
  /// wherever the next build puts it.
  final void Function(int from, int to) onReorder;

  /// Called with a row's index when it is picked up.
  final ValueChanged<int>? onReorderStart;

  /// Called when a picked-up row is put down, moved or not, with the index
  /// it is put down at.
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
  /// parent: for a short list inside a scrolling page, which then scrolls
  /// when a row is held near its edge.
  final bool shrinkWrap;

  /// What assistive technology calls the row at an index in announcements
  /// ("Introduction, position 2 of 5"). Without it only the position is
  /// announced.
  final String Function(int index)? itemSemanticLabel;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      slivers: [
        SliverPadding(
          padding: padding ?? EdgeInsets.zero,
          sliver: SliverReorderableListView(
            itemCount: itemCount,
            itemId: itemId,
            itemBuilder: itemBuilder,
            onReorder: onReorder,
            onReorderStart: onReorderStart,
            onReorderEnd: onReorderEnd,
            longPressToDrag: longPressToDrag,
            enabled: enabled,
            itemSemanticLabel: itemSemanticLabel,
          ),
        ),
      ],
    );
  }
}

/// A [ReorderableListView] as a sliver: rows that can be dragged into a new
/// order, among the other slivers of a `CustomScrollView`.
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     const SliverAppBar.large(title: Text('Queue')),
///     SliverReorderableListView(
///       itemCount: tracks.length,
///       itemId: (index) => tracks[index].id,
///       itemBuilder: (context, index) => ListTile(
///         title: Text(tracks[index].title),
///         trailing: const ReorderableDragHandle(),
///       ),
///       onReorder: (from, to) => setState(() {
///         tracks.insert(to, tracks.removeAt(from));
///       }),
///     ),
///   ],
/// )
/// ```
///
/// Rows are built as they scroll into view. While a row is held near an
/// edge, the nearest scroll view that has somewhere to scroll does. (The
/// widgets layer has a `SliverReorderableList` of its own, with a fixed
/// slide and no lift; this is the one that moves like a [Board].)
class SliverReorderableListView extends StatelessWidget {
  /// Creates a reorderable sliver list.
  const SliverReorderableListView({
    required this.itemCount,
    required this.itemId,
    required this.itemBuilder,
    required this.onReorder,
    this.onReorderStart,
    this.onReorderEnd,
    this.longPressToDrag = true,
    this.enabled = true,
    this.itemSemanticLabel,
    super.key,
  });

  /// The number of rows.
  final int itemCount;

  /// What identifies the item at an index; see
  /// [ReorderableListView.itemId].
  final Object Function(int index) itemId;

  /// Builds the row at an index. It is also called for the copy that
  /// follows the pointer.
  final IndexedWidgetBuilder itemBuilder;

  /// Called when a row has been moved; see [ReorderableListView.onReorder].
  final void Function(int from, int to) onReorder;

  /// Called with a row's index when it is picked up.
  final ValueChanged<int>? onReorderStart;

  /// Called when a picked-up row is put down, moved or not, with the index
  /// it is put down at.
  final ValueChanged<int>? onReorderEnd;

  /// Whether a touch that is held on a row picks it up.
  final bool longPressToDrag;

  /// Whether rows can be moved at all.
  final bool enabled;

  /// What assistive technology calls the row at an index in announcements.
  final String Function(int index)? itemSemanticLabel;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final ids = List<Object>.generate(itemCount, itemId, growable: false);
    return _ListBoard(
      list: this,
      enabled: enabled,
      columns: [
        BoardColumn<Object>(id: _ListColumn.only, label: '', items: ids),
      ],
      itemBuilder: (context, id, details) {
        final index = details.index;
        // A copy in the air outlives its item when the item is taken out
        // of the list: the caller's builder cannot be asked for a row that
        // is no longer there, so the copy keeps the picture it has.
        final there = index < ids.length && ids[index] == id;
        return _ReorderableRow(
          id: id,
          lifted: details.dragging,
          child: there ? itemBuilder(context, index) : null,
        );
      },
      onMove: (move) => onReorder(move.fromIndex, move.toIndex),
    );
  }
}

/// The id of a list's one column.
enum _ListColumn { only }

/// A [Board] that is one bare column, built as a sliver.
class _ListBoard extends Board<Object> {
  const _ListBoard({
    required this.list,
    required super.columns,
    required super.itemBuilder,
    required super.onMove,
    super.enabled,
  });

  final SliverReorderableListView list;

  @override
  State<Board<Object>> createState() => _ListBoardState();
}

class _ListBoardState extends _BoardState<Object> {
  SliverReorderableListView get _list => (widget as _ListBoard).list;

  /// How many drag handles the row of each item holds. A row that has one
  /// is not a Tab stop itself: its handle is.
  final Map<Object, int> _handles = {};

  /// The index a drag that is ending leaves its row at.
  int? _endIndex;

  _ListColumnState? get _column =>
      _columnStates[_ListColumn.only] as _ListColumnState?;

  int get _count => widget.columns.single.items.length;

  // --- What a list says ----------------------------------------------------

  /// The board's wording names a column; a list has its own.
  @override
  void _announce(String message) {}

  void _say(String message) => super._announce(message);

  String _positionOf(int index) {
    final position = FinesseLocalizations.of(
      context,
    ).reorder.position(position: index + 1, count: _count);
    final label = index < _count ? _list.itemSemanticLabel?.call(index) : null;
    return label == null ? position : '$label, $position';
  }

  // --- Picking up ----------------------------------------------------------

  @override
  void _itemPointerDown(
    PointerDownEvent event,
    Object id, {
    required bool immediate,
  }) {
    if (!immediate) {
      // A press on the row itself: a finger's picks it up once it has been
      // held. A mouse has the handle, and its press on a row is a click.
      final touch = switch (event.kind) {
        PointerDeviceKind.mouse || PointerDeviceKind.trackpad => false,
        _ => true,
      };
      if (!touch || !_list.longPressToDrag) return;
    }
    super._itemPointerDown(event, id, immediate: immediate);
  }

  @override
  _Drag<Object>? _startDrag(
    Object id, {
    required _DragMode mode,
    required Offset pointer,
    required bool touch,
  }) {
    final drag = super._startDrag(
      id,
      mode: mode,
      pointer: pointer,
      touch: touch,
    );
    if (drag != null) {
      final index = _locations[id]?.index;
      if (index != null) _list.onReorderStart?.call(index);
    }
    return drag;
  }

  /// Picks the row of [id] up for the keyboard; returns whether it did.
  bool _pickUp(Object id) {
    if (_drag != null) return false;
    final drag = _startDrag(
      id,
      mode: _DragMode.keyboard,
      pointer: Offset.zero,
      touch: false,
    );
    if (drag == null) return false;
    _say(FinesseLocalizations.of(context).reorder.pickedUp);
    return true;
  }

  // --- Keys ----------------------------------------------------------------

  @override
  KeyEventResult _handleItemKey(
    _BoardItemState<Object> item,
    KeyEvent event,
  ) {
    final before = _drag;
    final result = super._handleItemKey(item, event);
    final drag = _drag;
    if (before == null && drag != null && drag.mode == _DragMode.keyboard) {
      _say(FinesseLocalizations.of(context).reorder.pickedUp);
    }
    return result;
  }

  @override
  void _keyboardStep(_Drag<Object> drag, {int rows = 0, int columns = 0}) {
    // One column: there is nowhere to go sideways.
    if (columns != 0) return;
    final before = drag.targetIndex;
    super._keyboardStep(drag, rows: rows);
    if (drag.targetIndex != before) _say(_positionOf(drag.targetIndex));
  }

  // --- Letting go ----------------------------------------------------------

  @override
  void _endDrag({required bool commit}) {
    final drag = _drag;
    if (drag == null) return;
    final source = _locations[drag.id]?.index;
    final move = commit ? _moveFor(drag) : null;
    final index = _endIndex = move?.toIndex ?? source;
    super._endDrag(commit: commit);
    _endIndex = null;
    if (drag.mode != _DragMode.keyboard || !mounted) return;
    final strings = FinesseLocalizations.of(context).reorder;
    _say(
      commit && index != null
          ? strings.dropped(position: index + 1, count: _count)
          : strings.cancelled,
    );
  }

  @override
  void _reportDragEnd(_Drag<Object> drag) {
    final index = _endIndex ?? _locations[drag.id]?.index;
    void report() {
      if (index != null) _list.onReorderEnd?.call(index);
    }

    // The parent may well call `setState`, which it cannot while building.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) report();
      });
    } else {
      report();
    }
  }

  @override
  bool _moveDirect(
    Object id,
    Object toColumn,
    int? toIndex, {
    bool announce = true,
  }) {
    final last = _count - 1;
    final moved = super._moveDirect(id, toColumn, toIndex, announce: announce);
    if (moved && announce) _say(_positionOf((toIndex ?? last).clamp(0, last)));
    return moved;
  }

  // --- Rows and their handles ----------------------------------------------

  @override
  void _itemMounted(_BoardItemState<Object> item) {
    super._itemMounted(item);
    item._focusNode.skipTraversal = (_handles[item.widget.id] ?? 0) > 0;
  }

  void _handleMounted(Object id) {
    _handles[id] = (_handles[id] ?? 0) + 1;
    _items[id]?._focusNode.skipTraversal = true;
  }

  void _handleUnmounted(Object id) {
    final count = (_handles[id] ?? 0) - 1;
    if (count > 0) {
      _handles[id] = count;
    } else {
      _handles.remove(id);
      _items[id]?._focusNode.skipTraversal = false;
    }
  }

  /// "Move up" and "Move down" are the board's; a list adds its two ends.
  @override
  Map<CustomSemanticsAction, VoidCallback> _moreItemActions(
    _BoardItemState<Object> item,
  ) {
    final strings = FinesseLocalizations.of(context).reorder;
    final id = item.widget.id;
    final last = _count - 1;
    return {
      if (item.widget.index > 0)
        CustomSemanticsAction(label: strings.moveToTop): () =>
            _moveDirect(id, _ListColumn.only, 0),
      if (item.widget.index < last)
        CustomSemanticsAction(label: strings.moveToBottom): () =>
            _moveDirect(id, _ListColumn.only, last),
    };
  }

  /// A row rings only while the focus is on the row itself: with the focus
  /// on something inside it — its handle, a switch — that shows its own.
  @override
  bool _ringsFocus(_BoardItemState<Object> item) =>
      item._focusNode.hasPrimaryFocus;

  // --- Geometry ------------------------------------------------------------

  /// Where a dragged row counts as over the list: the scroll view it is in.
  @override
  Rect? get _boardRect => _column?._listRect;

  @override
  Offset? _offscreenTarget(_Proxy<Object> proxy) {
    final target = super._offscreenTarget(proxy);
    // Straight up or down: the rows need not start at the viewport's edge.
    return target == null ? null : Offset(proxy.x.value, target.dy);
  }

  // --- Build ---------------------------------------------------------------

  @override
  _BoardStyle _resolveStyle(BuildContext context) {
    final style = super._resolveStyle(context);
    return _BoardStyle(
      // Rows touch, and the list has no surface of its own.
      columnGap: 0,
      itemGap: 0,
      padding: EdgeInsets.zero,
      columnPadding: EdgeInsets.zero,
      headerPadding: EdgeInsets.zero,
      footerPadding: EdgeInsets.zero,
      columnRadius: BorderRadius.zero,
      columnColor: style.columnColor,
      columnBorderColor: style.columnBorderColor,
      targetColumnColor: style.targetColumnColor,
      targetColumnBorderColor: style.targetColumnBorderColor,
      refusedColumnColor: style.refusedColumnColor,
      refusedColumnBorderColor: style.refusedColumnBorderColor,
      headerTextStyle: style.headerTextStyle,
      countTextStyle: style.countTextStyle,
      countColor: style.countColor,
      countForegroundColor: style.countForegroundColor,
      fullCountColor: style.fullCountColor,
      fullCountForegroundColor: style.fullCountForegroundColor,
      itemRadius: style.itemRadius,
      placeholderColor: style.placeholderColor,
      placeholderBorderColor: style.placeholderBorderColor,
      emptyHeight: 0,
      dragScale: style.dragScale,
      dragTilt: style.dragTilt,
      landScale: style.landScale,
      dragShadows: style.dragShadows,
      highlightColor: style.highlightColor,
      highlightSeconds: style.highlightSeconds,
      lift: style.lift,
      shift: style.shift,
      drop: style.drop,
      land: style.land,
      fade: style.fade,
      fadeCurve: style.fadeCurve,
      turn: style.turn,
      turnCurve: style.turnCurve,
      autoScrollExtent: style.autoScrollExtent,
      autoScrollSpeed: style.autoScrollSpeed,
      snap: false,
      reduced: style.reduced,
      // A row is whatever the caller built, not a board's card.
      itemTheme: Theme.of(context),
      textDirection: style.textDirection,
    );
  }

  @override
  Widget build(BuildContext context) {
    _style = _resolveStyle(context);
    return _ReorderableScope(
      list: this,
      enabled: widget.enabled,
      child: SliverMainAxisGroup(
        slivers: [
          // The lifted copies are overlay children of the list. A portal
          // is a box, so it rides along in a sliver of no extent.
          SliverToBoxAdapter(
            child: OverlayPortal(
              controller: _portal,
              overlayChildBuilder: (context) =>
                  _ProxyLayer<Object>(board: this),
              child: const SizedBox.shrink(),
            ),
          ),
          _ListColumnView(
            board: this,
            column: widget.columns.single,
            index: 0,
            width: 0,
          ),
        ],
      ),
    );
  }
}

class _ListColumnView extends _BoardColumnView<Object> {
  const _ListColumnView({
    required super.board,
    required super.column,
    required super.index,
    required super.width,
  });

  @override
  State<_BoardColumnView<Object>> createState() => _ListColumnState();
}

/// The list's rows: a board column without a surface, a header or a scroll
/// view of its own. What a column measures in its viewport this measures in
/// the scroll views around it.
class _ListColumnState extends _BoardColumnState<Object> {
  /// The positions of every scroll view the list is in: when any of them
  /// moves, the rows move under a held pointer.
  List<ScrollPosition> _positions = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final positions = <ScrollPosition>[];
    for (
      var scrollable = Scrollable.maybeOf(context);
      scrollable != null;
      scrollable = Scrollable.maybeOf(scrollable.context)
    ) {
      positions.add(scrollable.position);
    }
    if (listEquals(positions, _positions)) return;
    for (final position in _positions) {
      position.removeListener(_board._scrolled);
    }
    for (final position in positions) {
      position.addListener(_board._scrolled);
    }
    _positions = positions;
  }

  @override
  void dispose() {
    for (final position in _positions) {
      position.removeListener(_board._scrolled);
    }
    super.dispose();
  }

  /// The scroll view that scrolls while a row is held near its edge: the
  /// nearest vertical one with somewhere to go — a shrink-wrapped list in a
  /// scrolling page has none itself — or else the nearest.
  ScrollableState? get _scrollable {
    final nearest = Scrollable.maybeOf(context, axis: Axis.vertical);
    for (
      var scrollable = nearest;
      scrollable != null;
      scrollable = Scrollable.maybeOf(scrollable.context, axis: Axis.vertical)
    ) {
      final position = scrollable.position;
      if (position.hasContentDimensions &&
          position.maxScrollExtent > position.minScrollExtent) {
        return scrollable;
      }
    }
    return nearest;
  }

  @override
  ScrollPosition? get _position => _scrollable?.position;

  /// The viewport the rows are laid out in. It is what positions are
  /// measured against, so it is always the same one: the nearest.
  @override
  RenderBox? get _listBox {
    final sliver = context.findRenderObject();
    if (sliver == null || !sliver.attached) return null;
    final RenderObject? viewport = RenderAbstractViewport.maybeOf(sliver);
    return viewport is RenderBox && viewport.attached && viewport.hasSize
        ? viewport
        : null;
  }

  /// The area the rows show in, and scroll in: the scrolling view's.
  @override
  Rect? get _listRect {
    final box = _scrollable?.context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Rect? get _rect => _listRect;

  /// The rows are as wide as the list, wherever in the viewport that is: a
  /// slot is its row's own, moved up or down.
  @override
  Rect? _slotRect(int index, _Drag<Object> drag) {
    final own = _board._cardRect(drag.id);
    if (widget.column.items.length <= 1) return own;
    final rect = super._slotRect(index, drag);
    if (rect == null || own == null) return rect;
    return Rect.fromLTWH(own.left, rect.top, own.width, rect.height);
  }

  @override
  Widget build(BuildContext context) {
    final board = _board;
    final column = widget.column;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final id = column.items[index];
          return _BoardSlot<Object>(
            key: ValueKey<Object>(id),
            board: board,
            columnState: this,
            column: column,
            index: index,
            item: id,
            id: id,
          );
        },
        childCount: column.items.length,
        // The slot paints through a boundary of its own, inside its
        // translation.
        addRepaintBoundaries: false,
        findChildIndexCallback: (key) =>
            board._locations[(key as ValueKey<Object>).value]?.index,
      ),
    );
  }
}

/// Tells the rows of a list, and the copies in the air, which list they
/// belong to.
class _ReorderableScope extends InheritedWidget {
  const _ReorderableScope({
    required this.list,
    required this.enabled,
    required super.child,
  });

  final _ListBoardState list;
  final bool enabled;

  @override
  bool updateShouldNotify(_ReorderableScope oldWidget) =>
      list != oldWidget.list || enabled != oldWidget.enabled;
}

/// A row of the list, or its copy in the air: what its handle and its
/// semantics need to know.
class _ReorderableRow extends StatefulWidget {
  const _ReorderableRow({
    required this.id,
    required this.lifted,
    required this.child,
  });

  final Object id;

  /// Whether this is the copy that follows the pointer.
  final bool lifted;

  /// The caller's row, or null when its item has left the list.
  final Widget? child;

  @override
  State<_ReorderableRow> createState() => _ReorderableRowState();
}

class _ReorderableRowState extends State<_ReorderableRow> {
  bool _hovered = false;
  Widget? _last;

  @override
  Widget build(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_ReorderableScope>()!;
    final list = scope.list;
    final id = widget.id;
    final lifted = widget.lifted;
    final child = _last = widget.child ?? _last ?? const SizedBox.shrink();

    final row = _RowScope(
      id: id,
      list: list,
      // The copy in the air shows its grip: that is what was grabbed.
      hovered: _hovered || lifted,
      lifted: lifted,
      enabled: scope.enabled,
      child: child,
    );

    if (lifted) {
      // In the air a row needs a ground of its own: rows are usually
      // transparent, and what is under the copy would show through.
      final theme = Theme.of(context);
      final board = theme.boardTheme;
      final proxy = list._proxies[id];
      return proxy == null
          ? row
          : _LiftFill(
              proxy: proxy,
              color: board.itemColor ?? theme.colorScheme.card,
              borderRadius: list._style.itemRadius,
              child: row,
            );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: row,
    );
  }
}

class _RowScope extends InheritedWidget {
  const _RowScope({
    required this.id,
    required this.list,
    required this.hovered,
    required this.lifted,
    required this.enabled,
    required super.child,
  });

  final Object id;
  final _ListBoardState list;
  final bool hovered;
  final bool lifted;
  final bool enabled;

  static _RowScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RowScope>();

  @override
  bool updateShouldNotify(_RowScope oldWidget) =>
      id != oldWidget.id ||
      list != oldWidget.list ||
      hovered != oldWidget.hovered ||
      lifted != oldWidget.lifted ||
      enabled != oldWidget.enabled;
}

/// The ground under a row in the air: the card colour, coming in with the
/// lift and going as the row lands.
class _LiftFill extends SingleChildRenderObjectWidget {
  const _LiftFill({
    required this.proxy,
    required this.color,
    required this.borderRadius,
    required super.child,
  });

  final _Proxy<Object> proxy;
  final Color color;
  final BorderRadius borderRadius;

  @override
  _RenderLiftFill createRenderObject(BuildContext context) =>
      _RenderLiftFill(proxy: proxy, color: color, borderRadius: borderRadius);

  @override
  void updateRenderObject(BuildContext context, _RenderLiftFill renderObject) {
    renderObject
      ..proxy = proxy
      ..color = color
      ..borderRadius = borderRadius;
  }
}

/// Listens to the copy it is in and repaints only while the lift changes:
/// the first moments in the air and the landing, not every frame of a drag.
class _RenderLiftFill extends RenderProxyBox {
  _RenderLiftFill({
    required _Proxy<Object> proxy,
    required Color color,
    required BorderRadius borderRadius,
  }) : _proxy = proxy,
       _color = color,
       _borderRadius = borderRadius;

  _Proxy<Object> get proxy => _proxy;
  _Proxy<Object> _proxy;
  set proxy(_Proxy<Object> value) {
    if (identical(value, _proxy)) return;
    if (attached) _proxy.removeListener(_changed);
    _proxy = value;
    if (attached) {
      _proxy.addListener(_changed);
      markNeedsPaint();
    }
  }

  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  BorderRadius get borderRadius => _borderRadius;
  BorderRadius _borderRadius;
  set borderRadius(BorderRadius value) {
    if (value == _borderRadius) return;
    _borderRadius = value;
    markNeedsPaint();
  }

  double _painted = -1;

  double get _amount => _proxy.lift.value.clamp(0.0, 1.0);

  void _changed() {
    if (_amount != _painted) markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _proxy.addListener(_changed);
  }

  @override
  void detach() {
    _proxy.removeListener(_changed);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final amount = _painted = _amount;
    if (amount > 0) {
      context.canvas.drawRRect(
        _borderRadius.toRRect(offset & size),
        Paint()..color = _color.withValues(alpha: _color.a * amount),
      );
    }
    super.paint(context, offset);
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
/// picks the row up, the arrow keys, Home and End move it, Space or Enter
/// drops it and Escape puts it back where it was.
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

  /// The row this handle has told its list about, so that the row leaves
  /// the Tab order to it.
  (_ListBoardState, Object)? _row;

  @override
  void initState() {
    super.initState();
    final tracker = RendererBinding.instance.mouseTracker;
    _mouse = tracker.mouseIsConnected;
    tracker.addListener(_onMouseChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = _RowScope.maybeOf(context);
    final row = scope == null || scope.lifted || !scope.enabled
        ? null
        : (scope.list, scope.id);
    if (row == _row) return;
    _leaveRow();
    _row = row;
    row?.$1._handleMounted(row.$2);
  }

  void _leaveRow() {
    final row = _row;
    _row = null;
    if (row != null && row.$1.mounted) row.$1._handleUnmounted(row.$2);
  }

  @override
  void dispose() {
    _leaveRow();
    RendererBinding.instance.mouseTracker.removeListener(_onMouseChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onMouseChanged() {
    final connected = RendererBinding.instance.mouseTracker.mouseIsConnected;
    if (connected != _mouse && mounted) setState(() => _mouse = connected);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final row = _row;
    if (row == null || event is! KeyDownEvent) return KeyEventResult.ignored;
    final (list, id) = row;
    // Only the pick-up is the handle's: once the row is held, its keys are
    // the list's, which hears them from the row around this handle.
    final key = event.logicalKey;
    final activate =
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter;
    if (!activate || list._drag != null || !node.hasPrimaryFocus) {
      return KeyEventResult.ignored;
    }
    return list._pickUp(id) ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = _RowScope.maybeOf(context);
    final active = scope != null && scope.enabled && !scope.lifted;
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
    final shown = !_mouse || scope == null || scope.hovered || _focused;

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
            cursor: active ? SystemMouseCursors.grab : MouseCursor.defer,
            child: Listener(
              behavior: active
                  ? HitTestBehavior.opaque
                  : HitTestBehavior.deferToChild,
              onPointerDown: active
                  ? (event) => scope.list._itemPointerDown(
                      event,
                      scope.id,
                      immediate: true,
                    )
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
