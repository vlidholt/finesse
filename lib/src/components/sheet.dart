// ignore_for_file: cascade_invocations

import 'dart:async';
import 'dart:math' as math;

import 'package:finesse/src/components/dialog.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/position.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Tailwind's `max-w-sm` (24rem) — the width cap shadcn applies to left/right
/// sheets from the `sm` breakpoint up.
const _sideSheetSmMaxWidth = 384.0;

/// Default constraints for a left/right sheet: full cross-axis height
/// (`inset-y-0 h-full`) with main-axis width capped at `w-3/4 sm:max-w-sm`.
BoxConstraints _horizontalSideSheetConstraints(
  Size screenSize,
  double smBreakpoint,
) {
  final fractionalWidth = screenSize.width * 0.75;
  final maxWidth = screenSize.width >= smBreakpoint
      ? math.min(fractionalWidth, _sideSheetSmMaxWidth)
      : fractionalWidth;
  return BoxConstraints(
    minHeight: screenSize.height,
    maxWidth: maxWidth,
  );
}

/// Shows a [Sheet], which is a modal bottom sheet implementation.
///
/// Returns a [Future] that resolves to the value (if any) that the sheet is
/// closed with.
Future<T?> showSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  SheetSide? side,
  Color? backgroundColor,

  /// The accessibility label for the barrier. Defaults to the localized
  /// "Dismiss".
  String? barrierLabel,
  ShapeBorder? shape,

  /// Defaults to `DialogTheme.barrierColor` — shadcn gives a sheet the
  /// same `bg-black/10` overlay as a dialog.
  Color? barrierColor,

  /// The gaussian blur applied behind the barrier.
  double? barrierBlurSigma,
  bool useRootNavigator = false,
  bool isDismissible = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  List<Effect<dynamic>>? animateIn,
  List<Effect<dynamic>>? animateOut,

  /// Whether the route occludes the routes behind it.
  /// When false, [MediaQuery.viewInsetsOf] from the host scaffold will be
  /// available in the sheet context, allowing keyboard-aware content.
  /// Defaults to false.
  bool? opaque = false,
}) {
  final theme = Theme.of(context);
  final effectiveSide = side ?? theme.sheetTheme.side ?? SheetSide.bottom;
  final defaultAnimateIn = switch (effectiveSide) {
    SheetSide.top => const SlideEffect(
      begin: Offset(0, -1),
      end: Offset.zero,
      duration: Sheet.defaultEnterDuration,
      curve: Sheet.defaultAnimationCurve,
    ),
    SheetSide.bottom => const SlideEffect(
      begin: Offset(0, 1),
      end: Offset.zero,
      duration: Sheet.defaultEnterDuration,
      curve: Sheet.defaultAnimationCurve,
    ),
    SheetSide.left => const SlideEffect(
      begin: Offset(-1, 0),
      end: Offset.zero,
      duration: Sheet.defaultEnterDuration,
      curve: Sheet.defaultAnimationCurve,
    ),
    SheetSide.right => const SlideEffect(
      begin: Offset(1, 0),
      end: Offset.zero,
      duration: Sheet.defaultEnterDuration,
      curve: Sheet.defaultAnimationCurve,
    ),
  };

  final effectiveAnimateIn =
      animateIn ?? theme.sheetTheme.animateIn ?? [defaultAnimateIn];

  final defaultAnimateOut = switch (effectiveSide) {
    SheetSide.top => const SlideEffect(
      begin: Offset.zero,
      end: Offset(0, -1),
      duration: Sheet.defaultExitDuration,
      curve: Sheet.defaultAnimationCurve,
    ),
    SheetSide.bottom => const SlideEffect(
      begin: Offset.zero,
      end: Offset(0, 1),
      duration: Sheet.defaultExitDuration,
      curve: Sheet.defaultAnimationCurve,
    ),
    SheetSide.left => const SlideEffect(
      begin: Offset.zero,
      end: Offset(-1, 0),
      duration: Sheet.defaultExitDuration,
      curve: Sheet.defaultAnimationCurve,
    ),
    SheetSide.right => const SlideEffect(
      begin: Offset.zero,
      end: Offset(1, 0),
      duration: Sheet.defaultExitDuration,
      curve: Sheet.defaultAnimationCurve,
    ),
  };

  final effectiveAnimateOut =
      animateOut ?? theme.sheetTheme.animateOut ?? [defaultAnimateOut];

  return showDialog(
    context: context,
    opaque: opaque ?? false,
    builder: (context) {
      final viewInsets = MediaQuery.viewInsetsOf(context);
      final padding = switch (effectiveSide) {
        SheetSide.bottom => EdgeInsets.only(bottom: viewInsets.bottom),
        SheetSide.top => EdgeInsets.only(top: viewInsets.top),
        SheetSide.left => EdgeInsets.only(left: viewInsets.left),
        SheetSide.right => EdgeInsets.only(right: viewInsets.right),
      };
      final hasInset = padding != EdgeInsets.zero;
      return AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.linearToEaseOut,
        padding: padding,
        child: MediaQuery.removeViewInsets(
          context: context,
          removeBottom: hasInset,
          removeTop: hasInset,
          removeLeft: hasInset,
          removeRight: hasInset,
          child: SheetInheritedWidget(
            side: effectiveSide,
            child: builder(context),
          ),
        ),
      );
    },
    barrierColor: barrierColor,
    barrierBlurSigma: barrierBlurSigma,
    barrierLabel: barrierLabel,
    barrierDismissible: isDismissible,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    animateIn: effectiveAnimateIn,
    animateOut: effectiveAnimateOut,
  );
}

/// Inherited widget to provide [SheetSide] down the widget tree.
class SheetInheritedWidget extends InheritedWidget {
  /// Provides [side] to the descendants of a sheet.
  const SheetInheritedWidget({
    super.key,
    required super.child,
    required this.side,
  });

  /// {@template Sheet.side}
  /// The side from which the sheet slides in.
  /// {@endtemplate}
  final SheetSide side;

