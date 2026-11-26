import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/theme/data.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/shadow.dart';

// The drawer of a `Scaffold`: the route it is shown in and the gestures that
// move it. Internal; `Scaffold` is the public face.

/// The widest a drawer grows, and the share of a narrow screen it takes.
const _maxDrawerWidth = 360.0;
const _drawerWidthFraction = .85;

/// The speed, in logical pixels per second, above which a release decides
/// the drawer's fate by its direction rather than by where it is.
const _flingSpeed = 365.0;

/// The pointers that can drag a drawer: a finger or a pen. A mouse opens it
/// with the button and closes it on the scrim.
const Set<PointerDeviceKind> drawerDragDevices = {
  PointerDeviceKind.touch,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
};

/// The width of a drawer on a screen [available] wide.
double drawerWidthFor(double available) =>
    math.min(available * _drawerWidthFraction, _maxDrawerWidth);

/// Whether a drawer let go at [progress], moving at [opening] logical pixels
/// per second in the direction that opens it, ends up open.
bool drawerSettlesOpen(double progress, double opening) =>
    opening.abs() >= _flingSpeed ? opening > 0 : progress > .5;

/// Whether drawers slide under [motion]. With reduced motion, or none, they
/// fade in place and are not dragged.
bool drawerSlides(Motion motion) => !motion.reduced && !motion.smooth.isInstant;

/// The colour of the scrim behind a drawer.
///
/// The dialog's barrier is as light as it is because the page behind it is
/// also blurred. A drawer follows a finger, and a full-screen blur on every
/// frame of that is not worth its cost, so the scrim is deeper instead.
Color drawerScrimColor(ThemeData? theme) {
  final barrier =
      theme?.primaryDialogTheme.barrierColor ?? const Color(0x1a000000);
  return barrier.withValues(alpha: math.min(barrier.a * 2.5, 1));
}

/// How long a drawer at [progress] takes to shut, and on what curve.
///
/// Thrown shut at [velocity] (progress per second) it leaves in a straight
/// line at that speed; let go at rest it accelerates away over what is left
/// of [full].
(Duration, Curve) drawerExit(
  double progress,
  double velocity,
  Duration full,
  Motion motion,
) {
  if (velocity > 0) {
    final micros = (progress / velocity * Duration.microsecondsPerSecond)
        .clamp(60000, math.max(full.inMicroseconds, 60000))
        .round();
    return (Duration(microseconds: micros), Curves.linear);
  }
  return (
    Duration(microseconds: (full.inMicroseconds * progress).round()),
    motion.exit,
  );
}

/// A drawer as a modal route: a panel against the start or the end edge of
/// the navigator, over a scrim.
///
/// Being a route is what makes the system back gesture, Escape and a tap on
/// the scrim close it, keeps the focus inside it and hides the page behind
/// it from assistive technology.
///
/// The panel's place is always linear in the route's animation value, and
/// the *value* is driven by whatever moves the drawer: a spring when it is
/// opened, the finger while it is dragged, a spring carrying the finger's
/// speed when it is let go. Nothing jumps when one hands over to another.
class ScaffoldDrawerRoute extends PopupRoute<void> {
  /// Creates the route of one drawer.
  ScaffoldDrawerRoute({
    required this.content,
    required this.atEnd,
    required this.motion,
    required this.theme,
    required this.semanticLabel,
    this.barrierLabel,
    this.initialProgress = 0,
    this.initialVelocity = 0,
  });

  /// The drawer's content. A listenable, because the scaffold that owns the
  /// drawer may be rebuilt with another one while it is open.
  final ValueListenable<Widget?> content;

  /// Whether the panel sits against the end edge rather than the start.
  final bool atEnd;

  /// The motion tokens where the drawer was opened.
  final Motion motion;

  /// The theme of the scaffold, when it is not the navigator's own: a
  /// drawer opened from a re-themed subtree keeps that theme.
  final ThemeData? theme;

  /// What assistive technology calls the drawer.
  final String semanticLabel;

  /// How far open the drawer already is when the route takes over, and how
  /// fast it is moving, in progress per second: where an edge drag let go
  /// of it.
  final double initialProgress;

  /// See [initialProgress].
  final double initialVelocity;

