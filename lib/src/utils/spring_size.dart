import 'dart:math' as math;

import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Follows the size of its child on a spring: when the child grows or
/// shrinks, this box takes a moment to catch up, and everything around it
/// moves smoothly instead of jumping.
///
/// The spring-driven counterpart of `AnimatedSize`. Width and height each
/// ride their own [MotionSpring], so a size that changes again mid-flight —
/// a message whose text is still streaming in — carries on with the
/// velocity it has. The child is always laid out at its real size and is
/// pinned to [alignment]; while the box is smaller than the child the rest
/// is clipped, to [borderRadius] when one is given.
///
/// ```dart
/// DecoratedBox(
///   decoration: bubble,
///   child: SpringSize(
///     borderRadius: radius,
///     child: Padding(padding: padding, child: message),
///   ),
/// )
/// ```
///
/// Three things never animate: the first layout, a change of the
/// *constraints* (a window being resized — the child follows the layout
/// rigidly, as it should), and a change no larger than [rigidDistance] on
/// an axis, which is how a child that already grows smoothly by itself is
/// kept from being smoothed twice. With reduced motion nothing animates.
///
/// The size is laid out on every frame of the motion, as any change of size
/// must be; the child itself is not laid out again.
class SpringSize extends StatefulWidget {
  /// Creates a box that follows its child's size on a spring.
  const SpringSize({
    required this.child,
    this.spring,
    this.alignment = AlignmentDirectional.topStart,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.rigidDistance = 0,
    this.enabled = true,
    super.key,
  });

  /// The spring the size moves with. Defaults to the theme's `Motion.snappy`
  /// without its bounce, so the box never grows past its child.
  final MotionSpring? spring;

  /// Where the child sits in the box while the two differ in size: the
  /// corner that stays put.
  final AlignmentGeometry alignment;

  /// The corners of the clip applied while the box is smaller than its
  /// child. Null clips to the box's rectangle.
  final BorderRadiusGeometry? borderRadius;

  /// How the child is clipped while the box is smaller than it. With
  /// [Clip.none] it overflows instead.
  final Clip clipBehavior;

  /// The largest change, in logical pixels on one axis, that is followed at
  /// once rather than on the spring.
  ///
  /// Text that is revealed a character at a time widens by a few pixels a
  /// frame: that is already smooth, and a spring chasing it would only lag
  /// behind. A new line is a jump of a whole line height, and takes the
  /// spring.
  final double rigidDistance;

  /// Whether size changes are animated at all. False follows the child
  /// exactly.
  final bool enabled;

  /// The widget whose size is followed.
  final Widget child;

  @override
  State<SpringSize> createState() => _SpringSizeState();
}

class _SpringSizeState extends State<SpringSize> with TickerProviderStateMixin {
  // In logical pixels, hence the looser tolerance.
  late final _width = SpringController(vsync: this, tolerance: .05);
  late final _height = SpringController(vsync: this, tolerance: .05);

  @override
  void dispose() {
    _width.dispose();
    _height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    return _SpringSizeBox(
      width: _width,
      height: _height,
      spring: widget.enabled
          ? (widget.spring ?? motion.snappy.copyWith(bounce: 0))
          : MotionSpring.instant,
      alignment: widget.alignment,
      textDirection: direction,
      borderRadius: widget.borderRadius?.resolve(direction),
      clipBehavior: widget.clipBehavior,
      rigidDistance: widget.rigidDistance,
      child: widget.child,
    );
  }
}

class _SpringSizeBox extends SingleChildRenderObjectWidget {
  const _SpringSizeBox({
    required this.width,
    required this.height,
    required this.spring,
    required this.alignment,
    required this.textDirection,
    required this.borderRadius,
    required this.clipBehavior,
    required this.rigidDistance,
    required super.child,
  });

  final SpringController width;
  final SpringController height;
  final MotionSpring spring;
  final AlignmentGeometry alignment;
  final TextDirection textDirection;
  final BorderRadius? borderRadius;
  final Clip clipBehavior;
  final double rigidDistance;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderSpringSize(
    width: width,
    height: height,
    spring: spring,
    alignment: alignment,
    textDirection: textDirection,
    borderRadius: borderRadius,
    clipBehavior: clipBehavior,
    rigidDistance: rigidDistance,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSpringSize renderObject,
  ) {
    renderObject
      ..spring = spring
      ..alignment = alignment
      ..textDirection = textDirection
      ..borderRadius = borderRadius
      ..clipBehavior = clipBehavior
      ..rigidDistance = rigidDistance;
  }
}

