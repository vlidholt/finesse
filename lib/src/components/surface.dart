import 'dart:math' as math;
import 'dart:ui';

import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:finesse/src/utils/entrance.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/services.dart';
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

    // A filter has to be clipped, and the clip would cut off the surface's
    // own shadow, which is painted outside the box — so with a filter the
    // shadow is painted by the `BackdropSurface`, outside the clip, and not
    // by the decoration.
    final radius = decoration.border?.radius ?? BorderRadius.zero;
    final outerShadows = filter == null
        ? const <BoxShadow>[]
        : decoration.shadows ?? const <BoxShadow>[];
    final castsOutside = outerShadows.isNotEmpty;

    final surface = Decorator(
      decoration: castsOutside
          ? decoration.copyWith(shadows: const [])
          : decoration,
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
///
/// The popover takes the keyboard focus when it opens, like any route. Set
/// [requestFocus] to false — it is `ModalRoute.requestFocus` — to leave the
/// focus where it is: a toolbar over a text selection must not take the
/// caret. Escape still closes the popover then, before anything under it.
/// Its content is another route, though, and no Tab stop from the page:
/// anchor a `Popover` to a widget when it should be one.
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
  bool requestFocus = true,
  RouteSettings? routeSettings,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  // The route is built under the navigator; republish a theme applied to the
  // subtree the popover was opened from (see ThemeScope).
  final theme = Theme.of(context, listen: false);
  // It arrives and leaves like a `Popover`: on the motion tokens, and
  // faster out than in.
  final motion = Motion.of(context);
  return navigator.push(
    _AnchoredPopoverRoute<T>(
      anchorRect: anchorRect,
      gap: gap,
      transitionDuration: motion.reduced
          ? motion.fast
          : motion.snappy.settleDuration,
      reverseTransitionDuration: motion.fast,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? '',
      takesFocus: requestFocus,
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
    required this.transitionDuration,
    required this.reverseTransitionDuration,
    required this.takesFocus,
    super.settings,
  }) : super(requestFocus: takesFocus);

  final Rect anchorRect;
  final double gap;
  final WidgetBuilder builder;

  /// Whether the route takes the focus when it is pushed. Without it the
  /// route's own Escape binding is out of reach — the key goes to whatever
  /// has the focus, in the route below — so the route listens for Escape
  /// itself; see [_onKey].
  final bool takesFocus;

  @override
  void install() {
    super.install();
    if (!takesFocus) FocusManager.instance.addEarlyKeyEventHandler(_onKey);
  }

  @override
  void dispose() {
    if (!takesFocus) FocusManager.instance.removeEarlyKeyEventHandler(_onKey);
    super.dispose();
  }

  /// Escape, before the focus tree sees it.
  ///
  /// Before, not after: a focused text field consumes Escape whether or not
  /// it has a use for it, so a handler for keys nobody wanted would never
  /// hear it. And the route on top is what Escape should close first — a
  /// dialog under it must not close on the same key press, which is why the
  /// event stops here.
  KeyEventResult _onKey(KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape ||
        !isCurrent ||
        !barrierDismissible) {
      return KeyEventResult.ignored;
    }
    // With the focus inside the popover its own bindings act: whatever in
    // it wants the key first, then the route's.
    final context = subtreeContext;
    if (context != null &&
        FocusScope.of(context, createDependency: false).hasFocus) {
      return KeyEventResult.ignored;
    }
    navigator?.maybePop();
    return KeyEventResult.handled;
  }

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final bool barrierDismissible;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => null;

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

  /// The animations the transition is drawn from. They depend only on the
  /// route's animation and the motion tokens, so they are made when those
  /// change — not in [buildTransitions], which the framework calls on every
  /// tick, and where new ones made every render object below drop its
  /// listener and subscribe again.
  _PopoverAnimations? _animations;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // shadcn's `fade-in-0 zoom-in-95`, on the theme's motion: in on the
    // spring, out in a straight line from wherever it is. The fade goes
    // through a host, so a glass surface fades inside its own filter
    // rather than under an opacity layer (see [BackdropFade]).
    final motion = Motion.of(context);
    final curve = motion.reduced ? motion.standard : motion.snappy.curve;
    var animations = _animations;
    if (animations == null ||
        !animations.isFor(animation, curve: curve, from: motion.overlayScale)) {
      animations = _animations = _PopoverAnimations(
        animation,
        curve: curve,
        from: motion.overlayScale,
      );
    }
    return ScaleTransition(
      scale: animations.scale,
      child: BackdropFadeHost(opacity: animations.fade, child: child),
    );
  }
}

/// The animations of one [_AnchoredPopoverRoute]'s transition.
class _PopoverAnimations {
  _PopoverAnimations(
    this._animation, {
    required Curve curve,
    required double from,
  }) : _curve = curve,
       _from = from {
    final progress = EntranceProgress(_animation, curve: curve);
    scale = progress.drive(Tween<double>(begin: from, end: 1));
    fade = progress.drive(const _FadeInBy(.6));
  }

  final Animation<double> _animation;
  final Curve _curve;
  final double _from;

  /// From the motion's overlay scale up to full size.
  late final Animation<double> scale;

  /// The popover is readable well before it has settled.
  late final Animation<double> fade;

  /// Whether these were made for the given animation and tokens.
  bool isFor(
    Animation<double> animation, {
    required Curve curve,
    required double from,
  }) => identical(animation, _animation) && curve == _curve && from == _from;
}

/// A fade that is finished by [end] of the way.
class _FadeInBy extends Animatable<double> {
  const _FadeInBy(this.end);

  final double end;

  @override
  double transform(double t) => (t / end).clamp(0.0, 1.0);
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