  /// The panel's laid-out width, for turning a drag in pixels into
  /// progress.
  double panelWidth = _maxDrawerWidth;

  @override
  final String? barrierLabel;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => drawerScrimColor(theme ?? _navigatorTheme);

  // Linear, like the panel: the scrim of a drawer that is being dragged
  // follows the finger too.
  @override
  Curve get barrierCurve => Curves.linear;

  ThemeData? get _navigatorTheme {
    final context = navigator?.context;
    return context == null ? null : Theme.maybeOf(context, listen: false);
  }

  @override
  Duration get transitionDuration =>
      motion.reduced ? motion.fast : motion.smooth.settleDuration;

  // It leaves faster than it arrives.
  @override
  Duration get reverseTransitionDuration =>
      motion.reduced ? motion.fast : motion.normal;

  bool get _slides => drawerSlides(motion);

  @override
  TickerFuture didPush() {
    final future = super.didPush();
    if (!_slides) return future;
    // On the surface spring, from wherever a drag left it.
    final controller = this.controller!;
    final from = initialProgress.clamp(0.0, 1.0);
    controller
      ..value = from
      ..animateWith(
        motion.smooth.simulation(
          start: from,
          end: 1,
          velocity: initialVelocity,
        ),
      );
    return future;
  }

  /// The speed, in progress per second, the drawer is thrown shut with.
  double _closingVelocity = 0;

  @override
  bool didPop(void result) {
    final controller = this.controller!;
    final from = controller.value;
    final popped = super.didPop(result);
    if (!_slides || from <= 0) return popped;
    final (duration, curve) = drawerExit(
      from,
      _closingVelocity,
      reverseTransitionDuration,
      motion,
    );
    controller.animateBack(0, duration: duration, curve: curve);
    return popped;
  }

  /// Closes the drawer whether or not it is the topmost route.
  void close() {
    if (!isActive) return;
    if (isCurrent) {
      navigator!.pop();
    } else {
      navigator!.removeRoute(this);
    }
  }

  /// A drag began on the panel.
  void dragStart() {
    if (!isActive || !_slides) return;
    controller!.stop();
  }

  /// The finger moved [delta] logical pixels, positive towards the end of
  /// the line.
  void dragUpdate(double delta) {
    if (!isActive || !_slides) return;
    final controller = this.controller!;
    final progress = (atEnd ? -delta : delta) / panelWidth;
    controller.value = (controller.value + progress).clamp(0.0, 1.0);
  }

  /// The finger let go at [velocity] logical pixels per second, positive
  /// towards the end of the line.
  void dragEnd(double velocity) {
    if (!isActive || !_slides) return;
    final controller = this.controller!;
    final opening = atEnd ? -velocity : velocity;
    if (drawerSettlesOpen(controller.value, opening)) {
      controller.animateWith(
        motion.smooth.simulation(
          start: controller.value,
          end: 1,
          velocity: opening / panelWidth,
        ),
      );
    } else {
      _closingVelocity = opening < 0 ? -opening / panelWidth : 0;
      close();
    }
  }

  /// A drag was cancelled: settle on whichever side is nearer.
  void dragCancel() => dragEnd(0);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final sign = Directionality.of(context) == TextDirection.ltr ? 1.0 : -1.0;
    Widget page = Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: DrawerPanel(
        content: content,
        atEnd: atEnd,
        onWidth: (width) => panelWidth = width,
        onDragStart: dragStart,
        onDragUpdate: (delta) => dragUpdate(delta * sign),
        onDragEnd: (velocity) => dragEnd(velocity * sign),
        onDragCancel: dragCancel,
      ),
    );
    if (theme case final theme?) page = Theme(data: theme, child: page);
    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Called on every tick. Both branches hold the same animation from one
    // tick to the next, so updating them is a comparison, and the movement
    // itself is paint.
    if (!_slides) return FadeTransition(opacity: animation, child: child);
    return DrawerSlide(progress: animation, atEnd: atEnd, child: child);
  }
}

/// The panel: the drawer's surface against its edge, and the drag that
/// closes it.
class DrawerPanel extends StatelessWidget {
  /// Creates the panel of a drawer.
  const DrawerPanel({
    required this.content,
    required this.atEnd,
    this.onWidth,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDragCancel,
    super.key,
  });

