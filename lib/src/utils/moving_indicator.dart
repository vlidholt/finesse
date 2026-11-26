import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/utils/shadow.dart';
import 'package:una/src/utils/spring.dart';

/// Paints one selection indicator that travels between the
/// [MovingIndicatorTarget]s below it.
///
/// It is the shared shape behind a tab pill, an underline, a segmented
/// control or a toggle group: instead of one item's highlight switching off
/// and another's switching on, a single decoration slides from the old item
/// to the new one. While it travels, the edge facing the destination leads
/// and the other follows a little later, so the shape stretches in the
/// direction of travel and settles — the theme's `Motion.indicatorStretch`.
///
/// Wrap the items' common parent in a [MovingIndicator] and each item — or
/// the part of it the indicator should cover — in a [MovingIndicatorTarget]:
///
/// ```dart
/// MovingIndicator(
///   child: Row(
///     children: [
///       for (final (i, label) in labels.indexed)
///         MovingIndicatorTarget(
///           selected: i == selected,
///           decoration: pill,
///           child: label,
///         ),
///     ],
///   ),
/// )
/// ```
///
/// The indicator is painted, not laid out: when it paints, it takes the
/// selected target's rectangle and draws that target's [Decoration] there,
/// behind the child (or in front, with [position]). Nothing is rebuilt or
/// laid out while it moves.
///
/// What it does when:
///
/// * The first time it is painted, and whenever motion is reduced, the
///   indicator is simply on the selected target.
/// * When another target becomes selected, it springs there. Interrupting
///   the travel with a third selection keeps the velocity it had.
/// * When the *same* target moves or resizes — the window was resized, a
///   label changed — it follows rigidly, with no animation.
/// * With no target selected it fades out, and fades in on the next one.
/// * While [track] has a value it is held between two targets — those whose
///   [MovingIndicatorTarget.index] the value lies between — and follows the
///   value rigidly: a finger dragging the pages the targets stand for.
///
/// A scrolling row belongs *inside* the scroll view: put the
/// [MovingIndicator] around the scrolled content, not around the viewport,
/// so the targets' rectangles do not change as it scrolls. For the same
/// reason, do not put a `RepaintBoundary` between the indicator and its
/// targets: a target that moves behind one is only seen at the next paint.
class MovingIndicator extends StatefulWidget {
  /// Creates a travelling selection indicator for the targets in [child].
  const MovingIndicator({
    required this.child,
    this.position = DecorationPosition.background,
    this.spring,
    this.stretch,
    this.fadeDuration,
    this.track,
    super.key,
  });

  /// Where to hold the indicator while something drags the selection: a
  /// fractional index among the targets that carry an
  /// [MovingIndicatorTarget.index], so 1.25 is a quarter of the way from
  /// the target with index 1 to the one with index 2.
  ///
  /// While its value is null — at rest — the indicator is on the selected
  /// target as usual, and springs there from wherever it was held if the
  /// two differ.
  final ValueListenable<double?>? track;

  /// Whether the indicator is painted behind [child] or in front of it.
  final DecorationPosition position;

  /// The spring the indicator travels with. Defaults to the theme's
  /// `Motion.snappy`.
  final MotionSpring? spring;

  /// How far the indicator stretches while it travels: the extra time its
  /// trailing edge takes, as a fraction. 0 moves it rigidly. Defaults to the
  /// theme's `Motion.indicatorStretch`.
  final double? stretch;

  /// How long the indicator takes to fade in and out when the selection
  /// appears or disappears. Defaults to the theme's `Motion.fast`.
  final Duration? fadeDuration;

  /// The subtree that contains the [MovingIndicatorTarget]s.
  final Widget child;

  @override
  State<MovingIndicator> createState() => _MovingIndicatorState();
}

