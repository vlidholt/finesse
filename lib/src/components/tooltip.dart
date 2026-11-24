import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/anchor_stage.dart';
import 'package:finesse/src/utils/animate.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:finesse/src/utils/dismiss_shortcut.dart';
import 'package:finesse/src/utils/entrance.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:finesse/src/utils/mouse_area.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Controls the visibility of a [Tooltip].
typedef TooltipController = PopoverController;

/// {@template Tooltip}
/// A widget that displays a tooltip on hover or focus, styled to match the
/// Shadcn UI design system.
///
/// Provides customizable delay, duration, animation effects, and styling.
/// {@endtemplate}
class Tooltip extends StatefulWidget {
  /// {@macro Tooltip}
  const Tooltip({
    super.key,
    required this.child,
    required this.builder,
    this.focusNode,
    this.waitDuration,
    this.showDuration,
    this.effects,
    this.padding,
    this.decoration,
    this.anchor,
    this.hoverStrategies,
    this.controller,
    this.longPressDuration,
    this.reverseDuration,
    this.showArrow,
    this.arrowDirection,
    this.filter,
  });

  /// {@template Tooltip.builder}
  /// The builder function that creates the tooltip content widget.
  ///
  /// Called with the [BuildContext] to build the tooltip's content.
  /// {@endtemplate}
  final WidgetBuilder builder;

  /// {@template Tooltip.child}
  /// The child widget that triggers the tooltip when hovered or focused.
  ///
  /// This is the widget that the tooltip is attached to.
  /// {@endtemplate}
  final Widget child;

  /// {@template Tooltip.focusNode}
  /// The focus node of the child widget.
  ///
  /// When the child gains focus, the tooltip will be shown.
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// {@template Tooltip.waitDuration}
  /// The length of time that a pointer must hover over a tooltip's widget
  /// before the tooltip will be shown.
  ///
  /// Defaults to null (tooltips are shown immediately upon hover). The wait
  /// is skipped while another tooltip is still showing or leaving, so
  /// moving along a row of buttons shows each one's tooltip at once.
  /// {@endtemplate}
  final Duration? waitDuration;

  /// {@template Tooltip.showDuration}
  /// The length of time that the tooltip will be shown after a mouse pointer
  /// exits the widget.
  ///
  /// Defaults to null.
  /// {@endtemplate}
  final Duration? showDuration;

  /// {@template Tooltip.effects}
  /// The animation effects applied to the tooltip.
  ///
  /// Defaults to the theme's, and then to a quick `EntranceEffect` on the
  /// theme's motion tokens: the bubble pops out of the side that faces its
  /// trigger. A tooltip that takes over from another one — the pointer moved
  /// to the next button — only fades in.
  ///
  /// The entrance lasts as long as its effects do: to change its length,
  /// give the effects a duration ([Effect.duration]). An empty list shows
  /// the tooltip at once.
  /// {@endtemplate}
  final List<Effect<dynamic>>? effects;

