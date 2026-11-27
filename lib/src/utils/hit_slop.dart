import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Takes the pointer within [slop] of its child as a hit on the child, at
/// the nearest point inside it, without changing the child's size or
/// anything around it.
///
/// A small control keeps its drawn size and still offers a pointer target
/// of the size the guidelines ask for (24 by 24). Every box on the way down
/// tests its own bounds, so the slop has to be granted at each level a hit
/// outside the control passes through: the control's own outermost box,
/// and the row it is in when the slop reaches past the row.
///
/// Internal: not exported.
class HitSlop extends SingleChildRenderObjectWidget {
  /// Grows [child]'s pointer target by [slop] on every side.
  const HitSlop({required this.slop, super.child, super.key});

  /// How far beyond each edge a pointer still lands on [child].
  final double slop;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderHitSlop(slop);

  @override
  void updateRenderObject(BuildContext context, RenderHitSlop renderObject) {
    renderObject.slop = slop;
  }
}

/// The render object of a [HitSlop].
class RenderHitSlop extends RenderProxyBox {
  /// Creates the render object of a [HitSlop].
  RenderHitSlop(this._slop);

  double _slop;

  /// How far beyond each edge a pointer still lands on the child.
  double get slop => _slop;
  set slop(double value) {
    if (value == _slop) return;
    _slop = value;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      return super.hitTest(result, position: position);
    }
    if (_slop <= 0 || size.isEmpty) return false;
    if (!(Offset.zero & size).inflate(_slop).contains(position)) return false;
    // `Size.contains` excludes the right and bottom edges.
    const inset = 0.01;
    final inside = Offset(
      position.dx.clamp(0, math.max(0, size.width - inset)),
      position.dy.clamp(0, math.max(0, size.height - inset)),
    );
    if (hitTestChildren(result, position: inside) || hitTestSelf(inside)) {
      result.add(BoxHitTestEntry(this, inside));
      return true;
    }
    return false;
  }
}