class _MovingIndicatorState extends State<MovingIndicator>
    with TickerProviderStateMixin {
  // One spring per edge: the stretch is the two edges of an axis arriving at
  // different times.
  late final _left = SpringController(vsync: this, tolerance: .05);
  late final _top = SpringController(vsync: this, tolerance: .05);
  late final _right = SpringController(vsync: this, tolerance: .05);
  late final _bottom = SpringController(vsync: this, tolerance: .05);
  late final _opacity = AnimationController(vsync: this, value: 0);

  late final Listenable _repaint = Listenable.merge([
    _left.animation,
    _top.animation,
    _right.animation,
    _bottom.animation,
    _opacity,
  ]);

  final _targets = <RenderMovingIndicatorTarget>{};
  RenderMovingIndicator? _renderObject;

  RenderMovingIndicatorTarget? _current;
  Rect? _targetRect;
  bool _resolved = false;

  // Resolved in build, read during layout.
  late MotionSpring _spring;
  late double _stretch;
  late Duration _fadeDuration;

  Rect get _rect =>
      Rect.fromLTRB(_left.value, _top.value, _right.value, _bottom.value);

  void _register(RenderMovingIndicatorTarget target) {
    _targets.add(target);
    _targetChanged();
  }

  void _unregister(RenderMovingIndicatorTarget target) {
    _targets.remove(target);
    _targetChanged();
  }

  void _targetChanged() {
    // Not from a detached tree: the group itself is going away.
    if (_renderObject?.attached ?? false) _renderObject!.markNeedsPaint();
  }

  @override
  void initState() {
    super.initState();
    widget.track?.addListener(_targetChanged);
  }

  @override
  void didUpdateWidget(MovingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.track, oldWidget.track)) {
      oldWidget.track?.removeListener(_targetChanged);
      widget.track?.addListener(_targetChanged);
      _targetChanged();
    }
  }

  /// The targets on either side of the fractional index [at], and how far
  /// between them it is. Null when no target carries an index.
  ({
    RenderMovingIndicatorTarget from,
    RenderMovingIndicatorTarget to,
    double t,
  })?
  _around(double at) {
    RenderMovingIndicatorTarget? below;
    RenderMovingIndicatorTarget? above;
    for (final target in _targets) {
      final index = target.index;
      if (index == null || !target.attached || !target.hasSize) continue;
      if (index <= at && (below == null || index > below.index!)) {
        below = target;
      }
      if (index >= at && (above == null || index < above.index!)) {
        above = target;
      }
    }
    // Past either end: on the last target that way.
    below ??= above;
    above ??= below;
    if (below == null || above == null) return null;
    final span = above.index! - below.index!;
    return (
      from: below,
      to: above,
      t: span <= 0 ? 0 : (at - below.index!) / span,
    );
  }

  /// Called by the render object before it paints while the widget's
  /// `track` holds the indicator on [rect], nearest to [target].
  void _resolveTracked(RenderMovingIndicatorTarget target, Rect rect) {
    _resolved = true;
    _current = target;
    _targetRect = rect;
    _jumpTo(rect);
    _opacity.value = 1;
  }

  RenderMovingIndicatorTarget? get _selected {
    for (final target in _targets) {
      if (target.selected && target.attached && target.hasSize) return target;
    }
    return null;
  }

  void _jumpTo(Rect rect) {
    _left.jumpTo(rect.left);
    _top.jumpTo(rect.top);
    _right.jumpTo(rect.right);
    _bottom.jumpTo(rect.bottom);
  }

  /// Called by the render object before it paints, with the selected target
  /// and its rectangle in the group's coordinates.
  void _resolve(RenderMovingIndicatorTarget? target, Rect? rect) {
    final first = !_resolved;
    _resolved = true;
    final previous = _current;
    final previousRect = _targetRect;
    _current = target;
    _targetRect = rect;

    if (target == null || rect == null) {
      if (previous != null) {
        // Fade out where it was.
        _opacity.animateTo(0, duration: _fadeDuration);
      }
      return;
    }

    if (first || previous == null || previousRect == null) {
      // Nothing to travel from: appear in place.
      _jumpTo(rect);
      if (first || _fadeDuration == Duration.zero) {
        _opacity.value = 1;
      } else {
        _opacity.animateTo(1, duration: _fadeDuration);
      }
      return;
    }

    if (rect == previousRect && identical(target, previous)) return;

    if (identical(target, previous)) {
      // The same item moved: follow it rigidly, keeping any travel that is
      // still in flight.
      _left.shiftBy(rect.left - previousRect.left, spring: _spring);
      _top.shiftBy(rect.top - previousRect.top, spring: _spring);
      _right.shiftBy(rect.right - previousRect.right, spring: _spring);
      _bottom.shiftBy(rect.bottom - previousRect.bottom, spring: _spring);
      return;
    }

    if (_opacity.value == 0 && !_opacity.isAnimating) {
      _jumpTo(rect);
    } else {
      // The edge facing the destination leads; the other trails.
      final trailing = _spring.scaled(1 + _stretch);
      final dx = rect.center.dx - previousRect.center.dx;
      final dy = rect.center.dy - previousRect.center.dy;
      _left.animateTo(rect.left, spring: dx > 0 ? trailing : _spring);
      _right.animateTo(rect.right, spring: dx < 0 ? trailing : _spring);
      _top.animateTo(rect.top, spring: dy > 0 ? trailing : _spring);
      _bottom.animateTo(rect.bottom, spring: dy < 0 ? trailing : _spring);
    }
    if (_opacity.value != 1) {
      _opacity.animateTo(1, duration: _fadeDuration);
    }
  }

  @override
  void dispose() {
    widget.track?.removeListener(_targetChanged);
    _left.dispose();
    _top.dispose();
    _right.dispose();
    _bottom.dispose();
    _opacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    _spring = widget.spring ?? motion.snappy;
    _stretch = _spring.isInstant
        ? 0
        : (widget.stretch ?? motion.indicatorStretch);
    _fadeDuration = widget.fadeDuration ?? motion.fast;
    return _MovingIndicatorScope(
      state: this,
      child: _MovingIndicatorRenderWidget(
        state: this,
        position: widget.position,
        textDirection: Directionality.maybeOf(context),
        child: widget.child,
      ),
    );
  }
}

