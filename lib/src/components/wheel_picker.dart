import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ClipOp;

import 'package:finesse/src/components/glass.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/text_scaled_height.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// One row of a [WheelPicker].
@immutable
class WheelPickerItem<T> {
  /// Creates a row that stands for [value] and reads [label].
  const WheelPickerItem({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  /// What the wheel reports when this row is under the lens.
  final T value;

  /// The text of the row. It is also what assistive technology reads and
  /// what typing on a keyboard searches.
  final String label;

  /// Whether the wheel can rest on this row. The wheel rolls on past a
  /// disabled row and never reports it.
  final bool enabled;
}

/// Returns the row at [index] of a [WheelPicker.builder].
typedef WheelPickerItemBuilder<T> = WheelPickerItem<T> Function(int index);

/// A wheel of rows, one of which rests under a lens.
///
/// ```dart
/// WheelPicker<int>(
///   value: _minutes,
///   onChanged: (value) => setState(() => _minutes = value),
///   items: [
///     for (var m = 0; m < 60; m += 5)
///       WheelPickerItem(value: m, label: '$m min'),
///   ],
/// )
/// ```
///
/// The wheel is the phone's way of choosing from a short, ordered list — an
/// hour, a day, a unit — where a desktop would open a menu. It scrolls with
/// the platform's own momentum and settles on a row; the row under the lens
/// is drawn in the foreground colour and slightly magnified, the others are
/// muted, turn away and fade towards the edges. On a touch screen each row
/// that passes the lens gives a haptic tick.
///
/// It is controlled: [onChanged] reports the row under the lens as the wheel
/// turns, and the wheel comes to rest on [value]. A parent that does not
/// take a reported value gets the wheel rolled back to the one it holds; a
/// [value] changed from outside is rolled to. [onChangeEnd] reports once,
/// when the wheel has stopped.
///
/// With a mouse the wheel moves one row per notch and a click on a row
/// brings it under the lens; with a keyboard the arrow keys, Page Up, Page
/// Down, Home and End move it and typing jumps to the row that starts with
/// what was typed. To assistive technology it is one adjustable control.
///
/// Rows are text, drawn by the wheel itself: turning it paints and never
/// lays out or builds, however long the list. Put several wheels in a
/// [WheelPickerGroup] to share one lens.
class WheelPicker<T> extends StatefulWidget {
  /// Creates a wheel over [items].
  const WheelPicker({
    required List<WheelPickerItem<T>> this.items,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.itemExtent,
    this.visibleItems = 5,
    this.looping = false,
    this.width,
    this.alignment = AlignmentDirectional.center,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    super.key,
  }) : itemCount = null,
       itemBuilder = null,
       indexOf = null,
       sizingLabels = null,
       assert(visibleItems > 0, 'A wheel shows at least one row.');

  /// Creates a wheel whose rows are made on demand, for a long list — the
  /// years of a century, the days of a year.
  ///
  /// [itemBuilder] returns the row at an index from 0 to [itemCount] − 1 and
  /// [indexOf] is its inverse: the index of the row that stands for a value.
  ///
  /// ```dart
  /// WheelPicker<int>.builder(
  ///   itemCount: 201,
  ///   itemBuilder: (index) =>
  ///       WheelPickerItem(value: 1900 + index, label: '${1900 + index}'),
  ///   indexOf: (year) => year - 1900,
  ///   value: _year,
  ///   onChanged: (year) => setState(() => _year = year),
  /// )
  /// ```
  const WheelPicker.builder({
    required int this.itemCount,
    required WheelPickerItemBuilder<T> this.itemBuilder,
    required int Function(T value) this.indexOf,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.itemExtent,
    this.visibleItems = 5,
    this.looping = false,
    this.width,
    this.sizingLabels,
    this.alignment = AlignmentDirectional.center,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    super.key,
  }) : items = null,
       assert(itemCount >= 0, 'A wheel cannot have a negative row count.'),
       assert(visibleItems > 0, 'A wheel shows at least one row.');

  /// The rows, first at the top.
  final List<WheelPickerItem<T>>? items;

  /// The number of rows of a [WheelPicker.builder].
  final int? itemCount;

  /// Makes the row at an index of a [WheelPicker.builder].
  final WheelPickerItemBuilder<T>? itemBuilder;

  /// The index of the row that stands for a value, in a
  /// [WheelPicker.builder].
  final int Function(T value)? indexOf;

  /// The value of the row the wheel rests on.
  final T value;

  /// Called with the value of the row under the lens whenever another
  /// enabled row arrives there, also while the wheel is still turning.
  final ValueChanged<T> onChanged;

  /// Called once the wheel has come to rest on another row than the one it
  /// last rested on.
  final ValueChanged<T>? onChangeEnd;

  /// The height of a row. Defaults to the theme's, which is a touch target
  /// on a phone, and grows with the text scale. Inside a
  /// [WheelPickerGroup] the group's is used.
  final double? itemExtent;

  /// How many rows fit in the wheel's height; the wheel is that many
  /// [itemExtent]s tall. Inside a [WheelPickerGroup] the group's is used.
  final int visibleItems;

  /// Whether the rows repeat without end, so that the first follows the
  /// last.
  final bool looping;

  /// The wheel's width. Defaults to the width of its widest label and the
  /// theme's padding; `double.infinity` fills the room the parent gives.
  ///
  /// A [WheelPicker.builder] with more than 64 rows measures a sample of
  /// them; give [sizingLabels] when the rows differ much in width.
  final double? width;

  /// The labels a [WheelPicker.builder] is made wide enough for, in place
  /// of a sample of its rows: the widest things a row can read, such as
  /// each weekday with each month.
  final List<String>? sizingLabels;

  /// Where a label sits across the wheel's width.
  final AlignmentGeometry alignment;

  /// Whether the wheel can be turned.
  final bool enabled;

  /// The focus node of the wheel.
  final FocusNode? focusNode;

  /// Whether the wheel takes the focus when it first appears.
  final bool autofocus;

  /// What the wheel chooses, for assistive technology: "Hour", "Month".
  final String? semanticLabel;

  @override
  State<WheelPicker<T>> createState() => _WheelPickerState<T>();
}

/// What the wheel's render object asks for while it paints.
abstract interface class _WheelSource {
  /// The number of rows.
  int get count;

  /// The label of the row at [index], from 0 to [count] − 1.
  String labelAt(int index);

  /// Whether the row at [index] can be rested on.
  bool enabledAt(int index);
}

/// The one number the wheel's physics needs. A `Scrollable` keeps the
/// physics it was first given while their type stays the same, so the
/// extent is read through an object that lives as long as the wheel.
class _WheelMetrics {
  double itemExtent = 1;
}

class _WheelPickerState<T> extends State<WheelPicker<T>>
    implements _WheelSource {
  ScrollController? _controller;
  FocusNode? _ownNode;
  final _metrics = _WheelMetrics();

  /// Rows a builder has made, until the widget is next rebuilt.
  final _built = <int, WheelPickerItem<T>>{};

  /// Bumped whenever the rows may read differently, to repaint the wheel.
  int _revision = 0;

  /// The index, from 0 to [count] − 1, last reported or last given by the
  /// parent: where the wheel is meant to rest.
  int _reported = 0;

  /// The index last reported through `onChangeEnd`.
  int _rested = 0;

  /// The row nearest the lens. Not wrapped: a looping wheel counts on.
  int _centre = 0;

  /// The row a move of the wheel's own is heading for.
  int? _pending;
  BallisticScrollActivity? _drive;

  /// Whether a finger, a pointer or their momentum is turning the wheel.
  bool _userDriven = false;

  /// Whether the wheel is rolling to the value its parent holds. The rows
  /// it passes on the way are nobody's choice and are not reported.
  bool _correcting = false;
  bool _touch = false;
  int _pointers = 0;
  bool _movingAtDown = false;
  bool _silent = false;
  bool _showFocus = false;
  int _visible = 5;

  String _typed = '';
  Timer? _typedReset;

  double _wheelDelta = 0;
  Duration _wheelStepAt = Duration.zero;

  final _viewportKey = GlobalKey();

  List<String>? _measuredLabels;
  Object? _measuredKey;
  double _measuredWidth = 0;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'WheelPicker'));

