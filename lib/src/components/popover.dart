import 'dart:ui';

import 'package:finesse/src/components/surface.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/theme/themes/shadows.dart';
import 'package:finesse/src/utils/animate.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/dismiss_shortcut.dart';
import 'package:finesse/src/utils/entrance.dart';
import 'package:finesse/src/utils/mouse_area.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Controls the visibility of a [Popover].
class PopoverController extends ChangeNotifier {
  /// Creates a controller. The popover starts hidden unless [isOpen] is true.
  PopoverController({bool isOpen = false}) : _isOpen = isOpen;

  bool _isOpen = false;

  /// Indicates if the popover is visible.
  bool get isOpen => _isOpen;

  /// Displays the popover.
  void show() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  /// Hides the popover.
  void hide() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  /// Shows the popover when [open] is true and hides it otherwise.
  void setOpen(bool open) {
    if (_isOpen == open) return;
    _isOpen = open;
    notifyListeners();
  }

  /// Toggles the visibility of the popover.
  void toggle() => _isOpen ? hide() : show();
}

/// Shows a floating panel next to its [child], shadcn/ui's `Popover`.
///
/// Control the visibility with a [PopoverController] or with [visible].
class Popover extends StatefulWidget {
  /// Creates a popover that shows [popover] next to [child].
  const Popover({
    super.key,
    required this.child,
    required this.popover,
    this.controller,
    this.visible,
    this.closeOnTapOutside = true,
    this.focusNode,
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
  }) : assert(
         (controller != null) ^ (visible != null),
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

  /// {@template Popover.visible}
  /// Indicates if the popover should be visible.
  /// {@endtemplate}
  final bool? visible;

  /// {@template Popover.closeOnTapOutside}
  /// Closes the popover when the user taps outside, defaults to true.
  /// {@endtemplate}
  final bool closeOnTapOutside;

  /// {@template Popover.focusNode}
  /// The focus node of the child, the [popover] will be shown when
  /// focused.
  /// {@endtemplate}
  final FocusNode? focusNode;

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

  // The focus node of the popover.
  // It's used to be able to focus the popover and receive key events.
  final _popoverFocusNode = FocusNode();

  Object get groupId => widget.groupId ?? _popoverKey;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = PopoverController(isOpen: widget.visible ?? false);
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

  /// Whether tickers run in this part of the tree.
  ///
  /// They do not while the popover's anchor is in an inactive branch — an
  /// `IndexedStack` child that is not showing, a route under an opaque one.
  /// The overlay is not in that branch, though: it would stay on screen over
  /// whatever replaced the anchor, and its exit animation, driven by a muted
  /// ticker, would never finish. So the overlay is only shown while this is
  /// true, and a close is completed at once while it is false.
  bool _tickersEnabled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncReverseDuration();
    final tickersEnabled = TickerMode.valuesOf(context).enabled;
    if (tickersEnabled != _tickersEnabled) {
      _tickersEnabled = tickersEnabled;
      if (!tickersEnabled) _finishClosing();
    }
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

    if (widget.visible != null) {
      if (widget.visible! && !controller.isOpen) {
        controller.show();
      } else if (!widget.visible! && controller.isOpen) {
        controller.hide();
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
    _popoverFocusNode.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _onPopoverToggle() {
    if (controller.isOpen) {
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
      // When the popover is opened, request focus
      // to be able to receive key events.
      _popoverFocusNode.requestFocus();
    } else if (_entrancePending) {
      // Closed before it was ever seen.
      _entrancePending = false;
      _portalVisible.value = !animationController.isDismissed;
    } else if (_tickersEnabled) {
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

    final effectiveAnchor =
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

    Widget popover = MouseArea(
      groupId: widget.areaGroupId,
      child: SurfacePainter(
        decoration: effectiveDecoration,
        padding: effectivePadding,
        filter: effectiveFilter,
        textStyle: widget.textStyle ?? theme.popoverTheme.textStyle,
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
        onTapOutside: (_) => controller.hide(),
        child: popover,
      );
    }

    Widget child = DismissShortcut(
      isActive: () => controller.isOpen,
      onDismiss: controller.hide,
      child: ValueListenableBuilder(
        valueListenable: _portalVisible,
        builder: (context, visible, _) {
          if (!(visible && _tickersEnabled)) _portalShown = false;
          return Portal(
            portalBuilder: (_) {
              // used to trap the focus inside the popover.
              return FocusScope(
                child: Focus(
                  skipTraversal: true,
                  focusNode: _popoverFocusNode,
                  child: popover,
                ),
              );
            },
            visible: visible && _tickersEnabled,
            anchor: effectiveAnchor,
            onShown: _onPortalShown,
            child: widget.child,
          );
        },
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
