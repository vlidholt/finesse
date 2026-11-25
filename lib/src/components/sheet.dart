import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/components/dialog.dart';
import 'package:finesse/src/components/icon_button.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/components/button.dart';
import 'package:finesse/src/theme/form_factor.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/theme/themes/shadows.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:finesse/src/utils/expanded_actions_theme.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:finesse/src/utils/haptics.dart';
import 'package:finesse/src/utils/position.dart';
import 'package:finesse/src/utils/route_theme.dart';
import 'package:finesse/src/utils/separated_iterable.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The widest a sheet from the left or right is by default: Tailwind's
/// `max-w-sm` (24rem), which shadcn caps a side sheet at.
const double _sideSheetMaxWidth = 384;

/// The share of the page a side sheet covers on a narrow screen (`w-3/4`).
const double _sideSheetFraction = .75;

/// The widest a sheet from the top or bottom is on a desktop, where it is
/// centred instead of spanning the window.
const double _desktopSheetMaxWidth = 640;

/// The speed, in logical pixels per second, from which a release counts as
/// a fling: it sends the sheet to the next detent, or away.
const double _flingVelocity = 700;

/// How much of the page stays visible past the safe area above a sheet at
/// [SheetDetent.large], and the least of it that does.
const double _largeGap = 12;
const double _largeMinStrip = 40;

/// The room the drag handle takes at the sheet's open edge, and how much of
/// the content's padding it replaces there.
const double _handleExtent = 20;
const double _handlePaddingCut = 12;

/// Shows a [Sheet] over the page as a modal route: a barrier behind it, the
/// focus held inside it, and Escape, the system back button and — when it
/// is [dismissible] — a tap on the barrier or a drag closing it.
///
/// [builder] returns the [Sheet] (it may wrap it, in a provider say). The
/// sheet comes from [side]: the theme's by default, and then the bottom.
/// [SheetSide.start] and [SheetSide.end] follow the text direction.
///
/// ```dart
/// final choice = await showSheet<String>(
///   context: context,
///   builder: (context) => Sheet(
///     title: const Text('Share'),
///     child: ShareTargets(
///       onSelected: (target) => Navigator.of(context).pop(target),
///     ),
///   ),
/// );
/// ```
///
/// The future completes with the value the route was popped with. The
/// barrier defaults to the dialog's: `DialogTheme.barrierColor` and
/// `barrierBlurSigma`.
Future<T?> showSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  SheetSide? side,
  bool dismissible = true,
  Color? barrierColor,
  double? barrierBlurSigma,
  String? barrierLabel,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
}) {
  final theme = Theme.of(context, listen: false);
  final motion = Motion.of(context);
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  // Resolved here, where the sheet is asked for: the route is built under
  // the navigator, which need not share the opener's text direction.
  final effectiveSide = (side ?? theme.sheetTheme.side ?? SheetSide.bottom)
      .resolve(Directionality.of(context));

  late final _SheetRoute<T> route;
  route = _SheetRoute<T>(
    pageBuilder: routeThemedBuilder(
      opener: context,
      navigator: navigator,
      builder: (context) => _SheetInsets(
        side: effectiveSide,
        child: _SheetScope(
          route: route,
          side: effectiveSide,
          child: Builder(builder: builder),
        ),
      ),
    ),
    barrierColor:
        barrierColor ??
        theme.primaryDialogTheme.barrierColor ??
        const Color(0x1a000000),
    barrierBlurSigma:
        barrierBlurSigma ?? theme.primaryDialogTheme.barrierBlurSigma ?? 2,
    barrierDismissible: dismissible,
    barrierLabel:
        barrierLabel ?? FinesseLocalizations.of(context).dialog.dismiss,
    settings: routeSettings,
    // The sheet arrives on the surface spring and leaves faster than it
    // came. With reduced motion it only fades.
    transitionDuration: motion.reduced
        ? motion.fast
        : motion.smooth.settleDuration,
    reverseTransitionDuration: motion.reduced ? motion.fast : motion.normal,
  );
  return navigator.push(route);
}

/// The route of a modal sheet.
///
/// Its animation is the sheet's *presence*: 1 when the sheet is all there,
/// 0 when it is gone. The route does not move the sheet — the [Sheet] reads
/// the animation and places itself — but the barrier fades and the blur
/// behind it grows with it, which is why a drag that dismisses the sheet
/// drives this controller rather than an offset of the sheet's own.
class _SheetRoute<T> extends DialogRoute<T> {
  _SheetRoute({
    required super.pageBuilder,
    super.barrierDismissible,
    super.barrierLabel,
    super.barrierColor,
    super.barrierBlurSigma,
    super.transitionDuration,
    super.reverseTransitionDuration,
    super.settings,
  }) : super(transitionBuilder: _passThrough);

  static Widget _passThrough(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;

  /// The controller behind [animation], for the sheet to drive while it is
  /// dragged.
  AnimationController get presence => controller!;

  @override
  AnimationController createAnimationController() {
    // By default a controller runs twenty times as fast when the platform
    // asks for reduced motion. The durations given to this route are
    // already the reduced ones — a short fade — and are kept.
    return AnimationController(
      duration: transitionDuration,
      reverseDuration: reverseTransitionDuration,
      debugLabel: debugLabel,
      vsync: navigator!,
      animationBehavior: AnimationBehavior.preserve,
    );
  }
}

/// Tells a [Sheet] which route presents it, and from which side.
///
/// A sheet takes the scope for itself and hides it from its content, so a
/// second sheet placed inside the first one is an inline sheet.
class _SheetScope extends InheritedWidget {
  const _SheetScope({
    required this.route,
    required this.side,
    required super.child,
  });

  final _SheetRoute<Object?>? route;
  final SheetSide? side;

  static _SheetScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SheetScope>();

  @override
  bool updateShouldNotify(_SheetScope oldWidget) =>
      route != oldWidget.route || side != oldWidget.side;
}

/// Keeps a modal sheet clear of the on-screen keyboard: the area the sheet
/// lives in ends where the keyboard begins, so its detents are measured in
/// what is left.
class _SheetInsets extends StatelessWidget {
  const _SheetInsets({required this.side, required this.child});

  final SheetSide side;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linearToEaseOut,
      padding: EdgeInsets.only(bottom: bottom),
      child: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: child,
      ),
    );
  }
}

/// The edge of the page a [Sheet] is attached to.
enum SheetSide {
  /// The top edge.
  top,

  /// The right edge.
  right,

  /// The bottom edge.
  bottom,

  /// The left edge.
  left,

  /// The edge where a line of text starts: the left one in a left-to-right
  /// language, the right one in a right-to-left language.
  start,

  /// The edge where a line of text ends.
  end;

  /// Whether the sheet moves along the vertical axis: [top] and [bottom].
  bool get isVertical => this == SheetSide.top || this == SheetSide.bottom;

  /// This side with [start] and [end] turned into [left] or [right] for
  /// [direction]. The other four are returned as they are.
  SheetSide resolve(TextDirection direction) => switch (this) {
    SheetSide.start =>
      direction == TextDirection.ltr ? SheetSide.left : SheetSide.right,
    SheetSide.end =>
      direction == TextDirection.ltr ? SheetSide.right : SheetSide.left,
    _ => this,
  };
}

enum _DetentKind { content, fraction, height, large }

/// A size a [Sheet] comes to rest at, measured along the axis it moves on:
/// its height for a sheet from the top or bottom, its width for one from a
/// side.
///
/// A sheet with several detents can be dragged, flung or sent between them
/// (`SheetController.animateTo`). With one — [content], the default — it is
/// as big as what it holds.
///
/// ```dart
/// Sheet(
///   detents: const [SheetDetent.medium, SheetDetent.large],
///   builder: (context, controller) => ListView(controller: controller),
/// )
/// ```
@immutable
class SheetDetent {
  /// A share of the room the sheet has: its page for a modal sheet, its
  /// parent for an inline one. `SheetDetent.fraction(.25)` is a quarter.
  const SheetDetent.fraction(double fraction)
    : assert(
        fraction > 0 && fraction <= 1,
        'A fraction is greater than 0 and at most 1.',
      ),
      _kind = _DetentKind.fraction,
      _value = fraction;

  /// A fixed size in logical pixels, never more than the room there is. For
  /// a sheet from the left or right it is the width.
  const SheetDetent.height(double height)
    : assert(height > 0, 'A height is greater than 0.'),
      _kind = _DetentKind.height,
      _value = height;

  const SheetDetent._(this._kind) : _value = 0;

  /// As big as the sheet's content, up to [large]. Content that does not
  /// fit scrolls.
  static const content = SheetDetent._(_DetentKind.content);

  /// Half of the room.
  static const medium = SheetDetent.fraction(.5);

  /// All of the room but a strip of the page behind, which stays visible —
  /// and clear of the status bar — as a reminder of where the sheet came
  /// from and as something to tap to close it.
  static const large = SheetDetent._(_DetentKind.large);

  /// All of the room. The sheet's content keeps clear of the status bar.
  static const full = SheetDetent.fraction(1);

