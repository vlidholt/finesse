import 'dart:ui';

import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/arrow_surface.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/widgets.dart';

/// Which component's surface a [Surface] paints.
enum SurfaceKind {
  /// A popover's: `PopoverTheme`'s decoration, shadows, padding and
  /// filter, in the popover colours.
  popover,

  /// A menu's: the popover surface with `ContextMenuTheme`'s decoration,
  /// shadows, padding and filter over it, as `ContextMenu` and
  /// `Select` draw it.
  menu,
}

/// {@template Surface}
/// The surface of a popover or menu, around any [child].
///
/// Use it for floating UI that finesse does not provide as a component — a
/// cell editor, a find bar, a palette of swatches — so it gets the same outline
/// (shadcn's `ring-foreground/10`, not `--border`), radius, padding,
/// colours and shadow as a `Popover`. The shadow is painted the way CSS
/// paints `box-shadow`, outside the element only; a hand-built
/// `BoxDecoration(boxShadow:)` washes a translucent fill grey and loses the
/// shadow next to the element.
///
/// To show one anchored to a rectangle, see `showPopover`.
/// {@endtemplate}
class Surface extends StatelessWidget {
  /// {@macro Surface}
  const Surface({
    super.key,
    required this.child,
    this.kind = SurfaceKind.popover,
    this.padding,
    this.decoration,
    this.shadows,
    this.filter,
    this.textStyle,
    this.arrow,
  });

  /// The content.
  final Widget child;

  /// Whose surface to paint. Defaults to [SurfaceKind.popover].
  final SurfaceKind kind;

  /// Overrides the surface's padding.
  final EdgeInsetsGeometry? padding;

  /// Merged over the surface's decoration.
  final FinesseDecoration? decoration;

  /// Overrides the surface's shadows.
  final List<BoxShadow>? shadows;

  /// Overrides the surface's backdrop filter (a translucent menu's blur).
  final ImageFilter? filter;

  /// Merged into the default text style, which is the popover foreground.
  final TextStyle? textStyle;

  /// An arrow pointing at what the surface is anchored to; see
  /// [SurfacePainter.arrow].
  final SurfaceArrow? arrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final popoverTheme = theme.popoverTheme;
    final menuTheme = theme.contextMenuTheme;
    final isMenu = kind == SurfaceKind.menu;

    var effectiveDecoration =
        (popoverTheme.decoration ?? const FinesseDecoration())
            .merge(isMenu ? menuTheme.decoration : null)
            .merge(decoration);
    effectiveDecoration = effectiveDecoration.copyWith(
      shadows:
          shadows ??
          (isMenu ? menuTheme.shadows : null) ??
          popoverTheme.shadows ??
          effectiveDecoration.shadows,
    );

    final effectivePadding =
        padding ??
        (isMenu
            ? menuTheme.padding ?? const EdgeInsets.symmetric(vertical: 4)
            : popoverTheme.padding ??
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6));

    return SurfacePainter(
      decoration: effectiveDecoration,
      padding: effectivePadding,
      filter:
          filter ?? (isMenu ? menuTheme.filter : null) ?? popoverTheme.filter,
      textStyle: (popoverTheme.textStyle ?? const TextStyle()).merge(textStyle),
      arrow: arrow,
      child: child,
    );
  }
}

/// The arrow of a [SurfacePainter]: a small tip on the edge of the surface
/// that faces what the surface is anchored to, as on a `Tooltip`.
///
/// It is for a surface shown by a [Portal] — `Popover(showArrow: true)`
/// passes one — because the portal is what knows where the surface ended
/// up: on which side of its anchor, and how far it was pushed along the
/// edge of the screen. The arrow reads both, from the [PortalPlacement]
/// above it, and keeps pointing at the anchor. `showPopover` publishes the
/// same for the rectangle it is given.
@immutable
class SurfaceArrow {
  /// Creates the arrow of a surface that its portal placed by [anchor].
  const SurfaceArrow({
    required this.anchor,
    this.size = 10,
    this.radius = 2,
    this.targetSize,
  });

  /// The anchor the surface's [Portal] was given. The arrow rides the edge
  /// that faces the anchor's target, following the portal to a fallback.
  final AnchorBase anchor;

  /// The side of the arrow's square, which is turned 45° and sunk into the
  /// edge: the tip stands [protrusion] proud of it.
  final double size;

  /// The corner radius of the tip.
  final double radius;

  /// The size of the portal's child, asked while the surface is built. With
  /// it the arrow points at the middle of the child's edge even when the
  /// surface is aligned with one of its ends.
  final ValueGetter<Size?>? targetSize;

  /// How far the tip pokes out of the surface.
  double get protrusion => ArrowShape.protrusionOf(size, radius);

  /// [anchor] with room for the arrow between the surface and its target:
  /// every anchor of the chain moved [protrusion] further from the target.
  AnchorBase spaced(TextDirection textDirection) =>
      ArrowPlacement.withGap(anchor, protrusion, textDirection);

  @override
  bool operator ==(Object other) =>
      other is SurfaceArrow &&
      other.anchor == anchor &&
      other.size == size &&
      other.radius == radius &&
      other.targetSize == targetSize;

  @override
  int get hashCode => Object.hash(anchor, size, radius, targetSize);
}

/// Paints a resolved popover-style surface: [decoration], [padding], the
/// popover foreground for text and icons, and an optional backdrop [filter].
///
/// [Surface] resolves the theme and paints through this; `Popover`
/// paints its own surface through it too, so the two cannot drift apart.
class SurfacePainter extends StatelessWidget {
  /// Creates a painter for an already resolved surface.
  const SurfacePainter({
    super.key,
    required this.decoration,
    required this.padding,
    required this.child,
    this.filter,
    this.textStyle,
    this.arrow,
  });

