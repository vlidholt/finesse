import 'dart:math' as math;

import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/animate.dart';
import 'package:finesse/src/utils/dismiss_shortcut.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:finesse/src/utils/mouse_area.dart';
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
    this.duration,
    this.reverseDuration,
    this.showArrow,
    this.arrowDirection,
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
  /// Defaults to null (tooltips are shown immediately upon hover).
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
  /// Defaults to [FadeEffect(), ScaleEffect(begin: Offset(.95, .95), end:
  /// Offset(1, 1)),
  /// MoveEffect(begin: Offset(0, 2), end: Offset(0, 0))].
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

  /// {@template Tooltip.duration}
  /// The duration of the tooltip's entrance animation.
  ///
  /// Defaults to [Animate.defaultDuration].
  /// {@endtemplate}
  final Duration? duration;

  /// {@template Tooltip.reverseDuration}
  /// The duration of the tooltip's exit animation.
  ///
  /// Defaults to [Duration.zero].
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
      duration: Animate.defaultDuration,
      reverseDuration: Duration.zero,
    );
    if (widget.controller == null) _controller = TooltipController();
    widget.focusNode?.addListener(onFocusChange);
  }

  @override
  void dispose() {
    animationController.dispose();
    widget.focusNode?.removeListener(onFocusChange);
    _controller?.dispose();
    super.dispose();
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
  /// FinesseInheritedTheme then reported a change and rebuilt the tooltip's entire
  /// child subtree on every tooltip rebuild — and `ThemeData.copyWith`
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
    animationController
      ..duration = widget.duration ?? theme.tooltipTheme.duration
      ..reverseDuration =
          widget.reverseDuration ?? theme.tooltipTheme.reverseDuration;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncEffectiveTheme();
  }

  @override
  void didUpdateWidget(Tooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(onFocusChange);
      widget.focusNode?.addListener(onFocusChange);
    }
    if (widget.hoverStrategies != oldWidget.hoverStrategies ||
        widget.longPressDuration != oldWidget.longPressDuration ||
        widget.duration != oldWidget.duration ||
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
      if (widget.waitDuration != null) {
        await Future<void>.delayed(widget.waitDuration!);
        if (!mounted) return;
      }
      if (hovered) {
        controller.show();
      }
    } else {
      if (widget.showDuration != null) {
        await Future<void>.delayed(widget.showDuration!);
        if (!mounted) return;
      }
      if (!hovered && !hasFocus) {
        await animationController.reverse();
        if (!mounted) return;
        controller.hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveEffects = widget.effects ?? theme.tooltipTheme.effects ?? [];
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
            visible: controller.isOpen,
            anchor: effectiveAnchor,
            portalBuilder: (context) {
              // Key caps invert along with the surface, the reference's
              // `in-data-[slot=tooltip-content]:bg-background/20
              // text-background` (a `/10` wash in dark).
              final contentTheme = theme.copyWith(
                kbdTheme: theme.kbdTheme.copyWith(
                  backgroundColor: theme.colorScheme.background.withValues(
                    alpha: theme.brightness == Brightness.dark ? .1 : .2,
                  ),
                  foregroundColor: theme.colorScheme.background,
                ),
              );

              Widget tooltip = Decorator(
                decoration: effectiveDecoration,
                child: Padding(
                  padding: effectivePadding ?? EdgeInsets.zero,
                  child: DefaultTextStyle(
                    // The inverted surface's `text-background`, at `text-xs`.
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
                      // sees the inverted text style and theme through its
                      // own context.
                      child: Builder(builder: widget.builder),
                    ),
                  ),
                ),
              );

              final maxWidth = theme.tooltipTheme.maxWidth ?? 320.0;
              tooltip = ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: tooltip,
              );

              final showArrow =
                  widget.showArrow ?? theme.tooltipTheme.showArrow ?? true;
              if (showArrow) {
                // The default anchors put the tooltip above the trigger, so
                // the arrow rides the bottom edge — flipping up when the
                // portal fell back below.
                final direction =
                    widget.arrowDirection ??
                    (PortalPlacement.usedFallbackOf(context)
                        ? AxisDirection.up
                        : AxisDirection.down);
                tooltip = _TooltipArrow(
                  direction: direction,
                  size: theme.tooltipTheme.arrowSize ?? 10,
                  radius: theme.tooltipTheme.arrowRadius ?? 2,
                  color:
                      effectiveDecoration.color ?? theme.colorScheme.foreground,
                  // The bubble slides along the viewport edge to stay on
                  // screen; the arrow slides back the same distance so it
                  // keeps pointing at the trigger.
                  shift: PortalPlacement.shiftOf(context),
                  cornerRadius: _cornerRadius(
                    effectiveDecoration,
                    Directionality.of(context),
                  ),
                  child: tooltip,
                );
              }

              if (effectiveEffects.isNotEmpty) {
                tooltip = FinesseAnimate(
                  controller: animationController,
                  effects: effectiveEffects,
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

/// The largest corner radius of the tooltip's own surface, which is how far
/// along an edge the arrow has to stay before it starts eating into a corner.
double _cornerRadius(
  FinesseDecoration decoration,
  TextDirection textDirection,
) {
  final radius = decoration.border?.radius?.resolve(textDirection);
  if (radius == null) return 0;
  return [
    radius.topLeft.x,
    radius.topRight.x,
    radius.bottomLeft.x,
    radius.bottomRight.x,
  ].reduce(math.max);
}

/// The arrow pointing from the tooltip at its trigger, shadcn/ui's
/// `TooltipArrow`: a `size-2.5` square rotated 45°, filled like the surface,
/// its tip rounded by `rounded-[2px]`.
///
/// The square's centre sits 2px inside the edge it rides
/// (`translate-y-[calc(-50%-2px)]`), so about half its diagonal — 5px —
/// pokes out across the anchor gap. It is painted under the bubble and in
/// the same colour, so the overlap never shows.
///
/// Along its edge the arrow tracks the trigger rather than the bubble: a
/// tooltip near the side of the window is pushed inward to stay on screen
/// (see [PortalPlacement.shift]) and a centred arrow would then point
/// somewhere the trigger is not. It stops short of the bubble's corners,
/// where a rounded surface has no straight edge left to sit on.
class _TooltipArrow extends StatelessWidget {
  const _TooltipArrow({
    required this.direction,
    required this.size,
    required this.radius,
    required this.color,
    required this.shift,
    required this.cornerRadius,
    required this.child,
  });

  final AxisDirection direction;
  final double size;
  final double radius;
  final Color color;

  /// How far the bubble was moved off its anchor, from
  /// [PortalPlacement.shift]. The arrow moves back by as much of this as
  /// its edge has room for.
  final Offset shift;

  /// The bubble's corner radius, which the arrow keeps clear of.
  final double cornerRadius;

  final Widget child;

  /// How far from the centre of an edge of [extent] the arrow may sit.
  double _travel(double extent) {
    // The rotated square is `size * sqrt2` across, so its own half-diagonal
    // has to clear the corner too.
    final keepClear = cornerRadius + size * math.sqrt2 / 2;
    return math.max(0, extent / 2 - keepClear);
  }

  Widget _alongEdge(bool horizontal, Widget diamond) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final travel = _travel(
          horizontal ? constraints.maxWidth : constraints.maxHeight,
        );
        final offset = horizontal
            ? Offset((-shift.dx).clamp(-travel, travel), 0)
            : Offset(0, (-shift.dy).clamp(-travel, travel));
        return Center(
          child: Transform.translate(offset: offset, child: diamond),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final diamond = Transform.rotate(
      // Keyed so a test can measure where the tip actually landed.
      key: const ValueKey('finesse_tooltip_arrow'),
      angle: math.pi / 4,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
      ),
    );

    // The square's centre sits 2px inside the bubble's edge.
    final inset = -(size / 2) + 2;
    final positioned = switch (direction) {
      AxisDirection.down => Positioned(
        bottom: inset,
        left: 0,
        right: 0,
        child: _alongEdge(true, diamond),
      ),
      AxisDirection.up => Positioned(
        top: inset,
        left: 0,
        right: 0,
        child: _alongEdge(true, diamond),
      ),
      AxisDirection.left => Positioned(
        left: inset,
        top: 0,
        bottom: 0,
        child: _alongEdge(false, diamond),
      ),
      AxisDirection.right => Positioned(
        right: inset,
        top: 0,
        bottom: 0,
        child: _alongEdge(false, diamond),
      ),
    };

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Painted before (under) the bubble, so only the protruding tip
        // shows.
        positioned,
        child,
      ],
    );
  }
}