  final _DetentKind _kind;
  final double _value;

  @override
  bool operator ==(Object other) =>
      other is SheetDetent && other._kind == _kind && other._value == _value;

  @override
  int get hashCode => Object.hash(_kind, _value);

  @override
  String toString() => switch (_kind) {
    _DetentKind.content => 'SheetDetent.content',
    _DetentKind.large => 'SheetDetent.large',
    _DetentKind.fraction => 'SheetDetent.fraction($_value)',
    _DetentKind.height => 'SheetDetent.height($_value)',
  };
}

/// Moves a [Sheet] between its detents and closes it.
///
/// ```dart
/// final sheet = SheetController();
///
/// Sheet(
///   controller: sheet,
///   detents: const [SheetDetent.medium, SheetDetent.large],
///   child: Button(
///     onPressed: () => sheet.animateTo(SheetDetent.large),
///     child: const Text('Show more'),
///   ),
/// )
/// ```
///
/// It notifies its listeners when [detent] changes. Dispose it with the
/// state that made it.
class SheetController extends ChangeNotifier {
  _SheetState? _state;
  SheetDetent? _detent;

  /// The detent the sheet rests on or is on its way to; null until the
  /// controller is given to a sheet.
  SheetDetent? get detent => _detent;

  /// Whether a mounted sheet is using this controller.
  bool get isAttached => _state != null;

  /// Sends the sheet to [detent], which must be one of its detents, on the
  /// theme's surface spring. Does nothing while no sheet is attached.
  void animateTo(SheetDetent detent) => _state?._goToDetent(detent);

  /// Puts the sheet on [detent], which must be one of its detents, at once.
  void jumpTo(SheetDetent detent) =>
      _state?._goToDetent(detent, animate: false);

  /// Closes the sheet: a modal sheet's route is popped (unless a
  /// `PopScope` objects), an inline sheet's `onDismissed` is called.
  void close() => _state?._requestClose();

  void _setDetent(SheetDetent value) {
    if (_detent == value) return;
    _detent = value;
    notifyListeners();
  }
}

/// {@template Sheet}
/// A panel attached to an edge of the page.
///
/// Shown with [showSheet] it is modal: it slides in over a barrier and
/// holds the focus until it is closed. Placed in the tree — in a `Stack`,
/// or a scaffold's bottom-sheet slot — it is an inline sheet: no route, no
/// barrier, and the page around it stays in use.
///
/// The sheet lays out a [title], a [description], its [child] and a row of
/// [actions], like a dialog. Content that does not fit scrolls. A sheet
/// with a list of its own takes a [builder] instead of a [child] and gives
/// the list the scroll controller it is handed, so that dragging the list
/// moves the sheet before it scrolls.
///
/// **Detents.** By default a sheet is as big as its content
/// ([SheetDetent.content]). Give it [detents] and it rests on any of them:
/// the user drags or flings it from one to the next, and a
/// [SheetController] sends it there.
///
/// **Dragging.** On a touch screen a sheet follows the finger: pulled
/// towards its edge it goes down a detent, and past the smallest one a
/// dismissible modal sheet closes. A scrollable inside hands its drag over
/// once it is at its start. The drag handle — shown on a phone, and on any
/// sheet with several detents — is also what a mouse and the keyboard
/// (arrow keys, with the handle focused) resize it by. See [draggable].
///
/// On a phone a sheet from the top or bottom spans the screen, with the
/// corners on its open edge rounded. On a desktop it is centred and no
/// wider than a readable column; a sheet from a side is the usual choice
/// there.
/// {@endtemplate}
class Sheet extends StatefulWidget {
  /// {@macro Sheet}
  const Sheet({
    super.key,
    this.title,
    this.description,
    this.child,
    this.builder,
    this.actions = const [],
    this.side,
    this.detents,
    this.initialDetent,
    this.onDetentChanged,
    this.controller,
    this.draggable,
    this.showDragHandle,
    this.dragHandle,
    this.scrollable,
    this.padding,
    this.gap,
    this.constraints,
    this.backgroundColor,
    this.filter,
    this.borderRadius,
    this.border,
    this.shadows,
    this.titleStyle,
    this.descriptionStyle,
    this.showCloseButton,
    this.closeIcon,
    this.closeButton,
    this.closeIconPosition,
    this.onDismissed,
    this.useSafeArea,
    this.titlePinned,
    this.descriptionPinned,
    this.actionsPinned,
    this.semanticLabel,
  }) : assert(
         child == null || builder == null,
         'Give a sheet a child or a builder, not both.',
       );

  /// {@template Sheet.title}
  /// The title, at the top of the sheet. It names the sheet for a screen
  /// reader unless a [semanticLabel] does.
  /// {@endtemplate}
  final Widget? title;

  /// {@template Sheet.description}
  /// A line or two under the title that says what the sheet is for.
  /// {@endtemplate}
  final Widget? description;

  /// {@template Sheet.child}
  /// The content of the sheet. It scrolls when it does not fit, unless
  /// [scrollable] is false.
  /// {@endtemplate}
  final Widget? child;

  /// {@template Sheet.builder}
  /// Builds the content of a sheet that scrolls by itself, in place of
  /// [child]: give the scroll controller to the list. A drag on the list
  /// then moves the sheet first — up to its largest detent before the list
  /// scrolls, and down from the top of the list — as it does for a
  /// [child].
  ///
  /// The title, description and actions stay put around the list.
  /// {@endtemplate}
  final ScrollableWidgetBuilder? builder;

  /// {@template Sheet.actions}
  /// The buttons that end the sheet: in a row at its end on a desktop,
  /// stacked and as wide as the sheet on a phone, the first one at the
  /// bottom.
  ///
  /// An action that is not a `Button` — a row of them, say, for two
  /// choices side by side on a phone too — is given the sheet's width and
  /// lays out its own children.
  /// {@endtemplate}
  final List<Widget> actions;

  /// {@template Sheet.side}
  /// The edge the sheet is attached to. A sheet shown with [showSheet]
  /// takes the side it was shown from; otherwise the default is the
  /// theme's, and then the bottom.
  /// {@endtemplate}
  final SheetSide? side;

  /// {@template Sheet.detents}
  /// The sizes the sheet rests at. Null, the default, is
  /// `[SheetDetent.content]`.
  /// {@endtemplate}
  final List<SheetDetent>? detents;

  /// The detent the sheet opens at; the first of [detents] by default.
  final SheetDetent? initialDetent;

  /// Called when the sheet heads for another detent: after a drag or a
  /// fling, a key press on the handle, or a call on the [controller].
  final ValueChanged<SheetDetent>? onDetentChanged;

  /// Moves the sheet between its detents and closes it from outside.
  final SheetController? controller;

  /// {@template Sheet.draggable}
  /// Whether dragging the sheet moves it.
  ///
  /// Null, the default, follows the pointer: a finger or a stylus drags the
  /// sheet from anywhere on it, including from a scrollable inside it, and
  /// a mouse only by the drag handle — a mouse drag on the content is left
  /// to the content, to select text with. True lets every pointer drag the
  /// sheet from anywhere; false lets none, and hides the handle.
  /// {@endtemplate}
  final bool? draggable;

  /// {@template Sheet.showDragHandle}
  /// Whether the drag handle shows at the sheet's open edge.
  ///
  /// By default it does on a sheet from the top or bottom that can be
  /// dragged, on a phone or when the sheet has several detents: it says the
  /// sheet moves, and it is what a mouse and the keyboard resize it with.
  /// {@endtemplate}
  final bool? showDragHandle;

  /// A widget drawn in place of the handle's pill. The sheet still makes it
  /// draggable and focusable.
  final Widget? dragHandle;

  /// {@template Sheet.scrollable}
  /// Whether the sheet scrolls its content when it does not fit. Defaults
  /// to true. Set it to false for a [child] that lays out its own
  /// scrolling and needs a bounded height. Not used with a [builder].
  /// {@endtemplate}
  final bool? scrollable;

  /// {@template Sheet.padding}
  /// The space around the content. The safe area — the home indicator, the
  /// status bar under a full-height sheet — is added to it.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Sheet.gap}
  /// The space between the title, the description, the content and the
  /// actions.
  /// {@endtemplate}
  final double? gap;

  /// {@template Sheet.constraints}
  /// Limits on the sheet's size. Across its axis the largest size is the
  /// cap that keeps a sheet from the top or bottom readable on a wide
  /// window (640 on a desktop by default) or that gives a sheet from a
  /// side its width (three quarters of the page, at most 384, by default);
  /// along its axis the detents decide, within these.
  /// {@endtemplate}
  final BoxConstraints? constraints;

  /// {@template Sheet.backgroundColor}
  /// The colour of the sheet's surface.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Sheet.filter}
  /// A filter applied to what is behind the sheet, for a translucent
  /// [backgroundColor]: the blur of a glass surface. Null, the default,
  /// applies none.
  /// {@endtemplate}
  final ImageFilter? filter;