class _MovingIndicatorScope extends InheritedWidget {
  const _MovingIndicatorScope({required this.state, required super.child});

  final _MovingIndicatorState state;

  @override
  bool updateShouldNotify(_MovingIndicatorScope oldWidget) =>
      !identical(state, oldWidget.state);
}

class _MovingIndicatorRenderWidget extends SingleChildRenderObjectWidget {
  const _MovingIndicatorRenderWidget({
    required this.state,
    required this.position,
    required this.textDirection,
    required super.child,
  });

  final _MovingIndicatorState state;
  final DecorationPosition position;
  final TextDirection? textDirection;

  @override
  RenderMovingIndicator createRenderObject(BuildContext context) =>
      RenderMovingIndicator._(state, position, textDirection);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMovingIndicator renderObject,
  ) {
    renderObject
      ..position = position
      ..textDirection = textDirection;
  }
}

/// The render object of a [MovingIndicator]: lays out its child, finds the
/// selected target and paints that target's decoration on the animated
/// rectangle.
@internal
class RenderMovingIndicator extends RenderProxyBox {
  RenderMovingIndicator._(this._state, this._position, this._textDirection) {
    _state._renderObject = this;
  }

  final _MovingIndicatorState _state;

  /// Whether the indicator is painted behind the child or in front of it.
  DecorationPosition get position => _position;
  DecorationPosition _position;
  set position(DecorationPosition value) {
    if (value == _position) return;
    _position = value;
    markNeedsPaint();
  }