  /// {@template Tooltip.padding}
  /// The padding of the tooltip content.
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 12, vertical: 6)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Tooltip.decoration}
  /// The decoration of the tooltip.
  ///
  /// Defines the visual appearance of the tooltip's container.
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template Tooltip.anchor}
  /// The anchor position of the tooltip relative to its child.
  ///
  /// Defaults to
  /// ```dart
  /// const AnchorAuto(
  ///   offset: Offset(0, -4),
  ///   followerAnchor: Alignment.topCenter,
  ///   targetAnchor: Alignment.topCenter,
  /// );
  /// ```
  /// {@endtemplate}
  final AnchorBase? anchor;

  /// {@template Tooltip.hoverStrategies}
  /// The hover strategies to use for the tooltip on devices with touchscreens.
  ///
  /// Configures how hover interactions are interpreted, especially on touch
  /// devices.
  /// {@endtemplate}
  final HoverStrategies? hoverStrategies;

  /// {@template Tooltip.controller}
  /// The controller that manages the visibility of the [Tooltip].
  ///
  /// Allows programmatic control over showing and hiding the tooltip. If null,
  /// a default [TooltipController] is created internally.
  /// {@endtemplate}
  final TooltipController? controller;

  /// {@template Tooltip.longPressDuration}
  /// The duration for a long press to be recognized, triggering the tooltip on
  /// touch devices.
  ///
  /// Specifies how long a press must be to trigger the tooltip on touch-based
  /// interactions.
  /// {@endtemplate}
  final Duration? longPressDuration;

  /// {@template Tooltip.reverseDuration}
  /// The duration of the tooltip's exit animation: its [effects] played
  /// backwards over this long.
  ///
  /// Defaults to the theme's, and then to its `Motion.fast`.
  /// {@endtemplate}
  final Duration? reverseDuration;

  /// {@template Tooltip.showArrow}
  /// Whether the tooltip draws the arrow pointing at its trigger, defaults
  /// to true.
  /// {@endtemplate}
  final bool? showArrow;

  /// {@template Tooltip.arrowDirection}
  /// The direction the arrow points, i.e. which edge of the tooltip it
  /// rides: [AxisDirection.down] puts it on the bottom edge.
  ///
  /// Defaults to pointing at the trigger through the default anchors: down
  /// while the tooltip sits above it, flipping up when the portal falls
  /// back below. Set it explicitly when using a custom [anchor] that places
  /// the tooltip to the side.
  /// {@endtemplate}
  final AxisDirection? arrowDirection;

  /// {@template Tooltip.filter}
  /// A filter applied to what is behind the tooltip, such as the blur of a
  /// glass bubble. The bubble and its arrow are filtered as one shape.
  /// Defaults to the theme's, which is null in a style with solid tooltips.
  /// {@endtemplate}
  final ImageFilter? filter;

  @override
  State<Tooltip> createState() => _TooltipState();
}

