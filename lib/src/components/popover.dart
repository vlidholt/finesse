import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:finesse/src/components/surface.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/theme/themes/shadows.dart';
import 'package:finesse/src/utils/anchor_stage.dart';
import 'package:finesse/src/utils/animate.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/dismiss_shortcut.dart';
import 'package:finesse/src/utils/entrance.dart';
import 'package:finesse/src/utils/mouse_area.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Opens and closes a [Popover].
class PopoverController extends ChangeNotifier {
  /// Creates a controller. The popover starts closed unless [isOpen] is true.
  PopoverController({bool isOpen = false}) : _isOpen = isOpen;

  bool _isOpen = false;

  /// Whether the popover is open.
  bool get isOpen => _isOpen;

  /// Opens the popover.
  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  /// Closes the popover.
  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  /// Opens the popover when [open] is true and closes it otherwise.
  void setOpen(bool open) {
    if (_isOpen == open) return;
    _isOpen = open;
    notifyListeners();
  }

  /// Opens the popover if it is closed and closes it if it is open.
  void toggle() => _isOpen ? close() : open();
}

/// Shows a floating panel next to its [child], shadcn/ui's `Popover`.
///
/// Open and close it with a [PopoverController] or with [open].
///
/// By default the popover takes the keyboard focus when it opens and keeps
/// it until it closes, as a menu or a small form should. A popover that
/// only assists its [child] — the suggestions under a search field — sets
/// [requestFocus] to false and leaves the caret where it is:
///
/// ```dart
/// Popover(
///   controller: suggestions,
///   requestFocus: false,
///   // The same group for the field: a click on the panel is then not a
///   // click outside the field, which would take its focus on a desktop.
///   groupId: group,
///   popover: (context) => const SuggestionList(),
///   child: TextField(groupId: group, onChanged: search),
/// )
/// ```
class Popover extends StatefulWidget {
  /// Creates a popover that shows [popover] next to [child].
  const Popover({
    super.key,
    required this.child,
    required this.popover,
    this.controller,
    this.open,
    this.closeOnTapOutside = true,
    this.requestFocus = true,
    this.anchor,
    this.effects,
    this.reverseDuration,
    this.shadows,
    this.padding,
    this.decoration,
    this.filter,
    this.groupId,
    this.areaGroupId,
    this.useSameGroupIdForChild = true,
    this.textStyle,
    this.showArrow,
  }) : assert(
         (controller != null) ^ (open != null),
         'Either controller or visible must be provided',
       );

  /// {@template Popover.popover}
  /// The widget displayed as a popover.
  /// {@endtemplate}
  final WidgetBuilder popover;

  /// {@template Popover.child}
  /// The child widget.
  /// {@endtemplate}
  final Widget child;

  /// {@template Popover.controller}
  /// The controller that controls the visibility of the [popover].
  /// {@endtemplate}
  final PopoverController? controller;

  /// {@template Popover.open}
  /// Whether the popover is open, for a parent that holds that state
  /// itself. Give this or a [controller], not both.
  /// {@endtemplate}
  final bool? open;

  /// {@template Popover.closeOnTapOutside}
  /// Closes the popover when the user taps outside, defaults to true.
  /// {@endtemplate}
  final bool closeOnTapOutside;

  /// {@template Popover.requestFocus}
  /// Whether the popover takes the keyboard focus when it opens, defaults
  /// to true. The name is `ModalRoute.requestFocus`'s, which does the same
  /// for a route.
  ///
  /// A popover that takes the focus keeps it: Tab cycles through its
  /// content, and when it closes the focus goes back to where it was.
  ///
  /// With false the focus stays where it is — the caret stays in the field
  /// the popover hangs under — and the popover is a stop on the way rather
  /// than a place of its own:
  ///
  /// * Tab moves from the child into the popover's content, and from its
  ///   last control on to whatever follows the child; Shift+Tab goes back
  ///   the same way.
  /// * Escape closes it while the focus is in the child or in the popover.
  ///   Closed from inside, the focus returns to where it was before it
  ///   went in.
  /// * It still closes on a tap outside, and not on a tap on its child.
  ///   A text field gives up the focus on a click outside *its* tap region,
  ///   though, and the popover is outside it: give the field the same
  ///   `groupId` as the popover to keep the caret through a click on the
  ///   popover.
  /// {@endtemplate}
  final bool requestFocus;