  /// The direction the decoration is resolved with.
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsPaint();
  }

  /// The rectangle the indicator is painted on right now, in this render
  /// object's coordinates, or null while it is hidden.
  Rect? get indicatorRect => _state._opacity.value == 0 ? null : _state._rect;

  /// The opacity the indicator is painted with right now.
  double get indicatorOpacity => _state._opacity.value;

  BoxPainter? _painter;
  Decoration? _painterDecoration;

  // The target is resolved while painting, and resolving moves the springs:
  // their notifications must not mark this object dirty mid-paint. The
  // paint in progress already uses the new values.
  bool _resolving = false;

  void _handleTick() {
    if (!_resolving) markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _state._repaint.addListener(_handleTick);
  }

  @override
  void detach() {
    _state._repaint.removeListener(_handleTick);
    _painter?.dispose();
    _painter = null;
    _painterDecoration = null;
    super.detach();
  }

  @override
  void dispose() {
    _painter?.dispose();
    super.dispose();
  }

  /// Finds the selected target and tells the state where it is. Done at
  /// paint time rather than in layout, so that a target laid out behind a
  /// relayout boundary — a fixed-size tab — is still seen.
  void _resolve() {
    _resolving = true;
    try {
      final at = _state.widget.track?.value;
      final around = at == null ? null : _state._around(at);
      if (around != null) {
        final rect = Rect.lerp(
          _rectOf(around.from),
          _rectOf(around.to),
          around.t,
        )!;
        _state._resolveTracked(
          around.t < .5 ? around.from : around.to,
          rect,
        );
        return;
      }
      final target = _state._selected;
      if (target == null) {
        _state._resolve(null, null);
        return;
      }
      _state._resolve(target, _rectOf(target));
    } finally {
      _resolving = false;
    }
  }

  /// Where the indicator goes on [target], in this object's coordinates.
  Rect _rectOf(RenderMovingIndicatorTarget target) => MatrixUtils.transformRect(
    target.getTransformTo(this),
    target.padding.inflateRect(Offset.zero & target.size),
  );

  void _paintIndicator(PaintingContext context, Offset offset) {
    final opacity = _state._opacity.value;
    final decoration = _state._current?.decoration ?? _painterDecoration;
    if (opacity == 0 || decoration == null) return;
    final rect = _state._rect;
    if (rect.width <= 0 || rect.height <= 0) return;
    if (!identical(decoration, _painterDecoration) &&
        decoration != _painterDecoration) {
      _painter?.dispose();
      _painter = null;
    }
    _painterDecoration = decoration;
    final painter = _painter ??= decoration.createBoxPainter(markNeedsPaint);
    final configuration = ImageConfiguration(
      size: rect.size,
      textDirection: _textDirection,
    );
    final canvas = context.canvas;
    if (opacity < 1) {
      // A layer as large as what the decoration paints, not as large as
      // the clip: without bounds, fading a pill a few dozen pixels wide in
      // a bar that nothing clips takes an offscreen the size of the window.
      final reach = _reach(decoration);
      canvas.saveLayer(
        reach == null
            ? null
            : (offset & rect.size).shift(rect.topLeft).inflate(reach),
        Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
      );
    }
    painter.paint(canvas, offset + rect.topLeft, configuration);
    if (opacity < 1) canvas.restore();
  }

  /// How far beyond its box [decoration] paints — its shadows, and a pixel
  /// for anti-aliasing — or null for a kind of decoration this cannot tell
  /// about, whose layer is then left unbounded.
  static double? _reach(Decoration decoration) {
    double of(List<BoxShadow>? shadows) {
      var reach = 1.0;
      for (final shadow in shadows ?? const <BoxShadow>[]) {
        reach = math.max(
          reach,
          shadow.offset.distance +
              math.max(0, shadow.spreadRadius) +
              shadow.blurSigma * 3 +
              1,
        );
      }
      return reach;
    }

    switch (decoration) {
      case BoxDecoration(:final boxShadow, :final border):
        // A border may be drawn outside the box.
        return of(boxShadow) + _outset(border);
      case ShapeDecoration(:final shadows):
        return of(shadows);
      case ShadowDecoration(:final shadows, decoration: final inner):
        final within = _reach(inner);
        return within == null ? null : math.max(of(shadows), within);
      default:
        return null;
    }
  }

  static double _outset(BoxBorder? border) {
    if (border is! Border) return border == null ? 0 : 1;
    var outset = 0.0;
    for (final side in [border.top, border.right, border.bottom, border.left]) {
      outset = math.max(outset, side.strokeOutset);
    }
    return outset;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _resolve();
    if (_position == DecorationPosition.background) {
      _paintIndicator(context, offset);
    }
    super.paint(context, offset);
    if (_position == DecorationPosition.foreground) {
      _paintIndicator(context, offset);
    }
  }
}

/// Marks where a [MovingIndicator] goes when this item is the selected one,
/// and what it looks like there.
///
/// The indicator covers the target's own box, grown by [padding]. A target
/// does not have to wrap the whole item: an underline is a thin, empty
/// target positioned along the item's bottom edge.
///
/// Outside a [MovingIndicator] a selected target paints its [decoration]
/// itself, so an item works on its own.
class MovingIndicatorTarget extends SingleChildRenderObjectWidget {
  /// Creates an indicator target.
  const MovingIndicatorTarget({
    required this.selected,
    required this.decoration,
    this.padding = EdgeInsets.zero,
    this.index,
    super.child,
    super.key,
  });