  double get _extent => _metrics.itemExtent;

  @override
  int get count => widget.items?.length ?? widget.itemCount!;

  bool get _looping => widget.looping && count > 1;

  WheelPickerItem<T> _itemAt(int index) {
    final items = widget.items;
    if (items != null) return items[index];
    final cached = _built[index];
    if (cached != null) return cached;
    if (_built.length > 512) _built.clear();
    return _built[index] = widget.itemBuilder!(index);
  }

  @override
  String labelAt(int index) => _itemAt(index).label;

  @override
  bool enabledAt(int index) => _itemAt(index).enabled;

  int _indexOf(T value) {
    final items = widget.items;
    final index = items != null
        ? items.indexWhere((item) => item.value == value)
        : widget.indexOf!(value);
    return index >= 0 && index < count ? index : -1;
  }

  /// The row index [raw] stands for: wrapped on a looping wheel, held to
  /// the ends otherwise.
  int _wrap(int raw) {
    final n = count;
    if (n == 0) return 0;
    return _looping ? ((raw % n) + n) % n : raw.clamp(0, n - 1);
  }

  /// The turn of the wheel nearest to where it is that shows [index].
  int _nearest(int index) {
    if (!_looping) return index;
    final from = _pending ?? _centre;
    return index + ((from - index) / count).round() * count;
  }

  ScrollPosition? get _position {
    final controller = _controller;
    return controller != null && controller.hasClients
        ? controller.position
        : null;
  }

  @override
  void initState() {
    super.initState();
    _reported = math.max(0, _indexOf(widget.value));
    _rested = _reported;
    _centre = _reported;
  }