  /// The key of the empty box that marks where the arrow is, for tests.
  static const arrowKey = ValueKey<String>('finesse_surface_arrow');

  /// The decoration of the surface: fill, border, radius and shadows.
  final FinesseDecoration decoration;

  /// The space between the edge of the surface and [child].
  final EdgeInsetsGeometry padding;

  /// A filter applied to what is behind the surface, such as a blur. When
  /// null, nothing is filtered.
  final ImageFilter? filter;

  /// The base text style for [child]. Its color is always replaced with the
  /// popover foreground color.
  final TextStyle? textStyle;

  /// An arrow pointing at what the surface is anchored to, or null for a
  /// plain box.
  ///
  /// Surface and arrow are one shape: filled in one stroke, so a
  /// translucent fill is not doubled where they meet; outlined by one line
  /// that runs round the tip; clipped as one, so glass blurs one continuous
  /// area; and casting one shadow, which stays out of both.
  final SurfaceArrow? arrow;

  /// The content of the surface.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.popoverForeground;

    final content = Padding(
      padding: padding,
      child: IconTheme.merge(
        // Icons follow the surface's own foreground, not the page's, which
        // is the wrong colour as soon as the surface differs from the page
        // (an inverted menu rendered its icons invisibly).
        data: IconThemeData(color: foreground),
        child: DefaultTextStyle(
          style: (textStyle ?? const TextStyle()).copyWith(color: foreground),
          // Not centred: a popover is mostly a menu or a form, which
          // shadcn/ui aligns to the start.
          textAlign: TextAlign.start,
          child: child,
        ),
      ),
    );

    final arrow = this.arrow;
    if (arrow != null) return _buildArrowed(context, arrow, content);

    // A filter has to be clipped, and the clip would cut off the surface's
    // own shadow, which is painted outside the box — so with a filter the
    // shadow is painted by the `BackdropSurface`, outside the clip, and not
    // by the decoration.
    final radius = decoration.border?.borderRadius ?? BorderRadius.zero;
    final outerShadows = filter == null
        ? const <BoxShadow>[]
        : decoration.shadows ?? const <BoxShadow>[];
    final castsOutside = outerShadows.isNotEmpty;

    final surface = Decorator(
      decoration: castsOutside
          ? decoration.copyWith(shadows: const [])
          : decoration,
      child: content,
    );

    return BackdropSurface(
      filter: filter,
      tintOpacity: decoration.color?.a ?? 0,
      borderRadius: radius,
      shadow: castsOutside
          ? ShadowDecoration.box(borderRadius: radius, shadows: outerShadows)
          : null,
      child: surface,
    );
  }

  /// The surface with its [arrow]: one outline for the fill, the border,
  /// the clip and the shadow.
  Widget _buildArrowed(
    BuildContext context,
    SurfaceArrow arrow,
    Widget content,
  ) {
    final textDirection = Directionality.of(context);
    final placement = ArrowPlacement.of(
      context,
      arrow.anchor,
      targetSize: arrow.targetSize?.call(),
    );
    final border = decoration.border;
    final shape = ArrowShape(
      radius: border?.borderRadius?.resolve(textDirection) ?? BorderRadius.zero,
      direction: placement.direction,
      arrowSize: arrow.size,
      arrowRadius: arrow.radius,
      anchor: placement.anchor,
      shift: placement.shift,
    );
    final fill = decoration.color ?? const Color(0x00000000);
    final shadows = decoration.shadows ?? const <BoxShadow>[];
    // Under an opaque fill the shadow needs no clip, the expensive half of
    // a shadow of this shape: it is painted first and covered.
    final covered = filter == null && fill.a >= 1;

    // The box keeps its layout — a border is padding around the content —
    // and whatever else it paints, a gradient or an image. Its fill, its
    // line and its shadow are the outline's.
    FinesseBorderSide? cleared(FinesseBorderSide? side) => side == null
        ? null
        : FinesseBorderSide(
            canMerge: side.canMerge,
            color: const Color(0x00000000),
            width: side.width,
            style: side.style,
            strokeAlign: side.strokeAlign,
          );
    Widget surface = CustomPaint(
      painter: ArrowShapePainter(
        shape: shape,
        color: fill,
        single: true,
        border: border?.top?.toBorderSide() ?? BorderSide.none,
        shadows: covered ? shadows : const [],
      ),
      child: Decorator(
        decoration: decoration.copyWith(
          color: const Color(0x00000000),
          shadows: const [],
          border: border == null || border is FinesseRoundedSuperellipseBorder
              ? border
              : border.copyWith(
                  top: cleared(border.top),
                  right: cleared(border.right),
                  bottom: cleared(border.bottom),
                  left: cleared(border.left),
                ),
        ),
        child: content,
      ),
    );
    if (shape.direction != null) {
      surface = Stack(
        clipBehavior: Clip.none,
        children: [
          surface,
          Positioned.fill(
            child: ArrowMarker(shape: shape, markerKey: arrowKey),
          ),
        ],
      );
    }
    return BackdropSurface(
      filter: filter,
      tintOpacity: fill.a,
      clipper: ArrowShapeClipper(shape, single: true),
      shadow: shadows.isNotEmpty && !covered
          ? ShadowDecoration(
              decoration: ShapeDecoration(
                shape: ArrowShapeOutline(shape, single: true),
              ),
              shadows: shadows,
            )
          : null,
      child: surface,
    );
  }
}