  /// Retrieves the [SheetSide] from the nearest [SheetInheritedWidget]
  /// ancestor.
  static SheetSide of(BuildContext context) {
    final inherited =
        context
                .getElementForInheritedWidgetOfExactType<
                  SheetInheritedWidget
                >()!
                .widget
            as SheetInheritedWidget;
    return inherited.side;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

/// Enum representing the side from which the [Sheet] slides in.
enum SheetSide {
  /// Sheet slides in from the top.
  top,

  /// Sheet slides in from the right.
  right,

  /// Sheet slides in from the bottom.
  bottom,

  /// Sheet slides in from the left.
  left;

  /// Whether the sheet slides along the vertical axis.
  bool get isVertical => this == SheetSide.top || this == SheetSide.bottom;

  /// Converts the [SheetSide] to an [Alignment].
  Alignment toAlignment() {
    return switch (this) {
      SheetSide.top => Alignment.topCenter,
      SheetSide.bottom => Alignment.bottomCenter,
      SheetSide.left => Alignment.topLeft,
      SheetSide.right => Alignment.topRight,
    };
  }

  /// Converts the [SheetSide] to an edge-centered [Alignment]. Unlike
  /// [toAlignment], left/right return [Alignment.centerLeft]/[Alignment.centerRight]
  /// so a partial-size sheet sits vertically centered on its edge rather
  /// than at the corner.
  Alignment toEdgeAlignment() {
    return switch (this) {
      SheetSide.top => Alignment.topCenter,
      SheetSide.bottom => Alignment.bottomCenter,
      SheetSide.left => Alignment.centerLeft,
      SheetSide.right => Alignment.centerRight,
    };
  }

  /// Returns the alignment for the inner [Dialog] in expandable mode.
  ///
  /// Aligns the content cluster adjacent to the drag pill so there is no
  /// gap between the pill and the visible content area.
  Alignment toInnerExpandableAlignment() {
    return switch (this) {
      SheetSide.bottom => Alignment.topCenter,
      SheetSide.top => Alignment.bottomCenter,
      SheetSide.left => Alignment.centerRight,
      SheetSide.right => Alignment.centerLeft,
    };
  }
}

/// Builds the drag handle widget for [Sheet] expandable mode.
///
/// Receives the current [SheetSide] so the handle can adapt its
/// shape or orientation to the sheet side. Returning a widget from
/// this builder replaces the default pill entirely.
typedef SheetDragHandleBuilder =
    Widget Function(BuildContext context, SheetSide side);

/// A callback for when the user begins dragging the sheet.
///
/// Used by [Sheet.onDragStart].
typedef SheetDragStartHandler = void Function(DragStartDetails details);

/// A callback for when the user stops dragging the sheet.
///
/// Used by [Sheet.onDragEnd].
typedef SheetDragEndHandler =
    void Function(
      DragEndDetails details, {
      required bool isClosing,
    });

/// Controller for an expandable [Sheet].
///
/// Exposes the current [size] ratio (0..1) and imperative methods [animateTo]
/// and [jumpTo] that mirror [DraggableScrollableController] semantics.
class SheetController extends ChangeNotifier {
  double _size = 0.5;

  /// The current size ratio of the sheet (0.0..1.0).
  double get size => _size;

  // Drives the animation; supplied by the sheet state while mounted.
  Future<void> Function(double size, Duration duration, Curve curve)?
  _animateDelegate;

  /// Animates the sheet to [size] using the provided [duration] and [curve].
  ///
  /// If no sheet is mounted yet (e.g. called before the sheet is built),
  /// falls back to [jumpTo] — the size is set immediately without animation.
  Future<void> animateTo(
    double size, {
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeInOut,
  }) async {
    final clamped = size.clamp(0.0, 1.0);
    final delegate = _animateDelegate;
    if (delegate == null) {
      jumpTo(clamped);
      return;
    }
    await delegate(clamped, duration, curve);
  }

  /// Jumps the sheet to [size] immediately, without animation.
  /// [size] is clamped to the allowed `[0.0, 1.0]` range.
  void jumpTo(double size) {
    final clamped = size.clamp(0.0, 1.0);
    if (_size == clamped) return;
    _size = clamped;
    notifyListeners();
  }

  // Internal setter used by the state during drag updates. Callers should
  // have already clamped to effectiveMinSize/effectiveMaxSize; this guards
  // against accidental out-of-range writes as a last line of defence.
  void _setSize(double size) {
    final clamped = size.clamp(0.0, 1.0);
    if (_size == clamped) return;
    _size = clamped;
    notifyListeners();
  }
}

/// {@template Sheet}
/// A customizable sheet component that slides in from the edges of the screen.
///
/// It can be configured to slide from the top, bottom, left, or right, and
/// supports draggable dismissal, custom styling, and actions.
/// {@endtemplate}
class Sheet extends StatefulWidget {
  /// {@macro Sheet}
  const Sheet({
    super.key,
    this.title,
    this.description,
    this.child,
    this.actions = const [],
    this.constraints,
    this.expandCrossSide,
    this.closeIcon,
    this.closeIconData,
    this.closeIconPosition,
    this.radius,
    this.backgroundColor,
    this.expandActionsWhenTiny,
    this.padding,
    this.gap,
    this.actionsAxis,
    this.actionsMainAxisSize,
    this.actionsMainAxisAlignment,
    this.actionsVerticalDirection,
    this.border,
    this.shadows,
    this.removeBorderRadiusWhenTiny,
    this.titleStyle,
    this.descriptionStyle,
    this.titleTextAlign,
    this.descriptionTextAlign,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.scrollable,
    this.scrollPadding,
    this.draggable,
    this.onClosing,
    this.onDragStart,
    this.onDragEnd,
    this.animationController,
    this.isScrollControlled = false,
    this.minFlingVelocity,
    this.closeProgressThreshold,
    this.enterDuration = const Duration(milliseconds: 250),
    this.exitDuration = const Duration(milliseconds: 200),
    this.disabledScrollControlMaxRatio,
    this.useSafeArea,
    this.titlePinned,
    this.descriptionPinned,
    this.actionsPinned,
    this.expandable,
    this.initialSize,
    this.minSize,
    this.maxSize,
    this.snap,
    this.snapSizes,
    this.snapAnimationDuration,
    this.snapAnimationCurve,
    this.snapFlingVelocity,
    this.dragHandle,
    this.dragHandleBuilder,
    this.showDragHandle,
    this.dragHandleExtent,
    this.onSizeChanged,
    this.controller,
  }) : assert(
         initialSize == null || (initialSize >= 0.0 && initialSize <= 1.0),
         'initialSize must be in [0.0, 1.0]',
       ),
       assert(
         minSize == null || (minSize >= 0.0 && minSize <= 1.0),
         'minSize must be in [0.0, 1.0]',
       ),
       assert(
         maxSize == null || (maxSize >= 0.0 && maxSize <= 1.0),
         'maxSize must be in [0.0, 1.0]',
       ),
       assert(
         minSize == null || maxSize == null || minSize <= maxSize,
         'minSize must be <= maxSize',
       ),
       assert(
         initialSize == null || minSize == null || initialSize >= minSize,
         'initialSize must be >= minSize',
       ),
       assert(
         initialSize == null || maxSize == null || initialSize <= maxSize,
         'initialSize must be <= maxSize',
       );

  /// Default open-transition duration for sheets shown via [showSheet].
  /// Matches Material's `BottomSheet` enter timing. Override per call via
  /// `animateIn`, or globally via `SheetTheme.animateIn`.
  static const defaultEnterDuration = Duration(milliseconds: 250);

  /// Default close-transition duration for sheets shown via [showSheet].
  /// Matches Material's `BottomSheet` exit timing. Override per call via
  /// `animateOut`, or globally via `SheetTheme.animateOut`.
  static const defaultExitDuration = Duration(milliseconds: 200);

  /// Default easing for the open/close transitions of sheets shown via
  /// [showSheet]. M3 `emphasizedDecelerate` token — recommended by the
  /// Material 3 motion spec for sheets and dialogs entering view.
  static const defaultAnimationCurve = Cubic(0.05, 0.7, 0.1, 1);

  /// {@template Sheet.title}
  /// The title widget of the sheet, typically displayed at the top.
  /// {@endtemplate}
  final Widget? title;

  /// {@template Sheet.description}
  /// The description widget, providing more context under the title.
  /// {@endtemplate}
  final Widget? description;

  /// {@template Sheet.child}
  /// The main content of the sheet.
  /// {@endtemplate}
  final Widget? child;

  /// {@template Sheet.actions}
  /// List of action widgets, typically buttons, displayed at the bottom or side
  /// of the sheet.
  /// {@endtemplate}
  final List<Widget> actions;

  /// {@template Sheet.constraints}
  /// Constraints for the sheet's size.
  /// {@endtemplate}
  final BoxConstraints? constraints;

  /// {@template Sheet.expandCrossSide}
  /// Whether to expand the sheet to the full width/height of the screen along the cross axis.
  /// {@endtemplate}
  final bool? expandCrossSide;

  /// {@template Sheet.closeIcon}
  /// Custom close icon widget.
  /// {@endtemplate}
  final Widget? closeIcon;

  /// {@template Sheet.closeIconData}
  /// Icon data for the default close icon.
  /// {@endtemplate}
  final IconData? closeIconData;

  /// {@template Sheet.closeIconPosition}
  /// Position of the close icon.
  /// {@endtemplate}
  final Position? closeIconPosition;

  /// {@template Sheet.radius}
  /// Border radius of the sheet.
  /// {@endtemplate}
  final BorderRadius? radius;

  /// {@template Sheet.backgroundColor}
  /// Background color of the sheet.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Sheet.expandActionsWhenTiny}
  /// Whether to expand actions to full width when the screen is tiny.
  /// {@endtemplate}
  final bool? expandActionsWhenTiny;

  /// {@template Sheet.padding}
  /// Padding around the content of the sheet.
  ///
  /// When [expandable] is true and [useSafeArea] is true, the sheet
  /// merges the relevant safe-area insets into this padding before
  /// passing it to the underlying [Dialog]. This lets the sheet
  /// background cover the notch / home-indicator while the content
  /// stays inset; widget inspectors that read the dialog's padding at
  /// runtime will see the merged value, not the raw value set here.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Sheet.gap}
  /// Vertical gap between title, description, child, and actions.
  /// {@endtemplate}
  final double? gap;

  /// {@template Sheet.actionsAxis}
  /// Axis for arranging actions.
  /// {@endtemplate}
  final Axis? actionsAxis;

  /// {@template Sheet.actionsMainAxisSize}
  /// Main axis size for actions.
  /// {@endtemplate}
  final MainAxisSize? actionsMainAxisSize;

  /// {@template Sheet.actionsMainAxisAlignment}
  /// Main axis alignment for actions.
  /// {@endtemplate}
  final MainAxisAlignment? actionsMainAxisAlignment;

  /// {@template Sheet.actionsVerticalDirection}
  /// Vertical direction for actions.
  /// {@endtemplate}
  final VerticalDirection? actionsVerticalDirection;

  /// {@template Sheet.border}
  /// Border of the sheet.
  /// {@endtemplate}
  final BoxBorder? border;

  /// {@template Sheet.shadows}
  /// List of shadows for the sheet.
  /// {@endtemplate}
  final List<BoxShadow>? shadows;

  /// {@template Sheet.removeBorderRadiusWhenTiny}
  /// Whether to remove border radius when the screen is tiny.
  /// {@endtemplate}
  final bool? removeBorderRadiusWhenTiny;

  /// {@template Sheet.titleStyle}
  /// Style for the title text.
  /// {@endtemplate}
  final TextStyle? titleStyle;

  /// {@template Sheet.descriptionStyle}
  /// Style for the description text.
  /// {@endtemplate}
  final TextStyle? descriptionStyle;

  /// {@template Sheet.titleTextAlign}
  /// Text alignment for the title.
  /// {@endtemplate}
  final TextAlign? titleTextAlign;

  /// {@template Sheet.descriptionTextAlign}
  /// Text alignment for the description.
  /// {@endtemplate}
  final TextAlign? descriptionTextAlign;

  /// {@template Sheet.mainAxisAlignment}
  /// Main axis alignment for the sheet's content.
  /// {@endtemplate}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@template Sheet.crossAxisAlignment}
  /// Cross axis alignment for the sheet's content.
  /// {@endtemplate}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@template Sheet.scrollable}
  /// Whether the sheet's content is scrollable.
  /// {@endtemplate}
  final bool? scrollable;

  /// {@template Sheet.scrollPadding}
  /// Padding for scrollable content.
  /// {@endtemplate}
  final EdgeInsetsGeometry? scrollPadding;

  /// {@template Sheet.draggable}
  /// Whether the sheet is draggable, allowing dismissal by dragging.
  /// Defaults to false.
  /// {@endtemplate}
  final bool? draggable;

  /// {@template Sheet.isScrollControlled}
  /// Whether the sheet is scroll controlled, allowing it to expand to full
  /// screen if content is taller.
  /// Defaults to false.
  /// {@endtemplate}
  final bool isScrollControlled;

  /// {@template Sheet.onClosing}
  /// Called when the sheet begins to close.
  ///
  /// A sheet might be prevented from closing (e.g., by user
  /// interaction) even after this callback is called. For this reason, this
  /// callback might be call multiple times for a given sheet.
  /// {@endtemplate}
  final VoidCallback? onClosing;

  /// {@template Sheet.onDragStart}
  /// Called when the user begins dragging the sheet vertically, if
  /// [draggable] is true.
  ///
  /// Would typically be used to change the sheet animation curve so
  /// that it tracks the user's finger accurately.
  /// {@endtemplate}
  final SheetDragStartHandler? onDragStart;

  /// {@template Sheet.onDragEnd}
  /// Called when the user stops dragging the sheet, if [draggable]
  /// is true.
  ///
  /// Would typically be used to reset the sheet animation curve, so
  /// that it animates non-linearly. Called before [onClosing] if the
  /// sheet is closing.
  /// {@endtemplate}
  final SheetDragEndHandler? onDragEnd;

  /// {@template Sheet.animationController}
  /// The animation controller that controls the sheet's entrance and
  /// exit animations.
  ///
  /// The Sheet widget will manipulate the position of this animation, it
  /// is not just a passive observer.
  /// {@endtemplate}
  final AnimationController? animationController;

  /// {@template Sheet.minFlingVelocity}
  /// The minimum velocity to initiate a fling.
  ///
  /// Defaults to 700.
  /// {@endtemplate}
  final double? minFlingVelocity;

  /// {@template Sheet.closeProgressThreshold}
  /// The threshold for determining whether the sheet is closing.
  ///
  /// Defaults to 0.5.
  /// {@endtemplate}
  final double? closeProgressThreshold;

  /// {@template Sheet.enterDuration}
  /// The duration of the sheet's entrance animation.
  ///
  /// Defaults to 250ms.
  /// {@endtemplate}
  final Duration enterDuration;

  /// {@template Sheet.exitDuration}
  /// The duration of the sheet's exit animation.
  ///
  /// Defaults to 200ms.
  /// {@endtemplate}
  final Duration exitDuration;

  /// {@template Sheet.disabledScrollControlMaxRatio}
  /// The maximum ratio of the sheet's height when is not scroll controlled.
  /// Defaults to 9/16. Has no effect when [draggable] is false.
  /// {@endtemplate}
  final double? disabledScrollControlMaxRatio;

  /// {@macro Dialog.useSafeArea}
  final bool? useSafeArea;

  /// {@macro Dialog.titlePinned}
  final bool? titlePinned;

  /// {@macro Dialog.descriptionPinned}
  final bool? descriptionPinned;

  /// {@macro Dialog.actionsPinned}
  final bool? actionsPinned;

  /// {@template Sheet.expandable}
  /// Whether the sheet is expandable/resizable by dragging the handle.
  /// When true, a drag handle is shown and the sheet can be resized.
  /// Defaults to false.
  /// {@endtemplate}
  final bool? expandable;

  /// {@template Sheet.initialSize}
  /// The initial size of the sheet as a fraction of screen height (vertical
  /// sides) or screen width (horizontal sides). Defaults to 0.5.
  ///
  /// When a [controller] is supplied, this value is ignored — the controller
  /// is the single source of truth for size and is not mutated on mount or
  /// on prop updates.
  /// {@endtemplate}
  final double? initialSize;

  /// {@template Sheet.minSize}
  /// The minimum size the sheet can be dragged to. Defaults to 0.25.
  /// {@endtemplate}
  final double? minSize;

  /// {@template Sheet.maxSize}
  /// The maximum size the sheet can be dragged to. Defaults to 1.0.
  /// {@endtemplate}
  final double? maxSize;

  /// {@template Sheet.snap}
  /// Whether the sheet snaps to stops after a drag. Defaults to false.
  /// {@endtemplate}
  final bool? snap;

  /// {@template Sheet.snapSizes}
  /// The size stops the sheet snaps to. Defaults to
  /// [minSize, initialSize, maxSize] when null.
  /// {@endtemplate}
  final List<double>? snapSizes;

  /// {@template Sheet.snapAnimationDuration}
  /// Duration of the snap animation. Defaults to 250ms.
  /// {@endtemplate}
  final Duration? snapAnimationDuration;

  /// {@template Sheet.snapAnimationCurve}
  /// Curve of the snap animation. Defaults to [Curves.easeInOut].
  /// {@endtemplate}
  final Curve? snapAnimationCurve;

  /// {@template Sheet.snapFlingVelocity}
  /// Minimum velocity (px/s) in the resize axis to treat a drag release as a
  /// fling. Flings always target [maxSize] or [minSize], ignoring [snapSizes],
  /// so reaching the full screen requires [maxSize] to be `1.0`. Applies even
  /// when [snap] is false.
  ///
  /// Defaults to 700.
  /// {@endtemplate}
  final double? snapFlingVelocity;

  /// {@template Sheet.dragHandle}
  /// Custom widget to use as the drag handle. When null, a default pill is
  /// shown (only when [expandable] is true and [showDragHandle] is true).
  ///
  /// Use [dragHandleBuilder] instead when the handle needs to adapt to
  /// the sheet [SheetSide] (e.g. a horizontal pill for top/bottom and
  /// a vertical pill for left/right).
  /// {@endtemplate}
  final Widget? dragHandle;

  /// {@template Sheet.dragHandleBuilder}
  /// Side-aware builder for the drag handle. Takes precedence over
  /// [dragHandle] when non-null. Return the fully-rendered handle widget,
  /// including any padding or orientation logic your design needs — the
  /// sheet wraps whatever you return in the resize gesture detector.
  ///
  /// Runs on every rebuild (including drag-triggered ticks while the
  /// user is resizing), so keep the returned subtree cheap to build.
  /// {@endtemplate}
  final SheetDragHandleBuilder? dragHandleBuilder;

  /// {@template Sheet.showDragHandle}
  /// Whether to show the drag handle. Defaults to true when [expandable] is
  /// true.
  /// {@endtemplate}
  final bool? showDragHandle;

  /// {@template Sheet.dragHandleExtent}
  /// Extra draggable extent along the sheet's drag axis that overlays the
  /// sheet-adjacent edge of the body, in logical pixels.
  ///
  /// When non-zero, the top strip of a bottom sheet (or the corresponding
  /// edge of top/left/right sheets) also triggers resize — so the user can
  /// grab the visual top of the sheet (title area) instead of having to
  /// hit the small pill. Descendant widgets still receive tap events
  /// because the overlay uses translucent hit-testing; only drags are
  /// captured by the resize detector.
  ///
  /// Falls back to the theme value, then to 56 logical pixels. Set to 0
  /// to disable the body-edge drag region and limit resize to the pill.
  ///
  /// When combined with [draggable] = true, drags that start inside this
  /// strip resize the sheet rather than dismiss it. Users must drag from
  /// below the strip (or from below the title) to dismiss. Set a smaller
  /// extent, or 0, if dismissal from the top is important for your UX.
  /// {@endtemplate}
  final double? dragHandleExtent;

  /// {@template Sheet.onSizeChanged}
  /// Called whenever the sheet size changes.
  /// {@endtemplate}
  final ValueChanged<double>? onSizeChanged;

  /// {@template Sheet.controller}
  /// Controller for programmatic size control. A private one is created
  /// automatically if not provided.
  ///
  /// When supplied, [initialSize] is ignored; the controller is the
  /// single source of truth for size and is not mutated on mount or on
  /// prop updates.
  /// {@endtemplate}
  final SheetController? controller;

  @override
  State<Sheet> createState() => _SheetState();
}

// Shifts a [Position] by [insets], leaving null axes null so Positioned
// stays un-anchored on those axes.
Position _shiftPosition(Position base, EdgeInsets insets) {
  return Position(
    top: base.top != null ? base.top! + insets.top : null,
    bottom: base.bottom != null ? base.bottom! + insets.bottom : null,
    left: base.left != null ? base.left! + insets.left : null,
    right: base.right != null ? base.right! + insets.right : null,
  );
}

class _SheetState extends State<Sheet> with TickerProviderStateMixin {
  AnimationController? _animationController;
  final dragHandleMaterialState = <WidgetState>{};
  final GlobalKey childKey = GlobalKey(debugLabel: 'Sheet child');
  static const Curve legacyDecelerate = Cubic(0, 0, 0.2, 1);

  // Non-null only when the state created its own controller; null means the
  // caller supplied one via `widget.controller`.
  SheetController? ownedController;
  AnimationController? snapController;
  double? dragStartSizeRatio;
  double? dragStartPointer;
  // Whether the one-shot listener wiring / theme seed has run.
  bool sizeControllerReady = false;

  // The controller used this frame: caller-supplied, else the one we own.
  SheetController get sizeController => widget.controller ?? ownedController!;

  bool get ownsController => widget.controller == null;

  void initSizeController() {
    if (ownsController) {
      ownedController ??= SheetController();
    }
    sizeController
      ..addListener(handleSizeChanged)
      .._animateDelegate = animateSheetTo;
    sizeControllerReady = true;
  }

  // Resolves the initial size via widget prop → themed value → hard default.
  double resolveSeedSize() {
    final themedInitialSize = Theme.of(context).sheetTheme.initialSize;
    return widget.initialSize ?? themedInitialSize ?? 0.5;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // One-shot init; later dependency changes leave a user-dragged size alone.
    if (!sizeControllerReady) {
      initSizeController();
      if (ownsController) {
        ownedController!._size = resolveSeedSize();
      }
    }
  }

  void handleSizeChanged() {
    setState(() {});
    widget.onSizeChanged?.call(sizeController.size);
  }

  @override
  void didUpdateWidget(Sheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      // Detach from the outgoing controller before rewiring the new one.
      final outgoing = oldWidget.controller ?? ownedController;
      outgoing?._animateDelegate = null;
      outgoing?.removeListener(handleSizeChanged);
      if (oldWidget.controller == null) {
        ownedController?.dispose();
        ownedController = null;
      }
      sizeControllerReady = false;
      initSizeController();
      if (ownsController) {
        ownedController!._size = resolveSeedSize();
      }
    } else if (widget.initialSize != oldWidget.initialSize &&
        dragStartSizeRatio == null &&
        ownsController) {
      // Caller-owned controllers are the single source of truth, so only
      // re-seed one we own.
      ownedController!.jumpTo(resolveSeedSize());
    }
  }

  @override
  void dispose() {
    sizeController._animateDelegate = null;
    sizeController.removeListener(handleSizeChanged);
    ownedController?.dispose();
    snapController?.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  AnimationController get animationController =>
      widget.animationController ??
      (_animationController ??= AnimationController(
        duration: widget.enterDuration,
        reverseDuration: widget.exitDuration,
        debugLabel: 'Sheet',
        vsync: this,
        value: 1,
      ));

  double get childHeight {
    final renderBox = childKey.currentContext!.findRenderObject()! as RenderBox;
    return renderBox.size.height;
  }

  void handleDragStart(DragStartDetails details) {
    setState(() {
      dragHandleMaterialState.add(WidgetState.dragged);
    });
    widget.onDragStart?.call(details);
  }

  bool get effectiveDraggable => widget.draggable ?? false;

  bool get dismissUnderway =>
      animationController.status == AnimationStatus.reverse;

  void handleDragUpdate(DragUpdateDetails details, SheetSide side) {
    if (dismissUnderway) {
      return;
    }

    switch (side) {
      case SheetSide.bottom:
        animationController.value -= details.primaryDelta! / childHeight;
      case SheetSide.top:
        animationController.value += details.primaryDelta! / childHeight;
      case SheetSide.left:
        animationController.value += details.primaryDelta! / childHeight;
      case SheetSide.right:
        animationController.value -= details.primaryDelta! / childHeight;
    }
  }

  void handleDragEnd(
    DragEndDetails details, {
    required SheetSide side,
    required double minFlingVelocity,
    required double closeProgressThreshold,
  }) {
    if (dismissUnderway) {
      return;
    }
    setState(() {
      dragHandleMaterialState.remove(WidgetState.dragged);
    });
    var isClosing = false;
    final velocity = side == SheetSide.top
        ? details.velocity.pixelsPerSecond.dy
        : -details.velocity.pixelsPerSecond.dy;

    if (velocity.abs() > minFlingVelocity) {
      final flingVelocity = velocity / childHeight;
      if (animationController.value > 0.0) {
        animationController.fling(velocity: flingVelocity);
      }
      if (flingVelocity < 0.0) {
        isClosing = true;
      }
    } else if (animationController.value < closeProgressThreshold) {
      if (animationController.value > 0.0) {
        animationController.fling(velocity: -1);
      }
      isClosing = true;
    } else {
      animationController.forward();
    }

    widget.onDragEnd?.call(
      details,
      isClosing: isClosing,
    );

    if (isClosing) {
      if (widget.onClosing != null) {
        widget.onClosing!();
      } else {
        Navigator.of(context).maybePop();
      }
    }
  }

  // +1 where increasing pointer coordinate grows the sheet, -1 otherwise.
  double _growthSign(SheetSide side) => switch (side) {
    SheetSide.bottom => -1,
    SheetSide.top => 1,
    SheetSide.left => 1,
    SheetSide.right => -1,
  };

  void handleResizeDragStart(DragStartDetails details, SheetSide side) {
    dragStartSizeRatio = sizeController.size;
    dragStartPointer = side.isVertical
        ? details.globalPosition.dy
        : details.globalPosition.dx;
    // Cancel any in-flight snap animation so the drag controls the sheet.
    snapController?.stop();
  }

  void handleResizeDragUpdate(
    DragUpdateDetails details, {
    required SheetSide side,
    required Size mSize,
    required double minSize,
    required double maxSize,
  }) {
    if (dragStartSizeRatio == null || dragStartPointer == null) return;
    final isVertical = side.isVertical;
    final pointer = isVertical
        ? details.globalPosition.dy
        : details.globalPosition.dx;
    final pixelDelta = pointer - dragStartPointer!;
    final screenDim = isVertical ? mSize.height : mSize.width;
    final ratioDelta = pixelDelta / screenDim;
    final signed = ratioDelta * _growthSign(side);
    final next = (dragStartSizeRatio! + signed).clamp(minSize, maxSize);
    sizeController._setSize(next);
  }

  void handleResizeDragEnd(
    DragEndDetails details, {
    required SheetSide side,
    required bool snap,
    required List<double>? snapSizes,
    required double minSize,
    required double maxSize,
    required Duration duration,
    required Curve curve,
    required double snapFlingVelocity,
  }) {
    final isVertical = side.isVertical;
    final rawVelocity = isVertical
        ? details.velocity.pixelsPerSecond.dy
        : details.velocity.pixelsPerSecond.dx;
    final growingVelocity = rawVelocity * _growthSign(side);

    double? target;
    if (growingVelocity.abs() >= snapFlingVelocity) {
      // Ignore snapSizes so a fling cannot overshoot maxSize; reaching 1.0
      // therefore requires maxSize == 1.0. Activates even when snap=false.
      target = growingVelocity > 0 ? maxSize : minSize;
    } else if (snap && snapSizes != null) {
      final current = sizeController.size;
      target = snapSizes.reduce(
        (a, b) => (a - current).abs() < (b - current).abs() ? a : b,
      );
    }

    if (target != null) {
      unawaited(animateSheetTo(target, duration, curve));
    }

    dragStartSizeRatio = null;
    dragStartPointer = null;
  }

  // The single place that animates the sheet size. Drives the snap
  // AnimationController; a drag can cancel it mid-flight via
  // [handleResizeDragStart], in which case the size stays where the drag
  // takes over instead of jumping.
  Future<void> animateSheetTo(
    double size,
    Duration duration,
    Curve curve,
  ) async {
    snapController ??= AnimationController(vsync: this);
    final ctrl = snapController!..stop();
    final animation = CurvedAnimation(parent: ctrl, curve: curve);
    final tween = Tween<double>(begin: sizeController.size, end: size);
    void tick() => sizeController._setSize(tween.evaluate(animation));
    ctrl
      ..duration = duration
      ..value = 0
      ..addListener(tick);
    try {
      await ctrl.forward().orCancel;
    } on TickerCanceled {
      // Interrupted by a drag; leave the size where the drag takes over.
    } finally {
      ctrl.removeListener(tick);
      animation.dispose();
    }
  }

  // Pins the translucent body-edge overlay strip to the side adjacent
  // to the sheet's handle. Horizontal sides span full height; vertical
  // sides span full width. Abstraction keeps the four cases readable
  // and self-documenting.
  Widget _positionedBodyStrip({
    required SheetSide side,
    required Widget child,
  }) {
    return switch (side) {
      SheetSide.bottom => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: child,
      ),
      SheetSide.top => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: child,
      ),
      SheetSide.left => Positioned(
        top: 0,
        bottom: 0,
        right: 0,
        child: child,
      ),
      SheetSide.right => Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        child: child,
      ),
    };
  }

  Widget _buildDefaultHandlePill({
    required SheetSide side,
    required bool isVertical,
    required double width,
    required double height,
    required Color color,
    required BorderRadius radius,
  }) {
    final pill = Container(
      key: const ValueKey('finesse_sheet_drag_pill'),
      width: isVertical ? width : height,
      height: isVertical ? height : width,
      decoration: BoxDecoration(color: color, borderRadius: radius),
    );
    // Asymmetric padding: 28px on the outer edge + 12px on the
    // sheet-adjacent edge (+ 4px pill = 44px touch target). Keeps the
    // Apple HIG minimum tap area while pulling the pill visually close
    // to the sheet body.
    const outerPad = 28.0;
    const sheetPad = 12.0;
    final padding = switch (side) {
      SheetSide.bottom => const EdgeInsets.only(
        top: outerPad,
        bottom: sheetPad,
      ),
      SheetSide.top => const EdgeInsets.only(
        top: sheetPad,
        bottom: outerPad,
      ),
      SheetSide.left => const EdgeInsets.only(
        left: sheetPad,
        right: outerPad,
      ),
      SheetSide.right => const EdgeInsets.only(
        left: outerPad,
        right: sheetPad,
      ),
    };
    return Padding(
      padding: padding,
      child: Center(child: pill),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final side = SheetInheritedWidget.of(context);
    final mSize = MediaQuery.sizeOf(context);

    final effectiveExpandCrossSide =
        widget.expandCrossSide ?? theme.sheetTheme.expandCrossSide ?? true;

    final effectiveRadius =
        widget.radius ?? theme.sheetTheme.radius ?? BorderRadius.zero;

    final effectiveBackgroundColor =
        widget.backgroundColor ??
        theme.sheetTheme.backgroundColor ??
        theme.colorScheme.background;

    final effectiveExpandActionsWhenTiny =
        widget.expandActionsWhenTiny ??
        theme.sheetTheme.expandActionsWhenTiny ??
        true;

    final defaultConstraints = switch (side) {
      SheetSide.top || SheetSide.bottom => BoxConstraints(
        minWidth: mSize.width,
      ),
      SheetSide.left || SheetSide.right => _horizontalSideSheetConstraints(
        mSize,
        theme.breakpoints.sm.value,
      ),
    };

    final defaultCrossAxisAlignment = switch (side) {
      SheetSide.top || SheetSide.bottom => CrossAxisAlignment.stretch,
      SheetSide.left || SheetSide.right => CrossAxisAlignment.start,
    };

    final defaultMainAxisAlignment = switch (side) {
      SheetSide.top || SheetSide.bottom => MainAxisAlignment.start,
      SheetSide.left || SheetSide.right => MainAxisAlignment.end,
    };

    final effectiveMainAxisAlignment =
        widget.mainAxisAlignment ??
        theme.sheetTheme.mainAxisAlignment ??
        defaultMainAxisAlignment;

    final effectiveCrossAxisAlignment =
        widget.crossAxisAlignment ??
        theme.sheetTheme.crossAxisAlignment ??
        defaultCrossAxisAlignment;

    var effectiveConstraints =
        widget.constraints ??
        theme.sheetTheme.constraints ??
        (effectiveExpandCrossSide ? defaultConstraints : null);

    if (effectiveExpandCrossSide) {
      effectiveConstraints = effectiveConstraints?.enforce(defaultConstraints);
    }

    final effectiveBorder =
        widget.border ??
        theme.sheetTheme.border ??
        Border.all(color: theme.colorScheme.border);

    final effectiveShadows = widget.shadows ?? theme.sheetTheme.shadows;

    final effectiveRemoveBorderRadiusWhenTiny =
        widget.removeBorderRadiusWhenTiny ??
        theme.sheetTheme.removeBorderRadiusWhenTiny;
    final effectivePadding = widget.padding ?? theme.sheetTheme.padding;

    final effectiveGap = widget.gap ?? theme.sheetTheme.gap;

    final effectiveTitleStyle =
        widget.titleStyle ?? theme.sheetTheme.titleStyle;

    final effectiveDescriptionStyle =
        widget.descriptionStyle ?? theme.sheetTheme.descriptionStyle;

    final effectiveCloseIcon = widget.closeIcon ?? theme.sheetTheme.closeIcon;

    final effectiveCloseIconData =
        widget.closeIconData ?? theme.sheetTheme.closeIconData;

    final effectiveCloseIconPosition =
        widget.closeIconPosition ?? theme.sheetTheme.closeIconPosition;

    final effectiveActionsAxis =
        widget.actionsAxis ?? theme.sheetTheme.actionsAxis;

    final effectiveActionsMainAxisSize =
        widget.actionsMainAxisSize ?? theme.sheetTheme.actionsMainAxisSize;

    final effectiveActionsMainAxisAlignment =
        widget.actionsMainAxisAlignment ??
        theme.sheetTheme.actionsMainAxisAlignment;

    final effectiveActionsVerticalDirection =
        widget.actionsVerticalDirection ??
        theme.sheetTheme.actionsVerticalDirection;

    final effectiveTitleTextAlign =
        widget.titleTextAlign ?? theme.sheetTheme.titleTextAlign;

    final effectiveDescriptionTextAlign =
        widget.descriptionTextAlign ?? theme.sheetTheme.descriptionTextAlign;

    final effectiveScrollable =
        widget.scrollable ?? theme.sheetTheme.scrollable ?? true;

    final effectiveScrollPadding =
        widget.scrollPadding ??
        theme.sheetTheme.scrollPadding ??
        MediaQuery.viewInsetsOf(context);

    final effectiveUseSafeArea =
        widget.useSafeArea ?? theme.sheetTheme.useSafeArea ?? true;

    final effectiveTitlePinned =
        widget.titlePinned ?? theme.sheetTheme.titlePinned ?? false;

    final effectiveDescriptionPinned =
        widget.descriptionPinned ?? theme.sheetTheme.descriptionPinned ?? false;

    final effectiveActionsPinned =
        widget.actionsPinned ?? theme.sheetTheme.actionsPinned ?? true;

    final effectiveExpandable =
        widget.expandable ?? theme.sheetTheme.expandable ?? false;

    // Anchor + side safe-area insets, merged into the dialog's content
    // padding (below) and into the close-icon position so content clears
    // hardware affordances. The free-edge inset is handled separately in
    // [buildExpandable] (it depends on the live drag size).
    final safeAreaInsets = effectiveExpandable && effectiveUseSafeArea
        ? expandableSafeAreaInsets(side)
        : EdgeInsets.zero;

    // Dialog falls back to EdgeInsets.all(24) when padding is null;
    // expandable mode passes an explicit pre-merged value, so mirror that.
    const dialogDefaultPadding = EdgeInsets.all(24);
    final effectivePaddingWithSafeArea = effectiveExpandable
        ? EdgeInsets.zero
              .add(effectivePadding ?? dialogDefaultPadding)
              .add(safeAreaInsets)
        : effectivePadding;

    // Mirrors Dialog's default close-icon position so it shifts with the
    // safe-area insets merged into the padding above.
    final Position? adjustedCloseIconPosition;
    if (effectiveExpandable && effectiveUseSafeArea) {
      final base =
          effectiveCloseIconPosition ??
          Position.directional(
            top: 8,
            end: 8,
            textDirection: Directionality.of(context),
          );
      adjustedCloseIconPosition = _shiftPosition(base, safeAreaInsets);
    } else {
      adjustedCloseIconPosition = effectiveCloseIconPosition;
    }

    Widget dialog = Dialog(
      key: childKey,
      title: widget.title,
      description: widget.description,
      alignment: effectiveExpandable
          ? side.toInnerExpandableAlignment()
          : side.isVertical
          ? side.toAlignment()
          : side.toEdgeAlignment(),
      constraints: effectiveConstraints,
      actions: widget.actions,
      radius: effectiveExpandable ? BorderRadius.zero : effectiveRadius,
      closeIcon: effectiveCloseIcon,
      closeIconData: effectiveCloseIconData,
      closeIconPosition: adjustedCloseIconPosition,
      backgroundColor: effectiveExpandable
          ? const Color(0x00000000)
          : effectiveBackgroundColor,
      expandActionsWhenTiny: effectiveExpandActionsWhenTiny,
      padding: effectivePaddingWithSafeArea,
      gap: effectiveGap,
      actionsAxis: effectiveActionsAxis,
      actionsMainAxisSize: effectiveActionsMainAxisSize,
      actionsMainAxisAlignment: effectiveActionsMainAxisAlignment,
      actionsVerticalDirection: effectiveActionsVerticalDirection,
      border: effectiveExpandable
          ? Border.all(color: const Color(0x00000000), width: 0)
          : effectiveBorder,
      shadows: effectiveExpandable ? const <BoxShadow>[] : effectiveShadows,
      removeBorderRadiusWhenTiny: effectiveRemoveBorderRadiusWhenTiny,
      titleStyle: effectiveTitleStyle,
      descriptionStyle: effectiveDescriptionStyle,
      titleTextAlign: effectiveTitleTextAlign,
      descriptionTextAlign: effectiveDescriptionTextAlign,
      crossAxisAlignment: effectiveCrossAxisAlignment,
      mainAxisAlignment: effectiveMainAxisAlignment,
      scrollable: effectiveScrollable,
      scrollPadding: effectiveScrollPadding,
      // Expandable sheets handle safe area themselves (merged into padding +
      // an outer inset); only the non-expandable path defers to Dialog.
      useSafeArea: !effectiveExpandable && effectiveUseSafeArea,
      titlePinned: effectiveTitlePinned,
      descriptionPinned: effectiveDescriptionPinned,
      actionsPinned: effectiveActionsPinned,
      child: widget.child,
    );

    // Isolate the dialog's internal scroll view from the ambient
    // PrimaryScrollController; a shared controller crashes the Scrollbar
    // ("attached to more than one ScrollPosition") during snap animations
    // (issue #655). No-op when Dialog has `scrollable: false`.
    if (effectiveExpandable) {
      dialog = PrimaryScrollController.none(child: dialog);
    }

    var child = effectiveExpandable
        ? buildExpandable(
            context,
            dialog,
            side,
            radius: effectiveRadius,
            backgroundColor: effectiveBackgroundColor,
            border: effectiveBorder,
            shadows: effectiveShadows,
            useSafeArea: effectiveUseSafeArea,
          )
        : dialog;

    if (effectiveDraggable) {
      final effectiveDisabledScrollControlMaxRatio =
          widget.disabledScrollControlMaxRatio ??
          theme.sheetTheme.disabledScrollControlMaxRatio ??
          9 / 16;

      final effectiveMinFlingVelocity =
          widget.minFlingVelocity ?? theme.sheetTheme.minFlingVelocity ?? 700;

      final effectiveCloseProgressThreshold =
          widget.closeProgressThreshold ??
          theme.sheetTheme.closeProgressThreshold ??
          0.5;

      // Expandable forces isScrollControlled to bypass the 9/16 cap.
      final effectiveIsScrollControlled =
          effectiveExpandable || widget.isScrollControlled;

      child = SheetGestureDetector(
        onDragStart: handleDragStart,
        onDragUpdate: (details) => handleDragUpdate(details, side),
        onDragEnd: (details) => handleDragEnd(
          details,
          side: side,
          minFlingVelocity: effectiveMinFlingVelocity,
          closeProgressThreshold: effectiveCloseProgressThreshold,
        ),
        side: side,
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            final animationValue = legacyDecelerate.transform(
              animationController.view.value,
            );
            return SheetLayoutWithSizeListener(
              animationValue: animationValue,
              onChildSizeChanged: (_) {},
              scrollControlDisabledMaxRatio:
                  effectiveDisabledScrollControlMaxRatio,
              isScrollControlled: effectiveIsScrollControlled,
              side: side,
              child: child,
            );
          },
          child: child,
        ),
      );
    }

    return child;
  }

  // Builds the resizable composite (drag handle + dialog) for expandable
  // mode. Only called when `expandable` is true; reads the expandable-only
  // theme/widget values itself and reuses the decoration resolved in build().
  Widget buildExpandable(
    BuildContext context,
    Widget dialog,
    SheetSide side, {
    required BorderRadius radius,
    required Color backgroundColor,
    required BoxBorder border,
    required List<BoxShadow>? shadows,
    required bool useSafeArea,
  }) {
    final theme = Theme.of(context);
    final mSize = MediaQuery.sizeOf(context);
    final isVertical = side.isVertical;

    final effectiveInitialSize = resolveSeedSize();
    final effectiveMinSize = widget.minSize ?? theme.sheetTheme.minSize ?? 0.25;
    final effectiveMaxSize = widget.maxSize ?? theme.sheetTheme.maxSize ?? 1.0;
    final effectiveSnap = widget.snap ?? theme.sheetTheme.snap ?? false;
    final effectiveSnapSizes =
        widget.snapSizes ??
        theme.sheetTheme.snapSizes ??
        (effectiveSnap
            ? [effectiveMinSize, effectiveInitialSize, effectiveMaxSize]
            : null);
    final effectiveSnapAnimationDuration =
        widget.snapAnimationDuration ??
        theme.sheetTheme.snapAnimationDuration ??
        const Duration(milliseconds: 250);
    final effectiveSnapAnimationCurve =
        widget.snapAnimationCurve ??
        theme.sheetTheme.snapAnimationCurve ??
        Curves.easeInOut;
    final effectiveSnapFlingVelocity =
        widget.snapFlingVelocity ?? theme.sheetTheme.snapFlingVelocity ?? 700;
    final effectiveShowDragHandle =
        widget.showDragHandle ?? theme.sheetTheme.showDragHandle ?? true;
    final effectiveDragHandleColor =
        theme.sheetTheme.dragHandleColor ?? theme.colorScheme.border;
    final effectiveDragHandleWidth = theme.sheetTheme.dragHandleWidth ?? 36.0;
    final effectiveDragHandleHeight = theme.sheetTheme.dragHandleHeight ?? 4.0;
    final effectiveDragHandleExtent =
        widget.dragHandleExtent ?? theme.sheetTheme.dragHandleExtent ?? 56.0;
    final effectiveDragHandleRadius =
        theme.sheetTheme.dragHandleRadius ?? BorderRadius.circular(2);

    // Constrain the composite (handle + dialog) so the total always equals
    // `size * screenDim`, regardless of which handle the consumer supplies.
    final compositePx =
        sizeController.size * (isVertical ? mSize.height : mSize.width);

    // Precedence: builder (side-aware) > static widget > default pill.
    final handleWidget =
        widget.dragHandleBuilder?.call(context, side) ??
        widget.dragHandle ??
        (effectiveShowDragHandle
            ? _buildDefaultHandlePill(
                side: side,
                isVertical: isVertical,
                width: effectiveDragHandleWidth,
                height: effectiveDragHandleHeight,
                color: effectiveDragHandleColor,
                radius: effectiveDragHandleRadius,
              )
            : const SizedBox.shrink());

    void onStart(DragStartDetails d) => handleResizeDragStart(d, side);
    void onUpdate(DragUpdateDetails d) => handleResizeDragUpdate(
      d,
      side: side,
      mSize: mSize,
      minSize: effectiveMinSize,
      maxSize: effectiveMaxSize,
    );
    void onEnd(DragEndDetails d) => handleResizeDragEnd(
      d,
      side: side,
      snap: effectiveSnap,
      snapSizes: effectiveSnapSizes,
      minSize: effectiveMinSize,
      maxSize: effectiveMaxSize,
      duration: effectiveSnapAnimationDuration,
      curve: effectiveSnapAnimationCurve,
      snapFlingVelocity: effectiveSnapFlingVelocity,
    );

    final resizeHandle = SheetResizeHandle(
      side: side,
      onDragStart: onStart,
      onDragUpdate: onUpdate,
      onDragEnd: onEnd,
      child: handleWidget,
    );

    // Translucent strip extending the drag zone onto the body's sheet-adjacent
    // edge. Raw GestureDetector (not a second SheetResizeHandle) so
    // find.byType stays unique; translucent so descendant taps still land.
    final bodyDragStrip = effectiveDragHandleExtent > 0
        ? GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragStart: isVertical ? onStart : null,
            onVerticalDragUpdate: isVertical ? onUpdate : null,
            onVerticalDragEnd: isVertical ? onEnd : null,
            onHorizontalDragStart: isVertical ? null : onStart,
            onHorizontalDragUpdate: isVertical ? null : onUpdate,
            onHorizontalDragEnd: isVertical ? null : onEnd,
            child: SizedBox(
              width: isVertical ? double.infinity : effectiveDragHandleExtent,
              height: isVertical ? effectiveDragHandleExtent : double.infinity,
            ),
          )
        : null;

    // childKey stays on Dialog so childHeight measures the content, not
    // the composite (needed by the draggable-dismiss velocity math).
    // SizedBox.expand fills the composite's cross axis (the Column/Row
    // centers its children).
    final dialogWithStrip = SizedBox.expand(
      child: bodyDragStrip == null
          ? dialog
          : Stack(
              children: [
                Positioned.fill(child: dialog),
                _positionedBodyStrip(side: side, child: bodyDragStrip),
              ],
            ),
    );

    final composite = switch (side) {
      SheetSide.bottom => Column(
        children: [
          resizeHandle,
          Expanded(child: dialogWithStrip),
        ],
      ),
      SheetSide.top => Column(
        children: [
          Expanded(child: dialogWithStrip),
          resizeHandle,
        ],
      ),
      SheetSide.left => Row(
        children: [
          Expanded(child: dialogWithStrip),
          resizeHandle,
        ],
      ),
      SheetSide.right => Row(
        children: [
          resizeHandle,
          Expanded(child: dialogWithStrip),
        ],
      ),
    };

    // Free-edge inset outside the composite keeps the handle and body strip
    // reachable below the notch; the DecoratedBox wraps it so the background
    // still paints behind the notch.
    final outerInsets = useSafeArea
        ? expandableOuterInsets(side, mSize)
        : EdgeInsets.zero;
    final paddedComposite = outerInsets == EdgeInsets.zero
        ? composite
        : Padding(padding: outerInsets, child: composite);

    Widget child = SizedBox(
      height: isVertical ? compositePx : null,
      width: isVertical ? null : compositePx,
      child: DecoratedBox(
        key: const ValueKey('finesse_sheet_expandable_fill'),
        decoration: ShadowDecoration.box(
          color: backgroundColor,
          borderRadius: radius,
          border: border,
          shadows: shadows ?? const [],
        ),
        child: paddedComposite,
      ),
    );

    // Align the shrinkwrapped composite to its edge (toEdgeAlignment centers
    // left/right sheets). Skipped when draggable: SheetLayoutWithSizeListener
    // positions via absolute offsets and would conflict with Align.
    if (!effectiveDraggable) {
      child = Align(alignment: side.toEdgeAlignment(), child: child);
    }
    return child;
  }

  // Anchor + side safe-area insets (home indicator, side gutters); the guard
  // for `useSafeArea` lives at the call site.
  EdgeInsets expandableSafeAreaInsets(SheetSide side) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    return switch (side) {
      SheetSide.bottom => EdgeInsets.only(
        bottom: viewPadding.bottom,
        left: viewPadding.left,
        right: viewPadding.right,
      ),
      SheetSide.top => EdgeInsets.only(
        top: viewPadding.top,
        left: viewPadding.left,
        right: viewPadding.right,
      ),
      SheetSide.left => EdgeInsets.only(
        top: viewPadding.top,
        bottom: viewPadding.bottom,
        left: viewPadding.left,
      ),
      SheetSide.right => EdgeInsets.only(
        top: viewPadding.top,
        bottom: viewPadding.bottom,
        right: viewPadding.right,
      ),
    };
  }

  // Proportional free-edge inset that keeps the resize handle reachable below
  // the notch / Dynamic Island. Proportional (not gated at full size) so a
  // drag away from full size doesn't cause a hard layout jump.
  EdgeInsets expandableOuterInsets(SheetSide side, Size mSize) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final screenDim = side.isVertical ? mSize.height : mSize.width;
    final freeEdgeOffset = (1.0 - sizeController.size) * screenDim;
    return switch (side) {
      SheetSide.bottom => EdgeInsets.only(
        top: (viewPadding.top - freeEdgeOffset).clamp(0.0, viewPadding.top),
      ),
      SheetSide.top => EdgeInsets.only(
        bottom: (viewPadding.bottom - freeEdgeOffset).clamp(
          0.0,
          viewPadding.bottom,
        ),
      ),
      SheetSide.left => EdgeInsets.only(
        right: (viewPadding.right - freeEdgeOffset).clamp(
          0.0,
          viewPadding.right,
        ),
      ),
      SheetSide.right => EdgeInsets.only(
        left: (viewPadding.left - freeEdgeOffset).clamp(0.0, viewPadding.left),
      ),
    };
  }
}