  /// The corners of the sheet, used as given. By default a sheet from the
  /// top or bottom takes the theme's radius on the two corners of its open
  /// edge, and a sheet from a side is square.
  final BorderRadius? borderRadius;

  /// {@template Sheet.border}
  /// The outline of the sheet.
  /// {@endtemplate}
  final BoxBorder? border;

  /// {@template Sheet.shadows}
  /// The shadows the sheet casts on the page.
  /// {@endtemplate}
  final List<BoxShadow>? shadows;

  /// {@template Sheet.titleStyle}
  /// The text style of the title.
  /// {@endtemplate}
  final TextStyle? titleStyle;

  /// {@template Sheet.descriptionStyle}
  /// The text style of the description, and of text in the content that
  /// has none of its own.
  /// {@endtemplate}
  final TextStyle? descriptionStyle;

  /// {@template Sheet.showCloseButton}
  /// Whether the sheet has a close button in its top end corner. A modal
  /// sheet has one by default; an inline sheet has one when it is given
  /// an [onDismissed].
  /// {@endtemplate}
  final bool? showCloseButton;

  /// {@template Sheet.closeIcon}
  /// The icon of the close button; a cross by default.
  /// {@endtemplate}
  final Widget? closeIcon;

  /// {@template Sheet.closeButton}
  /// A widget that stands in for the close button, shown in the sheet's top
  /// end corner whatever [showCloseButton] says. It closes the sheet
  /// itself; [closeIcon] is not used.
  /// {@endtemplate}
  final Widget? closeButton;

  /// {@template Sheet.closeIconPosition}
  /// Where the close button sits in the sheet; 8 from the top and from the
  /// end by default.
  /// {@endtemplate}
  final Position? closeIconPosition;

  /// Called when the sheet is dismissed: by the close button, by
  /// `SheetController.close` and by a drag that dismisses it. A modal sheet
  /// pops its route when this is null (`Navigator.maybePop`, which a
  /// `PopScope` can refuse); an inline sheet has no default, since only its
  /// parent can take it away.
  final VoidCallback? onDismissed;

  /// {@template Sheet.useSafeArea}
  /// Whether the content keeps clear of the system's bars and cut-outs
  /// while the surface runs under them. Defaults to true.
  /// {@endtemplate}
  final bool? useSafeArea;

  /// {@template Sheet.titlePinned}
  /// Whether the title stays in place while the content scrolls. Defaults
  /// to false; with a [builder] it always does.
  /// {@endtemplate}
  final bool? titlePinned;

  /// {@template Sheet.descriptionPinned}
  /// Whether the description stays in place while the content scrolls.
  /// Defaults to false; with a [builder] it always does.
  /// {@endtemplate}
  final bool? descriptionPinned;

  /// {@template Sheet.actionsPinned}
  /// Whether the actions stay in place while the content scrolls. Defaults
  /// to true.
  /// {@endtemplate}
  final bool? actionsPinned;

  /// The accessible name of the sheet, announced when it opens. Without
  /// one a modal sheet is named by its [title].
  final String? semanticLabel;

  @override
  State<Sheet> createState() => _SheetState();
}

/// How a modal sheet's place follows its route's animation.
enum _Presence {
  /// Arriving: the route runs from 0 to 1 and the sheet rides the surface
  /// spring's curve over it.
  entering,

  /// Under the finger, or on a spring let go by it: the hidden share is
  /// one minus the animation's value, exactly.
  tracking,

  /// Leaving, from wherever it was when the route was popped.
  exiting,
}

class _SheetState extends State<Sheet> with TickerProviderStateMixin {
  final _layoutKey = GlobalKey(debugLabel: 'Sheet layout');
  final _handleFocus = FocusNode(debugLabel: 'Sheet handle');

  /// The sheet's size along its axis while it is between detents.
  late final _size = SpringController(vsync: this, tolerance: .05);

  /// How far a sheet that cannot be dragged away has been pulled anyway.
  late final _over = SpringController(vsync: this, tolerance: .05);

  late final _scroll = _SheetScrollController(this);

  _SheetRoute<Object?>? _route;
  SheetSide? _scopeSide;

  /// What slides the sheet without resizing it: its route's animation and
  /// the pull on a sheet that cannot go. Sliding is paint only, so the
  /// render object listens to this itself and nothing is rebuilt for it.
  late Listenable _slides = _over.animation;
  late Animation<double> _fade = _SheetFade(this, _slides);

  Motion _motion = Motion.none;
  late SheetSide _side;
  late List<SheetDetent> _detents;
  int _index = 0;

  /// Whether the sheet rests on `_detents[_index]`. While it does it is laid
  /// out from the detent, so a change in the room it has moves it rigidly;
  /// otherwise from [_size], in pixels.
  bool _settled = true;

  _Presence _presence = _Presence.entering;
  double _exitFromValue = 1;
  double _exitFromHidden = 0;

  // Geometry of the last layout.
  double _available = 0;
  double _strip = 0;
  double _naturalCap = 0;

  bool _dragEnabledFor(PointerDeviceKind? kind) {
    final draggable = widget.draggable ?? _themeDraggable;
    if (draggable != null) return draggable;
    return kind == PointerDeviceKind.touch ||
        kind == PointerDeviceKind.stylus ||
        kind == PointerDeviceKind.invertedStylus;
  }

  bool? _themeDraggable;
  PointerDeviceKind? _dragKind;

  bool get _isModal => _route != null;

  _RenderSheetLayout? get _render =>
      _layoutKey.currentContext?.findRenderObject() as _RenderSheetLayout?;

  @override
  void initState() {
    super.initState();
    _detents = _detentsOf(widget);
    final initial = widget.initialDetent;
    if (initial != null) {
      final index = _detents.indexOf(initial);
      assert(index >= 0, 'initialDetent is not one of the detents.');
      _index = math.max(0, index);
    }
    _bind(widget.controller);
  }

  static List<SheetDetent> _detentsOf(Sheet widget) {
    final detents = widget.detents;
    assert(
      detents == null || detents.isNotEmpty,
      'A sheet needs at least one detent.',
    );
    return detents == null || detents.isEmpty
        ? const [SheetDetent.content]
        : detents;
  }

  void _bind(SheetController? controller) {
    if (controller == null) return;
    assert(
      controller._state == null || controller._state == this,
      'A SheetController is used by one sheet at a time.',
    );
    controller
      .._state = this
      .._detent = _detents[_index];
  }

  void _unbind(SheetController? controller) {
    if (controller?._state == this) controller!._state = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motion = Motion.of(context);
    final scope = _SheetScope.maybeOf(context);
    _scopeSide = scope?.side;
    _attach(scope?.route);
  }

  void _attach(_SheetRoute<Object?>? route) {
    if (identical(route, _route)) return;
    _route?.animation?.removeStatusListener(_onRouteStatus);
    _route = route;
    final animation = route?.animation;
    animation?.addStatusListener(_onRouteStatus);
    _presence = animation?.status == AnimationStatus.reverse
        ? _Presence.exiting
        : _Presence.entering;
    _slides = animation == null
        ? _over.animation
        : Listenable.merge([animation, _over.animation]);
    _fade = _SheetFade(this, _slides);
  }