  ///{@template Popover.anchor}
  /// The position of the [popover] in the global coordinate system.
  ///
  /// Defaults to `AnchorAuto(offset: Offset(0, 4))`.
  /// {@endtemplate}
  final AnchorBase? anchor;

  /// {@template Popover.effects}
  /// The animation effects applied to the [popover]. Defaults to the
  /// theme's, and then to `EntranceEffect.forMotion`: a fade with a little
  /// growth out of the edge that faces the trigger, on the theme's motion
  /// tokens. An empty list shows the popover at once.
  /// {@endtemplate}
  final List<Effect<dynamic>>? effects;

  /// {@template Popover.shadows}
  /// The shadows applied to the [popover], defaults to
  /// [Shadows.md].
  /// {@endtemplate}
  final List<BoxShadow>? shadows;

  /// {@template Popover.padding}
  /// The padding of the [popover], defaults to
  /// `EdgeInsets.symmetric(horizontal: 12, vertical: 6)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Popover.decoration}
  /// The decoration of the [popover].
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template Popover.filter}
  /// The filter of the [popover]. If `null`, falls back to `PopoverTheme`.
  /// {@endtemplate}
  final ImageFilter? filter;

  /// {@template Popover.groupId}
  /// The group id of the [popover], defaults to `UniqueKey()`.
  ///
  /// Used to determine it the tap is inside the [popover] or not.
  /// {@endtemplate}
  final Object? groupId;

  /// {@macro MouseArea.groupId}
  final Object? areaGroupId;

  /// {@template Popover.useSameGroupIdForChild}
  /// Whether the [groupId] should be used for the child widget, defaults to
  /// `true`. This teams that taps on the child widget will be handled as inside
  /// the popover.
  /// {@endtemplate}
  final bool useSameGroupIdForChild;

  /// {@template Popover.textStyle}
  /// The default text style of the popover's content.
  /// {@endtemplate}
  final TextStyle? textStyle;

  /// {@template Popover.showArrow}
  /// Whether the popover has an arrow pointing at its [child], defaults to
  /// the theme's, and then to false.
  ///
  /// The arrow is part of the surface: one shape with it, under the same
  /// fill, outline, glass and shadow. It rides the edge that faces the
  /// child — following the popover to the other side when its anchor falls
  /// back — and points at the middle of the child's edge, sliding along its
  /// own when the popover was pushed aside to stay on screen or is aligned
  /// with one end of the child. A popover centred over its child has no
  /// edge that faces it and gets no arrow.
  ///
  /// The popover stands off its child by the height of the arrow on top of
  /// its [anchor]'s own offset, so the tip lands where the edge of the
  /// popover would have been.
  /// {@endtemplate}
  final bool? showArrow;

  /// {@template Popover.reverseDuration}
  /// The duration of the popover's exit animation.
  ///
  /// Defaults to the theme's, and then to its `Motion.fast`: a popover
  /// leaves faster than it arrives.
  ///
  /// To customize the opening animation duration,
  /// use [Effect.duration] in specified [effects].
  /// {@endtemplate}
  final Duration? reverseDuration;

  @override
  State<Popover> createState() => _PopoverState();
}

class _PopoverState extends State<Popover> with SingleTickerProviderStateMixin {
  final _popoverKey = UniqueKey();
  PopoverController? _controller;
  PopoverController get controller => widget.controller ?? _controller!;

  late final AnimationController animationController;

  /// Around the popover: it has the focus while anything in the popover
  /// does, and takes it when a popover with [Popover.requestFocus] opens, so
  /// that key events reach the popover before anything in it is focused.
  final _popoverFocusNode = FocusNode(debugLabel: 'Popover');