/// {@template SheetGestureDetector}
/// A [GestureDetector] specifically for [Sheet] to handle drag gestures for
/// dismissal.
/// {@endtemplate}
class SheetGestureDetector extends StatelessWidget {
  /// {@macro SheetGestureDetector}
  const SheetGestureDetector({
    super.key,
    required this.child,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.side,
  });

  /// {@template SheetGestureDetector.child}
  /// The child widget to wrap with gesture detection.
  /// {@endtemplate}
  final Widget child;

  /// {@template SheetGestureDetector.onDragStart}
  /// Callback for drag start events.
  /// {@endtemplate}
  final GestureDragStartCallback onDragStart;

  /// {@template SheetGestureDetector.onDragUpdate}
  /// Callback for drag update events.
  /// {@endtemplate}
  final GestureDragUpdateCallback onDragUpdate;

  /// {@template SheetGestureDetector.onDragEnd}
  /// Callback for drag end events.
  /// {@endtemplate}
  final GestureDragEndCallback onDragEnd;

  /// {@template SheetGestureDetector.side}
  /// The side from which the sheet is sliding.
  /// {@endtemplate}
  final SheetSide side;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      excludeFromSemantics: true,
      gestures: <Type, GestureRecognizerFactory<GestureRecognizer>>{
        if (side.isVertical)
          VerticalDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                VerticalDragGestureRecognizer
              >(
                () => VerticalDragGestureRecognizer(debugOwner: this),
                (VerticalDragGestureRecognizer instance) {
                  instance
                    ..onStart = onDragStart
                    ..onUpdate = onDragUpdate
                    ..onEnd = onDragEnd
                    ..onlyAcceptDragOnThreshold = true;
                },
              ),
        if (side == SheetSide.left || side == SheetSide.right)
          HorizontalDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                HorizontalDragGestureRecognizer
              >(
                () => HorizontalDragGestureRecognizer(debugOwner: this),
                (HorizontalDragGestureRecognizer instance) {
                  instance
                    ..onStart = onDragStart
                    ..onUpdate = onDragUpdate
                    ..onEnd = onDragEnd
                    ..onlyAcceptDragOnThreshold = true;
                },
              ),
      },
      child: child,
    );
  }
}

