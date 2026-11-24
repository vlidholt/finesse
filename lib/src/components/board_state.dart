part of 'board.dart';

/// Where an item is: the index of its column and its index there.
@immutable
class _Location {
  const _Location(this.column, this.index);

  final int column;
  final int index;
}

/// How far outside the board a dragged item still counts as over it.
const double _dropSlack = 48;

/// How close to its slot a flying item starts to land.
const double _touchdown = 14;

/// How long the pointer rests at the edge of a snapping board before the
/// board turns to the next column.
const double _turnDwell = .45;

class _BoardState<T extends Object> extends State<Board<T>>
    with SingleTickerProviderStateMixin
    implements _SlotHost {
  // The items by id, and each column's ids in order: the board's own copy,
  // which is what a rebuild is compared against. The parent's lists are
  // often the same objects, changed in place.
  Map<Object, _Location> _locations = {};
  List<List<Object>> _order = [];
  List<Object> _columnIds = [];

  final Map<Object, _BoardSlotState<T>> _slots = {};
  final Map<Object, _BoardColumnState<T>> _columnStates = {};

  /// The translation of every item that is not where it is laid out.
  final Map<Object, _Spring> _shifts = {};

  /// The lifted copies: the dragged item's, and those still flying.
  final Map<Object, _Proxy<T>> _proxies = {};

  _Drag<T>? _drag;
  MultiDragGestureRecognizer? _recognizer;
  PointerEvent? _lastDown;

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  ScrollController? _ownScroll;
  final _SnapMetrics _snapMetrics = _SnapMetrics();
  ScrollPosition? _outerPosition;

  late _BoardStyle _style;

  @override
  int _flipGeneration = 0;
  Map<Object, (Object, double)> _flipOrigins = const {};
  // Items found in another column after a rebuild, with where they were.
  // They are hidden at once and take off after the frame, when an overlay
  // entry can be inserted.
  final Map<Object, Rect> _pendingFlights = {};
  bool _afterFrameScheduled = false;
  Object? _refocus;

  static final Expando<ThemeData> _itemThemes = Expando<ThemeData>();

  ScrollController get _horizontal =>
      widget.scrollController ?? (_ownScroll ??= ScrollController());

  ScrollPosition? get _horizontalPosition =>
      _horizontal.hasClients ? _horizontal.position : null;

  // --- Lifecycle -----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    widget.controller?._state = this;
    _horizontal.addListener(_scrolled);
    _indexColumns();
  }

  @override
  void didUpdateWidget(Board<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._state = this;
    }
    if (oldWidget.scrollController != widget.scrollController) {
      (oldWidget.scrollController ?? _ownScroll)?.removeListener(_scrolled);
      _horizontal.addListener(_scrolled);
    }
    _syncData();
    if (!widget.enabled && _drag != null) {
      // Not during build: ending a drag reports to the parent.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && !widget.enabled) _endDrag(commit: false);
      });
    }
  }

  @override
  void dispose() {
    _recognizer?.dispose();
    HardwareKeyboard.instance.removeHandler(_handleDragKey);
    _outerPosition?.removeListener(_scrolled);
    for (final proxy in _proxies.values) {
      proxy.entry?.remove();
      proxy.entry?.dispose();
      proxy.dispose();
    }
    _proxies.clear();
    _drag = null;
    _ticker.dispose();
    widget.controller?._detach(this);
    (widget.scrollController ?? _ownScroll)?.removeListener(_scrolled);
    _ownScroll?.dispose();
    super.dispose();
  }

  // --- Data ----------------------------------------------------------------

  Object _idOf(T item) => widget.itemId?.call(item) ?? item;

  void _indexColumns() {
    final locations = <Object, _Location>{};
    final order = <List<Object>>[];
    final columnIds = <Object>[];
    for (final (c, column) in widget.columns.indexed) {
      assert(
        !columnIds.contains(column.id),
        'Two columns of a Board have the id ${column.id}. Column ids must '
        'be unique: moves are reported by column id.',
      );
      columnIds.add(column.id);
      final ids = <Object>[];
      for (final (i, item) in column.items.indexed) {
        final id = _idOf(item);
        assert(
          !locations.containsKey(id),
          'Two items of a Board have the id $id. The board tells its items '
          'apart by Board.itemId — or by == when it is not given — so every '
          'item needs an id of its own.',
        );
        locations[id] = _Location(c, i);
        ids.add(id);
      }
      order.add(ids);
    }
    _locations = locations;
    _order = order;
    _columnIds = columnIds;
  }

  /// The item at [location], or null when the parent's lists have moved on
  /// since the board last indexed them.
  T? _itemAt(_Location? location) {
    if (location == null || location.column >= widget.columns.length) {
      return null;
    }
    final items = widget.columns[location.column].items;
    return location.index < items.length ? items[location.index] : null;
  }

  BoardColumn<T>? _columnOf(Object? columnId) {
    final index = columnId == null ? -1 : _columnIds.indexOf(columnId);
    return index < 0 || index >= widget.columns.length
        ? null
        : widget.columns[index];
  }

  /// Compares the new lists with the ones the board last saw and prepares
  /// the animation between the two.
  void _syncData() {
    final oldOrder = _order;
    final oldLocations = _locations;
    final oldColumnIds = _columnIds;
    _indexColumns();

    final changed =
        !listEquals(oldColumnIds, _columnIds) || !_sameOrder(oldOrder, _order);
    if (changed && !_style.reduced) {
      // First: where every item on screen is now, measured in its column,
      // and a repaint for each so that it can work out where it has gone.
      final origins = <Object, (Object, double)>{};
      for (final MapEntry(key: id, value: slot) in _slots.entries) {
        if (!slot.mounted) continue;
        final box = slot._box;
        final ancestor = slot.widget.columnState._listBox;
        if (box == null || ancestor == null) continue;
        final columnId = slot.widget.column.id;
        origins[id] = (
          columnId,
          box.localToGlobal(Offset.zero, ancestor: ancestor).dy + box.shift,
        );
        box.markNeedsPaint();

        // An item the parent moved to another column by itself flies there.
        final from = oldLocations[id];
        final to = _locations[id];
        if (from != null &&
            to != null &&
            from.column < oldColumnIds.length &&
            oldColumnIds[from.column] != _columnIds[to.column] &&
            !_proxies.containsKey(id)) {
          final rect = _cardRect(id);
          if (rect != null) _pendingFlights[id] = rect;
        }
      }
      _flipOrigins = origins;
      _flipGeneration++;
    }

    final drag = _drag;
    if (drag != null) {
      final item = _itemAt(_locations[drag.id]);
      if (item == null) {
        // The dragged item has left the board: let go of it.
        _abortDrag();
      } else {
        drag.item = item;
      }
    }
    for (final proxy in _proxies.values) {
      if (!_locations.containsKey(proxy.id)) proxy.fading = true;
    }
    if (changed || _proxies.isNotEmpty || _drag != null) {
      _scheduleAfterFrame();
    }
  }

  static bool _sameOrder(List<List<Object>> a, List<List<Object>> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!listEquals(a[i], b[i])) return false;
    }
    return true;
  }

  void _scheduleAfterFrame() {
    if (_afterFrameScheduled) return;
    _afterFrameScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _afterFrameScheduled = false;
      if (mounted) _afterFrame();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  /// Runs once the frame that followed a change has been laid out and
  /// painted: everything that needs the new positions.
  void _afterFrame() {
    _flipOrigins = const {};

    final flights = Map.of(_pendingFlights);
    _pendingFlights.clear();
    for (final MapEntry(key: id, value: rect) in flights.entries) {
      final item = _itemAt(_locations[id]);
      if (item == null || _proxies.containsKey(id)) {
        final slot = _slots[id];
        if (slot != null && slot.mounted) slot._render?.hidden = _isHidden(id);
        continue;
      }
      _spawnProxy(id, item, rect)
        ..phase = _ProxyPhase.flying
        ..lift.target = 1;
    }

    for (final proxy in _proxies.values) {
      final location = _locations[proxy.id];
      final item = _itemAt(location);
      if (location == null || item == null) continue;
      proxy
        ..item = item
        ..details = BoardItemDetails<T>(
          column: widget.columns[location.column],
          index: location.index,
          dragging: true,
        )
        ..child = _proxyChild(proxy);
      proxy.entry?.markNeedsBuild();
    }

    final drag = _drag;
    if (drag != null) {
      if (drag.mode == _DragMode.pointer) {
        _updateTarget();
      } else {
        final column = _columnOf(drag.targetColumn);
        if (column == null) {
          final source = _locations[drag.id]!;
          drag
            ..targetColumn = _columnIds[source.column]
            ..targetIndex = source.index;
        } else {
          drag.targetIndex = math.min(
            drag.targetIndex,
            _countWithout(column, drag.id),
          );
        }
      }
    }
    _applyShiftTargets();
    _refreshDragVisuals();

    final refocus = _refocus;
    if (refocus != null) {
      _refocus = null;
      _slots[refocus]?._focusNode.requestFocus();
    }
    _ensureTicking();
  }

  int _countWithout(BoardColumn<T> column, Object id) {
    final location = _locations[id];
    final own =
        location != null &&
        location.column < _columnIds.length &&
        _columnIds[location.column] == column.id;
    return column.items.length - (own ? 1 : 0);
  }

  // --- Slots ---------------------------------------------------------------

  void _slotMounted(_BoardSlotState<T> slot) {
    final id = slot.widget.id;
    _slots[id] = slot;
    // A slot that comes into being mid-drag starts where it belongs, not
    // from wherever its item was in another column.
    _shifts.remove(id);
    final target = _targetShift(
      slot.widget.columnState.widget.index,
      slot.widget.index,
      id,
    );
    if (target != 0) _shifts[id] = _Spring(target);
  }

  void _slotUnmounted(_BoardSlotState<T> slot, Object id) {
    if (_slots[id] != slot) return;
    _slots.remove(id);
    _shifts.remove(id);
  }

  @override
  double _shiftOf(Object id) => _shifts[id]?.value ?? 0;

  @override
  bool _isHidden(Object id) =>
      _proxies.containsKey(id) || _pendingFlights.containsKey(id);

  @override
  double? _flipOrigin(Object id, Object columnId) {
    final origin = _flipOrigins[id];
    return origin != null && origin.$1 == columnId ? origin.$2 : null;
  }

  @override
  RenderObject? _flipAncestor(Object columnId) =>
      _columnStates[columnId]?._listBox;

  @override
  void _adoptShift(Object id, double shift) {
    // Called from paint: only state changes here. The ticker is started by
    // the callback scheduled when the lists changed.
    (_shifts[id] ??= _Spring()).value = shift;
  }

  /// The item's card as it is drawn now, in global coordinates.
  Rect? _cardRect(Object id) {
    final slot = _slots[id];
    final box = slot != null && slot.mounted ? slot._box : null;
    if (box == null) return null;
    final origin = box.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      origin.dx,
      origin.dy + box.shift,
      box.size.width,
      box.size.height - _style.itemGap,
    );
  }

  /// How far the item at [index] of [column] is moved while the dragged
  /// item is where it is: up by one slot when it follows the hole the
  /// dragged item left, down by one when it is at or after the slot that
  /// opens for it.
  double _targetShift(int column, int index, Object id) {
    final drag = _drag;
    if (drag == null || drag.id == id) return 0;
    final source = _locations[drag.id];
    if (source == null) return 0;

    var shift = 0.0;
    var reduced = index;
    if (column == source.column && index > source.index) {
      shift -= drag.extent;
      reduced = index - 1;
    }
    final (targetColumn, targetIndex) = _effectiveTarget(drag, source);
    if (column == targetColumn && reduced >= targetIndex) {
      shift += drag.extent;
    }
    return shift;
  }

  /// Where the slot is: at the target, or — while the item is over nothing
  /// that takes it — back where it came from.
  (int, int) _effectiveTarget(_Drag<T> drag, _Location source) {
    final column = drag.refused || drag.targetColumn == null
        ? -1
        : _columnIds.indexOf(drag.targetColumn!);
    return column < 0
        ? (source.column, source.index)
        : (column, drag.targetIndex);
  }

  void _applyShiftTargets() {
    for (final MapEntry(key: id, value: slot) in _slots.entries) {
      final location = _locations[id];
      if (location == null || !slot.mounted) continue;
      final target = _targetShift(location.column, location.index, id);
      var spring = _shifts[id];
      if (spring == null) {
        if (target == 0) continue;
        spring = _shifts[id] = _Spring();
      }
      spring.target = target;
    }
    _ensureTicking();
  }

  // --- The lifted copy -----------------------------------------------------

  Widget _proxyChild(_Proxy<T> proxy) => Theme(
    data: _style.itemTheme,
    child: Builder(
      builder: (context) =>
          widget.itemBuilder(context, proxy.item, proxy.details),
    ),
  );

  _Proxy<T> _spawnProxy(Object id, T item, Rect rect) {
    final location = _locations[id]!;
    final overlay = Overlay.of(context);
    final proxy = _Proxy<T>(
      id: id,
      item: item,
      details: BoardItemDetails<T>(
        column: widget.columns[location.column],
        index: location.index,
        dragging: true,
      ),
      size: rect.size,
      position: rect.topLeft,
    );
    proxy
      ..origin = (_columnIds[location.column], location.index)
      ..themes = InheritedTheme.capture(from: context, to: overlay.context)
      ..textDirection = _style.textDirection
      ..mediaQuery = context.getInheritedWidgetOfExactType<MediaQuery>()?.data
      ..child = _proxyChild(proxy)
      ..entry = OverlayEntry(
        builder: (context) => _ProxyView<T>(proxy: proxy, board: this),
      );
    overlay.insert(proxy.entry!);
    _proxies[id] = proxy;
    final slot = _slots[id];
    if (slot != null && slot.mounted) {
      slot
        .._render?.hidden = true
        .._keepAliveChanged();
    }
    return proxy;
  }

  void _removeProxy(_Proxy<T> proxy) {
    if (_proxies[proxy.id] == proxy) {
      _proxies.remove(proxy.id);
      final slot = _slots[proxy.id];
      if (slot != null && slot.mounted) {
        slot
          .._render?.hidden = false
          .._keepAliveChanged();
      }
    }
    proxy.entry?.remove();
    proxy.entry?.dispose();
    proxy.entry = null;
    proxy.dispose();
  }

  // --- Picking up ----------------------------------------------------------

  void _itemPointerDown(
    PointerDownEvent event,
    Object id, {
    required bool immediate,
  }) {
    if (!widget.enabled || _drag != null) return;
    // A handle and the item around it both see the same event; the handle,
    // which is deeper, is asked first and keeps it.
    final down = event.original ?? event;
    if (identical(down, _lastDown)) return;
    _lastDown = down;
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons != kPrimaryButton) {
      return;
    }
    final touch = switch (event.kind) {
      PointerDeviceKind.mouse || PointerDeviceKind.trackpad => false,
      _ => true,
    };
    _recognizer?.dispose();
    Drag? start(Offset position) =>
        _startPointerDrag(id, position, touch: touch);
    final settings = MediaQuery.maybeGestureSettingsOf(context);
    _recognizer =
        (touch && !immediate
              ? DelayedMultiDragGestureRecognizer(
                  delay: widget.longPressDelay,
                  debugOwner: this,
                )
              : _SlopMultiDragGestureRecognizer(
                  // A finger on a handle drags once it has left the spot; a
                  // mouse once it has moved as far as any drag has to. The
                  // board is asked first, being deepest, so at the same
                  // distance it wins the pointer from a text selection or
                  // a pan around it — and a click with a slightly unsteady
                  // hand is still a click.
                  slop: touch
                      ? computeHitSlop(event.kind, settings)
                      : computePanSlop(event.kind, settings),
                  debugOwner: this,
                ))
          ..gestureSettings = settings
          ..onStart = start
          ..addPointer(event);
  }

  _Drag<T>? _startDrag(
    Object id, {
    required _DragMode mode,
    required Offset pointer,
    required bool touch,
  }) {
    if (_drag != null || !mounted || !widget.enabled) return null;
    final location = _locations[id];
    final item = _itemAt(location);
    final slot = _slots[id];
    final box = slot != null && slot.mounted ? slot._box : null;
    if (location == null || item == null || box == null) return null;

    // An item caught while it is still flying is picked up where it is,
    // and comes to the pointer from there.
    final flying = _proxies[id];
    final rect = _cardRect(id)!;
    final proxy = flying ?? _spawnProxy(id, item, rect);
    final behind = proxy.position - rect.topLeft;
    proxy
      ..phase = _ProxyPhase.held
      ..interactive = mode == _DragMode.pointer
      ..forbidden = false
      ..fading = false
      ..settled = false
      ..opacity = 1
      ..highlight = 0
      ..holdFrames = 0
      ..predicted = null
      ..origin = (_columnIds[location.column], location.index)
      ..moveTo(proxy.position)
      ..lift.target = 1
      ..changed();

    final drag = _Drag<T>(
      id: id,
      item: item,
      mode: mode,
      proxy: proxy,
      size: proxy.size,
      extent: box.size.height,
      grab: pointer - rect.topLeft,
      pointer: pointer,
      touch: touch,
      targetColumn: _columnIds[location.column],
      targetIndex: location.index,
    )..lastX = proxy.x.value;
    drag.catchUpX.value = behind.dx;
    drag.catchUpY.value = behind.dy;
    _drag = drag;

    final outer = widget.shrinkWrap
        ? Scrollable.maybeOf(context, axis: Axis.vertical)?.position
        : null;
    _outerPosition = outer?..addListener(_scrolled);

    widget.onDragStart?.call(item);
    widget.controller?._dragChanged();
    _applyShiftTargets();
    _refreshDragVisuals(restart: true);
    _ensureTicking();
    return drag;
  }

  Drag? _startPointerDrag(
    Object id,
    Offset position, {
    required bool touch,
  }) {
    final drag = _startDrag(
      id,
      mode: _DragMode.pointer,
      pointer: position,
      touch: touch,
    );
    if (drag == null) return null;
    if (touch) HapticFeedback.mediumImpact();
    HardwareKeyboard.instance.addHandler(_handleDragKey);
    return _PointerDrag<T>(this, drag);
  }

  void _pointerMoved(_Drag<T> drag, Offset position) {
    if (drag != _drag) return;
    drag.pointer = position;
    drag.proxy
      ..moveTo(drag.position)
      ..changed();
    _updateTarget();
    _ensureTicking();
  }

  void _pointerReleased(_Drag<T> drag) {
    if (drag == _drag) _endDrag(commit: true);
  }

  void _pointerCancelled(_Drag<T> drag) {
    if (drag == _drag) _endDrag(commit: false);
  }

  bool _handleDragKey(KeyEvent event) {
    if (_drag?.mode == _DragMode.pointer &&
        event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _endDrag(commit: false);
      return true;
    }
    return false;
  }

  void _cancelDrag() => _endDrag(commit: false);

  // --- Where the dragged item would land -----------------------------------

  Rect? get _boardRect {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  bool _columnAccepts(BoardColumn<T> column, T item, Object fromColumn) {
    if (column.id == fromColumn) return true;
    if (column.isFull) return false;
    return column.canAccept?.call(item) ?? true;
  }

  /// Works the target out from where the pointer is. Called when the
  /// pointer moves and whenever anything under it does.
  void _updateTarget() {
    final drag = _drag;
    if (drag == null || drag.mode != _DragMode.pointer) return;
    final source = _locations[drag.id];
    final board = _boardRect;
    if (source == null || board == null) return;

    Object? column;
    var index = 0;
    var refused = false;
    if (board.inflate(_dropSlack).contains(drag.pointer)) {
      // The column is the one under the pointer; the index comes from the
      // card's centre, which is what the eye follows.
      _BoardColumnState<T>? nearest;
      var distance = double.infinity;
      for (final state in _columnStates.values) {
        final rect = state._rect;
        if (rect == null) continue;
        final d = drag.pointer.dx < rect.left
            ? rect.left - drag.pointer.dx
            : drag.pointer.dx > rect.right
            ? drag.pointer.dx - rect.right
            : 0.0;
        if (d < distance) {
          distance = d;
          nearest = state;
        }
      }
      if (nearest != null) {
        final target = nearest.widget.column;
        final from = _columnIds[source.column];
        column = target.id;
        final centre = drag.proxy.y.value + drag.size.height / 2;
        index = nearest._indexAt(centre, drag);
        // Staying put is not a move, and is always allowed.
        final stays = target.id == from && index == source.index;
        refused =
            !_columnAccepts(target, drag.item, from) ||
            !(stays ||
                (widget.canMove?.call(
                      BoardMove<T>(
                        item: drag.item,
                        fromColumn: from,
                        fromIndex: source.index,
                        toColumn: target.id,
                        toIndex: index,
                      ),
                    ) ??
                    true));
      }
    }

    if (column == drag.targetColumn &&
        index == drag.targetIndex &&
        refused == drag.refused) {
      // The same slot, but it may have scrolled.
      _refreshDragVisuals();
      return;
    }
    drag
      ..targetColumn = column
      ..targetIndex = index
      ..refused = refused;
    drag.proxy
      ..forbidden = refused
      ..changed();
    if (drag.touch) HapticFeedback.selectionClick();
    _applyShiftTargets();
    _refreshDragVisuals(restart: true);
  }

  /// Brings each column's colour, its trailing room and the painted slot in
  /// line with the drag.
  void _refreshDragVisuals({bool restart = false}) {
    final drag = _drag;
    final source = drag == null ? null : _locations[drag.id];
    final (slotColumn, slotIndex) = drag == null || source == null
        ? (-1, 0)
        : _effectiveTarget(drag, source);
    for (final state in _columnStates.values) {
      if (!state.mounted) continue;
      final index = state.widget.index;
      final hovered =
          drag != null && drag.targetColumn == state.widget.column.id;
      state._mood.value = !hovered
          ? _ColumnMood.idle
          : drag.refused
          ? _ColumnMood.refused
          : _ColumnMood.target;
      final holdsSlot = drag != null && index == slotColumn;
      state._trailing.value = holdsSlot && index != source?.column
          ? drag.extent
          : 0;
      state._setSlot(
        holdsSlot ? state._slotRect(slotIndex, drag) : null,
        restart: restart,
      );
    }
    if (drag != null) _ensureTicking();
  }

  /// Called when any scroll view the board cares about moves.
  void _scrolled() {
    if (_drag == null) return;
    // A position may correct itself during layout; nothing can be marked
    // dirty from there.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      _scheduleAfterFrame();
      return;
    }
    if (_drag!.mode == _DragMode.pointer) {
      _updateTarget();
    } else {
      _refreshDragVisuals();
    }
  }

  // --- Letting go ----------------------------------------------------------

  /// Ends the drag: with [commit] the item is dropped where it is, and the
  /// parent is told if that is somewhere new; without, it goes back.
  void _endDrag({required bool commit}) {
    final drag = _drag;
    if (drag == null) return;
    final proxy = drag.proxy;
    final source = _locations[drag.id];
    final item = _itemAt(source);

    BoardMove<T>? move;
    Rect? landing;
    if (commit &&
        source != null &&
        item != null &&
        drag.targetColumn != null &&
        !drag.refused) {
      final from = _columnIds[source.column];
      if (drag.targetColumn != from || drag.targetIndex != source.index) {
        move = BoardMove<T>(
          item: item,
          fromColumn: from,
          fromIndex: source.index,
          toColumn: drag.targetColumn!,
          toIndex: drag.targetIndex,
        );
        landing = _columnStates[drag.targetColumn]?._slotRect(
          drag.targetIndex,
          drag,
        );
      }
    }
    final target = _columnOf(drag.targetColumn);

    _drag = null;
    HardwareKeyboard.instance.removeHandler(_handleDragKey);
    _outerPosition?.removeListener(_scrolled);
    _outerPosition = null;

    if (_style.reduced) {
      // Nothing flies: the item is simply where the next build puts it.
      _removeProxy(proxy);
    } else {
      proxy
        ..phase = _ProxyPhase.flying
        ..interactive = false
        ..forbidden = false
        // Until the parent has rebuilt, the slot is still where it was;
        // fly to where it is about to be.
        ..predicted = landing?.topLeft
        ..holdFrames = move == null ? 0 : 1
        ..changed();
    }
    _refreshDragVisuals();
    // After a move the other items keep heading where the drag sent them:
    // that is where the parent's new lists will have them. Told to go home
    // first, they would start back for a frame and then turn round again.
    if (move == null) _applyShiftTargets();

    if (drag.touch) HapticFeedback.lightImpact();
    if (item != null) widget.onDragEnd?.call(item);
    widget.controller?._dragChanged();

    if (move != null) {
      if (drag.mode == _DragMode.keyboard) _refocus = drag.id;
      widget.onMove(move);
      _scheduleAfterFrame();
    }
    if (drag.mode == _DragMode.keyboard) {
      final strings = FinesseLocalizations.of(context).board;
      _announce(
        move == null || target == null
            ? strings.cancelled
            : strings.dropped(
                column: target.label,
                position: move.toIndex + 1,
                count: _countWithout(target, drag.id) + 1,
              ),
      );
    }
    _ensureTicking();
  }

  /// Lets go of a dragged item that is no longer on the board.
  void _abortDrag() {
    final drag = _drag;
    if (drag == null) return;
    _drag = null;
    HardwareKeyboard.instance.removeHandler(_handleDragKey);
    _outerPosition?.removeListener(_scrolled);
    _outerPosition = null;
    drag.proxy
      ..phase = _ProxyPhase.flying
      ..interactive = false
      ..fading = true;
    // Told after the frame: this is called while the board is building.
    final controller = widget.controller;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onDragEnd?.call(drag.item);
      controller?._dragChanged();
    });
  }

  /// Moves an item without a drag: for assistive technology and the
  /// controller. [toIndex] counts as `BoardMove.toIndex` does; null is the
  /// end of the column.
  bool _moveDirect(
    Object id,
    Object toColumn,
    int? toIndex, {
    bool announce = true,
  }) {
    if (!mounted) return false;
    final source = _locations[id];
    final item = _itemAt(source);
    final to = _columnOf(toColumn);
    if (source == null || item == null || to == null) return false;
    final from = _columnIds[source.column];
    final count = _countWithout(to, id);
    final index = (toIndex ?? count).clamp(0, count);
    if (to.id == from && index == source.index) return false;

    final move = BoardMove<T>(
      item: item,
      fromColumn: from,
      fromIndex: source.index,
      toColumn: to.id,
      toIndex: index,
    );
    final strings = FinesseLocalizations.of(context).board;
    if (!_columnAccepts(to, item, from) ||
        !(widget.canMove?.call(move) ?? true)) {
      if (announce) _announce(strings.refused(column: to.label));
      return false;
    }
    if (_drag?.id == id) _endDrag(commit: false);

    // Across columns the item flies; within one, it slides with the rest.
    if (to.id != from && !_style.reduced && !_proxies.containsKey(id)) {
      final rect = _cardRect(id);
      if (rect != null) {
        _spawnProxy(id, item, rect)
          ..phase = _ProxyPhase.flying
          ..holdFrames = 1
          ..lift.target = 1;
      }
    }
    if (_slots[id]?._focusNode.hasFocus ?? false) _refocus = id;
    widget.onMove(move);
    _scheduleAfterFrame();
    if (announce) {
      _announce(
        strings.dropped(
          column: to.label,
          position: index + 1,
          count: count + 1,
        ),
      );
    }
    _ensureTicking();
    return true;
  }

  void _announce(String message) {
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      _style.textDirection,
    );
  }

  // --- Keyboard ------------------------------------------------------------

  KeyEventResult _handleItemKey(_BoardSlotState<T> slot, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final drag = _drag;
    final activate =
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter;

    if (drag != null &&
        drag.mode == _DragMode.keyboard &&
        drag.id == slot.widget.id) {
      if (key == LogicalKeyboardKey.escape) {
        _endDrag(commit: false);
        return KeyEventResult.handled;
      }
      if (activate) {
        if (event is KeyDownEvent) _endDrag(commit: true);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.tab) {
        _endDrag(commit: true);
        return KeyEventResult.ignored;
      }
      final forward = _style.textDirection == TextDirection.rtl ? -1 : 1;
      if (key == LogicalKeyboardKey.arrowUp) {
        _keyboardStep(drag, rows: -1);
      } else if (key == LogicalKeyboardKey.arrowDown) {
        _keyboardStep(drag, rows: 1);
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        _keyboardStep(drag, columns: -forward);
      } else if (key == LogicalKeyboardKey.arrowRight) {
        _keyboardStep(drag, columns: forward);
      } else if (key == LogicalKeyboardKey.home) {
        _keyboardStep(drag, rows: -drag.targetIndex);
      } else if (key == LogicalKeyboardKey.end) {
        _keyboardStep(drag, rows: 1 << 20);
      } else {
        return KeyEventResult.ignored;
      }
      return KeyEventResult.handled;
    }

    if (drag == null &&
        activate &&
        event is KeyDownEvent &&
        slot._focusNode.hasPrimaryFocus) {
      final started = _startDrag(
        slot.widget.id,
        mode: _DragMode.keyboard,
        pointer: Offset.zero,
        touch: false,
      );
      if (started == null) return KeyEventResult.ignored;
      _announce(FinesseLocalizations.of(context).board.pickedUp);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// An item picked up from the keyboard is put back when focus leaves it.
  void _itemBlurred(Object id) {
    final drag = _drag;
    if (drag != null && drag.mode == _DragMode.keyboard && drag.id == id) {
      _endDrag(commit: false);
    }
  }

  void _keyboardStep(_Drag<T> drag, {int rows = 0, int columns = 0}) {
    final source = _locations[drag.id];
    final item = _itemAt(source);
    if (source == null || item == null) return;
    final from = _columnIds[source.column];
    final strings = FinesseLocalizations.of(context).board;

    var columnIndex = _columnIds.indexOf(drag.targetColumn ?? from);
    if (columnIndex < 0) columnIndex = source.column;
    var index = drag.targetIndex;
    if (columns != 0) {
      var next = columnIndex + columns;
      String? refusedBy;
      while (next >= 0 &&
          next < widget.columns.length &&
          !_columnAccepts(widget.columns[next], item, from)) {
        refusedBy ??= widget.columns[next].label;
        next += columns;
      }
      if (next < 0 || next >= widget.columns.length) {
        if (refusedBy != null) _announce(strings.refused(column: refusedBy));
        return;
      }
      columnIndex = next;
    }
    final column = widget.columns[columnIndex];
    final count = _countWithout(column, drag.id);
    index = (index + rows).clamp(0, count);

    final allowed =
        widget.canMove?.call(
          BoardMove<T>(
            item: item,
            fromColumn: from,
            fromIndex: source.index,
            toColumn: column.id,
            toIndex: index,
          ),
        ) ??
        true;
    if (!allowed && (column.id != from || index != source.index)) {
      _announce(strings.refused(column: column.label));
      return;
    }
    if (column.id == drag.targetColumn && index == drag.targetIndex) return;

    drag
      ..targetColumn = column.id
      ..targetIndex = index;
    _applyShiftTargets();
    _refreshDragVisuals(restart: true);
    _reveal(drag);
    _announce(
      strings.position(
        column: column.label,
        position: index + 1,
        count: count + 1,
      ),
    );
    _ensureTicking();
  }

  /// Scrolls the board and the target column until the slot is in view.
  void _reveal(_Drag<T> drag) {
    final columnId = drag.targetColumn;
    if (columnId == null) return;
    _showColumn(columnId);
    final state = _columnStates[columnId];
    final slot = state?._slotRect(drag.targetIndex, drag);
    final position = widget.shrinkWrap ? _outerPosition : state?._position;
    final viewport = widget.shrinkWrap ? _outerViewport : state?._listRect;
    if (slot == null || position == null || viewport == null) return;
    final margin = _style.itemGap + _style.columnPadding.bottom;
    var delta = 0.0;
    if (slot.top < viewport.top + margin) {
      delta = slot.top - viewport.top - margin;
    } else if (slot.bottom > viewport.bottom - margin) {
      delta = slot.bottom - viewport.bottom + margin;
    }
    if (delta == 0) return;
    _animateTo(position, position.pixels + delta);
  }

  void _animateTo(ScrollPosition position, double pixels) {
    final to = pixels.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if ((to - position.pixels).abs() < .5) return;
    if (_style.reduced) {
      position.jumpTo(to);
    } else {
      position.animateTo(to, duration: _style.turn, curve: _style.turnCurve);
    }
  }

  Future<void> _showColumn(Object columnId) async {
    final index = _columnIds.indexOf(columnId);
    final position = _horizontalPosition;
    final board = _boardRect;
    if (index < 0 || position == null || board == null) return;
    final step = _snapMetrics.step;
    final width = step - _style.columnGap;
    final padding = _style.padding;
    final rtl = _style.textDirection == TextDirection.rtl;
    final leading = rtl ? padding.right : padding.left;
    final trailing = rtl ? padding.left : padding.right;

    // The column's leading edge is `index * step` into the content, in
    // either text direction.
    final start = index * step;
    double to;
    if (_style.snap) {
      to = start;
    } else if (start < position.pixels) {
      to = start;
    } else if (start + leading + width + trailing >
        position.pixels + board.width) {
      to = start + leading + width + trailing - board.width;
    } else {
      return;
    }
    to = to.clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((to - position.pixels).abs() < .5) return;
    if (_style.reduced) {
      position.jumpTo(to);
      return;
    }
    await position.animateTo(
      to,
      duration: _style.turn,
      curve: _style.turnCurve,
    );
  }

  // --- Scrolling while dragging --------------------------------------------

  Rect? get _outerViewport {
    final scrollable = Scrollable.maybeOf(context, axis: Axis.vertical);
    final box = scrollable?.context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// The speed to scroll at when the pointer is at [point] between [start]
  /// and [end]: nothing in the middle, rising with the square of how far
  /// into an edge zone the pointer is.
  double _edgeSpeed(double point, double start, double end) {
    final zone = math.min(_style.autoScrollExtent, (end - start) / 3);
    if (zone <= 0) return 0;
    double depth;
    if (point < start + zone) {
      depth = -((start + zone - point) / zone).clamp(0.0, 1.0);
    } else if (point > end - zone) {
      depth = ((point - (end - zone)) / zone).clamp(0.0, 1.0);
    } else {
      return 0;
    }
    return depth * depth.abs() * _style.autoScrollSpeed;
  }

  static bool _canScroll(ScrollPosition position, double direction) =>
      direction < 0
      ? position.pixels > position.minScrollExtent
      : position.pixels < position.maxScrollExtent;

  static void _scrollBy(ScrollPosition position, double delta) {
    final to = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (to != position.pixels) position.jumpTo(to);
  }

  /// Scrolls the column under the pointer and the board itself while the
  /// pointer is near an edge. Returns whether there is more to do.
  bool _autoScroll(_Drag<T> drag, double dt) {
    var active = false;

    final column = drag.targetColumn == null
        ? null
        : _columnStates[drag.targetColumn];
    final vertical = widget.shrinkWrap ? _outerPosition : column?._position;
    final viewport = widget.shrinkWrap ? _outerViewport : column?._listRect;
    if (vertical != null && viewport != null && column != null) {
      var speed = _edgeSpeed(drag.pointer.dy, viewport.top, viewport.bottom);
      if (axisDirectionIsReversed(vertical.axisDirection)) speed = -speed;
      if (speed != 0 && _canScroll(vertical, speed)) {
        active = true;
        _scrollBy(vertical, speed * dt);
      }
    }

    final horizontal = _horizontalPosition;
    final board = _boardRect;
    if (horizontal != null && board != null) {
      var speed = _edgeSpeed(drag.pointer.dx, board.left, board.right);
      if (axisDirectionIsReversed(horizontal.axisDirection)) speed = -speed;
      if (speed == 0 || !_canScroll(horizontal, speed)) {
        drag.dwell = 0;
      } else if (!_style.snap) {
        active = true;
        _scrollBy(horizontal, speed * dt);
      } else if (!drag.turning) {
        // A board that snaps turns one column at a time, after a pause.
        active = true;
        drag.dwell += dt;
        if (drag.dwell >= _turnDwell) {
          drag.dwell = 0;
          final step = _snapMetrics.step;
          final page = (horizontal.pixels / step).round() + speed.sign;
          final to = (page * step).clamp(
            horizontal.minScrollExtent,
            horizontal.maxScrollExtent,
          );
          if (_style.reduced) {
            horizontal.jumpTo(to);
          } else {
            drag.turning = true;
            horizontal
                .animateTo(
                  to,
                  duration: _style.turn,
                  curve: _style.turnCurve,
                )
                .whenComplete(() {
                  drag.turning = false;
                  if (mounted && _drag == drag) _ensureTicking();
                });
          }
        }
      }
    }
    return active;
  }

  /// The wheel, while an item is held: the lifted copy is under the pointer
  /// and would otherwise swallow it.
  void _handleDragPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      final drag = _drag;
      if (drag == null || !mounted) return;
      var delta = (event as PointerScrollEvent).scrollDelta;
      if (HardwareKeyboard.instance.isShiftPressed && delta.dx == 0) {
        delta = Offset(delta.dy, 0);
      }
      final column = drag.targetColumn == null
          ? null
          : _columnStates[drag.targetColumn];
      final vertical = widget.shrinkWrap ? _outerPosition : column?._position;
      if (vertical != null && delta.dy != 0) _scrollBy(vertical, delta.dy);
      final horizontal = _horizontalPosition;
      if (horizontal != null && delta.dx != 0) {
        _scrollBy(
          horizontal,
          axisDirectionIsReversed(horizontal.axisDirection)
              ? -delta.dx
              : delta.dx,
        );
      }
    });
  }

  // --- The ticker ----------------------------------------------------------

  void _ensureTicking() {
    if (_ticker.isActive || !mounted) return;
    _lastTick = Duration.zero;
    _ticker.start();
  }

  /// Advances everything that moves: the items making way, the lifted
  /// copies, the slot fading in and the scrolling under a dragged item.
  /// One ticker drives it all, and stops when all of it is at rest.
  void _tick(Duration elapsed) {
    final dt =
        (elapsed - _lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    _lastTick = elapsed;
    final style = _style;
    var busy = false;

    final drag = _drag;
    if (drag != null && drag.mode == _DragMode.pointer) {
      if (_autoScroll(drag, dt)) busy = true;
    }

    _shifts.removeWhere((id, spring) {
      final moving = spring.advance(dt, style.shift);
      final slot = _slots[id];
      if (slot != null && slot.mounted) slot._render?.shift = spring.value;
      if (moving) busy = true;
      return !moving && spring.value == 0;
    });

    for (final proxy in _proxies.values.toList()) {
      if (_advanceProxy(proxy, dt)) {
        busy = true;
        proxy.changed();
      } else if (proxy.phase == _ProxyPhase.held) {
        proxy.changed();
      } else {
        _removeProxy(proxy);
      }
    }

    final fade = style.fade.inMicroseconds / Duration.microsecondsPerSecond;
    for (final state in _columnStates.values) {
      final slot = state._slot;
      if (slot.rect == null || slot.opacity >= 1) continue;
      slot
        ..opacity = fade <= 0 ? 1 : math.min(1, slot.opacity + dt / fade)
        ..changed();
      if (slot.opacity < 1) busy = true;
    }

    if (!busy) _ticker.stop();
  }

  /// Advances one lifted copy; returns whether it is still moving. A copy
  /// that has stopped and is no longer held is done.
  bool _advanceProxy(_Proxy<T> proxy, double dt) {
    final style = _style;
    final drag = _drag;

    if (proxy.phase == _ProxyPhase.held) {
      var moving = false;
      if (drag != null && drag.proxy == proxy) {
        if (drag.mode == _DragMode.keyboard) {
          // The keyboard's copy rests on the slot it would drop into.
          final rect = _columnStates[drag.targetColumn]?._slotRect(
            drag.targetIndex,
            drag,
          );
          if (rect != null) {
            proxy.x.target = rect.left;
            proxy.y.target = rect.top;
          }
          if (proxy.x.advance(dt, style.drop)) moving = true;
          if (proxy.y.advance(dt, style.drop)) moving = true;
        } else if (dt > 0) {
          // Still on its way to the pointer, if it was caught in flight.
          final catchingUp =
              drag.catchUpX.advance(dt, style.drop) |
              drag.catchUpY.advance(dt, style.drop);
          if (catchingUp || proxy.position != drag.position) {
            proxy.moveTo(drag.position);
            moving = moving || catchingUp;
          }
          // Lean into the movement, by a smoothed speed.
          final x = proxy.x.value;
          final speed = (x - drag.lastX) / dt;
          drag
            ..lastX = x
            ..speedX += (speed - drag.speedX) * (1 - math.exp(-dt * 12));
          if (drag.speedX.abs() < 4) drag.speedX = 0;
          proxy.tilt.target = style.reduced
              ? 0
              : (drag.speedX / 1400).clamp(-1.0, 1.0) * style.dragTilt;
          if (drag.speedX != 0) moving = true;
        } else {
          moving = true;
        }
      }
      if (proxy.lift.advance(dt, style.lift, tolerance: .001)) moving = true;
      if (proxy.tilt.advance(dt, style.lift, tolerance: .0002)) moving = true;
      return moving;
    }

    // Until the parent has had a frame to rebuild in, nobody knows whether
    // the item has moved: it flies, but it does not land.
    final waiting = proxy.holdFrames > 0;
    if (waiting) {
      proxy.holdFrames--;
      final predicted = proxy.predicted;
      if (predicted == null) return true;
      proxy.x.target = predicted.dx;
      proxy.y.target = predicted.dy;
    } else {
      final rect = _cardRect(proxy.id);
      if (rect != null) {
        proxy.x.target = rect.left;
        proxy.y.target = rect.top;
      } else {
        // Its slot is out of view, or the item is gone: fade on the way.
        proxy.fading = true;
        final edge = _offscreenTarget(proxy);
        if (edge != null) {
          proxy.x.target = edge.dx;
          proxy.y.target = edge.dy;
        }
      }
    }

    if (proxy.settled) {
      // Landed: stay on the slot, wherever a scroll takes it.
      proxy.moveTo(Offset(proxy.x.target, proxy.y.target));
    } else {
      proxy.x.advance(dt, style.drop);
      proxy.y.advance(dt, style.drop);
    }

    final distance =
        (Offset(proxy.x.target, proxy.y.target) - proxy.position).distance;
    if (proxy.phase == _ProxyPhase.flying &&
        !waiting &&
        distance < _touchdown) {
      proxy
        ..phase = _ProxyPhase.landing
        ..tilt.target = 0;
      final location = _locations[proxy.id];
      final moved =
          location != null &&
          proxy.origin != (_columnIds[location.column], location.index);
      if (moved && !proxy.fading) {
        // Somewhere new: press it into the slot and let it spring back,
        // with a glow.
        proxy
          ..highlight = 1
          ..lift.kickThrough(
            0,
            style.dragScale > 1
                ? (style.landScale - 1) / (style.dragScale - 1)
                : 0,
            style.land,
          );
      } else {
        proxy.lift.target = 0;
      }
    }
    if (proxy.phase == _ProxyPhase.landing &&
        proxy.x.atRest &&
        proxy.y.atRest) {
      proxy.settled = true;
    }

    final landing = proxy.phase == _ProxyPhase.landing;
    final lifting = proxy.lift.advance(
      dt,
      landing ? style.land : style.lift,
      tolerance: .001,
    );
    final tilting = proxy.tilt.advance(dt, style.lift, tolerance: .0002);
    if (landing && proxy.highlight > 0) {
      proxy.highlight = style.highlightSeconds <= 0
          ? 0
          : math.max(0, proxy.highlight - dt / style.highlightSeconds);
    }
    if (proxy.fading) {
      proxy.opacity = math.max(0, proxy.opacity - dt / .18);
      return proxy.opacity > 0;
    }
    return !proxy.settled || lifting || tilting || proxy.highlight > 0;
  }

  /// Where a copy flies to when its slot is not built: just past the edge
  /// of its column, on the side its item is.
  Offset? _offscreenTarget(_Proxy<T> proxy) {
    final location = _locations[proxy.id];
    if (location == null) return null;
    final state = _columnStates[_columnIds[location.column]];
    final list = state?._listRect;
    if (state == null || list == null) return null;
    var first = 1 << 30;
    for (final slot in state._mounted) {
      if (slot._box != null) first = math.min(first, slot.widget.index);
    }
    return Offset(
      list.left + _style.columnPadding.left,
      location.index < first ? list.top - proxy.size.height : list.bottom,
    );
  }

  // --- Build ---------------------------------------------------------------

  _BoardStyle _resolveStyle(BuildContext context) {
    final theme = Theme.of(context);
    final board = theme.boardTheme;
    final scheme = theme.colorScheme;
    final motion = Motion.of(context);
    final direction = Directionality.of(context);
    final columnColor = board.columnColor ?? scheme.muted;
    final itemRadius = board.itemRadius ?? theme.radii.xl;
    final small = theme.textTheme.small;

    MotionSpring spring(MotionSpring? own, MotionSpring fallback) =>
        motion.reduced ? MotionSpring.instant : own ?? fallback;

    return _BoardStyle(
      columnGap: widget.columnGap ?? board.columnGap ?? 16,
      itemGap: widget.itemGap ?? board.itemGap ?? 8,
      padding: (widget.padding ?? board.padding ?? EdgeInsets.zero).resolve(
        direction,
      ),
      columnPadding: (board.columnPadding ?? const EdgeInsets.all(8)).resolve(
        direction,
      ),
      headerPadding:
          (board.headerPadding ?? const EdgeInsets.fromLTRB(16, 12, 8, 8))
              .resolve(direction),
      footerPadding:
          (board.footerPadding ?? const EdgeInsets.fromLTRB(8, 0, 8, 8))
              .resolve(direction),
      columnRadius: board.columnRadius ?? theme.radii.xl2,
      columnColor: columnColor,
      columnBorderColor: board.columnBorderColor ?? const Color(0x00000000),
      targetColumnColor: board.targetColumnColor ?? columnColor,
      targetColumnBorderColor: board.targetColumnBorderColor ?? scheme.ring,
      refusedColumnColor: board.refusedColumnColor ?? columnColor,
      refusedColumnBorderColor:
          board.refusedColumnBorderColor ?? scheme.destructive,
      headerTextStyle: board.headerTextStyle ?? small,
      countTextStyle: board.countTextStyle ?? small,
      countColor: board.countColor ?? scheme.secondary,
      countForegroundColor:
          board.countForegroundColor ?? scheme.mutedForeground,
      fullCountColor:
          board.fullCountColor ?? scheme.destructive.withValues(alpha: .12),
      fullCountForegroundColor:
          board.fullCountForegroundColor ?? scheme.destructive,
      itemRadius: itemRadius,
      placeholderColor:
          board.placeholderColor ?? scheme.tint.withValues(alpha: .08),
      placeholderBorderColor:
          board.placeholderBorderColor ?? scheme.tint.withValues(alpha: .4),
      emptyHeight: board.emptyHeight ?? 72,
      dragScale: motion.reduced ? 1 : board.dragScale ?? 1.03,
      dragTilt: motion.reduced ? 0 : board.dragTilt ?? .026,
      landScale: motion.reduced ? 1 : board.landScale ?? 1,
      dragShadows: board.dragShadows ?? theme.style.floatingShadow,
      highlightColor: board.highlightColor ?? scheme.tint,
      highlightSeconds:
          (board.highlightDuration ?? motion.slow * 1.5).inMicroseconds /
          Duration.microsecondsPerSecond,
      lift: _SpringSpec(spring(board.liftSpring, motion.snappy)),
      // Without the bounce: an item that overshoots its slot reads as a
      // wobble in the whole column.
      shift: _SpringSpec(
        spring(
          board.shiftSpring,
          motion.snappy.isInstant
              ? motion.snappy
              : motion.snappy.copyWith(bounce: 0),
        ),
      ),
      drop: _SpringSpec(
        spring(
          board.dropSpring,
          motion.snappy.isInstant
              ? motion.snappy
              : motion.snappy.copyWith(bounce: 0),
        ),
      ),
      land: _SpringSpec(spring(board.landSpring, motion.bouncy)),
      fade: motion.fast,
      fadeCurve: motion.standard,
      turn: motion.slow,
      turnCurve: motion.emphasized,
      autoScrollExtent: board.autoScrollExtent ?? 64,
      autoScrollSpeed: board.autoScrollSpeed ?? 900,
      snap: widget.snap ?? board.snap ?? false,
      reduced: motion.reduced,
      itemTheme: _itemThemeOf(theme),
      textDirection: direction,
    );
  }

  /// [theme] with the card metrics of a board item. Rebuilding a theme is
  /// not free, so each one is derived once.
  static ThemeData _itemThemeOf(ThemeData theme) {
    return _itemThemes[theme] ??= () {
      final board = theme.boardTheme;
      return theme.copyWith(
        cardTheme: theme.cardTheme.copyWith(
          backgroundColor: board.itemColor,
          padding: board.itemPadding,
          radius: board.itemRadius,
          shadows: board.itemShadows,
          // An item is opaque: there is nothing for a backdrop to show, and
          // a filter per card is a great deal to pay for it.
          blur: 0,
          saturation: 1,
        ),
      );
    }();
  }

  @override
  Widget build(BuildContext context) {
    final style = _style = _resolveStyle(context);
    final board = Theme.of(context).boardTheme;
    final columns = widget.columns;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          throw FlutterError.fromParts([
            ErrorSummary('A Board was given an unbounded width.'),
            ErrorDescription(
              'A board scrolls its columns horizontally, so it has to know '
              'how wide it is.',
            ),
            ErrorHint(
              'Give it a width: put it in an Expanded, a SizedBox, or '
              'anything else that constrains it.',
            ),
          ]);
        }
        if (!widget.shrinkWrap && !constraints.hasBoundedHeight) {
          throw FlutterError.fromParts([
            ErrorSummary('A Board was given an unbounded height.'),
            ErrorDescription(
              'The columns of a board fill its height, and each scrolls its '
              'own items. Inside a vertically scrolling parent — a '
              'PageContainer(scrollable: true), a ListView, a Column in a '
              'SingleChildScrollView — there is no height to fill.',
            ),
            ErrorHint(
              'Either give the board a height (an Expanded in a Column, a '
              'SizedBox), or pass shrinkWrap: true so that every column is '
              'as tall as its items and the parent scrolls instead.',
            ),
          ]);
        }

        final padding = style.padding;
        final available = math.max<double>(
          0,
          constraints.maxWidth - padding.horizontal,
        );
        final gap = style.columnGap;
        final count = columns.length;
        final base = widget.columnWidth ?? board.columnWidth ?? 288;
        final fraction = board.columnViewportFraction;
        var width = base;
        if (widget.columnWidth == null && fraction != null) {
          // A share of the board, so the next column peeks in.
          width = math.min(base, constraints.maxWidth * fraction);
        } else if (widget.expandColumns && count > 0) {
          // Share the width out when every column fits; scroll when one
          // would have to be narrower than is comfortable.
          final fit = (available - gap * (count - 1)) / count;
          final narrowest = math.min(base, board.columnMinWidth ?? base);
          if (fit >= narrowest) {
            width = math.min(fit, math.max(base, board.columnMaxWidth ?? fit));
          }
        }
        width = math.min(width, available);
        _snapMetrics
          ..step = width + gap
          ..enabled = style.snap;

        Widget row = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.shrinkWrap
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.stretch,
          children: [
            for (final (index, column) in columns.indexed)
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: index == 0 ? 0 : gap,
                ),
                child: _BoardColumnView<T>(
                  key: ValueKey<Object>(column.id),
                  board: this,
                  column: column,
                  index: index,
                  width: width,
                ),
              ),
          ],
        );
        if (!widget.shrinkWrap) {
          row = SizedBox(
            height: math.max(0, constraints.maxHeight - padding.vertical),
            child: row,
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _horizontal,
          physics: _BoardSnapPhysics(metrics: _snapMetrics),
          padding: padding,
          child: row,
        );
      },
    );
  }
}