  @override
  void didUpdateWidget(WheelPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.items, oldWidget.items) ||
        widget.itemBuilder != oldWidget.itemBuilder ||
        widget.itemCount != oldWidget.itemCount) {
      _built.clear();
      _revision++;
    }
    final target = _indexOf(widget.value);
    if (target < 0 || target == _reported) return;
    // While the wheel is in the user's hand the parent's word waits; it is
    // heard when the wheel stops.
    if (_userDriven || _pointers > 0) return;
    _reported = target;
    _rested = target;
    final raw = _nearest(target);
    if (widget.value == oldWidget.value ||
        Motion.of(context).snappy.isInstant) {
      // The same value at another place in a new list: nothing moved, so
      // nothing is seen to move.
      _jumpSilently(raw);
    } else {
      _pending = raw;
      _correcting = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pending == raw) _animateTo(raw);
      });
    }
  }

  @override
  void dispose() {
    _typedReset?.cancel();
    _controller?.dispose();
    _ownNode?.dispose();
    super.dispose();
  }

  void _jumpSilently(int raw) {
    _centre = raw;
    _pending = null;
    _drive = null;
    _revision++;
    final position = _position;
    if (position == null) return;
    final pixels = raw * _extent;
    if (!position.hasContentDimensions) {
      position.correctPixels(pixels);
      return;
    }
    _silent = true;
    position.jumpTo(pixels);
    _silent = false;
  }

  void _animateTo(int raw) {
    final position = _position;
    if (position == null || count == 0) return;
    final clamped = _looping ? raw : raw.clamp(0, count - 1);
    final target = clamped * _extent;
    if ((position.pixels - target).abs() < .01) {
      _pending = null;
      return;
    }
    // Without its bounce: a wheel that rolls past its row and back reads
    // as two choices.
    final snappy = Motion.of(context).snappy;
    final spring = snappy.bounce > 0 ? snappy.copyWith(bounce: 0) : snappy;
    if (spring.isInstant || position is! ScrollPositionWithSingleContext) {
      _pending = null;
      position.jumpTo(target);
      return;
    }
    _pending = clamped;
    // A spring that starts at the speed the wheel already has, so a key held
    // down, or a new target given mid-roll, never restarts from a
    // standstill.
    final drive = BallisticScrollActivity(
      position,
      spring.simulation(
        start: position.pixels,
        end: target,
        velocity: _drive?.velocity ?? 0,
        tolerance: .05,
      ),
      position.context.vsync,
      false,
    );
    position.beginActivity(drive);
    _drive = drive;
  }

  /// The enabled row nearest to [raw] looking in direction [step], then
  /// back towards [from]; null when there is none.
  int? _enabledNear(int raw, int step, int from) {
    final n = count;
    for (var i = 0, r = raw; i < n; i++, r += step) {
      if (!_looping && (r < 0 || r >= n)) break;
      if (enabledAt(_wrap(r))) return r;
    }
    for (var r = raw - step; r != from; r -= step) {
      if (!_looping && (r < 0 || r >= n)) break;
      if (enabledAt(_wrap(r))) return r;
    }
    return null;
  }

  /// Moves [delta] rows on from where the wheel is, or is heading.
  bool _moveBy(int delta) {
    if (count == 0 || delta == 0) return false;
    final from = _pending ?? _centre;
    var raw = from + delta;
    if (!_looping) raw = raw.clamp(0, count - 1);
    final target = _enabledNear(raw, delta.sign, from);
    if (target == null || target == from) return false;
    _userDriven = false;
    _correcting = false;
    _touch = false;
    _animateTo(target);
    return true;
  }

  /// Moves to the first enabled row at or after [index], looking in
  /// direction [step].
  void _moveTo(int index, int step) {
    if (count == 0) return;
    final from = _pending ?? _centre;
    final target = _enabledNear(_nearest(index), step, from);
    if (target == null || target == from) return;
    _userDriven = false;
    _correcting = false;
    _touch = false;
    _animateTo(target);
  }

  void _onScroll() {
    final position = _position;
    if (_silent || position == null || count == 0) return;
    final raw = (position.pixels / _extent).round();
    if (raw == _centre) return;
    final before = _wrap(_centre);
    _centre = raw;
    final index = _wrap(raw);
    // Past either end of a wheel that does not loop there is no new row.
    if (index == before || _correcting) return;
    if (_touch && _userDriven) HapticFeedback.selectionClick();
    if (index == _reported || !enabledAt(index)) return;
    _reported = index;
    final value = _itemAt(index).value;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      // A correction made during layout: the parent cannot be rebuilt from
      // here.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged(value);
      });
    } else {
      widget.onChanged(value);
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      if (notification.dragDetails != null) {
        _userDriven = true;
        _correcting = false;
        _pending = null;
        _drive = null;
      }
    } else if (notification is ScrollEndNotification) {
      _scheduleReconcile();
    }
    // The wheel's scrolling is its own affair: a scrollbar or a
    // pull-to-refresh around it has nothing to follow.
    return true;
  }

  void _scheduleReconcile() {
    // After the frame, so a parent that took the last reported value has
    // been rebuilt with it.
    SchedulerBinding.instance
      ..addPostFrameCallback((_) => _reconcile())
      ..ensureVisualUpdate();
  }

  /// Once the wheel has stopped: the parent has the last word on where.
  void _reconcile() {
    final position = _position;
    if (!mounted || position == null || _pointers > 0) return;
    if (position.isScrollingNotifier.value) return;
    _userDriven = false;
    _drive = null;
    _pending = null;
    if (count == 0) return;
    final target = _indexOf(widget.value);
    final index = _wrap(_centre);
    if (target >= 0 && target != index) {
      // What the wheel says it is on is built from this.
      if (_reported != target) setState(() => _reported = target);
      _correcting = true;
      _animateTo(_nearest(target));
      return;
    }
    _correcting = false;
    // A simulation stops within its tolerance of the row, a fraction of a
    // pixel off. Text drawn there is soft, so the last of it is taken up.
    final exact = _centre * _extent;
    if (position.pixels != exact && (position.pixels - exact).abs() < 1) {
      position.correctPixels(exact);
      _viewportKey.currentContext?.findRenderObject()?.markNeedsPaint();
    }
    if (index != _rested) {
      _rested = index;
      widget.onChangeEnd?.call(_itemAt(index).value);
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointers++;
    _touch =
        event.kind == PointerDeviceKind.touch ||
        event.kind == PointerDeviceKind.stylus;
    _movingAtDown = _position?.isScrollingNotifier.value ?? false;
  }

  void _onPointerEnd(PointerEvent event) {
    _pointers = math.max(0, _pointers - 1);
    if (_pointers == 0) _scheduleReconcile();
  }

  void _onPointerSignal(PointerSignalEvent event) {
    // A trackpad scrolls by distance and is left to the scrollable; a mouse
    // wheel moves row by row.
    if (event is! PointerScrollEvent || event.kind != PointerDeviceKind.mouse) {
      return;
    }
    final delta = event.scrollDelta.dy != 0
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;
    if (delta == 0 || count == 0) return;
    final step = delta.sign.toInt();
    final from = _pending ?? _centre;
    // At the end of a wheel that does not loop the scroll belongs to
    // whatever is around it.
    if (!_looping && (from + step < 0 || from + step >= count)) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      if (_wheelDelta.sign != delta.sign) _wheelDelta = 0;
      _wheelDelta += delta;
      // One row per notch. A free-spinning wheel reports many small steps:
      // those are taken a row at a time as they add up.
      final since = event.timeStamp - _wheelStepAt;
      if (since.abs() < const Duration(milliseconds: 60) &&
          _wheelDelta.abs() < _extent) {
        return;
      }
      _wheelDelta = 0;
      _wheelStepAt = event.timeStamp;
      _moveBy(step);
    });
  }

  void _onTapUp(TapUpDetails details, double height, double curvature) {
    final position = _position;
    if (position == null || count == 0) return;
    if (details.kind == PointerDeviceKind.mouse) _focusNode.requestFocus();
    // A touch on a turning wheel stops it; it does not also choose a row.
    if (_movingAtDown) return;
    final y = details.localPosition.dy - height / 2;
    final distance = _WheelGeometry(
      halfHeight: height / 2,
      curvature: curvature,
    ).unproject(y);
    final raw = ((position.pixels + distance) / _extent).round();
    if (!_looping && (raw < 0 || raw >= count)) return;
    if (raw == _centre || !enabledAt(_wrap(raw))) return;
    _userDriven = false;
    _correcting = false;
    _animateTo(raw);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!widget.enabled || event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final page = math.max(1, _visible - 1);
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveBy(1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _moveBy(-1);
    } else if (key == LogicalKeyboardKey.pageDown) {
      _moveBy(page);
    } else if (key == LogicalKeyboardKey.pageUp) {
      _moveBy(-page);
    } else if (key == LogicalKeyboardKey.home) {
      _moveTo(0, 1);
    } else if (key == LogicalKeyboardKey.end) {
      _moveTo(count - 1, -1);
    } else {
      final character = event.character;
      final keyboard = HardwareKeyboard.instance;
      if (event is! KeyDownEvent ||
          character == null ||
          character.trim().isEmpty ||
          keyboard.isControlPressed ||
          keyboard.isMetaPressed ||
          keyboard.isAltPressed) {
        return KeyEventResult.ignored;
      }
      return _typeAhead(character)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  /// Jumps to the next row whose label starts with what has been typed.
  bool _typeAhead(String character) {
    _typedReset?.cancel();
    _typedReset = Timer(const Duration(seconds: 1), () => _typed = '');
    bool search(String typed) {
      final n = count;
      final from = _wrap(_pending ?? _centre);
      // One letter typed again steps through the rows that start with it.
      final start = typed.length == 1 ? from + 1 : from;
      for (var i = 0; i < n; i++) {
        final index = (start + i) % n;
        final item = _itemAt(index);
        if (!item.enabled) continue;
        final label = item.label.toLowerCase();
        // "7" finds "07".
        final bare = label.replaceFirst(RegExp(r'^0+(?=\d)'), '');
        if (label.startsWith(typed) || bare.startsWith(typed)) {
          final target = _nearest(index);
          if (target != (_pending ?? _centre)) {
            _userDriven = false;
            _correcting = false;
            _touch = false;
            _animateTo(target);
          }
          return true;
        }
      }
      return false;
    }

    final typed = _typed + character.toLowerCase();
    if (search(typed)) {
      _typed = typed;
      return true;
    }
    // Nothing starts with all of it: begin again from this letter.
    _typed = character.toLowerCase();
    if (search(_typed)) return true;
    _typed = '';
    return false;
  }

  /// The width the labels need, measured when they or their style change.
  double _widthFor(
    TextStyle style,
    TextScaler scaler,
    double magnification,
    EdgeInsets padding,
    TextDirection direction,
  ) {
    final n = count;
    // Every row of a short list; an even sample of a long one.
    final sample =
        widget.sizingLabels ??
        (n <= 64
            ? [for (var i = 0; i < n; i++) labelAt(i)]
            : [for (var i = 0; i < 64; i++) labelAt(i * (n - 1) ~/ 63)]);
    final key = (style, scaler, magnification, padding, direction);
    if (key == _measuredKey && listEquals(sample, _measuredLabels)) {
      return _measuredWidth;
    }
    var widest = 0.0;
    final painter = TextPainter(
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    );
    for (final label in sample) {
      painter
        ..text = TextSpan(text: label, style: style)
        ..layout();
      widest = math.max(widest, painter.width);
    }
    painter.dispose();
    _measuredKey = key;
    _measuredLabels = sample;
    return _measuredWidth =
        (widest * magnification).ceilToDouble() + padding.horizontal;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wheel = theme.wheelPickerTheme;
    final group = _WheelGroupScope.maybeOf(context);
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);

    _visible = group?.visibleItems ?? widget.visibleItems;
    final extent = textScaledMaxHeight(
      context,
      group?.itemExtent ?? widget.itemExtent ?? wheel.itemExtent ?? 36,
    );
    _metrics.itemExtent = extent;
    final controller = _controller ??= ScrollController(
      initialScrollOffset: _centre * extent,
      keepScrollOffset: false,
    )..addListener(_onScroll);

    final scheme = theme.colorScheme;
    final textStyle = theme.textTheme.p
        .copyWith(color: scheme.mutedForeground)
        .merge(wheel.textStyle);
    final selectedStyle = theme.textTheme.p
        .copyWith(color: scheme.foreground)
        .merge(wheel.selectedTextStyle);
    final padding = (wheel.itemPadding ?? EdgeInsets.zero).resolve(direction);
    final magnification = wheel.lensMagnification ?? 1;
    final curvature = wheel.curvature ?? 0;
    final radius = wheel.lensBorderRadius ?? theme.radius;
    final width =
        widget.width ??
        _widthFor(selectedStyle, scaler, magnification, padding, direction);
    final height = extent * _visible;

    // To assistive technology the wheel is on the row it rests on or is
    // rolling to, not on whichever row is passing the lens.
    final index = count == 0 ? null : _reported.clamp(0, count - 1);
    String? labelNear(int step) {
      if (index == null) return null;
      final from = _nearest(index);
      final raw = _enabledNear(from + step, step, from);
      return raw == null || raw == from ? null : labelAt(_wrap(raw));
    }

    final next = widget.enabled ? labelNear(1) : null;
    final previous = widget.enabled ? labelNear(-1) : null;

    Widget content = NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) => true,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: Scrollable(
          controller: controller,
          excludeFromSemantics: true,
          physics: _WheelPhysics(
            metrics: _metrics,
            parent: const BouncingScrollPhysics(),
          ),
          // A wheel is turned by whatever points at it, a mouse included,
          // and shows neither a scrollbar nor an overscroll glow.
          scrollBehavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            overscroll: false,
            dragDevices: PointerDeviceKind.values.toSet(),
          ),
          viewportBuilder: (context, offset) => Listener(
            onPointerDown: _onPointerDown,
            onPointerUp: _onPointerEnd,
            onPointerCancel: _onPointerEnd,
            onPointerSignal: _onPointerSignal,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => _onTapUp(details, height, curvature),
              child: _WheelViewport(
                key: _viewportKey,
                offset: offset,
                source: this,
                revision: _revision,
                itemExtent: extent,
                visibleItems: _visible,
                width: width,
                looping: _looping,
                textStyle: textStyle,
                selectedTextStyle: selectedStyle,
                disabledOpacity: wheel.disabledOpacity ?? .4,
                padding: padding,
                alignX: widget.alignment.resolve(direction).x,
                textDirection: direction,
                textScaler: scaler,
                // A group's lens is one shape across its wheels.
                lensRadius: group == null ? radius : BorderRadius.zero,
                magnification: magnification,
                curvature: curvature,
                edgeFade: wheel.edgeFade ?? 0,
                enabled: widget.enabled,
              ),
            ),
          ),
        ),
      ),
    );

    content = Stack(
      alignment: Alignment.center,
      children: [
        if (group == null)
          Positioned.fill(
            child: Center(child: _WheelLens(height: extent)),
          ),
        content,
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: FocusRing(
                visible: _showFocus && widget.enabled,
                borderRadius: radius,
                // Beside another wheel of a group there is no room outside.
                inset: group != null,
                child: SizedBox(height: extent, width: double.infinity),
              ),
            ),
          ),
        ),
      ],
    );

    return Semantics(
      container: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      value: index == null ? null : labelAt(index),
      increasedValue: next,
      decreasedValue: previous,
      onIncrease: next == null ? null : () => _moveBy(1),
      onDecrease: previous == null ? null : () => _moveBy(-1),
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _onKey,
        child: FocusableActionDetector(
          enabled: widget.enabled,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          onShowFocusHighlight: (value) {
            if (_showFocus != value) setState(() => _showFocus = value);
          },
          child: IgnorePointer(
            ignoring: !widget.enabled,
            child: ExcludeSemantics(child: content),
          ),
        ),
      ),
    );
  }
}

