import 'dart:ui' show ImageFilter;

import 'package:finesse/src/components/popover.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/anchor_stage.dart';
import 'package:finesse/src/utils/arrow_surface.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:finesse/src/utils/dismiss_shortcut.dart';
import 'package:finesse/src/utils/entrance.dart';
import 'package:finesse/src/utils/mouse_area.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// {@template Tooltip}
/// A widget that displays a tooltip on hover or focus, styled to match the
/// Shadcn UI design system.
///
/// A mouse shows it by hovering, the keyboard by focusing the child (give
/// the tooltip the child's `focusNode`), and a finger or a pen by a long
/// press: it shows while the press is held. The tooltip listens for all
/// three itself, so the child can be any widget.
///
/// It pops out of the side that faces its trigger on the theme's motion
/// tokens (`Motion.of`), and only fades in when it takes over from the
/// tooltip of a neighbouring trigger.
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
    this.padding,
    this.decoration,
    this.anchor,
    this.controller,
    this.longPressDuration,
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

  /// {@template Tooltip.controller}
  /// The controller that manages the visibility of the [Tooltip].
  ///
  /// Allows programmatic control over showing and hiding the tooltip. If null,
  /// a default [PopoverController] is created internally.
  /// {@endtemplate}
  final PopoverController? controller;

  /// {@template Tooltip.longPressDuration}
  /// How long a finger or a pen has to rest on the child before the tooltip
  /// shows, the platform's long-press time by default. It is read when the
  /// tooltip is first built.
  /// {@endtemplate}
  final Duration? longPressDuration;

  /// {@template Tooltip.showArrow}
  /// Whether the tooltip draws the arrow pointing at its trigger, defaults
  /// to true.
  /// {@endtemplate}
  final bool? showArrow;

  /// {@template Tooltip.arrowDirection}
  /// The direction the arrow points, i.e. which edge of the tooltip it
  /// rides: [AxisDirection.down] puts it on the bottom edge.
  ///
  /// Defaults to the edge that faces the trigger, worked out from the
  /// [anchor]: down while the tooltip sits above it, flipping up when the
  /// portal falls back below, left or right for a tooltip placed beside it.
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
  PopoverController? _controller;
  bool hovered = false;
  bool get hasFocus => widget.focusNode?.hasFocus ?? false;

  PopoverController get controller => widget.controller ?? _controller!;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      // Replaced by the entrance in the overlay, with its own length, each
      // time the tooltip is built.
      duration: const Duration(milliseconds: 300),
      reverseDuration: Duration.zero,
    );
    if (widget.controller == null) _controller = PopoverController();
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
    // It leaves faster than it arrives.
    animationController.reverseDuration = Motion.of(context).fast;
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
        _controller ??= PopoverController();
      }
      controller.addListener(_onOpenChanged);
      _onOpenChanged();
    }
  }

  void onFocusChange() {
    hasFocus ? controller.open() : controller.close();
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
        controller.open();
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
        // left — must not leave the tooltip up with nothing to close it.
        // A bare `await reverse()` never returns from a cancelled run.
      }
    }
    if (!mounted) return;
    if (hovered || hasFocus) return;
    controller.close();
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
            controller.close();
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
              final shape = ArrowShape(
                radius:
                    effectiveDecoration.border?.borderRadius?.resolve(
                      textDirection,
                    ) ??
                    BorderRadius.zero,
                // The edge that faces the trigger. The default anchors put
                // the tooltip above it, so the arrow rides the bottom edge
                // — flipping up when the portal fell back below.
                direction: !showArrow
                    ? null
                    : widget.arrowDirection ??
                          ArrowPlacement.of(
                            context,
                            effectiveAnchor,
                          ).direction ??
                          AxisDirection.down,
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
                painter: ArrowShapePainter(shape: shape, color: fill),
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
                    Positioned.fill(
                      child: ArrowMarker(
                        shape: shape,
                        markerKey: const ValueKey('finesse_tooltip_arrow'),
                      ),
                    ),
                  ],
                );
              }
              tooltip = BackdropSurface(
                filter: effectiveFilter,
                tintOpacity: fill.a,
                clipper: ArrowShapeClipper(shape),
                shadow: outerShadows.isNotEmpty
                    ? ShadowDecoration(
                        decoration: ShapeDecoration(
                          shape: ArrowShapeOutline(shape),
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
              final entrance = _warm
                  ? EntranceSpec.fade(motion)
                  : EntranceSpec.of(
                      motion,
                      spring: motion.snappy.scaled(.8),
                    );
              if (!entrance.isInstant) {
                // It starts by itself, after the frame that first builds
                // the bubble. The fade goes through a host, for a bubble
                // that is glass; see [BackdropFade].
                tooltip = OverlayEntrance(
                  controller: animationController,
                  spec: entrance,
                  child: tooltip,
                );
              }
              return MouseArea(groupId: 'tooltip', child: tooltip);
            },
            child: MouseArea(
              groupId: 'tooltip',
              // The tooltip listens itself rather than have its child
              // report: any child will do, a disabled button included, and
              // no theme has to be made per tooltip to carry a callback
              // down. A finger or a pen shows it with a long press, for as
              // long as the press is held; a mouse hovers.
              child: RawGestureDetector(
                // The press is the tooltip's own business: the child's
                // semantics say what the child does.
                excludeFromSemantics: true,
                gestures: {
                  LongPressGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        LongPressGestureRecognizer
                      >(
                        () => LongPressGestureRecognizer(
                          debugOwner: this,
                          duration:
                              widget.longPressDuration ??
                              theme.tooltipTheme.longPressDuration,
                          supportedDevices: const {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.stylus,
                            PointerDeviceKind.invertedStylus,
                          },
                        ),
                        (recognizer) => recognizer
                          ..onLongPress = (() => onHoverChange(true))
                          ..onLongPressEnd = ((_) => onHoverChange(false))
                          ..onLongPressCancel = (() => onHoverChange(false)),
                      ),
                },
                // A non-opaque MouseRegion reports a miss from hitTest even
                // when its child is hit, which hid the trigger from a
                // GestureDetector around the tooltip and let taps through
                // to widgets behind it. Deferring to the child keeps the
                // trigger's own hit test.
                child: MouseRegion(
                  hitTestBehavior: HitTestBehavior.deferToChild,
                  onEnter: (_) => onHoverChange(true),
                  onExit: (_) => onHoverChange(false),
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
