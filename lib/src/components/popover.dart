import 'dart:async';
import 'dart:ui';

import 'package:finesse/src/components/surface.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/components/layout.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/theme/themes/shadows.dart';
import 'package:finesse/src/utils/anchor_stage.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/dismiss_shortcut.dart';
import 'package:finesse/src/utils/entrance.dart';
import 'package:finesse/src/utils/mouse_area.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Opens and closes an overlay anchored to a widget: a [Popover], a
/// `Tooltip`, a `HoverCard`, a `ContextMenu`, a `DropdownMenu`.
///
/// [open] shows the overlay where its widget anchors it. [openAt] shows it
/// with its corner at a point instead, as a context menu opens at the
/// pointer:
///
/// ```dart
/// GestureDetector(
///   onSecondaryTapDown: (details) => menu.openAt(details.globalPosition),
///   child: ContextMenu(controller: menu, items: items, child: canvas),
/// )
/// ```
class PopoverController extends ChangeNotifier {
  /// Creates a controller. The overlay starts closed unless [isOpen] is
  /// true.
  PopoverController({bool isOpen = false}) : _isOpen = isOpen;

  bool _isOpen = false;

  /// Whether the overlay is open.
  bool get isOpen => _isOpen;

  Offset? _position;

  /// The point in global coordinates the overlay was opened at with
  /// [openAt]. Null when it is at its own anchor.
  Offset? get position => _position;

  /// Opens the overlay at its own anchor, forgetting any [openAt] point.
  void open() {
    _position = null;
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  /// Opens the overlay with its top start corner at [globalPosition],
  /// mirrored or shifted to stay on screen. Called while it is open, it
  /// moves the overlay there.
  void openAt(Offset globalPosition) {
    final moved = _position != globalPosition;
    _position = globalPosition;
    if (_isOpen) {
      if (moved) notifyListeners();
      return;
    }
    _isOpen = true;
    notifyListeners();
  }

  /// Closes the overlay.
  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  /// Opens the overlay when [open] is true and closes it otherwise. An
  /// overlay that is already open stays where it is.
  void setOpen(bool open) {
    if (_isOpen == open) return;
    if (open) _position = null;
    _isOpen = open;
    notifyListeners();
  }

  /// Opens the overlay if it is closed and closes it if it is open.
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
///   builder: (context) => const SuggestionList(),
///   child: TextField(groupId: group, onChanged: search),
/// )
/// ```
class Popover extends StatefulWidget {
  /// Creates a popover that shows [builder] next to [child].
  const Popover({
    super.key,
    required this.child,
    required this.builder,
    this.controller,
    this.open,
    this.closeOnTapOutside = true,
    this.requestFocus = true,
    this.anchor,
    this.shadows,
    this.padding,
    this.decoration,
    this.filter,
    this.groupId,
    this.textStyle,
    this.showArrow,
  }) : areaGroupId = null,
       useSameGroupIdForChild = true,
       entrance = null,
       exitDuration = null,
       assert(
         (controller != null) ^ (open != null),
         'Either controller or open must be provided',
       );

  /// Creates a popover with the plumbing the package's own overlays need:
  /// a hover group, a tap region that leaves the child out, an entrance and
  /// an exit of their own.
  @internal
  const Popover.internal({
    super.key,
    required this.child,
    required this.builder,
    this.controller,
    this.open,
    this.closeOnTapOutside = true,
    this.requestFocus = true,
    this.anchor,
    this.shadows,
    this.padding,
    this.decoration,
    this.filter,
    this.groupId,
    this.areaGroupId,
    this.useSameGroupIdForChild = true,
    this.entrance,
    this.exitDuration,
    this.textStyle,
    this.showArrow,
  }) : assert(
         (controller != null) ^ (open != null),
         'Either controller or open must be provided',
       );

  /// {@template Popover.builder}
  /// The widget displayed as a popover.
  /// {@endtemplate}
  final WidgetBuilder builder;

  /// {@template Popover.child}
  /// The child widget.
  /// {@endtemplate}
  final Widget child;

  /// {@template Popover.controller}
  /// Opens and closes the popover. Its `openAt` opens the popover with its
  /// corner at a point in global coordinates instead of at its [anchor].
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
  /// The position of the [builder] in the global coordinate system.
  ///
  /// Defaults to `AnchorAuto(offset: Offset(0, 4))`.
  /// {@endtemplate}
  final AnchorBase? anchor;

  /// {@template Popover.shadows}
  /// The shadows applied to the [builder], defaults to
  /// [Shadows.md].
  /// {@endtemplate}
  final List<BoxShadow>? shadows;

  /// {@template Popover.padding}
  /// The padding of the [builder], defaults to
  /// `EdgeInsets.symmetric(horizontal: 12, vertical: 6)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Popover.decoration}
  /// The decoration of the [builder].
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template Popover.filter}
  /// The filter of the [builder]. If `null`, falls back to `PopoverTheme`.
  /// {@endtemplate}
  final ImageFilter? filter;

  /// {@template Popover.groupId}
  /// The `TapRegion` group of the popover, for a widget outside it that
  /// should count as inside: a tap on anything in the group does not close
  /// the popover, and a text field given the same `groupId` keeps its
  /// focus through a tap on the popover. Defaults to a group of its own.
  ///
  /// A popover opened from inside this one needs none of it: its surface
  /// joins this popover's group by itself.
  /// {@endtemplate}
  final Object? groupId;

  /// The hover group of the popover's surface: every `MouseArea` with the
  /// same id counts as one area. A menu uses it to keep a submenu open
  /// while the pointer travels between it and its row.
  @internal
  final Object? areaGroupId;

  /// Whether a tap on the child counts as a tap inside the popover. A menu
  /// says no and wraps its trigger itself.
  @internal
  final bool useSameGroupIdForChild;

  /// The entrance, when it is not the theme's: the plain fade of a menu
  /// that takes over from the one beside it.
  @internal
  final EntranceSpec? entrance;

  /// How long the exit takes, when it is not the theme's `Motion.fast`:
  /// zero for a list that is gone the moment a choice was made.
  @internal
  final Duration? exitDuration;

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
      // Replaced by the entrance in the overlay, with its own length.
      duration: const Duration(milliseconds: 300),
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
    _syncExitDuration();
    if (_stage.resolve()) _stageChanged();
  }