/// The gesture target that resizes an expandable [Sheet] when dragged.
///
/// [Sheet] composes this widget internally when `expandable: true`, wiring
/// the drag callbacks to its resize logic. It can also be used directly to
/// build a custom resizable composition.
///
/// The detector uses [HitTestBehavior.opaque] so the entire padded touch
/// area absorbs drags, not only the visible child.
class SheetResizeHandle extends StatelessWidget {
  /// Creates a resize handle for an expandable [Sheet].
  const SheetResizeHandle({
    super.key,
    required this.side,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.child,
  });

  /// The side of the screen the parent sheet is anchored to. Determines
  /// whether the handle listens for vertical or horizontal drags.
  final SheetSide side;

  /// Fired at the start of a drag on the handle.
  final GestureDragStartCallback onDragStart;

  /// Fired for each drag update.
  final GestureDragUpdateCallback onDragUpdate;

  /// Fired when the drag ends (and before any snap animation).
  final GestureDragEndCallback onDragEnd;

  /// The visible content of the handle (typically a pill or custom widget).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isVertical = side.isVertical;
    return GestureDetector(
      // Opaque so the full padded touch target absorbs drags, not only
      // the visible pill.
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: isVertical ? onDragStart : null,
      onVerticalDragUpdate: isVertical ? onDragUpdate : null,
      onVerticalDragEnd: isVertical ? onDragEnd : null,
      onHorizontalDragStart: isVertical ? null : onDragStart,
      onHorizontalDragUpdate: isVertical ? null : onDragUpdate,
      onHorizontalDragEnd: isVertical ? null : onDragEnd,
      child: child,
    );
  }
}