  @override
  void didUpdateWidget(Sheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _unbind(oldWidget.controller);
      _bind(widget.controller);
    }
    final detents = _detentsOf(widget);
    if (!listEquals(detents, _detents)) {
      // Stay on the detent the sheet was on if it is still there, else on
      // the one nearest in size.
      final current = _detents[_index];
      final px = _currentExtent;
      _detents = detents;
      var index = detents.indexOf(current);
      if (index < 0) index = _nearestStop(px);
      _index = index;
      _size.stop();
      _settled = true;
      _report();
    }
  }

  @override
  void dispose() {
    _route?.animation?.removeStatusListener(_onRouteStatus);
    _unbind(widget.controller);
    _size.dispose();
    _over.dispose();
    _scroll.dispose();
    _handleFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Presence: where a modal sheet is between gone and all there.
  // ---------------------------------------------------------------------

  void _onRouteStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.reverse:
        // Popped. It leaves from where it is — under a finger, half-way
        // in — not from fully open.
        _exitFromHidden = _hiddenFraction;
        _exitFromValue = _route!.animation!.value;
        _presence = _Presence.exiting;
      case AnimationStatus.forward:
        if (_presence == _Presence.exiting) _presence = _Presence.entering;
      case AnimationStatus.completed:
        _presence = _Presence.entering;
      case AnimationStatus.dismissed:
        break;
    }
  }

  /// The share of the sheet that is slid off its edge, from 0 to 1.
  double get _hiddenFraction {
    final animation = _route?.animation;
    if (animation == null) return 0;
    final v = animation.value;
    switch (_presence) {
      case _Presence.entering:
        return _motion.reduced ? 0 : 1 - _motion.smooth.curve.transform(v);
      case _Presence.tracking:
        return 1 - v;
      case _Presence.exiting:
        if (_motion.reduced) return _exitFromHidden;
        final t = _exitFromValue <= 0
            ? 1.0
            : ((_exitFromValue - v) / _exitFromValue).clamp(0.0, 1.0);
        return lerpDouble(_exitFromHidden, 1, _motion.exit.transform(t))!;
    }
  }

  /// The sheet's opacity: 1 unless motion is reduced, when it fades in and
  /// out in place instead of sliding.
  double get _opacity {
    final animation = _route?.animation;
    if (animation == null || !_motion.reduced) return 1;
    final v = animation.value;
    return switch (_presence) {
      _Presence.entering => v,
      _Presence.tracking => 1,
      _Presence.exiting =>
        _exitFromValue <= 0 ? 0 : (v / _exitFromValue).clamp(0.0, 1.0),
    };
  }

  /// Hands the route's controller to the finger: from here on its value is
  /// the visible share of the sheet, with no curve in between.
  void _trackPresence() {
    final route = _route;
    if (route == null || _presence == _Presence.tracking) return;
    final visible = 1 - _hiddenFraction;
    _presence = _Presence.tracking;
    if (route.presence.value != visible) route.presence.value = visible;
  }

  bool get _routeLeaving {
    final route = _route;
    if (route == null) return false;
    return !route.isActive ||
        route.animation!.status == AnimationStatus.reverse;
  }

  bool get _canDismissByDrag {
    final route = _route;
    return route != null && route.barrierDismissible && route.isCurrent;
  }

  void _springBack(double closingVelocity) {
    final route = _route;
    if (route == null || !route.isActive) return;
    final controller = route.presence;
    final box = _render?.childExtent ?? 0;
    if (_motion.smooth.isInstant || box <= 0) {
      controller.value = 1;
      return;
    }
    _presence = _Presence.tracking;
    controller.animateWith(
      _motion.smooth.simulation(
        start: controller.value,
        end: 1,
        velocity: -closingVelocity / box,
      ),
    );
  }

  void _requestClose() {
    final onDismissed = widget.onDismissed;
    if (onDismissed != null) {
      onDismissed();
      return;
    }
    final route = _route;
    if (route == null || !route.isActive) return;
    // The sheet's own route, not whatever is on top of it.
    if (route.isCurrent) {
      route.navigator?.maybePop();
    } else {
      route.navigator?.removeRoute(route);
    }
  }

  Future<void> _dismissByDrag() async {
    _requestClose();
    // A `PopScope` may have refused, or `onDismissed` may have kept it:
    // then it comes back up rather than hanging half way.
    await Future<void>.delayed(Duration.zero);
    if (!mounted || _routeLeaving) return;
    if ((_route?.animation?.value ?? 1) < 1) _springBack(0);
  }

  // ---------------------------------------------------------------------
  // Detents.
  // ---------------------------------------------------------------------

  bool get _hasStops => _detents.length > 1;

  bool get _hasContentDetent => _detents.contains(SheetDetent.content);

  /// Whether the sheet is laid out as big as its content wants.
  bool get _isNatural => _settled && _detents[_index] == SheetDetent.content;

  double _resolve(SheetDetent detent) {
    final px = switch (detent._kind) {
      _DetentKind.content => math.min(
        _render?.naturalExtent ?? _naturalCap,
        _naturalCap,
      ),
      _DetentKind.fraction => _available * detent._value,
      _DetentKind.height => detent._value,
      _DetentKind.large => _available - _strip,
    };
    return px.clamp(0, math.max(0, _available)).toDouble();
  }

  List<double> get _stops => [for (final d in _detents) _resolve(d)];

  double get _currentExtent =>
      _settled ? _resolve(_detents[_index]) : _size.value;

  int _nearestStop(double px) {
    final stops = _stops;
    var best = 0;
    for (var i = 1; i < stops.length; i++) {
      if ((stops[i] - px).abs() < (stops[best] - px).abs()) best = i;
    }
    return best;
  }

  /// The stop next to [px] in one direction, or the last one that way.
  int _stopBeyond(double px, {required bool larger}) {
    final stops = _stops;
    int? best;
    int? extreme;
    for (var i = 0; i < stops.length; i++) {
      final s = stops[i];
      if (extreme == null ||
          (larger ? s > stops[extreme] : s < stops[extreme])) {
        extreme = i;
      }
      final beyond = larger ? s > px + 1 : s < px - 1;
      if (!beyond) continue;
      if (best == null || (larger ? s < stops[best] : s > stops[best])) {
        best = i;
      }
    }
    return best ?? extreme!;
  }

  /// Puts the size under the finger or a spring: from here on it is
  /// [_size], in pixels, until it settles.
  void _unsettle() {
    if (!_settled) {
      _size.stop();
      return;
    }
    _size.jumpTo(_currentExtent);
    setState(() => _settled = false);
  }

  void _report() {
    final detent = _detents[_index];
    final controller = widget.controller;
    if (controller != null && controller._detent != detent) {
      controller._setDetent(detent);
    }
  }

  void _goTo(int index, {double velocity = 0, bool animate = true}) {
    final moving = animate && !_motion.smooth.isInstant;
    // Before the index changes: the size is taken over from where the
    // sheet is now, not from where it is going.
    if (moving) _unsettle();
    final changed = index != _index;
    _index = index;
    if (changed) {
      widget.onDetentChanged?.call(_detents[index]);
      _report();
    }
    if (!moving) {
      _size.stop();
      if (!_settled || changed) setState(() => _settled = true);
      return;
    }
    final target = _resolve(_detents[index]);
    _size.animateTo(target, spring: _motion.smooth, velocity: velocity).then((
      _,
    ) {
      // Retargeted springs are cancelled and never get here.
      if (mounted && !_settled && _index == index && !_dragging) {
        setState(() => _settled = true);
      }
    });
  }

  void _goToDetent(SheetDetent detent, {bool animate = true}) {
    final index = _detents.indexOf(detent);
    assert(index >= 0, "$detent is not one of the sheet's detents.");
    if (index < 0) return;
    _goTo(index, animate: animate);
  }

  /// A step from the keyboard or a screen reader: one detent up or down.
  void _step({required bool larger}) {
    if (!_hasStops) return;
    _goTo(_stopBeyond(_currentExtent, larger: larger));
  }

  /// A tap on the handle: on to the next detent up, and from the largest
  /// back to the smallest.
  void _cycle() {
    if (!_hasStops) return;
    final px = _currentExtent;
    final up = _stopBeyond(px, larger: true);
    final atTop = (_stops[up] - px).abs() <= 1;
    _goTo(atTop ? _stopBeyond(double.negativeInfinity, larger: false) : up);
  }

  // ---------------------------------------------------------------------
  // Dragging. Every source — the sheet's own recognizer, the handle, a
  // scrollable inside — reports through these three, in pixels towards the
  // sheet's edge ("closing").
  // ---------------------------------------------------------------------

  bool _dragging = false;

  bool get _canDrag => !_routeLeaving;

  void _dragStart(PointerDeviceKind? kind) {
    _dragKind = kind;
    _dragging = true;
    _over.stop();
  }

  /// Moves the sheet by [closing] pixels towards its edge (negative: away
  /// from it) and returns how much of that it used.
  double _dragBy(double closing) {
    if (!_canDrag || closing == 0) return 0;
    var rest = closing;
    if (rest > 0) {
      if (_hasStops) {
        final stops = _stops;
        final min = stops.reduce(math.min);
        final px = _currentExtent;
        if (px > min) {
          _unsettle();
          final take = math.min(rest, px - min);
          _size.jumpTo(px - take);
          rest -= take;
        }
      }
      if (rest > 0) {
        final box = _render?.childExtent ?? 0;
        if (_canDismissByDrag && box > 0) {
          _trackPresence();
          final controller = _route!.presence;
          controller.value = math.max(0, controller.value - rest / box);
        } else {
          // It cannot go; it gives a little and comes back.
          final give = .35 / (1 + _over.value / 80);
          _over.jumpTo(_over.value + rest * give);
        }
        rest = 0;
      }
    } else {
      var open = -rest;
      if (_over.value > 0) {
        final take = math.min(open, _over.value);
        _over.jumpTo(_over.value - take);
        open -= take;
      }
      final route = _route;
      if (open > 0 && route != null && route.presence.value < 1) {
        final box = _render?.childExtent ?? 0;
        if (box > 0) {
          _trackPresence();
          final controller = route.presence;
          final hidden = (1 - controller.value) * box;
          final take = math.min(open, hidden);
          controller.value = math.min(1, controller.value + take / box);
          open -= take;
        }
      }
      if (open > 0 && _hasStops) {
        final max = _stops.reduce(math.max);
        final px = _currentExtent;
        if (px < max) {
          _unsettle();
          final take = math.min(open, max - px);
          _size.jumpTo(px + take);
          open -= take;
        }
      }
      rest = -open;
    }
    return closing - rest;
  }

  /// Whether the sheet is somewhere a drag left it: not on a detent, or
  /// part of the way out.
  bool get _displaced {
    if (_over.value > 0) return true;
    final route = _route;
    if (route != null &&
        _presence == _Presence.tracking &&
        route.presence.value < 1) {
      return true;
    }
    return !_settled;
  }

  /// The end of a drag the sheet was offered and took none of: a scrollable
  /// inside used all of it. The sheet stays where it is; a spring that
  /// finished while the drag was held settles now.
  void _dragUntaken() {
    if (!_dragging) return;
    _dragging = false;
    if (_over.value > 0) _over.animateTo(0, spring: _motion.smooth);
    if (!_settled && !_size.isAnimating) _goTo(_index);
  }

  /// Lets go at [closingVelocity] pixels per second towards the edge.
  void _dragEnd(double closingVelocity) {
    _dragging = false;
    if (_over.value > 0) _over.animateTo(0, spring: _motion.smooth);

    final route = _route;
    if (route != null &&
        _presence == _Presence.tracking &&
        route.presence.value < 1 &&
        !_routeLeaving) {
      final dismiss =
          closingVelocity > _flingVelocity ||
          (closingVelocity > -_flingVelocity && route.presence.value < .5);
      if (dismiss && _canDismissByDrag) {
        unawaited(_dismissByDrag());
        return;
      }
      _springBack(closingVelocity);
    }

    if (_settled) return;
    final px = _size.value;
    final previous = _index;
    final target = closingVelocity.abs() > _flingVelocity
        ? _stopBeyond(px, larger: closingVelocity < 0)
        : _nearestStop(px);
    _goTo(target, velocity: -closingVelocity);
    if (target != previous && _dragKind == PointerDeviceKind.touch) {
      Haptics.selection(context);
    }
  }

  // The pointer's travel towards the edge, per side.
  double _closing(SheetSide side, Offset delta) => switch (side) {
    SheetSide.bottom => delta.dy,
    SheetSide.top => -delta.dy,
    SheetSide.right => delta.dx,
    _ => -delta.dx,
  };

  void _onDragStart(DragStartDetails details) => _dragStart(details.kind);

  void _onDragUpdate(DragUpdateDetails details) =>
      _dragBy(_closing(_side, details.delta));

  void _onDragEnd(DragEndDetails details) =>
      _dragEnd(_closing(_side, details.velocity.pixelsPerSecond));

  void _onDragCancel() => _dragEnd(0);

  Set<PointerDeviceKind> _devices({required bool handle}) {
    final draggable = widget.draggable ?? _themeDraggable;
    if (draggable == false) return const {};
    if (draggable == true || handle) return PointerDeviceKind.values.toSet();
    return const {
      PointerDeviceKind.touch,
      PointerDeviceKind.stylus,
      PointerDeviceKind.invertedStylus,
    };
  }

  Widget _dragDetector({required bool handle, required Widget child}) {
    final devices = _devices(handle: handle);
    if (devices.isEmpty) return child;

    void configure(DragGestureRecognizer recognizer) {
      recognizer
        ..onStart = _onDragStart
        ..onUpdate = _onDragUpdate
        ..onEnd = _onDragEnd
        ..onCancel = _onDragCancel
        ..onlyAcceptDragOnThreshold = true;
    }

    return RawGestureDetector(
      excludeFromSemantics: true,
      behavior: handle ? HitTestBehavior.opaque : null,
      gestures: <Type, GestureRecognizerFactory>{
        if (_side.isVertical)
          VerticalDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                VerticalDragGestureRecognizer
              >(
                () => VerticalDragGestureRecognizer(
                  debugOwner: this,
                  supportedDevices: devices,
                ),
                configure,
              )
        else
          HorizontalDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                HorizontalDragGestureRecognizer
              >(
                () => HorizontalDragGestureRecognizer(
                  debugOwner: this,
                  supportedDevices: devices,
                ),
                configure,
              ),
      },
      child: child,
    );
  }

  KeyEventResult _onHandleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || !_hasStops) return KeyEventResult.ignored;
    final key = event.logicalKey;
    // The arrow that points away from the sheet's edge makes it larger.
    final (grow, shrink) = switch (_side) {
      SheetSide.bottom => (
        LogicalKeyboardKey.arrowUp,
        LogicalKeyboardKey.arrowDown,
      ),
      SheetSide.top => (
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.arrowUp,
      ),
      SheetSide.right => (
        LogicalKeyboardKey.arrowLeft,
        LogicalKeyboardKey.arrowRight,
      ),
      _ => (LogicalKeyboardKey.arrowRight, LogicalKeyboardKey.arrowLeft),
    };
    if (key == grow) {
      _step(larger: true);
      return KeyEventResult.handled;
    }
    if (key == shrink) {
      _step(larger: false);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ---------------------------------------------------------------------
  // Build.
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheetTheme = theme.sheetTheme;
    final direction = Directionality.of(context);
    final mobile = theme.formFactor == FormFactor.mobile;
    final modal = _isModal;

    _themeDraggable = sheetTheme.draggable;
    _side = (_scopeSide ?? widget.side ?? sheetTheme.side ?? SheetSide.bottom)
        .resolve(direction);
    final side = _side;
    final vertical = side.isVertical;

    final draggable = widget.draggable ?? sheetTheme.draggable;
    final showHandle =
        widget.showDragHandle ??
        sheetTheme.showDragHandle ??
        (vertical && draggable != false && (mobile || _hasStops));

    final backgroundColor =
        widget.backgroundColor ??
        sheetTheme.backgroundColor ??
        theme.colorScheme.background;
    final filter = widget.filter ?? sheetTheme.filter;
    final border =
        widget.border ??
        sheetTheme.border ??
        Border.all(color: theme.colorScheme.border);
    final shadows = widget.shadows ?? sheetTheme.shadows ?? Shadows.lg;
    final themeRadius = sheetTheme.borderRadius ?? theme.radius;
    final borderRadius =
        widget.borderRadius ??
        switch (side) {
          SheetSide.bottom => BorderRadius.only(
            topLeft: themeRadius.topLeft,
            topRight: themeRadius.topRight,
          ),
          SheetSide.top => BorderRadius.only(
            bottomLeft: themeRadius.bottomLeft,
            bottomRight: themeRadius.bottomRight,
          ),
          _ => BorderRadius.zero,
        };

    final useSafeArea = widget.useSafeArea ?? sheetTheme.useSafeArea ?? true;
    final safe = useSafeArea ? MediaQuery.paddingOf(context) : EdgeInsets.zero;
    // The inset on the sheet's open edge only counts once the sheet reaches
    // it — the status bar over a full-height sheet — and is applied in
    // [_frame]. The other three are always inside the surface.
    final (safeOpen, safeFixed) = switch (side) {
      SheetSide.bottom => (safe.top, safe.copyWith(top: 0)),
      SheetSide.top => (safe.bottom, safe.copyWith(bottom: 0)),
      SheetSide.left => (safe.right, safe.copyWith(right: 0)),
      _ => (safe.left, safe.copyWith(left: 0)),
    };

    // A list of the sheet's own that ends the sheet runs under the home
    // indicator, as a page's list does: the inset stays in the
    // `MediaQuery` for the list to pad itself with.
    final listToEdge =
        widget.builder != null &&
        widget.actions.isEmpty &&
        side != SheetSide.top;
    final contentSafe = listToEdge ? safeFixed.copyWith(bottom: 0) : safeFixed;

    final scrollable =
        widget.builder == null &&
        (widget.scrollable ?? sheetTheme.scrollable ?? true);
    final showClose =
        widget.showCloseButton ??
        (modal
            ? sheetTheme.showCloseButton ?? true
            : widget.onDismissed != null);

    Widget content = _SheetContent(
      side: side,
      fill: !vertical || !_isNatural,
      mobile: mobile,
      modal: modal,
      title: widget.title,
      description: widget.description,
      actions: widget.actions,
      scrollController: _scroll,
      scrollable: scrollable,
      builder: widget.builder,
      padding:
          (widget.padding ?? sheetTheme.padding ?? const EdgeInsets.all(24))
              .resolve(direction),
      safeArea: contentSafe,
      gap: widget.gap ?? sheetTheme.gap ?? 8,
      actionsGap: sheetTheme.actionsGap ?? 8,
      titleStyle:
          (widget.titleStyle ?? sheetTheme.titleStyle ?? theme.textTheme.large)
              .fallback(color: theme.colorScheme.foreground),
      descriptionStyle:
          (widget.descriptionStyle ??
                  sheetTheme.descriptionStyle ??
                  theme.textTheme.muted)
              .fallback(color: theme.colorScheme.mutedForeground),
      titlePinned: widget.titlePinned ?? sheetTheme.titlePinned ?? false,
      descriptionPinned:
          widget.descriptionPinned ?? sheetTheme.descriptionPinned ?? false,
      actionsPinned: widget.actionsPinned ?? sheetTheme.actionsPinned ?? true,
      semanticLabel: widget.semanticLabel,
      closeButton:
          widget.closeButton ??
          (showClose
              ? _SheetCloseButton(
                  icon: widget.closeIcon ?? sheetTheme.closeIcon,
                  mobile: mobile,
                  onPressed: _requestClose,
                )
              : null),
      closeIconPosition:
          widget.closeIconPosition ??
          sheetTheme.closeIconPosition ??
          Position.directional(top: 8, end: 8, textDirection: direction),
      handle: showHandle
          ? _SheetHandle(
              side: side,
              focusNode: _handleFocus,
              resizable: _hasStops,
              onKeyEvent: _onHandleKey,
              onTap: _cycle,
              onIncrease: () => _step(larger: true),
              onDecrease: () => _step(larger: false),
              detector: (child) => _dragDetector(handle: true, child: child),
              child: widget.dragHandle,
            )
          : null,
      child: widget.child,
    );

    content = _dragDetector(handle: false, child: content);
    // What is inside is not presented by this sheet's route, and the safe
    // area is spent.
    content = _SheetScope(
      route: null,
      side: null,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: useSafeArea,
        removeBottom: useSafeArea && !listToEdge,
        removeLeft: useSafeArea,
        removeRight: useSafeArea,
        child: content,
      ),
    );

    final surfaceShadow = ShadowDecoration.box(
      borderRadius: borderRadius,
      shadows: shadows,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = vertical
            ? constraints.maxHeight
            : constraints.maxWidth;
        final cross = vertical ? constraints.maxWidth : constraints.maxHeight;
        if (!available.isFinite || !cross.isFinite) {
          throw FlutterError.fromParts([
            ErrorSummary('A Sheet was given unbounded constraints.'),
            ErrorDescription(
              'A sheet measures its detents against the room it has, so it '
              'needs a bounded width and height: $constraints.',
            ),
            ErrorHint(
              'Show it with showSheet, or place it in a Stack, a '
              "Scaffold's bottom-sheet slot or another box of a known size.",
            ),
          ]);
        }

        final limits =
            widget.constraints ??
            sheetTheme.constraints ??
            (vertical
                ? (mobile
                      ? const BoxConstraints()
                      : const BoxConstraints(maxWidth: _desktopSheetMaxWidth))
                : BoxConstraints(
                    maxWidth: math.min(
                      available * _sideSheetFraction,
                      _sideSheetMaxWidth,
                    ),
                  ));
        final axisMax = vertical ? limits.maxHeight : limits.maxWidth;
        final axisMin = vertical ? limits.minHeight : limits.minWidth;
        final crossMax = vertical ? limits.maxWidth : limits.maxHeight;

        _available = available;
        _strip = vertical ? math.max(safeOpen + _largeGap, _largeMinStrip) : 0;
        _naturalCap = math.max(0, math.min(available - _strip, axisMax));
        final naturalMin = math.min(axisMin, _naturalCap);

        return ListenableBuilder(
          // Only a change of size builds anything: see [_slides].
          listenable: _size.animation,
          child: content,
          builder: (context, child) {
            double? extent;
            if (!_isNatural) {
              final stops = _stops;
              extent = _currentExtent.clamp(
                stops.reduce(math.min),
                stops.reduce(math.max),
              );
            }
            // How far the sheet reaches into the safe area of its open
            // edge: its content keeps that much clear.
            final reach = extent == null
                ? 0.0
                : (extent - (available - safeOpen)).clamp(0.0, safeOpen);
            final inset = switch (side) {
              SheetSide.bottom => EdgeInsets.only(top: reach),
              SheetSide.top => EdgeInsets.only(bottom: reach),
              SheetSide.left => EdgeInsets.only(right: reach),
              _ => EdgeInsets.only(left: reach),
            };

            return _SheetLayout(
              key: _layoutKey,
              side: side,
              fill: modal,
              extent: extent,
              naturalMin: naturalMin,
              naturalMax: _naturalCap,
              crossMax: crossMax,
              measureNatural: _hasContentDetent && !_isNatural,
              slides: _slides,
              hiddenFraction: () => _hiddenFraction,
              hiddenPixels: () => _over.value,
              child: BackdropFadeHost(
                opacity: _fade,
                child: RepaintBoundary(
                  child: BackdropSurface(
                    filter: filter,
                    tintOpacity: backgroundColor.a,
                    borderRadius: borderRadius,
                    // A filter is clipped, which would cut the shadow off;
                    // it is painted outside the clip instead.
                    shadow: filter == null ? null : surfaceShadow,
                    child: DecoratedBox(
                      decoration: ShadowDecoration.box(
                        color: backgroundColor,
                        borderRadius: borderRadius,
                        border: border,
                        shadows: filter == null ? shadows : const [],
                      ),
                      child: Padding(
                        // CSS's border-box: the content starts inside the
                        // outline.
                        padding: border.dimensions,
                        child: ClipRRect(
                          borderRadius: borderRadius,
                          child: Padding(padding: inset, child: child),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// The fade of a sheet under reduced motion, as an animation a
/// [BackdropFadeHost] can hand to a glass surface.
class _SheetFade extends Animation<double> {
  _SheetFade(this._state, this._ticks);

  final _SheetState _state;
  final Listenable _ticks;

  @override
  double get value => _state._opacity;

  @override
  AnimationStatus get status => AnimationStatus.forward;

  @override
  void addListener(VoidCallback listener) => _ticks.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _ticks.removeListener(listener);

  @override
  void addStatusListener(AnimationStatusListener listener) {}

  @override
  void removeStatusListener(AnimationStatusListener listener) {}
}

/// What is inside a sheet's surface: handle, title, description, content,
/// actions and the close button.
///
/// It is the part that does not change while the sheet moves, so it is
/// built once per rebuild of the [Sheet] and handed to each frame as it is.
class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.side,
    required this.fill,
    required this.mobile,
    required this.modal,
    required this.title,
    required this.description,
    required this.child,
    required this.builder,
    required this.actions,
    required this.scrollController,
    required this.scrollable,
    required this.padding,
    required this.safeArea,
    required this.gap,
    required this.actionsGap,
    required this.titleStyle,
    required this.descriptionStyle,
    required this.titlePinned,
    required this.descriptionPinned,
    required this.actionsPinned,
    required this.semanticLabel,
    required this.closeButton,
    required this.closeIconPosition,
    required this.handle,
  });

  final SheetSide side;

  /// Whether the sheet's height is given rather than taken from the
  /// content: the content then fills it, with the actions at its end.
  final bool fill;
  final bool mobile;
  final bool modal;
  final Widget? title;
  final Widget? description;
  final Widget? child;
  final ScrollableWidgetBuilder? builder;
  final List<Widget> actions;
  final ScrollController scrollController;
  final bool scrollable;
  final EdgeInsets padding;
  final EdgeInsets safeArea;
  final double gap;
  final double actionsGap;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final bool titlePinned;
  final bool descriptionPinned;
  final bool actionsPinned;
  final String? semanticLabel;
  final Widget? closeButton;
  final Position closeIconPosition;
  final Widget? handle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fit = fill ? FlexFit.tight : FlexFit.loose;
    final hasBuilder = builder != null;

    Widget? titleWidget;
    if (title != null) {
      titleWidget = Semantics(
        header: true,
        namesRoute: modal && semanticLabel == null,
        container: true,
        child: DefaultTextStyle(
          style: titleStyle,
          textAlign: TextAlign.start,
          child: closeButton == null
              ? title!
              // Clear of the close button in the corner.
              : Padding(
                  padding: const EdgeInsetsDirectional.only(end: 24),
                  child: title,
                ),
        ),
      );
    }
    final descriptionWidget = description == null
        ? null
        : DefaultTextStyle(
            style: descriptionStyle,
            textAlign: TextAlign.start,
            child: description!,
          );

    Widget? actionsWidget;
    if (actions.isNotEmpty) {
      actionsWidget = mobile
          ? DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                verticalDirection: VerticalDirection.up,
                spacing: actionsGap,
                children: [
                  for (final action in actions)
                    // A button fills the sheet's width and gives its label
                    // that width, so a long label ellipsizes instead of
                    // overflowing. The theme that does it reaches every
                    // button below it, so it goes around a button only:
                    // any other action — a row of buttons — is handed the
                    // width and lays out its own, where a button asked to
                    // be as wide as a row would have no width to take.
                    if (action is Button)
                      Theme(data: expandedActionsThemeOf(theme), child: action)
                    else
                      action,
                ],
              ),
            )
          : Wrap(
              alignment: WrapAlignment.end,
              spacing: actionsGap,
              runSpacing: actionsGap,
              children: actions,
            );
    }

    final pinTitle = hasBuilder || !scrollable || titlePinned;
    final pinDescription = hasBuilder || !scrollable || descriptionPinned;
    final pinActions = hasBuilder || !scrollable || actionsPinned;

    Widget? body;
    if (hasBuilder) {
      body = Builder(
        builder: (context) => builder!(context, scrollController),
      );
    } else {
      final content = child == null
          ? null
          : DefaultTextStyle(style: descriptionStyle, child: child!);
      if (scrollable) {
        final scrolled = <Widget>[
          if (!pinTitle) ?titleWidget,
          if (!pinDescription) ?descriptionWidget,
          ?content,
          if (!pinActions) ?actionsWidget,
        ];
        if (scrolled.isNotEmpty) {
          body = SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: scrolled.separatedBy(SizedBox(height: gap)),
            ),
          );
        }
      } else {
        body = content;
      }
    }

    // With a handle on that edge the padding is cut: the handle's own room
    // already separates the content from the edge.
    var insets = padding + safeArea;
    if (handle != null) {
      insets = switch (side) {
        SheetSide.bottom => insets.copyWith(
          top: math.max(0, padding.top - _handlePaddingCut),
        ),
        SheetSide.top => insets.copyWith(
          bottom: math.max(0, padding.bottom - _handlePaddingCut),
        ),
        SheetSide.left => insets.copyWith(
          right: math.max(0, padding.right - _handlePaddingCut),
        ),
        _ => insets.copyWith(
          left: math.max(0, padding.left - _handlePaddingCut),
        ),
      };
    }

    Widget result = Stack(
      // Tight when the sheet's size is given, so the content fills it.
      fit: StackFit.passthrough,
      children: [
        Padding(
          padding: insets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (pinTitle) ?titleWidget,
              if (pinDescription) ?descriptionWidget,
              if (body != null) Flexible(fit: fit, child: body),
              if (pinActions) ?actionsWidget,
            ].separatedBy(SizedBox(height: gap)),
          ),
        ),
        ?closeButton?.positionedWith(
          Position(
            top: closeIconPosition.top == null
                ? null
                : closeIconPosition.top! + safeArea.top,
            bottom: closeIconPosition.bottom == null
                ? null
                : closeIconPosition.bottom! + safeArea.bottom,
            left: closeIconPosition.left == null
                ? null
                : closeIconPosition.left! + safeArea.left,
            right: closeIconPosition.right == null
                ? null
                : closeIconPosition.right! + safeArea.right,
          ),
        ),
      ],
    );

    if (handle case final handle?) {
      final rest = Flexible(fit: fit, child: result);
      result = Flex(
        direction: side.isVertical ? Axis.vertical : Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // Left and right here are physical: the side is.
        textDirection: TextDirection.ltr,
        children: switch (side) {
          SheetSide.bottom || SheetSide.right => [handle, rest],
          _ => [rest, handle],
        },
      );
    }

    return Semantics(
      // As `Dialog` does: a modal sheet names and scopes its route, and its
      // children are described one by one rather than as one label.
      scopesRoute: modal,
      explicitChildNodes: true,
      namesRoute: modal && semanticLabel != null,
      label: semanticLabel,
      child: result,
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton({
    required this.icon,
    required this.mobile,
    required this.onPressed,
  });

  final Widget? icon;
  final bool mobile;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A finger needs more to aim at than a pointer does.
    final size = mobile ? 32.0 : 24.0;
    return IconButton.ghost(
      icon: icon ?? const PhosphorIcon(PhosphorIconsRegular.x, size: 16),
      style: ButtonTheme(
        width: size,
        height: size,
        padding: EdgeInsets.zero,
        foregroundColor: theme.colorScheme.foreground.withValues(alpha: .5),
        hoverForegroundColor: theme.colorScheme.foreground,
        pressedForegroundColor: theme.colorScheme.foreground,
      ),
      semanticLabel: FinesseLocalizations.of(context).dialog.close,
      onPressed: onPressed,
    );
  }
}

/// The pill at a sheet's open edge: something to drag, to focus and resize
/// with the arrow keys, and to tap through the detents.
class _SheetHandle extends StatefulWidget {
  const _SheetHandle({
    required this.side,
    required this.focusNode,
    required this.resizable,
    required this.onKeyEvent,
    required this.onTap,
    required this.onIncrease,
    required this.onDecrease,
    required this.detector,
    required this.child,
  });

  final SheetSide side;
  final FocusNode focusNode;

  /// Whether the sheet has more than one detent. A handle that resizes
  /// nothing is not a button and takes no focus.
  final bool resizable;
  final FocusOnKeyEventCallback onKeyEvent;
  final VoidCallback onTap;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final Widget Function(Widget child) detector;
  final Widget? child;

  @override
  State<_SheetHandle> createState() => _SheetHandleState();
}

class _SheetHandleState extends State<_SheetHandle> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheetTheme = theme.sheetTheme;
    final vertical = widget.side.isVertical;
    final length = sheetTheme.dragHandleWidth ?? 36.0;
    final thickness = sheetTheme.dragHandleHeight ?? 4.0;
    final radius =
        sheetTheme.dragHandleBorderRadius ?? BorderRadius.circular(thickness);

    final pill =
        widget.child ??
        DecoratedBox(
          decoration: BoxDecoration(
            color:
                sheetTheme.dragHandleColor ??
                theme.colorScheme.foreground.withValues(alpha: .2),
            borderRadius: radius,
          ),
          child: SizedBox(
            width: vertical ? length : thickness,
            height: vertical ? thickness : length,
          ),
        );

    Widget handle = SizedBox(
      width: vertical ? null : _handleExtent,
      height: vertical ? _handleExtent : null,
      child: Center(
        child: FocusRing(
          visible: _focused,
          borderRadius: radius,
          child: pill,
        ),
      ),
    );

    if (widget.resizable) {
      handle = Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: widget.onKeyEvent,
        child: FocusableActionDetector(
          focusNode: widget.focusNode,
          mouseCursor: vertical
              ? SystemMouseCursors.resizeUpDown
              : SystemMouseCursors.resizeLeftRight,
          onShowFocusHighlight: (value) {
            if (value != _focused) setState(() => _focused = value);
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) => widget.onTap(),
            ),
            // What Enter is bound to on the web.
            ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
              onInvoke: (_) => widget.onTap(),
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: widget.onTap,
            child: handle,
          ),
        ),
      );
      handle = Semantics(
        container: true,
        button: true,
        label: FinesseLocalizations.of(context).sheet.resize,
        onTap: widget.onTap,
        onIncrease: widget.onIncrease,
        onDecrease: widget.onDecrease,
        child: handle,
      );
    }
    return widget.detector(handle);
  }
}

