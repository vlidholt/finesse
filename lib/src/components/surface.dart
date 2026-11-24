import 'dart:math' as math;
import 'dart:ui';

import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
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
/// cell editor, a find bar, a hover card — so it gets the same outline
/// (shadcn's `ring-foreground/10`, not `--border`), radius, padding,
/// colours and shadow as a `Popover`. The shadow is painted the way CSS
/// paints `box-shadow`, outside the element only; a hand-built
/// `BoxDecoration(boxShadow:)` washes a translucent fill grey and loses the
/// shadow next to the element.
///
/// To show one anchored to a rectangle, see [showPopover].
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
      child: child,
    );
  }
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
  });

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

  /// The content of the surface.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.popoverForeground;

    Widget surface = Decorator(
      decoration: decoration,
      child: Padding(
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
      ),
    );

    final filter = this.filter;
    if (filter != null) {
      final radius = decoration.border?.radius ?? BorderRadius.zero;
      surface = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(filter: filter, child: surface),
      );
      // The clip that bounds the filter also cuts off the surface's own
      // shadow, which is painted outside the box, so it is painted again
      // outside the clip.
      final shadows = decoration.shadows;
      if (shadows != null && shadows.isNotEmpty) {
        surface = DecoratedBox(
          decoration: ShadowDecoration.box(
            borderRadius: radius,
            shadows: shadows,
          ),
          child: surface,
        );
      }
    }
    return surface;
  }
}

/// Shows a popover anchored to [anchorRect], a rectangle in global
/// coordinates, for UI that has a rectangle rather than a widget to anchor
/// to: a text selection, a table cell, a hit on a canvas.
///
/// The popover opens [gap] below the rectangle, centred on it, and moves
/// above when there is not enough room below; it is shifted to stay on
/// screen. It closes on a tap outside or on Escape, and the returned future
/// completes with the value it was popped with.
///
/// The content is wrapped in a [Surface] of [kind]; pass
/// [Surface.new]'s parameters through [padding] and [decoration], or set
/// [surface] to false to draw your own.
Future<T?> showPopover<T>({
  required BuildContext context,
  required Rect anchorRect,
  required WidgetBuilder builder,
  SurfaceKind kind = SurfaceKind.popover,
  bool surface = true,
  EdgeInsetsGeometry? padding,
  FinesseDecoration? decoration,
  double gap = 4,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  // The route is built under the navigator; republish a theme applied to the
  // subtree the popover was opened from (see ThemeScope).
  final theme = Theme.of(context, listen: false);
  return navigator.push(
    _AnchoredPopoverRoute<T>(
      anchorRect: anchorRect,
      gap: gap,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? '',
      settings: routeSettings,
      builder: (routeContext) {
        Widget content = Builder(builder: builder);
        if (surface) {
          content = Surface(
            kind: kind,
            padding: padding,
            decoration: decoration,
            child: content,
          );
        }
        return Theme(data: theme, child: content);
      },
    ),
  );
}

class _AnchoredPopoverRoute<T> extends PopupRoute<T> {
  _AnchoredPopoverRoute({
    required this.anchorRect,
    required this.gap,
    required this.builder,
    required this.barrierDismissible,
    required this.barrierLabel,
    super.settings,
  });

  final Rect anchorRect;
  final double gap;
  final WidgetBuilder builder;

  @override
  final bool barrierDismissible;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return CustomSingleChildLayout(
      delegate: _AnchorRectLayout(
        anchorRect: anchorRect,
        gap: gap,
        padding: MediaQuery.paddingOf(context),
      ),
      child: Builder(builder: builder),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // shadcn's `fade-in-0 zoom-in-95`.
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: .95, end: 1).animate(curved),
        child: child,
      ),
    );
  }
}

class _AnchorRectLayout extends SingleChildLayoutDelegate {
  _AnchorRectLayout({
    required this.anchorRect,
    required this.gap,
    required this.padding,
  });

  final Rect anchorRect;
  final double gap;
  final EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen().deflate(padding);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final top = padding.top;
    final bottom = size.height - padding.bottom;
    final below = anchorRect.bottom + gap;
    final above = anchorRect.top - gap - childSize.height;
    final y = below + childSize.height <= bottom || above < top ? below : above;
    final x = anchorRect.center.dx - childSize.width / 2;
    return Offset(
      x.clamp(
        padding.left,
        math.max(padding.left, size.width - padding.right - childSize.width),
      ),
      y.clamp(top, math.max(top, bottom - childSize.height)),
    );
  }

  @override
  bool shouldRelayout(_AnchorRectLayout oldDelegate) =>
      anchorRect != oldDelegate.anchorRect ||
      gap != oldDelegate.gap ||
      padding != oldDelegate.padding;
}