/// Callback for when the size of a widget changes.
typedef SizeChangeCallback = void Function(Size size);

/// A [SingleChildRenderObjectWidget] that listens for size changes in its child
/// and applies layout transformations for [Sheet] animations.
class SheetLayoutWithSizeListener extends SingleChildRenderObjectWidget {
  /// Creates a layout that sizes and slides its child for a sheet.
  const SheetLayoutWithSizeListener({
    super.key,
    required this.onChildSizeChanged,
    required this.animationValue,
    required this.isScrollControlled,
    required this.scrollControlDisabledMaxRatio,
    required this.side,
    super.child,
  });

  /// {@template SheetLayoutWithSizeListener.onChildSizeChanged}
  /// Callback when the child widget's size changes.
  /// {@endtemplate}
  final SizeChangeCallback onChildSizeChanged;

  /// {@template SheetLayoutWithSizeListener.animationValue}
  /// The current animation value (0.0 to 1.0) for the sheet's animation.
  /// {@endtemplate}
  final double animationValue;

  /// {@template SheetLayoutWithSizeListener.isScrollControlled}
  /// Whether the sheet is scroll controlled.
  /// {@endtemplate}
  final bool isScrollControlled;

  /// {@template SheetLayoutWithSizeListener.scrollControlDisabledMaxRatio}
  /// Maximum height ratio when not scroll controlled.
  /// {@endtemplate}
  final double scrollControlDisabledMaxRatio;