/// The scroll controller a sheet gives its content: its positions hand a
/// drag to the sheet before they scroll.
class _SheetScrollController extends ScrollController {
  _SheetScrollController(this._sheet);

  final _SheetState _sheet;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _SheetScrollPosition(
      sheet: _sheet,
      physics: physics,
      context: context,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

/// A scroll position that lets the sheet around it take a drag first.
///
/// This is the hand-off `DraggableScrollableSheet` makes, done the same
/// way — in the position, not in the gesture arena, so there is one drag
/// and no fight over it: a pull towards the sheet's edge moves the sheet
/// once the content is at its start, a pull away from it grows the sheet
/// to its largest detent before the content scrolls, and what the sheet
/// does not use scrolls as usual.
class _SheetScrollPosition extends ScrollPositionWithSingleContext {
  _SheetScrollPosition({
    required this.sheet,
    required super.physics,
    required super.context,
    super.oldPosition,
    super.debugLabel,
  });

  final _SheetState sheet;
  PointerDeviceKind? _kind;

  /// Whether the sheet was told that the drag under way started, and so
  /// has to be told that it ended — whether or not it took any of it.
  bool _offered = false;

  /// Whether the sheet moved for the drag under way.
  bool _handedOff = false;

  bool get _handsOff {
    if (!sheet.mounted) return false;
    final side = sheet._side;
    if (side.isVertical != (axis == Axis.vertical)) return false;
    return sheet._dragEnabledFor(_kind);
  }

  /// Turns an amount along the scroll axis that moves the content towards
  /// its start into pixels towards the sheet's edge.
  double _closing(double delta) {
    // `delta` is positive when the finger moves towards the end of the
    // axis the scrollable grows along; flip it back for a reversed one.
    final pointer = axisDirectionIsReversed(axisDirection) ? -delta : delta;
    return switch (sheet._side) {
      SheetSide.bottom || SheetSide.right => pointer,
      _ => -pointer,
    };
  }

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    _kind = details.kind;
    _handedOff = false;
    _offered = _handsOff;
    if (_offered) sheet._dragStart(details.kind);
    return super.drag(details, dragCancelCallback);
  }

  @override
  void applyUserOffset(double delta) {
    if (!_handsOff || delta == 0) {
      super.applyUserOffset(delta);
      return;
    }
    final closing = _closing(delta);
    if (closing < 0) {
      // Away from the edge: the sheet grows as far as it can first.
      _scrollRest(delta, closing, sheet._dragBy(closing));
      return;
    }
    if (sheet._displaced) {
      _scrollRest(delta, closing, sheet._dragBy(closing));
      return;
    }
    // Towards the edge: the content scrolls back to its start, and what is
    // left of the pull — in this same event, or the finger would have to
    // stop and start again — moves the sheet.
    final room = delta > 0
        ? pixels - minScrollExtent
        : maxScrollExtent - pixels;
    if (room >= delta.abs()) {
      super.applyUserOffset(delta);
      return;
    }
    final scrolled = room <= 0 ? 0.0 : delta.sign * room;
    if (scrolled != 0) super.applyUserOffset(scrolled);
    final rest = _closing(delta - scrolled);
    if (sheet._dragBy(rest) != 0) _handedOff = true;
  }

  /// Scrolls by what the sheet left of [delta] after using [used] of the
  /// [closing] pixels it stands for.
  void _scrollRest(double delta, double closing, double used) {
    if (used != 0) _handedOff = true;
    final left = closing - used;
    if (left.abs() < precisionErrorTolerance) return;
    super.applyUserOffset(delta * (left / closing));
  }

  @override
  void goBallistic(double velocity) {
    final offered = _offered;
    _offered = false;
    if (offered && !_handedOff && sheet.mounted) {
      // Only the content moved: the fling is the content's, and the sheet
      // stays where it is, but it is no longer being dragged.
      sheet._dragUntaken();
    }
    if (_handedOff && sheet.mounted) {
      _handedOff = false;
      final moving = sheet._displaced;
      // `velocity` is the content's, in the direction its offset grows:
      // the opposite of the finger's.
      sheet._dragEnd(_closing(-velocity));
      if (moving) {
        // The sheet took the fling; the content stays where it is.
        super.goBallistic(0);
        return;
      }
    }
    super.goBallistic(velocity);
  }
}

/// Sizes a sheet along its axis and holds it against its edge.
class _SheetLayout extends SingleChildRenderObjectWidget {
  const _SheetLayout({
    required this.side,
    required this.fill,
    required this.extent,
    required this.naturalMin,
    required this.naturalMax,
    required this.crossMax,
    required this.measureNatural,
    required this.slides,
    required this.hiddenFraction,
    required this.hiddenPixels,
    required super.child,
    super.key,
  });