/// The lens: a piece of glass laid over the row the wheel rests on.
class _WheelLens extends StatelessWidget {
  const _WheelLens({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wheel = theme.wheelPickerTheme;
    final borderWidth = wheel.lensBorderWidth ?? 0;
    // It lies on the flat surface the wheel is in, so it is glass without a
    // filter: there is nothing behind it to blur.
    return Glass(
      frosted: false,
      height: height,
      width: double.infinity,
      color: wheel.lensColor ?? theme.colorScheme.muted,
      borderRadius: wheel.lensBorderRadius ?? theme.radius,
      border: Border.fromBorderSide(
        borderWidth > 0
            ? BorderSide(
                color: wheel.lensBorderColor ?? theme.colorScheme.border,
                width: borderWidth,
              )
            : BorderSide.none,
      ),
    );
  }
}

/// Several [WheelPicker]s side by side under one lens.
///
/// ```dart
/// WheelPickerGroup(
///   children: [
///     WheelPicker<int>(value: _hours, onChanged: _setHours, items: hours),
///     const Text('h'),
///     WheelPicker<int>(value: _minutes, onChanged: _setMinutes, items: mins),
///     const Text('min'),
///   ],
/// )
/// ```
///
/// The group draws the lens once across all of its children and gives its
/// wheels one row height and one number of visible rows. A child that is not
/// a wheel — a colon, a unit — is centred on the lens and set in the style
/// of the selected row.
class WheelPickerGroup extends StatelessWidget {
  /// Creates a group of wheels that share a lens.
  const WheelPickerGroup({
    required this.children,
    this.itemExtent,
    this.visibleItems = 5,
    this.alignment = Alignment.center,
    this.mainAxisSize = MainAxisSize.min,
    super.key,
  }) : assert(visibleItems > 0, 'A wheel shows at least one row.');