  /// {@template SheetLayoutWithSizeListener.side}
  /// The side from which the sheet slides in.
  /// {@endtemplate}
  final SheetSide side;

  @override
  RenderSheetLayoutWithSizeListener createRenderObject(
    BuildContext context,
  ) {
    return RenderSheetLayoutWithSizeListener(
      onChildSizeChanged: onChildSizeChanged,
      animationValue: animationValue,
      isScrollControlled: isScrollControlled,
      scrollControlDisabledMaxRatio: scrollControlDisabledMaxRatio,
      side: side,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSheetLayoutWithSizeListener renderObject,
  ) {
    renderObject.onChildSizeChanged = onChildSizeChanged;
    renderObject.animationValue = animationValue;
    renderObject.isScrollControlled = isScrollControlled;
    renderObject.scrollControlDisabledMaxRatio = scrollControlDisabledMaxRatio;
  }
}

/// {@template RenderSheetLayoutWithSizeListener}
/// The render object for [SheetLayoutWithSizeListener], responsible for
/// layout and size change notifications.
/// {@endtemplate}
class RenderSheetLayoutWithSizeListener extends RenderShiftedBox {
  /// {@macro RenderSheetLayoutWithSizeListener}
  RenderSheetLayoutWithSizeListener({
    RenderBox? child,
    required this.side,
    required SizeChangeCallback onChildSizeChanged,
    required double animationValue,
    required bool isScrollControlled,
    required double scrollControlDisabledMaxRatio,
  }) : _onChildSizeChanged = onChildSizeChanged,
       _animationValue = animationValue,
       _isScrollControlled = isScrollControlled,
       _scrollControlDisabledMaxRatio = scrollControlDisabledMaxRatio,
       super(child);