class _RenderSpringSize extends RenderAligningShiftedBox {
  _RenderSpringSize({
    required SpringController width,
    required SpringController height,
    required this.spring,
    required super.alignment,
    required super.textDirection,
    required BorderRadius? borderRadius,
    required Clip clipBehavior,
    required this.rigidDistance,
  }) : _width = width,
       _height = height,
       _borderRadius = borderRadius,
       _clipBehavior = clipBehavior;

  final SpringController _width;
  final SpringController _height;

  /// Read at the next change of size; changing it does not need a layout.
  MotionSpring spring;

  /// See [SpringSize.rigidDistance].
  double rigidDistance;

  BorderRadius? get borderRadius => _borderRadius;
  BorderRadius? _borderRadius;
  set borderRadius(BorderRadius? value) {
    if (value == _borderRadius) return;
    _borderRadius = value;
    if (_clipped) markNeedsPaint();
  }

  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior;
  set clipBehavior(Clip value) {
    if (value == _clipBehavior) return;
    _clipBehavior = value;
    if (_clipped) markNeedsPaint();
  }

  BoxConstraints? _lastConstraints;
  bool _hasSize = false;
  bool _inLayout = false;
  bool _clipped = false;

  final _clipRectLayer = LayerHandle<ClipRectLayer>();
  final _clipRRectLayer = LayerHandle<ClipRRectLayer>();

  void _onTick() {
    // Moving a controller from inside `performLayout` reports here too.
    if (!_inLayout) markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _width.animation.addListener(_onTick);
    _height.animation.addListener(_onTick);
  }

  @override
  void detach() {
    _width.animation.removeListener(_onTick);
    _height.animation.removeListener(_onTick);
    super.detach();
  }

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    _clipRRectLayer.layer = null;
    super.dispose();
  }

  void _follow(SpringController axis, double target) {
    final delta = target - axis.target;
    if (delta == 0) return;
    if (delta.abs() <= rigidDistance) {
      axis.shiftBy(delta, spring: spring);
    } else {
      axis.animateTo(target, spring: spring);
    }
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    final child = this.child;
    if (child == null) {
      _hasSize = false;
      _clipped = false;
      size = constraints.smallest;
      return;
    }
    child.layout(constraints, parentUsesSize: true);
    final natural = child.size;
    final sameConstraints = constraints == _lastConstraints;
    _lastConstraints = constraints;

    _inLayout = true;
    if (!_hasSize || !sameConstraints || spring.isInstant) {
      _hasSize = true;
      _width.jumpTo(natural.width);
      _height.jumpTo(natural.height);
    } else {
      _follow(_width, natural.width);
      _follow(_height, natural.height);
    }
    _inLayout = false;

    size = constraints.constrain(
      Size(math.max(0, _width.value), math.max(0, _height.value)),
    );
    alignChild();
    // A quarter of a pixel of difference is not worth a clip layer.
    _clipped =
        size.width < natural.width - .25 || size.height < natural.height - .25;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      child?.getDryLayout(constraints) ?? constraints.smallest;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || !_clipped || clipBehavior == Clip.none) {
      _clipRectLayer.layer = null;
      _clipRRectLayer.layer = null;
      super.paint(context, offset);
      return;
    }
    final bounds = Offset.zero & size;
    final radius = borderRadius;
    if (radius == null || radius == BorderRadius.zero) {
      _clipRRectLayer.layer = null;
      _clipRectLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        bounds,
        super.paint,
        clipBehavior: clipBehavior,
        oldLayer: _clipRectLayer.layer,
      );
    } else {
      _clipRectLayer.layer = null;
      _clipRRectLayer.layer = context.pushClipRRect(
        needsCompositing,
        offset,
        bounds,
        radius.toRRect(bounds),
        super.paint,
        clipBehavior: clipBehavior,
        oldLayer: _clipRRectLayer.layer,
      );
    }
  }
}