  final SheetSide side;

  /// Whether to take all the room there is and hold the sheet against its
  /// edge of it — a modal sheet in its route — rather than be the size of
  /// the sheet, for a parent to place.
  final bool fill;

  /// The sheet's size along its axis, or null to let its content decide,
  /// between [naturalMin] and [naturalMax].
  final double? extent;
  final double naturalMin;
  final double naturalMax;

  /// The most the sheet takes across its axis.
  final double crossMax;

  /// Whether to find out how big the content wants to be even though the
  /// sheet is given an [extent]: the content detent, while the sheet is
  /// somewhere else.
  final bool measureNatural;

  /// Notifies when [hiddenFraction] or [hiddenPixels] may have changed.
  final Listenable slides;

  /// The share of the sheet slid off its edge.
  final ValueGetter<double> hiddenFraction;

  /// Pixels slid off its edge on top of that.
  final ValueGetter<double> hiddenPixels;

  @override
  _RenderSheetLayout createRenderObject(BuildContext context) =>
      _RenderSheetLayout(
        side: side,
        fill: fill,
        extent: extent,
        naturalMin: naturalMin,
        naturalMax: naturalMax,
        crossMax: crossMax,
        measureNatural: measureNatural,
        slides: slides,
        hiddenFraction: hiddenFraction,
        hiddenPixels: hiddenPixels,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSheetLayout renderObject,
  ) {
    renderObject
      ..side = side
      ..fill = fill
      ..extent = extent
      ..naturalMin = naturalMin
      ..naturalMax = naturalMax
      ..crossMax = crossMax
      ..measureNatural = measureNatural
      ..slides = slides
      ..hiddenFraction = hiddenFraction
      ..hiddenPixels = hiddenPixels;
  }
}

class _RenderSheetLayout extends RenderShiftedBox {
  _RenderSheetLayout({
    required SheetSide side,
    required bool fill,
    required double? extent,
    required double naturalMin,
    required double naturalMax,
    required double crossMax,
    required bool measureNatural,
    required Listenable slides,
    required this.hiddenFraction,
    required this.hiddenPixels,
  }) : _side = side,
       _slides = slides,
       _fill = fill,
       _extent = extent,
       _naturalMin = naturalMin,
       _naturalMax = naturalMax,
       _crossMax = crossMax,
       _measureNatural = measureNatural,
       super(null);