  /// {@template RenderSheetLayoutWithSizeListener.side}
  /// The side from which the sheet slides in.
  /// {@endtemplate}
  final SheetSide side;

  /// The last size of the child widget to track size changes.
  Size _lastSize = Size.zero;

  /// Callback when the child widget's size changes.
  SizeChangeCallback get onChildSizeChanged => _onChildSizeChanged;
  SizeChangeCallback _onChildSizeChanged;
  set onChildSizeChanged(SizeChangeCallback newCallback) {
    if (_onChildSizeChanged == newCallback) {
      return;
    }

    _onChildSizeChanged = newCallback;
    markNeedsLayout();
  }

  /// The current animation value (0.0 to 1.0) for the sheet's animation.
  double get animationValue => _animationValue;
  double _animationValue;
  set animationValue(double newValue) {
    if (_animationValue == newValue) {
      return;
    }

    _animationValue = newValue;
    markNeedsLayout();
  }

  /// Whether the sheet is scroll controlled.
  bool get isScrollControlled => _isScrollControlled;
  bool _isScrollControlled;
  set isScrollControlled(bool newValue) {
    if (_isScrollControlled == newValue) {
      return;
    }

    _isScrollControlled = newValue;
    markNeedsLayout();
  }

  /// Maximum height ratio when not scroll controlled.
  double get scrollControlDisabledMaxRatio => _scrollControlDisabledMaxRatio;
  double _scrollControlDisabledMaxRatio;
  set scrollControlDisabledMaxRatio(double newValue) {
    if (_scrollControlDisabledMaxRatio == newValue) {
      return;
    }

    _scrollControlDisabledMaxRatio = newValue;
    markNeedsLayout();
  }