  /// What the panel shows.
  final ValueListenable<Widget?> content;

  /// Whether the panel sits against the end edge rather than the start.
  final bool atEnd;

  /// Told the panel's width whenever it is laid out.
  final ValueChanged<double>? onWidth;

  /// A drag began on the panel.
  final VoidCallback? onDragStart;

  /// The finger moved by this many logical pixels, positive rightwards.
  final ValueChanged<double>? onDragUpdate;

  /// The finger let go at this many logical pixels per second, positive
  /// rightwards.
  final ValueChanged<double>? onDragEnd;

  /// The drag was cancelled.
  final VoidCallback? onDragCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheet = theme.sheetTheme;
    final direction = Directionality.of(context);
    // The physical side the panel is on.
    final onRight = atEnd == (direction == TextDirection.ltr);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = drawerWidthFor(constraints.maxWidth);
        onWidth?.call(width);
        final edge = BorderSide(color: theme.colorScheme.border);
        final media = MediaQuery.of(context);

        // Square, as a sheet from a side is: the sheet theme's radius is for
        // the sheets that come from the top and the bottom.
        Widget panel = DecoratedBox(
          decoration: BoxDecoration(
            color: sheet.backgroundColor ?? theme.colorScheme.background,
          ),
          // A hairline where the panel meets the page, drawn over the
          // content's last point.
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              border: Border(
                left: onRight ? edge : BorderSide.none,
                right: onRight ? BorderSide.none : edge,
              ),
            ),
            // The content is inset from the screen's edge the panel is on,
            // and from nothing on the side that faces the page.
            child: MediaQuery(
              data: media.copyWith(
                padding: media.padding.copyWith(
                  left: onRight ? 0 : media.padding.left,
                  right: onRight ? media.padding.right : 0,
                ),
              ),
              child: ValueListenableBuilder<Widget?>(
                valueListenable: content,
                builder: (context, content, _) =>
                    content ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
        final shadows =
            sheet.shadows ?? theme.primaryDialogTheme.shadows ?? const [];
        if (shadows.isNotEmpty) {
          panel = DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: ShadowDecoration.box(shadows: shadows),
            child: panel,
          );
        }

        return Align(
          alignment: onRight ? Alignment.centerRight : Alignment.centerLeft,
          child: SizedBox(
            width: width,
            height: constraints.maxHeight,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                if (onDragUpdate != null)
                  HorizontalDragGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        HorizontalDragGestureRecognizer
                      >(
                        () => HorizontalDragGestureRecognizer(
                          debugOwner: this,
                          supportedDevices: drawerDragDevices,
                        ),
                        (recognizer) => recognizer
                          ..onStart = ((_) => onDragStart?.call())
                          ..onUpdate = ((details) =>
                              onDragUpdate?.call(details.primaryDelta!))
                          ..onEnd = ((details) =>
                              onDragEnd?.call(details.primaryVelocity!))
                          ..onCancel = onDragCancel,
                      ),
              },
              child: panel,
            ),
          ),
        );
      },
    );
  }
}

/// What a drawer looks like while an edge drag is pulling it out: the scrim
/// and the panel, both following [progress].
///
/// It is shown in the navigator's overlay, not as a route. Pushing a route
/// cancels every pointer that is down, the dragging finger included, so the
/// route is only pushed once the finger has let go.
class DrawerDragPreview extends StatelessWidget {
  /// Creates the preview of a drawer being dragged open.
  const DrawerDragPreview({
    required this.progress,
    required this.content,
    required this.atEnd,
    required this.onWidth,
    this.theme,
    super.key,
  });

  /// How far open the drawer is, from 0 to 1.
  final Animation<double> progress;

  /// What the panel shows.
  final ValueListenable<Widget?> content;

  /// Whether the panel sits against the end edge rather than the start.
  final bool atEnd;

  /// Told the panel's width whenever it is laid out.
  final ValueChanged<double> onWidth;