class _TooltipState extends State<Tooltip> with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  TooltipController? _controller;
  bool hovered = false;
  bool get hasFocus => widget.focusNode?.hasFocus ?? false;

  TooltipController get controller => widget.controller ?? _controller!;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      // Replaced by the animate widget, with the length of its effects,
      // each time the tooltip is built.
      duration: Animate.defaultDuration,
      reverseDuration: Duration.zero,
    );
    if (widget.controller == null) _controller = TooltipController();
    widget.focusNode?.addListener(onFocusChange);
    controller.addListener(_onOpenChanged);
    // A controller that arrives open.
    if (controller.isOpen) _stage.watch();
  }

  @override
  void dispose() {
    _showing.remove(this);
    _stage.dispose();
    controller.removeListener(_onOpenChanged);
    animationController.dispose();
    widget.focusNode?.removeListener(onFocusChange);
    _controller?.dispose();
    super.dispose();
  }

  /// The tooltips the pointer has brought up: open, or still playing their
  /// exit. One that is held open by its controller or by focus is not among
  /// them — it would make every other tooltip a follow-up for as long as it
  /// stayed.
  static final _showing = <_TooltipState>{};

  bool get _othersShowing => _showing.any((other) => !identical(other, this));

  /// Whether this showing took over from another tooltip. Such a tooltip
  /// only fades in — a second pop right beside the first reads as a
  /// flicker — and does not wait.
  bool _warm = false;

  void _onOpenChanged() {
    if (controller.isOpen) {
      // Opened behind the scenes, it stays there until its trigger shows.
      _stage.watch();
    }
    if (!controller.isOpen) {
      _showing.remove(this);
      // However it closed — its exit played, focus left, Escape — the next
      // showing starts from nothing. Left at 1 (a close with no exit), the
      // next exit would be a real animation started before the overlay was
      // built, which the entrance then cancels: see [_leave].
      animationController.value = 0;
    } else if (!_showing.contains(this)) {
      // Opened by something other than the pointer.
      _warm = false;
    }
  }

  /// The hover strategies this tooltip was configured with, before the
  /// tooltip's own onHoverChange is layered on top.
  HoverStrategies? _baseHoverStrategies;

  /// The theme handed to [Tooltip.child], with the merged hover strategies
  /// applied.
  ///
  /// Computed here rather than in build(). Building it per build allocated a
  /// fresh `onHoverChange` closure, and HoverStrategies compares that
  /// closure in `==`, so the copied theme was never equal to the previous one.
  /// FinesseInheritedTheme then reported a change and rebuilt the tooltip's
  /// entire child subtree on every tooltip rebuild — and `ThemeData.copyWith`
  /// re-runs all 54 component-theme merges each time.
  late ThemeData _childTheme;

  void _handleHoverChange(bool value) {
    _baseHoverStrategies?.onHoverChange?.call(value);
    onHoverChange(value);
  }

  void _syncEffectiveTheme() {
    final theme = Theme.of(context);
    final base =
        widget.hoverStrategies ??
        theme.tooltipTheme.hoverStrategies ??
        theme.hoverStrategies;
    _baseHoverStrategies = base;
    _childTheme = theme.copyWith(
      hoverStrategies: base.copyWith(
        // A tear-off of an instance method is canonicalized per receiver, so
        // this keeps a stable identity across rebuilds.
        onHoverChange: _handleHoverChange,
        longPressDuration:
            widget.longPressDuration ?? theme.tooltipTheme.longPressDuration,
      ),
    );
    animationController.reverseDuration =
        widget.reverseDuration ??
        theme.tooltipTheme.reverseDuration ??
        Motion.of(context).fast;
  }

  /// Whether the trigger is in a part of the tree that is shown; see the
  /// same field on `Popover`. A tooltip whose trigger was hidden — in an
  /// `IndexedStack` child that is not showing, an `Offstage` — would
  /// otherwise stay on screen over whatever replaced it.
  late final _stage = AnchorStage(
    context: context,
    // Not one of this widget's dependencies: nothing else rebuilds it.
    onChanged: () => setState(() {}),
    watching: () => controller.isOpen,
  );

  bool get _onStage => _stage.onStage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncEffectiveTheme();
    _stage.resolve();
  }

  @override
  void didUpdateWidget(Tooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(onFocusChange);
      widget.focusNode?.addListener(onFocusChange);
    }
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _controller)?.removeListener(_onOpenChanged);
      if (widget.controller == null) {
        _controller ??= TooltipController();
      }
      controller.addListener(_onOpenChanged);
      _onOpenChanged();
    }
    if (widget.hoverStrategies != oldWidget.hoverStrategies ||
        widget.longPressDuration != oldWidget.longPressDuration ||
        widget.reverseDuration != oldWidget.reverseDuration) {
      _syncEffectiveTheme();
    }
  }

  void onFocusChange() {
    hasFocus ? controller.show() : controller.hide();
  }

  Future<void> onHoverChange(bool value) async {
    if (hovered == value) return;
    hovered = value;
    // Every await below can outlive the widget: the pointer leaves, the route
    // is popped, and the delay completes against a disposed controller.
    if (value) {
      if (controller.isOpen) {
        // Back before it had left: it turns around where it is.
        if (animationController.status == AnimationStatus.reverse) {
          animationController.forward();
        }
        return;
      }
      // No wait while another tooltip is up: the pointer is moving along a
      // row of triggers, and the next tooltip follows it.
      if (widget.waitDuration != null && !_othersShowing) {
        await Future<void>.delayed(widget.waitDuration!);
        if (!mounted) return;
      }
      if (hovered) {
        _warm = _othersShowing;
        _showing.add(this);
        controller.show();
      }
    } else {
      if (widget.showDuration != null) {
        await Future<void>.delayed(widget.showDuration!);
        if (!mounted) return;
      }
      if (!hovered && !hasFocus) await _leave();
    }
  }

  /// Plays the exit and closes the tooltip, unless the pointer or the focus
  /// came back in the meantime.
  Future<void> _leave() async {
    // Off stage nobody sees the exit, and with tickers muted it would never
    // complete.
    if (_onStage) {
      try {
        await animationController.reverse().orCancel;
      } on TickerCanceled {
        // Something else took the controller over. If that was the pointer
        // coming back, the check below keeps the tooltip; anything else —
        // the entrance of an overlay built after the pointer had already
        // left, effects that changed length mid-exit — must not leave the
        // tooltip up with nothing to close it. A bare `await reverse()`
        // never returns from a cancelled run.
      }
    }
    if (!mounted) return;
    if (hovered || hasFocus) return;
    controller.hide();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final motion = Motion.of(context);
    final effectivePadding = widget.padding ?? theme.tooltipTheme.padding;
    final effectiveDecoration =
        (theme.tooltipTheme.decoration ?? const FinesseDecoration()).merge(
          widget.decoration,
        );

    final effectiveAnchor =
        widget.anchor ??
        theme.tooltipTheme.anchor ??
        const AnchorAuto(
          offset: Offset(0, -4),
          followerAnchor: Alignment.topCenter,
          targetAnchor: Alignment.topCenter,
          fallback: AnchorAuto(
            offset: Offset(0, 4),
          ),
        );

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        // Radix dismisses a tooltip on Escape; without this a keyboard user
        // who focused the trigger had no way to get rid of it. Only while it
        // is shown, so Escape still reaches an enclosing dialog otherwise.
        return DismissShortcut(
          isActive: () => controller.isOpen,
          onDismiss: () {
            hovered = false;
            controller.hide();
          },
          child: Portal(
            visible: controller.isOpen && _onStage,
            anchor: effectiveAnchor,
            portalBuilder: (context) {
              // The portal takes its overlay down a frame after it is told
              // to; off stage that frame would show over what replaced the
              // trigger.
              if (!_onStage) return const SizedBox.shrink();
              // Key caps invert along with the surface, the reference's
              // `in-data-[slot=tooltip-content]:bg-background/20
              // text-background` (a `/10` wash in dark).
              final contentTheme = _contentThemeOf(theme);

              final textDirection = Directionality.of(context);
              final showArrow =
                  widget.showArrow ?? theme.tooltipTheme.showArrow ?? true;
              // The bubble and its arrow are one shape: filled in a single
              // stroke, so a translucent tint is not doubled where they
              // meet, and clipped as one, so a glass tooltip blurs one
              // continuous area.
              final shape = _TooltipShape(
                radius:
                    effectiveDecoration.border?.radius?.resolve(
                      textDirection,
                    ) ??
                    BorderRadius.zero,
                // The default anchors put the tooltip above the trigger, so
                // the arrow rides the bottom edge — flipping up when the
                // portal fell back below.
                direction: !showArrow
                    ? null
                    : widget.arrowDirection ??
                          (PortalPlacement.usedFallbackOf(context)
                              ? AxisDirection.up
                              : AxisDirection.down),
                arrowSize: theme.tooltipTheme.arrowSize ?? 10,
                arrowRadius: theme.tooltipTheme.arrowRadius ?? 2,
                // The bubble slides along the viewport edge to stay on
                // screen; the arrow slides back the same distance so it
                // keeps pointing at the trigger.
                shift: PortalPlacement.shiftOf(context),
              );
              final fill =
                  effectiveDecoration.color ?? theme.colorScheme.foreground;
              final effectiveFilter =
                  widget.filter ?? theme.tooltipTheme.filter;
              // Over a filter the shadow is painted outside the clip, and
              // outside the whole outline — arrow included — rather than by
              // the bubble's own decoration.
              final outerShadows = effectiveFilter == null
                  ? const <BoxShadow>[]
                  : effectiveDecoration.shadows ?? const <BoxShadow>[];

              Widget tooltip = CustomPaint(
                painter: _TooltipShapePainter(shape: shape, color: fill),
                child: Decorator(
                  // The fill is the painter's; the rest of the decoration —
                  // a border, a gradient — stays the bubble's own.
                  decoration: effectiveDecoration.copyWith(
                    color: const Color(0x00000000),
                    shadows: outerShadows.isNotEmpty ? const [] : null,
                  ),
                  child: Padding(
                    padding: effectivePadding ?? EdgeInsets.zero,
                    child: DefaultTextStyle(
                      // The inverted surface's `text-background`, at
                      // `text-xs`.
                      style:
                          theme.tooltipTheme.textStyle ??
                          theme.textTheme.muted.copyWith(
                            fontSize: 12,
                            height: 16 / 12,
                            color: theme.colorScheme.background,
                          ),
                      child: Theme(
                        data: contentTheme,
                        // Through a Builder, so a custom [Tooltip.builder]
                        // sees the inverted text style and theme through
                        // its own context.
                        child: Builder(builder: widget.builder),
                      ),
                    ),
                  ),
                ),
              );
              if (showArrow) {
                tooltip = Stack(
                  clipBehavior: Clip.none,
                  children: [
                    tooltip,
                    Positioned.fill(child: _TooltipArrowMarker(shape: shape)),
                  ],
                );
              }
              tooltip = BackdropSurface(
                filter: effectiveFilter,
                tintOpacity: fill.a,
                clipper: _TooltipShapeClipper(shape),
                shadow: outerShadows.isNotEmpty
                    ? ShadowDecoration(
                        decoration: ShapeDecoration(
                          shape: _TooltipOutline(shape),
                        ),
                        shadows: outerShadows,
                      )
                    : null,
                child: tooltip,
              );

              final maxWidth = theme.tooltipTheme.maxWidth ?? 320.0;
              tooltip = ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: tooltip,
              );

              // A quick pop out of the trigger's side — quicker than a
              // popover, which is a larger surface — or a plain fade when
              // it takes over from another tooltip. Resolved here, where
              // the tooltip is built for this showing.
              final effectiveEffects =
                  widget.effects ??
                  theme.tooltipTheme.effects ??
                  (_warm
                      ? EntranceEffect.fadeFor(motion)
                      : EntranceEffect.forMotion(
                          motion,
                          spring: motion.snappy.scaled(.8),
                        ));
              if (effectiveEffects.isNotEmpty) {
                tooltip = FinesseAnimate(
                  controller: animationController,
                  effects: effectiveEffects,
                  // The bubble may be glass; see [BackdropFade].
                  fadeThroughBackdrop: true,
                  child: tooltip,
                );
              }
              return MouseArea(groupId: 'tooltip', child: tooltip);
            },
            child: MouseArea(
              groupId: 'tooltip',
              // The child reports hover through the theme's hover strategies,
              // but a disabled button stops reporting, so its tooltip never
              // showed. Radix wraps disabled triggers for the same reason.
              // Listening here too covers any child; onHoverChange ignores
              // the duplicate when both report. A non-opaque MouseRegion
              // reports a miss from hitTest even when its child is hit, which
              // hid the trigger from a GestureDetector around the tooltip and
              // let taps through to widgets behind it. Deferring to the child
              // keeps the trigger's own hit test.
              child: MouseRegion(
                hitTestBehavior: HitTestBehavior.deferToChild,
                onEnter: (_) => onHoverChange(true),
                onExit: (_) => onHoverChange(false),
                child: Theme(
                  data: _childTheme,
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

final _contentThemes = Expando<ThemeData>();

/// [theme] as a tooltip's content sees it, with key caps inverted along
/// with the surface.
///
/// `ThemeData.copyWith` runs the theme factory again, so the result is kept
/// per theme: it is the same for every tooltip, and deriving it in the
/// portal's builder paid for every component theme on each build of each
/// open tooltip.
ThemeData _contentThemeOf(ThemeData theme) {
  return _contentThemes[theme] ??= theme.copyWith(
    kbdTheme: theme.kbdTheme.copyWith(
      backgroundColor: theme.colorScheme.background.withValues(
        alpha: theme.brightness == Brightness.dark ? .1 : .2,
      ),
      foregroundColor: theme.colorScheme.background,
    ),
  );
}

/// The outline of a tooltip: its bubble and, when [direction] is not null,
/// the arrow pointing from it at its trigger.
///
/// The arrow is shadcn/ui's `TooltipArrow`: a `size-2.5` square rotated 45°,
/// its tip rounded by `rounded-[2px]`, its centre 2px inside the edge it
/// rides (`translate-y-[calc(-50%-2px)]`) so about half its diagonal — 5px —
/// pokes out across the anchor gap.
///
/// Along its edge the arrow tracks the trigger rather than the bubble: a
/// tooltip near the side of the window is pushed inward to stay on screen
/// (see [PortalPlacement.shift]) and a centred arrow would then point
/// somewhere the trigger is not. It stops short of the bubble's corners,
/// where a rounded surface has no straight edge left to sit on.
@immutable
class _TooltipShape {
  const _TooltipShape({
    required this.radius,
    required this.direction,
    required this.arrowSize,
    required this.arrowRadius,
    required this.shift,
  });

  /// The bubble's corners.
  final BorderRadius radius;

  /// The edge the arrow rides, or null for no arrow.
  final AxisDirection? direction;
  final double arrowSize;
  final double arrowRadius;

  /// How far the bubble was moved off its anchor, from
  /// [PortalPlacement.shift]. The arrow moves back by as much of this as
  /// its edge has room for.
  final Offset shift;

  /// How far the arrow's centre sits inside the edge it rides.
  static const _inset = 2.0;

  /// How far from the centre of an edge of [extent] the arrow may sit.
  double _travel(double extent) {
    final cornerRadius = [
      radius.topLeft.x,
      radius.topRight.x,
      radius.bottomLeft.x,
      radius.bottomRight.x,
    ].reduce(math.max);
    // The rotated square is `size * sqrt2` across, so its own half-diagonal
    // has to clear the corner too.
    final keepClear = cornerRadius + arrowSize * math.sqrt2 / 2;
    return math.max(0, extent / 2 - keepClear);
  }

  /// The centre of the arrow's square on a bubble of [size], or null
  /// without an arrow.
  Offset? arrowCenter(Size size) {
    final direction = this.direction;
    if (direction == null) return null;
    final along = switch (direction) {
      AxisDirection.down || AxisDirection.up =>
        size.width / 2 +
            (-shift.dx).clamp(-_travel(size.width), _travel(size.width)),
      AxisDirection.left || AxisDirection.right =>
        size.height / 2 +
            (-shift.dy).clamp(-_travel(size.height), _travel(size.height)),
    };
    return switch (direction) {
      AxisDirection.down => Offset(along, size.height - _inset),
      AxisDirection.up => Offset(along, _inset),
      AxisDirection.left => Offset(_inset, along),
      AxisDirection.right => Offset(size.width - _inset, along),
    };
  }

  /// The outline on a bubble of [size].
  Path build(Size size) {
    final bubble = Path()..addRRect(radius.toRRect(Offset.zero & size));
    final center = arrowCenter(size);
    if (center == null) return bubble;
    final square = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: arrowSize,
            height: arrowSize,
          ),
          Radius.circular(arrowRadius),
        ),
      );
    final placed = square.transform(
      (Matrix4.translationValues(
        center.dx,
        center.dy,
        0,
      )..rotateZ(math.pi / 4)).storage,
    );
    // Two contours wound the same way, filled non-zero: their union, with
    // the overlap counted once. Not `Path.combine(PathOperation.union, …)`,
    // which on the web returns the bubble alone — a tooltip without its
    // arrow.
    return bubble..addPath(placed, Offset.zero);
  }

  @override
  bool operator ==(Object other) =>
      other is _TooltipShape &&
      other.radius == radius &&
      other.direction == direction &&
      other.arrowSize == arrowSize &&
      other.arrowRadius == arrowRadius &&
      other.shift == shift;

  @override
  int get hashCode =>
      Object.hash(radius, direction, arrowSize, arrowRadius, shift);
}

/// A [_TooltipShape] as a border, so a `ShadowDecoration` can cast its
/// shadow around the whole outline — bubble and arrow — and keep it out of
/// both.
class _TooltipOutline extends ShapeBorder {
  const _TooltipOutline(this.shape);

  final _TooltipShape shape;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      shape.build(rect.size).shift(rect.topLeft);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  @override
  bool operator ==(Object other) =>
      other is _TooltipOutline && other.shape == shape;

  @override
  int get hashCode => shape.hashCode;
}

class _TooltipShapePainter extends CustomPainter {
  const _TooltipShapePainter({required this.shape, required this.color});

  final _TooltipShape shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(shape.build(size), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TooltipShapePainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.color != color;
}

class _TooltipShapeClipper extends CustomClipper<Path> {
  const _TooltipShapeClipper(this.shape);

  final _TooltipShape shape;

  @override
  Path getClip(Size size) => shape.build(size);

  @override
  bool shouldReclip(_TooltipShapeClipper oldClipper) =>
      oldClipper.shape != shape;
}

/// An empty box where the arrow's square is, so a test can measure where
/// the tip landed. It takes its place from the same [_TooltipShape] the
/// painter does.
class _TooltipArrowMarker extends StatelessWidget {
  const _TooltipArrowMarker({required this.shape});

  final _TooltipShape shape;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = shape.arrowCenter(constraints.biggest)!;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fromRect(
              rect: Rect.fromCenter(
                center: center,
                width: shape.arrowSize,
                height: shape.arrowSize,
              ),
              child: const IgnorePointer(
                child: SizedBox.expand(
                  key: ValueKey('finesse_tooltip_arrow'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
