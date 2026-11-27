import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Grows the area in which [child] takes pointers to at least [minSize] on
/// each side, without changing how it is laid out or painted.
///
/// For a control drawn smaller than a finger or the WCAG minimum target
/// (24, 44 on a phone): a dialog's or a toast's close button. A press in the
/// grown area reaches [child] as if it had landed on its centre.
///
/// The area only reaches as far as the widgets around it take pointers: a
/// parent hit-tests its children inside its own bounds only. [alignment]
/// says where [child] sits in the grown area, so a control at an edge of
/// its parent can grow away from that edge.
///
/// It must be the outermost render object around the control: a box above
/// it that has the control's size turns a press outside that size away
/// before it gets here.
class HitArea extends SingleChildRenderObjectWidget {
  /// Grows [child]'s hit area to [minSize].
  const HitArea({
    super.key,
    required this.minSize,
    this.alignment = Alignment.center,
    super.child,
  });

  /// The smallest width and height the hit area has.
  final double minSize;

  /// Where [child] sits in the grown area. Centred by default.
  final AlignmentGeometry alignment;

  @override
  RenderHitArea createRenderObject(BuildContext context) => RenderHitArea(
    minSize: minSize,
    alignment: alignment,
    textDirection: Directionality.maybeOf(context),
  );

  @override
  void updateRenderObject(BuildContext context, RenderHitArea renderObject) {
    renderObject
      ..minSize = minSize
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context);
  }
}

/// The render object of a [HitArea].
class RenderHitArea extends RenderProxyBox {
  /// Grows its child's hit area to [minSize].
  RenderHitArea({
    required this.minSize,
    required this.alignment,
    this.textDirection,
  });

  // Read only when a pointer arrives: nothing to lay out or paint again
  // when they change.

  /// See [HitArea.minSize].
  double minSize;

  /// See [HitArea.alignment].
  AlignmentGeometry alignment;

  /// The direction [alignment] is resolved in.
  TextDirection? textDirection;

  /// The area that takes pointers, in this box's coordinates.
  Rect get area {
    final width = math.max(size.width, minSize);
    final height = math.max(size.height, minSize);
    final resolved = alignment.resolve(textDirection ?? TextDirection.ltr);
    return Rect.fromLTWH(
      -(width - size.width) * (resolved.x + 1) / 2,
      -(height - size.height) * (resolved.y + 1) / 2,
      width,
      height,
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      return super.hitTest(result, position: position);
    }
    if (!area.contains(position)) return false;
    if (hitTestChildren(result, position: size.center(Offset.zero))) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}