  /// The scaffold's theme, when it is not the overlay's own.
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final scrim = drawerScrimColor(theme ?? Theme.of(context));
    Widget preview = IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: progress,
            builder: (context, _) => ColoredBox(
              color: scrim.withValues(
                alpha: scrim.a * progress.value.clamp(0.0, 1.0),
              ),
            ),
          ),
          DrawerSlide(
            progress: progress,
            atEnd: atEnd,
            child: DrawerPanel(
              content: content,
              atEnd: atEnd,
              onWidth: onWidth,
            ),
          ),
        ],
      ),
    );
    if (theme case final theme?) preview = Theme(data: theme, child: preview);
    return preview;
  }
}

/// Paints its child moved off its edge by what is left of [progress].
///
/// The child fills the screen; the panel inside it is against one edge and
/// [drawerWidthFor] wide, so it is fully hidden one panel-width out.
class DrawerSlide extends SingleChildRenderObjectWidget {
  /// Creates a slide driven by [progress].
  const DrawerSlide({
    required this.progress,
    required this.atEnd,
    required super.child,
    super.key,
  });

  /// How far in the child is, from 0 (out of sight) to 1 (in place).
  final Animation<double> progress;

  /// Whether the child leaves towards the end edge rather than the start.
  final bool atEnd;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderDrawerSlide(
    progress: progress,
    atEnd: atEnd,
    textDirection: Directionality.of(context),
  );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDrawerSlide renderObject,
  ) {
    renderObject
      ..progress = progress
      ..atEnd = atEnd
      ..textDirection = Directionality.of(context);
  }
}

/// The render object of a [DrawerSlide].
class RenderDrawerSlide extends RenderProxyBox {
  /// Creates the render object of a [DrawerSlide].
  RenderDrawerSlide({
    required Animation<double> progress,
    required bool atEnd,
    required TextDirection textDirection,
  }) : _progress = progress,
       _atEnd = atEnd,
       _textDirection = textDirection;

  /// See [DrawerSlide.progress].
  Animation<double> get progress => _progress;
  Animation<double> _progress;
  set progress(Animation<double> value) {
    if (identical(value, _progress)) return;
    if (attached) _progress.removeListener(markNeedsPaint);
    _progress = value;
    if (attached) _progress.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  /// See [DrawerSlide.atEnd].
  bool get atEnd => _atEnd;
  bool _atEnd;
  set atEnd(bool value) {
    if (value == _atEnd) return;
    _atEnd = value;
    markNeedsPaint();
  }

  /// The direction that says which edge is the end.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _progress.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _progress.removeListener(markNeedsPaint);
    super.detach();
  }

  Offset get _shift {
    final hidden = 1 - _progress.value.clamp(0.0, 1.0);
    if (hidden == 0) return Offset.zero;
    final onRight = _atEnd == (_textDirection == TextDirection.ltr);
    // The panel's own width, so a dragged panel stays under the finger.
    final travel = drawerWidthFor(size.width) * hidden;
    return Offset(onRight ? travel : -travel, 0);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    context.paintChild(child, offset + _shift);
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final shift = _shift;
    transform.translateByDouble(shift.dx, shift.dy, 0, 1);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintOffset(
      offset: _shift,
      position: position,
      hitTest: (result, transformed) =>
          super.hitTestChildren(result, position: transformed),
    );
  }
}

/// A strip along one edge of a scaffold that opens its drawer when a finger
/// drags inwards from it.
class DrawerEdgeDragArea extends StatelessWidget {
  /// Creates the strip.
  const DrawerEdgeDragArea({
    required this.onUpdate,
    required this.onEnd,
    required this.onCancel,
    super.key,
  });

  /// The finger moved by this many logical pixels, positive rightwards.
  final ValueChanged<double> onUpdate;

  /// The finger let go at this many logical pixels per second, positive
  /// rightwards.
  final ValueChanged<double> onEnd;

  /// The drag was cancelled.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      // The strip lies over the page; taps and vertical scrolls in it still
      // belong to what is under it.
      behavior: HitTestBehavior.translucent,
      excludeFromSemantics: true,
      gestures: {
        HorizontalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
              HorizontalDragGestureRecognizer
            >(
              () => HorizontalDragGestureRecognizer(
                debugOwner: this,
                supportedDevices: drawerDragDevices,
              ),
              (recognizer) => recognizer
                ..onUpdate = ((details) => onUpdate(details.primaryDelta!))
                ..onEnd = ((details) => onEnd(details.primaryVelocity!))
                ..onCancel = onCancel,
            ),
      },
    );
  }
}