  /// The child's size along the sheet's axis after the last layout.
  double childExtent = 0;

  /// How big the content wanted to be when it was last asked.
  double? naturalExtent;

  SheetSide get side => _side;
  SheetSide _side;
  set side(SheetSide value) {
    if (_side == value) return;
    _side = value;
    markNeedsLayout();
  }

  bool get fill => _fill;
  bool _fill;
  set fill(bool value) {
    if (_fill == value) return;
    _fill = value;
    markNeedsLayout();
  }

  double? get extent => _extent;
  double? _extent;
  set extent(double? value) {
    if (_extent == value) return;
    _extent = value;
    markNeedsLayout();
  }

  double get naturalMin => _naturalMin;
  double _naturalMin;
  set naturalMin(double value) {
    if (_naturalMin == value) return;
    _naturalMin = value;
    markNeedsLayout();
  }

  double get naturalMax => _naturalMax;
  double _naturalMax;
  set naturalMax(double value) {
    if (_naturalMax == value) return;
    _naturalMax = value;
    markNeedsLayout();
  }

  double get crossMax => _crossMax;
  double _crossMax;
  set crossMax(double value) {
    if (_crossMax == value) return;
    _crossMax = value;
    markNeedsLayout();
  }

  bool get measureNatural => _measureNatural;
  bool _measureNatural;
  set measureNatural(bool value) {
    if (_measureNatural == value) return;
    _measureNatural = value;
    markNeedsLayout();
  }