  /// Whether the indicator belongs here. One target of a group is selected
  /// at a time; with none, the indicator fades out.
  final bool selected;

  /// What the indicator looks like on this target.
  final Decoration decoration;

  /// How far the indicator extends beyond the target's box. Negative values
  /// keep it inside.
  final EdgeInsets padding;

  /// This target's place among its siblings, for [MovingIndicator.track]:
  /// a tracked indicator is held between the targets whose indices its
  /// value lies between. Not needed otherwise.
  final int? index;

  @override
  RenderMovingIndicatorTarget createRenderObject(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_MovingIndicatorScope>();
    return RenderMovingIndicatorTarget._(
      scope?.state,
      selected,
      decoration,
      padding,
      Directionality.maybeOf(context),
    )..index = index;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMovingIndicatorTarget renderObject,
  ) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_MovingIndicatorScope>();
    renderObject
      .._setGroup(scope?.state)
      ..selected = selected
      ..decoration = decoration
      ..padding = padding
      ..index = index
      ..textDirection = Directionality.maybeOf(context);
  }
}

/// The render object of a [MovingIndicatorTarget].
@internal
class RenderMovingIndicatorTarget extends RenderProxyBox {
  RenderMovingIndicatorTarget._(
    this._group,
    this._selected,
    this._decoration,
    this._padding,
    this._textDirection,
  );

  _MovingIndicatorState? _group;
  void _setGroup(_MovingIndicatorState? value) {
    if (identical(value, _group)) return;
    if (attached) _group?._unregister(this);
    _group = value;
    if (attached) _group?._register(this);
    markNeedsPaint();
  }

  /// Whether the indicator belongs on this target.
  bool get selected => _selected;
  bool _selected;
  set selected(bool value) {
    if (value == _selected) return;
    _selected = value;
    _group?._targetChanged();
    if (_group == null) markNeedsPaint();
  }

  /// What the indicator looks like on this target.
  Decoration get decoration => _decoration;
  Decoration _decoration;
  set decoration(Decoration value) {
    if (value == _decoration) return;
    _decoration = value;
    _painter?.dispose();
    _painter = null;
    if (_group == null) {
      markNeedsPaint();
    } else if (_selected) {
      _group!._targetChanged();
    }
  }

  /// How far the indicator extends beyond this target's box.
  EdgeInsets get padding => _padding;
  EdgeInsets _padding;
  set padding(EdgeInsets value) {
    if (value == _padding) return;
    _padding = value;
    if (_group == null) {
      markNeedsPaint();
    } else if (_selected) {
      _group!._targetChanged();
    }
  }

  /// This target's place among its siblings; see
  /// [MovingIndicatorTarget.index].
  int? get index => _index;
  int? _index;
  set index(int? value) {
    if (value == _index) return;
    _index = value;
    _group?._targetChanged();
  }

  /// The direction the decoration is resolved with when the target paints
  /// it itself.
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (value == _textDirection) return;
    _textDirection = value;
    if (_group == null) markNeedsPaint();
  }

  BoxPainter? _painter;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _group?._register(this);
  }

  @override
  void detach() {
    _group?._unregister(this);
    _painter?.dispose();
    _painter = null;
    super.detach();
  }

  @override
  void dispose() {
    _painter?.dispose();
    super.dispose();
  }

  @override
  void performLayout() {
    super.performLayout();
    // Marking an ancestor for paint is allowed during layout; the group
    // reads this target's new box when it paints.
    if (_selected) _group?._targetChanged();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // On its own, the target is its own indicator.
    if (_group == null && _selected) {
      final rect = _padding.inflateRect(offset & size);
      (_painter ??= _decoration.createBoxPainter(markNeedsPaint)).paint(
        context.canvas,
        rect.topLeft,
        ImageConfiguration(size: rect.size, textDirection: _textDirection),
      );
    }
    super.paint(context, offset);
  }
}