  Size _getSize(BoxConstraints constraints) {
    return constraints.constrain(constraints.biggest);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final width = _getSize(BoxConstraints.tightForFinite(height: height)).width;
    if (width.isFinite) {
      return width;
    }
    return 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final width = _getSize(BoxConstraints.tightForFinite(height: height)).width;
    if (width.isFinite) {
      return width;
    }
    return 0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final height = _getSize(BoxConstraints.tightForFinite(width: width)).height;
    if (height.isFinite) {
      return height;
    }
    return 0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final height = _getSize(BoxConstraints.tightForFinite(width: width)).height;
    if (height.isFinite) {
      return height;
    }
    return 0;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _getSize(constraints);
  }

  BoxConstraints _getConstraintsForChild(BoxConstraints constraints) {
    return switch (side) {
      SheetSide.top || SheetSide.bottom => BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        maxHeight: isScrollControlled
            ? constraints.maxHeight
            : constraints.maxHeight * scrollControlDisabledMaxRatio,
      ),
      SheetSide.left || SheetSide.right => BoxConstraints(
        minHeight: constraints.maxHeight,
        maxHeight: constraints.maxHeight,
        maxWidth: isScrollControlled
            ? constraints.maxWidth
            : constraints.maxWidth * scrollControlDisabledMaxRatio,
      ),
    };
  }

  Offset _getPositionForChild(Size size, Size childSize) {
    return switch (side) {
      SheetSide.bottom => Offset(
        0,
        size.height - childSize.height * animationValue,
      ),
      SheetSide.top => Offset(0, childSize.height * (animationValue - 1)),
      SheetSide.left => Offset(childSize.width * (animationValue - 1), 0),
      SheetSide.right => Offset(
        size.width - childSize.width * animationValue,
        0,
      ),
    };
  }

  @override
  void performLayout() {
    size = _getSize(constraints);
    if (child != null) {
      final childConstraints = _getConstraintsForChild(constraints);
      assert(childConstraints.debugAssertIsValid(isAppliedConstraint: true));
      child!.layout(
        childConstraints,
        parentUsesSize: !childConstraints.isTight,
      );
      final childParentData = child!.parentData! as BoxParentData;
      childParentData.offset = _getPositionForChild(
        size,
        childConstraints.isTight ? childConstraints.smallest : child!.size,
      );
      final childSize = childConstraints.isTight
          ? childConstraints.smallest
          : child!.size;

      if (_lastSize != childSize) {
        _lastSize = childSize;
        _onChildSizeChanged.call(_lastSize);
      }
    }
  }
}