  // Sliding is paint only: the sheet is laid out where it rests, and a
  // tick of what slides it repaints this box without rebuilding anything.
  Listenable get slides => _slides;
  Listenable _slides;
  set slides(Listenable value) {
    if (identical(_slides, value)) return;
    if (attached) _slides.removeListener(_slid);
    _slides = value;
    if (attached) value.addListener(_slid);
    _slid();
  }

  /// The share of the sheet slid off its edge.
  ValueGetter<double> hiddenFraction;

  /// Pixels slid off its edge on top of that.
  ValueGetter<double> hiddenPixels;

  void _slid() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _slides.addListener(_slid);
  }

  @override
  void detach() {
    _slides.removeListener(_slid);
    super.detach();
  }

  bool get _vertical => _side.isVertical;

  double _along(Size size) => _vertical ? size.height : size.width;

  BoxConstraints _childConstraints(
    BoxConstraints constraints,
    double min,
    double max,
  ) {
    final cross = math.min(
      _vertical ? constraints.maxWidth : constraints.maxHeight,
      _crossMax,
    );
    return _vertical
        ? BoxConstraints(
            minWidth: cross,
            maxWidth: cross,
            minHeight: min,
            maxHeight: max,
          )
        : BoxConstraints(
            minHeight: cross,
            maxHeight: cross,
            minWidth: min,
            maxWidth: max,
          );
  }

  BoxConstraints _resting(BoxConstraints constraints) {
    final extent = _extent;
    return extent == null
        ? _childConstraints(constraints, _naturalMin, _naturalMax)
        : _childConstraints(constraints, extent, extent);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    if (_fill) return constraints.biggest;
    return constraints.constrain(child.getDryLayout(_resting(constraints)));
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      childExtent = 0;
      return;
    }
    final extent = _extent;
    if (extent == null || _measureNatural) {
      child.layout(
        _childConstraints(constraints, _naturalMin, _naturalMax),
        parentUsesSize: true,
      );
      naturalExtent = _along(child.size);
    }
    if (extent != null) {
      child.layout(
        _childConstraints(constraints, extent, extent),
        parentUsesSize: true,
      );
    }
    childExtent = _along(child.size);
    size = _fill ? constraints.biggest : constraints.constrain(child.size);

    // Flush with the sheet's edge, centred across it.
    (child.parentData! as BoxParentData).offset = switch (_side) {
      SheetSide.bottom => Offset(
        (size.width - child.size.width) / 2,
        size.height - child.size.height,
      ),
      SheetSide.top => Offset((size.width - child.size.width) / 2, 0),
      SheetSide.right => Offset(
        size.width - child.size.width,
        (size.height - child.size.height) / 2,
      ),
      _ => Offset(0, (size.height - child.size.height) / 2),
    };
  }

  /// How far the child is painted from where it was laid out.
  Offset get _slide {
    final distance = hiddenFraction() * childExtent + hiddenPixels();
    return switch (_side) {
      SheetSide.bottom => Offset(0, distance),
      SheetSide.top => Offset(0, -distance),
      SheetSide.right => Offset(distance, 0),
      _ => Offset(-distance, 0),
    };
  }

  Offset get _childOffset =>
      (child!.parentData! as BoxParentData).offset + _slide;

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    // All the way out: nothing to draw, and no shadow left on the edge.
    if (hiddenFraction() >= 1) return;
    context.paintChild(child, offset + _childOffset);
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final offset = _childOffset;
    transform.translateByDouble(offset.dx, offset.dy, 0, 1);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null) return false;
    return result.addWithPaintOffset(
      offset: _childOffset,
      position: position,
      hitTest: (result, transformed) =>
          child.hitTest(result, position: transformed),
    );
  }
}