  /// The scope of a popover that takes the focus: it keeps Tab inside.
  final _popoverScopeNode = FocusScopeNode(debugLabel: 'Popover scope');

  /// The anchor first, then the popover, whatever their places on screen:
  /// reading order alone would put a popover that opened *above* its anchor
  /// before it, and one beside a row of fields in the middle of the row.
  final _traversalPolicy = OrderedTraversalPolicy();

  bool get _focusInside =>
      _popoverFocusNode.hasFocus || _popoverScopeNode.hasFocus;

  /// What last had the focus outside the popover while it was open: where
  /// the focus goes back to when the popover closes with the focus in it.
  FocusNode? _focusOutside;
  bool _trackingFocus = false;

  void _trackFocus() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus != null && !_focusInside) _focusOutside = focus;
  }

  void _focusOnOpen() {
    _focusOutside = null;
    _trackFocus();
    if (!_trackingFocus) {
      _trackingFocus = true;
      FocusManager.instance.addListener(_trackFocus);
    }
    // To receive key events at once. The node is attached when the overlay
    // is built, and takes the focus then.
    if (widget.requestFocus) _popoverFocusNode.requestFocus();
  }

  void _focusOnClose() {
    if (_trackingFocus) {
      _trackingFocus = false;
      FocusManager.instance.removeListener(_trackFocus);
    }
    final target = _focusOutside;
    _focusOutside = null;
    // A scope would only hand the focus back to its last focused child,
    // which is this popover.
    if (target == null || target is FocusScopeNode) return;
    // Not at once: whatever closed the popover may have asked for the focus
    // itself — a press on another field — and that request is applied in a
    // microtask queued before this one. Only a focus that is still in the
    // popover then has nowhere else to go.
    scheduleMicrotask(() {
      if (!mounted || controller.isOpen || !_focusInside) return;
      if (target.context == null || !target.canRequestFocus) return;
      target.requestFocus();
    });
  }

  Object get groupId => widget.groupId ?? _popoverKey;

  /// The size of [Popover.child] as last laid out, for the arrow to find
  /// the middle of. Asked while the overlay is built, a frame after the
  /// child was laid out.
  Size? _childSize() {
    final box = context.findRenderObject();
    return box is RenderBox && box.hasSize ? box.size : null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = PopoverController(isOpen: widget.open ?? false);
    }
    animationController = AnimationController(
      vsync: this,
      // This duration will be overridden later
      // by the [Animate] widget based on the effects.
      duration: Animate.defaultDuration,
    );
    animationController.addStatusListener(_onAnimationStatusChanged);
    controller.addListener(_onPopoverToggle);
    _onPopoverToggle();
  }

  /// Whether [Portal] should be showing its overlay.
  ///
  /// This flips at most twice per open/close. Reading
  /// `!animationController.isDismissed` through an AnimatedBuilder instead
  /// rebuilt Portal on every animation frame, and each of those rebuilds
  /// scheduled another post-frame reposition.
  final _portalVisible = ValueNotifier(false);

  void _onAnimationStatusChanged(AnimationStatus status) {
    _portalVisible.value =
        _entrancePending || status != AnimationStatus.dismissed;
  }

  /// Whether the popover has been opened but its entrance has not started:
  /// the portal is laying the overlay out, unseen, to place it. The
  /// entrance starts when the portal reports the overlay shown, so none of
  /// it plays on frames nobody sees.
  bool _entrancePending = false;

  /// Whether the portal has reported its overlay shown and has not been
  /// told to hide since. A popover reopened in that state — closed and
  /// opened again before a frame was built in between — gets no second
  /// report, so it starts its entrance at once.
  bool _portalShown = false;

  void _onPortalShown() {
    _portalShown = true;
    if (!_entrancePending) return;
    _entrancePending = false;
    if (controller.isOpen) animationController.forward(from: 0);
  }

  /// Whether the popover's anchor is in a part of the tree that is shown.
  ///
  /// It is not in the hidden child of an `IndexedStack` or a `Visibility`,
  /// in a route under an opaque one, in an `Offstage`. The overlay is not in
  /// that branch, though: it would stay on screen over whatever replaced
  /// the anchor — and where the branch's tickers are muted, its exit
  /// animation would never finish. So the overlay is only shown while the
  /// anchor is on stage, and a close is completed at once while it is not.
  /// See [AnchorStage] for how that is found out.
  late final _stage = AnchorStage(
    context: context,
    onChanged: () {
      _stageChanged();
      // Not one of this widget's dependencies: nothing else rebuilds it.
      setState(() {});
    },
    watching: () => controller.isOpen || _portalVisible.value,
  );

  bool get _onStage => _stage.onStage;

  void _stageChanged() {
    if (!_onStage) {
      _finishClosing();
    } else if (controller.isOpen && widget.requestFocus) {
      // Its overlay was taken down while it was away, and the focus with
      // it. It comes back as it was.
      _popoverFocusNode.requestFocus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncReverseDuration();
    if (_stage.resolve()) _stageChanged();
  }

  /// Jumps to the end of an exit animation that can no longer run.
  void _finishClosing() {
    if (!controller.isOpen && !animationController.isDismissed) {
      animationController.value = 0;
    }
  }

  /// Mutating the controller belongs in a lifecycle callback, not in build().
  void _syncReverseDuration() {
    animationController.reverseDuration =
        widget.reverseDuration ??
        Theme.of(context).popoverTheme.reverseDuration ??
        // It leaves faster than it arrives.
        Motion.of(context).fast;
  }

  @override
  void didUpdateWidget(covariant Popover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reverseDuration != oldWidget.reverseDuration) {
      _syncReverseDuration();
    }
    if (widget.controller != null &&
        widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onPopoverToggle);
      widget.controller!.addListener(_onPopoverToggle);
    }

    if (widget.open != null) {
      if (widget.open! && !controller.isOpen) {
        controller.open();
      } else if (!widget.open! && controller.isOpen) {
        controller.close();
      }
    }
  }

  @override
  void dispose() {
    // Remove the listener from the provided `PopoverController`
    // or our internal controller.
    controller.removeListener(_onPopoverToggle);

    animationController
      ..removeStatusListener(_onAnimationStatusChanged)
      ..dispose();
    _portalVisible.dispose();
    _stage.dispose();
    if (_trackingFocus) FocusManager.instance.removeListener(_trackFocus);
    _popoverFocusNode.dispose();
    _popoverScopeNode.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _onPopoverToggle() {
    if (controller.isOpen) {
      // Opened behind the scenes, it stays there until its anchor shows.
      _stage.watch();
      if (animationController.isDismissed && !_portalShown) {
        // Shown first, animated once it is on screen.
        _entrancePending = true;
        _portalVisible.value = true;
      } else if (animationController.isDismissed) {
        animationController.forward(from: 0);
      } else {
        // Reopened while it was leaving: it turns around where it is.
        animationController.forward();
      }
      _focusOnOpen();
      return;
    }
    _focusOnClose();
    if (_entrancePending) {
      // Closed before it was ever seen.
      _entrancePending = false;
      _portalVisible.value = !animationController.isDismissed;
    } else if (_onStage) {
      animationController.reverse();
    } else {
      _finishClosing();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Grows out of the edge that faces the trigger; the portal says which.
    final effectiveEffects =
        widget.effects ??
        theme.popoverTheme.effects ??
        EntranceEffect.forMotion(Motion.of(context));

    final effectivePadding =
        widget.padding ??
        theme.popoverTheme.padding ??
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    final effectiveShadows = widget.shadows ?? theme.popoverTheme.shadows;
    var effectiveDecoration =
        (theme.popoverTheme.decoration ?? const FinesseDecoration())
            .merge(widget.decoration)
            .copyWith(shadows: effectiveShadows);
    // remove the top padding of the popover
    effectiveDecoration = effectiveDecoration.copyWith(
      secondaryBorder: FinesseBorder(
        padding: theme.decoration.secondaryBorder?.padding
            ?.resolve(Directionality.of(context))
            .copyWith(top: 0),
      ),
    );

    var effectiveAnchor =
        widget.anchor ??
        theme.popoverTheme.anchor ??
        const AnchorAuto(
          offset: Offset(0, 4),
          fallback: AnchorAuto(
            offset: Offset(0, -4),
            followerAnchor: Alignment.topCenter,
            targetAnchor: Alignment.topCenter,
          ),
        );

    final effectiveFilter = widget.filter ?? theme.popoverTheme.filter;

    SurfaceArrow? arrow;
    if (widget.showArrow ?? theme.popoverTheme.showArrow ?? false) {
      arrow = SurfaceArrow(
        anchor: effectiveAnchor,
        size: theme.popoverTheme.arrowSize ?? 10,
        radius: theme.popoverTheme.arrowRadius ?? 2,
        targetSize: _childSize,
      );
      // The arrow stands in the gap; the popover makes room for it.
      effectiveAnchor = arrow.spaced(Directionality.of(context));
    }

    Widget popover = MouseArea(
      groupId: widget.areaGroupId,
      child: SurfacePainter(
        decoration: effectiveDecoration,
        padding: effectivePadding,
        filter: effectiveFilter,
        textStyle: widget.textStyle ?? theme.popoverTheme.textStyle,
        arrow: arrow,
        child: Builder(builder: widget.popover),
      ),
    );

    if (effectiveEffects.isNotEmpty) {
      popover = FinesseAnimate(
        controller: animationController,
        effects: effectiveEffects,
        autoPlay: false,
        // The surface may be glass; see [BackdropFade].
        fadeThroughBackdrop: true,
        child: popover,
      );
    }

    if (widget.closeOnTapOutside) {
      popover = TapRegion(
        groupId: groupId,
        behavior: HitTestBehavior.opaque,
        onTapOutside: (_) => controller.close(),
        child: popover,
      );
    }

    // The overlay is built below the portal, so in the focus tree the
    // popover is a descendant of everything around the child: Escape
    // reaches the shortcut from the child and from the popover alike.
    Widget child = DismissShortcut(
      isActive: () => controller.isOpen,
      onDismiss: controller.close,
      // One traversal group for the child and the popover, in that order.
      // It is there whether or not the popover takes the focus, so the
      // child keeps its place in the tree when that changes.
      child: FocusTraversalGroup(
        policy: _traversalPolicy,
        child: ValueListenableBuilder(
          valueListenable: _portalVisible,
          builder: (context, visible, _) {
            if (!(visible && _onStage)) _portalShown = false;
            return Portal(
              portalBuilder: (_) {
                // The portal takes its overlay down a frame after it is
                // told to. Off stage that frame is one too many: it would
                // show over what replaced the anchor.
                if (!_onStage) return const SizedBox.shrink();
                Widget overlay = Focus(
                  skipTraversal: true,
                  focusNode: _popoverFocusNode,
                  child: popover,
                );
                // A popover that takes the focus traps it: Tab cycles
                // through its own content. Without the scope its controls
                // are stops after the child's, and Tab goes on from the
                // last of them.
                if (widget.requestFocus) {
                  overlay = FocusScope(node: _popoverScopeNode, child: overlay);
                }
                return FocusTraversalOrder(
                  order: const NumericFocusOrder(1),
                  child: FocusTraversalGroup(child: overlay),
                );
              },
              visible: visible && _onStage,
              anchor: effectiveAnchor,
              onShown: _onPortalShown,
              child: FocusTraversalOrder(
                order: const NumericFocusOrder(0),
                child: FocusTraversalGroup(child: widget.child),
              ),
            );
          },
        ),
      ),
    );
    if (widget.useSameGroupIdForChild) {
      child = TapRegion(
        groupId: groupId,
        child: child,
      );
    }
    return child;
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