  /// The wheels, and whatever stands between them, in reading order.
  final List<Widget> children;

  /// The height of a row in every wheel of the group. Defaults to the
  /// theme's.
  final double? itemExtent;

  /// How many rows fit in the height of the group.
  final int visibleItems;

  /// Where the children sit when the group is wider than they are.
  final AlignmentGeometry alignment;

  /// Whether the group, and with it the lens, is as wide as its children
  /// need or as wide as its parent allows.
  final MainAxisSize mainAxisSize;

  /// Whether [context] is inside a group, and so already under a lens.
  ///
  /// A widget made of several wheels asks before it builds a group of its
  /// own: inside one it lays its wheels out bare and shares the lens.
  static bool encloses(BuildContext context) =>
      _WheelGroupScope.maybeOf(context) != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wheel = theme.wheelPickerTheme;
    final base = itemExtent ?? wheel.itemExtent ?? 36;
    final extent = textScaledMaxHeight(context, base);
    // Wheels are as wide as their labels, whatever room there is. Where
    // there is less — a narrow screen, a large text scale — the group is
    // shown whole and smaller rather than cut off.
    final wheels = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: wheel.gap ?? 0,
        children: children,
      ),
    );
    return _WheelGroupScope(
      itemExtent: base,
      visibleItems: visibleItems,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Center(child: _WheelLens(height: extent)),
          ),
          Padding(
            padding: wheel.groupPadding ?? EdgeInsets.zero,
            child: DefaultTextStyle.merge(
              style: theme.textTheme.p
                  .copyWith(color: theme.colorScheme.foreground)
                  .merge(wheel.selectedTextStyle),
              child: mainAxisSize == MainAxisSize.max
                  ? Align(alignment: alignment, child: wheels)
                  : wheels,
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelGroupScope extends InheritedWidget {
  const _WheelGroupScope({
    required this.itemExtent,
    required this.visibleItems,
    required super.child,
  });

  final double itemExtent;
  final int visibleItems;

  static _WheelGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_WheelGroupScope>();

  @override
  bool updateShouldNotify(_WheelGroupScope oldWidget) =>
      oldWidget.itemExtent != itemExtent ||
      oldWidget.visibleItems != visibleItems;
}

/// Scroll physics that bring the wheel to rest on a row.
class _WheelPhysics extends ScrollPhysics {
  const _WheelPhysics({required this.metrics, super.parent});

  final _WheelMetrics metrics;

  @override
  _WheelPhysics applyTo(ScrollPhysics? ancestor) =>
      _WheelPhysics(metrics: metrics, parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Beyond an end the wheel springs back as any list does.
    if ((velocity <= 0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final extent = metrics.itemExtent;
    final tolerance = toleranceFor(position);
    // Where the momentum alone would take it, and the row nearest to that.
    final free = super.createBallisticSimulation(position, velocity);
    final landing = free?.x(double.infinity) ?? position.pixels;
    if (free != null &&
        (landing <= position.minScrollExtent ||
            landing >= position.maxScrollExtent)) {
      return free;
    }
    final target = (landing / extent).round() * extent;
    if (velocity.abs() < tolerance.velocity &&
        (target - position.pixels).abs() < tolerance.distance) {
      return null;
    }
    // Onto the row it is already at: a spring. Onto another: the friction
    // of the fling, arriving there exactly.
    if ((target - position.pixels).abs() < extent / 2 ||
        velocity.abs() < tolerance.velocity) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return FrictionSimulation.through(
      position.pixels,
      target,
      velocity,
      tolerance.velocity * velocity.sign,
    );
  }
}

/// How the flat list of rows is bent onto the wheel.
///
/// Distances are in logical pixels from the centre of the wheel: along the
/// list ("distance") and as drawn ("offset").
class _WheelGeometry {
  _WheelGeometry({required this.halfHeight, required double curvature})
    : maxAngle = curvature.clamp(0.0, 1.0) * 1.1;

  final double halfHeight;

  /// The angle, in radians, at which the wheel's rim meets the edge.
  final double maxAngle;

  bool get flat => maxAngle < 1e-3 || halfHeight <= 0;

  /// The radius of the wheel.
  double get radius => halfHeight / math.sin(maxAngle);

  /// How far along the list the wheel shows on either side of its centre.
  double get reach => flat ? halfHeight : radius * maxAngle;

  /// The distance along the list drawn at [offset].
  double unproject(double offset) {
    if (flat) return offset;
    return radius * math.asin((offset / radius).clamp(-1.0, 1.0));
  }
}

class _WheelViewport extends LeafRenderObjectWidget {
  const _WheelViewport({
    required this.offset,
    required this.source,
    required this.revision,
    required this.itemExtent,
    required this.visibleItems,
    required this.width,
    required this.looping,
    required this.textStyle,
    required this.selectedTextStyle,
    required this.disabledOpacity,
    required this.padding,
    required this.alignX,
    required this.textDirection,
    required this.textScaler,
    required this.lensRadius,
    required this.magnification,
    required this.curvature,
    required this.edgeFade,
    required this.enabled,
    super.key,
  });

  final ViewportOffset offset;
  final _WheelSource source;
  final int revision;
  final double itemExtent;
  final int visibleItems;
  final double width;
  final bool looping;
  final TextStyle textStyle;
  final TextStyle selectedTextStyle;
  final double disabledOpacity;
  final EdgeInsets padding;
  final double alignX;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final BorderRadius lensRadius;
  final double magnification;
  final double curvature;
  final double edgeFade;
  final bool enabled;

  @override
  RenderWheel createRenderObject(BuildContext context) => RenderWheel._(this);

  @override
  void updateRenderObject(BuildContext context, RenderWheel renderObject) {
    renderObject._update(this);
  }
}

class _WheelLabel {
  _WheelLabel(this.label, this.enabled, this.painter);

  final String label;
  final bool enabled;
  final TextPainter painter;
}

/// The render object of a `WheelPicker`: it paints the rows around a scroll
/// offset and repaints, without laying anything out, when the offset moves.
///
/// Public for tests, which read [debugLayoutCount] and [debugPaintCount]; it
/// is not exported from the package.
@visibleForTesting
class RenderWheel extends RenderBox {
  RenderWheel._(this._config);

  _WheelViewport _config;

  /// How many times this wheel has been laid out.
  int debugLayoutCount = 0;

  /// How many times this wheel has been painted.
  int debugPaintCount = 0;

  /// Rows laid out for painting, oldest first. A row has one entry for the
  /// lens and one for each step of the fade it has been drawn at.
  final _labels = <int, _WheelLabel>{};
  double? _laidOutExtent;
  int? _laidOutCount;

  static const _fadeSteps = 12;
  static const _lensStep = _fadeSteps + 1;
  static const _stepsPerRow = 16;
  static const _maxLabels = 256;

  void _update(_WheelViewport config) {
    final old = _config;
    _config = config;
    if (!identical(old.offset, config.offset)) {
      if (attached) {
        old.offset.removeListener(markNeedsPaint);
        config.offset.addListener(markNeedsPaint);
      }
      markNeedsLayout();
    }
    if (old.textStyle != config.textStyle ||
        old.selectedTextStyle != config.selectedTextStyle ||
        old.disabledOpacity != config.disabledOpacity ||
        old.textDirection != config.textDirection ||
        old.textScaler != config.textScaler ||
        old.enabled != config.enabled ||
        old.padding != config.padding ||
        old.magnification != config.magnification) {
      _disposeLabels();
    }
    if (old.itemExtent != config.itemExtent ||
        old.visibleItems != config.visibleItems ||
        old.width != config.width ||
        old.looping != config.looping ||
        config.source.count != _laidOutCount) {
      markNeedsLayout();
    }
    // Everything else only changes what is drawn. Labels that still read
    // the same keep their layout.
    markNeedsPaint();
  }

  void _disposeLabels() {
    for (final label in _labels.values) {
      label.painter.dispose();
    }
    _labels.clear();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _config.offset.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _config.offset.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void dispose() {
    _disposeLabels();
    super.dispose();
  }

  Size get _wanted =>
      Size(_config.width, _config.itemExtent * _config.visibleItems);

  @override
  double computeMinIntrinsicWidth(double height) =>
      _config.width.isFinite ? _config.width : 0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _config.width.isFinite ? _config.width : 0;

  @override
  double computeMinIntrinsicHeight(double width) => _wanted.height;

  @override
  double computeMaxIntrinsicHeight(double width) => _wanted.height;

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      constraints.constrain(_wanted);

  @override
  void performLayout() {
    debugLayoutCount++;
    size = constraints.constrain(_wanted);
    final offset = _config.offset;
    final extent = _config.itemExtent;
    final before = _laidOutExtent;
    // A new row height keeps the row that was under the lens there.
    if (before != null && before != extent && offset.hasPixels) {
      offset.correctBy(offset.pixels / before * extent - offset.pixels);
    }
    _laidOutExtent = extent;
    final count = _laidOutCount = _config.source.count;
    offset.applyViewportDimension(size.height);
    if (_config.looping) {
      offset.applyContentDimensions(double.negativeInfinity, double.infinity);
    } else {
      offset.applyContentDimensions(0, math.max(0, count - 1) * extent);
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  _WheelLabel _labelFor(int index, int step, double maxWidth) {
    final source = _config.source;
    final label = source.labelAt(index);
    final rowEnabled = source.enabledAt(index);
    final key = index * _stepsPerRow + step;
    final cached = _labels[key];
    if (cached != null &&
        cached.label == label &&
        cached.enabled == rowEnabled) {
      return cached;
    }
    cached?.painter.dispose();
    _labels.remove(key);
    final lens = step == _lensStep;
    final base = lens ? _config.selectedTextStyle : _config.textStyle;
    var alpha = lens ? 1.0 : step / _fadeSteps;
    if (!rowEnabled || !_config.enabled) alpha *= _config.disabledOpacity;
    final color = base.color ?? const Color(0xFF000000);
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: base.copyWith(color: color.withValues(alpha: color.a * alpha)),
      ),
      textDirection: _config.textDirection,
      textScaler: _config.textScaler,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: math.max(0, maxWidth));
    final made = _WheelLabel(label, rowEnabled, painter);
    _labels[key] = made;
    if (_labels.length > _maxLabels) {
      final oldest = _labels.keys.first;
      _labels.remove(oldest)!.painter.dispose();
    }
    return made;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    debugPaintCount++;
    final config = _config;
    final count = config.source.count;
    if (count == 0 || !config.offset.hasPixels || size.isEmpty) return;

    final canvas = context.canvas;
    final extent = config.itemExtent;
    final pixels = config.offset.pixels;
    final centre = size.height / 2;
    final geometry = _WheelGeometry(
      halfHeight: centre,
      curvature: config.curvature,
    );
    final room = size.width - config.padding.horizontal;
    final t = (config.alignX + 1) / 2;
    final anchor = config.padding.left + room * t;
    final lens = Rect.fromLTWH(0, centre - extent / 2, size.width, extent);

    int wrap(int raw) => ((raw % count) + count) % count;
    bool exists(int raw) => config.looping || (raw >= 0 && raw < count);

    canvas
      ..save()
      ..translate(offset.dx, offset.dy)
      ..clipRect(Offset.zero & size);

    // The rows around the lens: muted, turned away and faded by how far
    // from the centre they are.
    final fadeFrom = centre * (1 - config.edgeFade.clamp(0.0, 1.0));
    final first = ((pixels - geometry.reach) / extent).floor() - 1;
    final last = ((pixels + geometry.reach) / extent).ceil() + 1;
    canvas
      ..save()
      ..clipRect(lens, clipOp: ClipOp.difference);
    for (var raw = first; raw <= last; raw++) {
      if (!exists(raw)) continue;
      final distance = raw * extent - pixels;
      var y = distance;
      var squash = 1.0;
      if (!geometry.flat) {
        final angle = distance / geometry.radius;
        if (angle.abs() >= math.pi / 2) continue;
        y = geometry.radius * math.sin(angle);
        squash = math.cos(angle);
      }
      final edge = y.abs();
      if (edge - extent * squash / 2 >= centre) continue;
      final alpha = edge <= fadeFrom || centre <= fadeFrom
          ? 1.0
          : 1 - (edge - fadeFrom) / (centre - fadeFrom);
      final step = (alpha * _fadeSteps).round();
      if (step <= 0) continue;
      final painter = _labelFor(wrap(raw), step, room).painter;
      canvas
        ..save()
        ..translate(anchor, centre + y)
        ..scale(1, squash);
      painter.paint(canvas, Offset(-painter.width * t, -painter.height / 2));
      canvas.restore();
    }
    canvas.restore();

    // The row under the lens, and the parts of its neighbours that are:
    // in the foreground colour and magnified, as if seen through it.
    final zoom = config.magnification;
    canvas
      ..save()
      ..clipRRect(config.lensRadius.toRRect(lens));
    final near = (pixels / extent).round();
    for (var raw = near - 1; raw <= near + 1; raw++) {
      if (!exists(raw)) continue;
      final y = (raw * extent - pixels) * zoom;
      if (y.abs() >= extent * (1 + zoom) / 2) continue;
      final painter = _labelFor(wrap(raw), _lensStep, room / zoom).painter;
      canvas
        ..save()
        ..translate(anchor, centre + y)
        ..scale(zoom, zoom);
      painter.paint(canvas, Offset(-painter.width * t, -painter.height / 2));
      canvas.restore();
    }
    canvas
      ..restore()
      ..restore();
  }
}