  /// Jumps to the end of an exit animation that can no longer run.
  void _finishClosing() {
    if (!controller.isOpen && !animationController.isDismissed) {
      animationController.value = 0;
    }
  }

  /// Mutating the controller belongs in a lifecycle callback, not in build().
  void _syncExitDuration() {
    animationController.reverseDuration =
        widget.exitDuration ??
        // It leaves faster than it arrives.
        Motion.of(context).fast;
  }

  @override
  void didUpdateWidget(covariant Popover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exitDuration != oldWidget.exitDuration) {
      _syncExitDuration();
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

  /// The [PopoverController.position] the popover was last built for, and
  /// whether it has been built at all.
  Offset? _builtPosition;
  bool _built = false;

  void _onPopoverToggle() {
    // The anchor is resolved in build, so a new `openAt` point needs one.
    if (_built && mounted && controller.position != _builtPosition) {
      setState(() {});
    }
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
    final entrance = widget.entrance ?? EntranceSpec.of(Motion.of(context));

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

    // A point given to the controller's `openAt` wins over the popover's
    // own anchor: it opens with its corner there, as a context menu opens
    // at the pointer.
    final position = controller.position;
    _built = true;
    _builtPosition = position;
    var effectiveAnchor = position != null
        ? GlobalAnchor(position, followerAnchor: AlignmentDirectional.topStart)
        : widget.anchor ??
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

    // The popovers this one was opened from inside of. Its surface is part
    // of each of them — a tap on the list of a select in a popover is not a
    // tap outside that popover — while a tap on one of them is still a tap
    // outside this one.
    final outerGroups = PopoverTapGroups.of(context);

    Widget popover = MouseArea(
      groupId: widget.areaGroupId,
      child: SurfacePainter(
        decoration: effectiveDecoration,
        padding: effectivePadding,
        filter: effectiveFilter,
        textStyle: widget.textStyle ?? theme.popoverTheme.textStyle,
        arrow: arrow,
        child: PopoverTapGroups(
          groups: [...outerGroups, groupId],
          child: Builder(builder: widget.builder),
        ),
      ),
    );
    for (final outer in outerGroups) {
      if (outer != groupId) popover = TapRegion(groupId: outer, child: popover);
    }

    if (!entrance.isInstant) {
      // Started when the portal reports the overlay shown. Its fade goes
      // through a host, for a surface that is glass; see [BackdropFade].
      popover = OverlayEntrance(
        controller: animationController,
        spec: entrance,
        autoPlay: false,
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

/// The tap-region groups of the popovers a widget is inside of, outermost
/// first.
///
/// A popover opened from inside another one — the list of a select in a
/// popover, a menu in a date picker — is drawn in the overlay, outside the
/// first one's box. Its surface joins every group listed here, so a tap on
/// it is not a tap outside the popovers around it.
///
/// Internal: it is not exported from `package:finesse/finesse.dart`.
class PopoverTapGroups extends InheritedWidget {
  /// Publishes [groups] to [child].
  const PopoverTapGroups({
    required this.groups,
    required super.child,
    super.key,
  });

  /// The `TapRegion` group ids, outermost popover first.
  final List<Object> groups;

  /// The groups of the popovers around [context], or none.
  static List<Object> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PopoverTapGroups>()?.groups ??
      const [];

  @override
  bool updateShouldNotify(PopoverTapGroups oldWidget) =>
      !listEquals(groups, oldWidget.groups);
}

/// Shows a popover anchored to [anchorRect], a rectangle in global
/// coordinates, for UI that has a rectangle rather than a widget to anchor
/// to: a text selection, a table cell, a hit on a canvas.
///
/// The popover opens [gap] below the rectangle, centred on it, and moves
/// above when there is not enough room below; one that would cross a side
/// of the screen is moved in, the theme's small gap clear of it. It closes
/// on a tap outside or on Escape, and the returned future completes with
/// the value it was popped with.
///
/// The content is wrapped in a [Surface] of [kind]; pass
/// [Surface.new]'s parameters through [padding] and [decoration], or set
/// [surface] to false to draw your own.
///
/// [showArrow] puts an arrow on the edge that faces the rectangle, pointing
/// at its middle wherever the popover had to go, as `Popover.showArrow`
/// does; it defaults to `PopoverTheme.showArrow`. The surface draws it, so
/// it needs [surface].
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
  bool? showArrow,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useRootNavigator = false,
  bool requestFocus = true,
  RouteSettings? routeSettings,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  // The popover is laid out in the navigator's overlay, which is not the
  // whole screen when the navigator is nested beside something.
  final overlay = navigator.overlay?.context.findRenderObject();
  final localRect = overlay is RenderBox && overlay.hasSize
      ? Rect.fromPoints(
          overlay.globalToLocal(anchorRect.topLeft),
          overlay.globalToLocal(anchorRect.bottomRight),
        )
      : anchorRect;
  // The route is built under the navigator; republish a theme applied to the
  // subtree the popover was opened from (see ThemeScope).
  final theme = Theme.of(context, listen: false);
  final popoverTheme = theme.popoverTheme;
  final arrow = surface && (showArrow ?? popoverTheme.showArrow ?? false)
      ? SurfaceArrow(
          anchor: _AnchoredPopoverRoute.anchor,
          size: popoverTheme.arrowSize ?? 10,
          radius: popoverTheme.arrowRadius ?? 2,
          targetSize: () => anchorRect.size,
        )
      : null;
  // It arrives and leaves like a `Popover`: on the motion tokens, and
  // faster out than in.
  final motion = Motion.of(context);
  return navigator.push(
    _AnchoredPopoverRoute<T>(
      anchorRect: localRect,
      // The arrow stands in the gap; the popover makes room for it.
      gap: gap + (arrow?.protrusion ?? 0),
      margin: theme.layoutTheme.gap(GapSize.sm),
      placesArrow: arrow != null,
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
            arrow: arrow,
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
    required this.margin,
    required this.placesArrow,
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

  /// The gap kept from the edges of the screen by a popover moved in.
  final double margin;

  /// Whether the content has an arrow, which has to be told where the
  /// popover went; see [_placement].
  final bool placesArrow;

  final WidgetBuilder builder;

  /// Where [_AnchorRectLayout] puts the popover, said the way a [Portal]
  /// with this anchor would: below the rectangle and centred on it, or
  /// above it as the fallback. A `SurfaceArrow` reads the placement against
  /// it.
  static const anchor = AnchorAuto(
    fallback: AnchorAuto(
      followerAnchor: Alignment.topCenter,
      targetAnchor: Alignment.topCenter,
    ),
  );

  /// Where the popover was put, as the [PortalPlacement] its arrow reads;
  /// null until it has been laid out once.
  ///
  /// The arrow is built and the popover's place is only known at layout, so
  /// the popover is first laid out unseen, as a portal's overlay is, and
  /// shown from the next frame with its arrow where it belongs. Later
  /// changes (the window resized) reach the arrow a frame late.
  late final ValueNotifier<_RectPlacement?> _placement = ValueNotifier(null);
  _RectPlacement? _pendingPlacement;
  bool _disposed = false;

  void _placed(_RectPlacement placement) {
    if (placement == (_pendingPlacement ?? _placement.value)) return;
    final scheduled = _pendingPlacement != null;
    _pendingPlacement = placement;
    if (scheduled) return;
    // Layout may not rebuild; the frame after it does.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = _pendingPlacement;
      _pendingPlacement = null;
      if (!_disposed) _placement.value = pending;
    });
  }

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
    _disposed = true;
    _placement.dispose();
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
    Widget content = Builder(builder: builder);
    if (placesArrow) {
      content = ValueListenableBuilder(
        valueListenable: _placement,
        builder: (context, placement, child) => Visibility.maintain(
          visible: placement != null,
          child: IgnorePointer(
            ignoring: placement == null,
            child: PortalPlacement(
              usedFallback: placement?.above ?? false,
              shift: Offset(placement?.shift ?? 0, 0),
              child: child!,
            ),
          ),
        ),
        child: content,
      );
    }
    return CustomSingleChildLayout(
      delegate: _AnchorRectLayout(
        anchorRect: anchorRect,
        gap: gap,
        margin: margin,
        padding: MediaQuery.paddingOf(context),
        onPlaced: placesArrow ? _placed : null,
      ),
      child: content,
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

/// Where an anchored popover went: above its rectangle or below, and how
/// far its centre was moved across to stay on screen.
@immutable
class _RectPlacement {
  const _RectPlacement({required this.above, required this.shift});

  final bool above;
  final double shift;

  @override
  bool operator ==(Object other) =>
      other is _RectPlacement && other.above == above && other.shift == shift;

  @override
  int get hashCode => Object.hash(above, shift);
}

class _AnchorRectLayout extends SingleChildLayoutDelegate {
  _AnchorRectLayout({
    required this.anchorRect,
    required this.gap,
    required this.margin,
    required this.padding,
    this.onPlaced,
  });

  final Rect anchorRect;
  final double gap;

  /// The gap kept from the edges of the screen by a popover moved in.
  final double margin;

  final EdgeInsets padding;

  /// Told where the popover went, for its arrow.
  final ValueChanged<_RectPlacement>? onPlaced;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen().deflate(padding);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final top = padding.top;
    final bottom = size.height - padding.bottom;
    final below = anchorRect.bottom + gap;
    final above = anchorRect.top - gap - childSize.height;
    final goesBelow = below + childSize.height <= bottom || above < top;
    // Left where it is when it fits between the insets, and otherwise
    // moved in, [margin] clear of them.
    double placed(double start, double extent, double from, double to) =>
        from +
        PositionDelegate.clearOfEdges(start - from, extent, to - from, margin);
    final x = placed(
      anchorRect.center.dx - childSize.width / 2,
      childSize.width,
      padding.left,
      size.width - padding.right,
    );
    final y = placed(
      goesBelow ? below : above,
      childSize.height,
      top,
      bottom,
    );
    onPlaced?.call(
      _RectPlacement(
        above: !goesBelow,
        shift: x + childSize.width / 2 - anchorRect.center.dx,
      ),
    );
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_AnchorRectLayout oldDelegate) =>
      anchorRect != oldDelegate.anchorRect ||
      gap != oldDelegate.gap ||
      margin != oldDelegate.margin ||
      padding != oldDelegate.padding ||
      (onPlaced == null) != (oldDelegate.onPlaced == null);
}
