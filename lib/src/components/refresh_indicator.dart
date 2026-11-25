import 'dart:async';
import 'dart:math' as math;

import 'package:finesse/src/components/ring_painter.dart';
import 'package:finesse/src/i18n/localizations_delegate.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/haptics.dart';
import 'package:finesse/src/utils/pop_in.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Pull a list down past its top to refresh it.
///
/// ```dart
/// RefreshIndicator(
///   onRefresh: () => feed.reload(),
///   child: ListView.builder(
///     physics: const AlwaysScrollableScrollPhysics(),
///     itemCount: posts.length,
///     itemBuilder: (context, index) => PostTile(posts[index]),
///   ),
/// )
/// ```
///
/// A small circle comes down from the top edge as the list is pulled, its
/// ring filling with the pull. Past [triggerDistance] it pops — with a tap
/// of haptic feedback on a touch screen — and letting go there calls
/// [onRefresh]: the circle settles just under the edge and spins until the
/// returned future completes, then shrinks away. Letting go sooner sends it
/// back.
///
/// It works with both kinds of scroll physics: a list that stops dead at
/// its top (Android) reports the pull as overscroll, and one that bounces
/// (iOS) is followed by how far its content has been dragged past the top.
/// The list has to be scrollable for either to happen, so a list that may
/// be shorter than the screen takes `AlwaysScrollableScrollPhysics`.
///
/// A mouse wheel cannot pull; a trackpad can. Give desktop users a button
/// or a shortcut and call [RefreshIndicatorState.show] from it:
///
/// ```dart
/// final refreshKey = GlobalKey<RefreshIndicatorState>();
///
/// IconButton.ghost(
///   icon: const PhosphorIcon(PhosphorIconsRegular.arrowClockwise),
///   onPressed: () => refreshKey.currentState?.show(),
/// )
/// ```
///
/// The circle starts [edgeOffset] below the top of this widget — by default
/// the top `MediaQuery` padding, so under a `Scaffold`'s app bar it comes
/// out from beneath the bar.
///
/// Only a vertical scroll view that starts at the top is followed; a
/// reversed list has no top to pull.
class RefreshIndicator extends StatefulWidget {
  /// Creates a refresh indicator around a scrollable [child].
  const RefreshIndicator({
    required this.child,
    required this.onRefresh,
    this.triggerDistance,
    this.edgeOffset,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.color,
    this.semanticLabel,
    super.key,
  });

  /// The scrollable to refresh, or a widget that contains it.
  final Widget child;

  /// Called when the list has been pulled far enough and let go, and by
  /// [RefreshIndicatorState.show]. The indicator spins until the future
  /// completes, with a value or an error.
  final Future<void> Function() onRefresh;

  /// How far the list has to be pulled before letting go refreshes, in
  /// logical pixels of the finger's travel. Defaults to the theme's, 80.
  final double? triggerDistance;

  /// Where the circle comes from, as a distance below the top of this
  /// widget. Defaults to the top `MediaQuery` padding: the status bar, or
  /// an app bar a `Scaffold` lays over its body.
  final double? edgeOffset;

  /// Which scroll notifications are followed. The default takes those of
  /// the nearest scrollable under [child] and ignores nested ones.
  final ScrollNotificationPredicate notificationPredicate;

  /// The colour of the ring. Defaults to the theme's tint.
  final Color? color;

  /// What assistive technology announces while refreshing. Defaults to the
  /// localized "Refreshing".
  final String? semanticLabel;

  @override
  State<RefreshIndicator> createState() => RefreshIndicatorState();
}

enum _Mode {
  /// Nothing showing.
  idle,

  /// Following a pull that has not reached the trigger.
  drag,

  /// Following a pull past the trigger: letting go refreshes.
  armed,

  /// Let go too soon; going back.
  cancel,

  /// Resting under the edge, spinning, waiting for the future.
  refresh,

  /// The future completed; shrinking away.
  done,
}

/// The state of a [RefreshIndicator]: [show] starts a refresh from code.
class RefreshIndicatorState extends State<RefreshIndicator>
    with TickerProviderStateMixin {
  /// A bouncing list moves its content about half as far as the finger, so
  /// what it reports is scaled to compare with a finger's travel.
  static const _bounceGain = 1.6;

  /// How much of the circle the ring's arc covers once the pull is armed,
  /// and while it spins.
  static const _arcSweep = math.pi * 1.5;

  _Mode _mode = _Mode.idle;

  /// The pull, in logical pixels of the finger's travel.
  double _pull = 0;

  /// Whether the pull under way is a finger's: only that one gets haptics.
  bool _touch = false;

  /// The times the pull has become armed, for the pop.
  int _armings = 0;

  /// The angle the arc had when it started to spin.
  double _spinBase = 0;

  Completer<void>? _pending;

  /// The pull as a fraction of the trigger distance: 0 hidden, 1 at the
  /// resting place, more while pulled further.
  late final _position = SpringController(vsync: this);

  /// 0 shown, 1 shrunk away.
  late final _out = AnimationController(vsync: this);

  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final _frame = Listenable.merge([_position.animation, _out]);
  late final _ringFrame = Listenable.merge([_position.animation, _spin]);

  double get _trigger =>
      widget.triggerDistance ??
      Theme.of(context).refreshIndicatorTheme.triggerDistance ??
      80;

  bool get _following => _mode == _Mode.drag || _mode == _Mode.armed;

  @override
  void dispose() {
    _position.dispose();
    _out.dispose();
    _spin.dispose();
    super.dispose();
  }

  /// Shows the indicator and calls `onRefresh`, as a pull would: for a
  /// refresh button, a keyboard shortcut, or a first load.
  ///
  /// The future completes when the refresh has finished and the indicator
  /// has started to leave. Called while a refresh is under way, it returns
  /// that refresh's future and starts no second one.
  Future<void> show() {
    if (_mode == _Mode.refresh || _mode == _Mode.done) {
      return _pending?.future ?? Future<void>.value();
    }
    final motion = Motion.of(context);
    _position.jumpTo(1);
    // It grows in at the resting place: the leaving animation, backwards.
    _out
      ..duration = motion.normal
      ..value = 1
      ..animateTo(0, curve: motion.emphasized);
    _spinBase = -math.pi / 2;
    return _refresh();
  }

  Future<void> _refresh() {
    final pending = _pending = Completer<void>();
    setState(() => _mode = _Mode.refresh);
    _spin.repeat();
    Future<void> run() async {
      try {
        await widget.onRefresh();
      } on Object catch (error, stack) {
        // The indicator has nobody to hand the error to; it must still
        // leave.
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'finesse',
            context: ErrorDescription('while refreshing'),
          ),
        );
      } finally {
        if (mounted && identical(_pending, pending)) _finish();
        pending.complete();
      }
    }

    unawaited(run());
    return pending.future;
  }

  void _finish() {
    final motion = Motion.of(context);
    setState(() => _mode = _Mode.done);
    _out
      ..duration = motion.fast
      ..forward(from: 0).whenCompleteOrCancel(() {
        if (!mounted || _mode != _Mode.done) return;
        _reset();
      });
  }

  void _reset() {
    _spin
      ..stop()
      ..value = 0;
    _position.jumpTo(0);
    _out.value = 0;
    _pull = 0;
    _pending = null;
    setState(() => _mode = _Mode.idle);
  }

  // --- Following the scroll view ------------------------------------------

  bool _handleScroll(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) return false;
    final metrics = notification.metrics;
    if (metrics.axisDirection != AxisDirection.down) return false;

    final atTop = metrics.extentBefore == 0;
    final dragged = switch (notification) {
      ScrollStartNotification(:final dragDetails) => dragDetails != null,
      ScrollUpdateNotification(:final dragDetails) => dragDetails != null,
      OverscrollNotification(:final dragDetails) => dragDetails != null,
      _ => false,
    };

    if (_mode == _Mode.idle) {
      // A drag that starts at the top, or one that reaches it.
      if (dragged && atTop && notification is! ScrollEndNotification) {
        _pull = 0;
        _out.value = 0;
        _position.jumpTo(0);
        setState(() => _mode = _Mode.drag);
      } else {
        return false;
      }
    }
    if (!_following) return false;

    switch (notification) {
      case ScrollUpdateNotification(:final scrollDelta, :final dragDetails):
        if (metrics.extentBefore > 0) {
          // Scrolled into the content: the pull is over.
          _cancel();
        } else if (dragDetails == null && _mode == _Mode.armed) {
          // Let go while armed. Asked before the content's first step
          // home is counted, which would take a pull let go just past the
          // trigger back under it.
          _release();
        } else {
          // A bouncing list: its content is past the top, and moves about
          // half as far as the finger. Followed on the way back too, so
          // the circle goes home with the content.
          _setPull(_pull - (scrollDelta ?? 0) * _bounceGain);
        }
      case OverscrollNotification(:final overscroll):
        // A clamping list: the finger's own travel past the top.
        _setPull(_pull - overscroll);
      case ScrollEndNotification():
        _release();
      default:
        break;
    }
    return false;
  }

  bool _handleOverscrollIndicator(OverscrollIndicatorNotification n) {
    // The pull is this widget's to show: no glow and no stretch at the top
    // while it is followed.
    if (n.depth != 0 || !n.leading || !_following) return false;
    n.disallowIndicator();
    return true;
  }

  void _setPull(double pull) {
    _pull = math.max(0, pull);
    _position.jumpTo(_pull / _trigger);
    final armed = _pull >= _trigger;
    if (armed && _mode == _Mode.drag) {
      if (_touch) Haptics.impact(context, HapticImpact.medium);
      setState(() {
        _mode = _Mode.armed;
        _armings++;
      });
    } else if (!armed && _mode == _Mode.armed) {
      setState(() => _mode = _Mode.drag);
    }
  }

  void _release() {
    if (_mode == _Mode.armed) {
      _spinBase = _arcStart(_position.value);
      _position.animateTo(1, spring: Motion.of(context).snappy);
      _refresh();
    } else if (_mode == _Mode.drag) {
      _cancel();
    }
  }

  void _cancel() {
    // An ordinary scroll that began at the top: nothing was ever shown.
    if (_position.value <= 0) return _reset();
    setState(() => _mode = _Mode.cancel);
    _position
        .animateTo(0, spring: Motion.of(context).snappy)
        .whenCompleteOrCancel(() {
          if (!mounted || _mode != _Mode.cancel) return;
          _reset();
        });
  }

  // --- Painting ------------------------------------------------------------

  /// The angle the arc starts at for a pull of [t]: it turns as it fills.
  double _arcStart(double t) => -math.pi / 2 + math.min(t, 1.5) * math.pi;

  ({double start, double sweep}) _arc() {
    if (_mode == _Mode.refresh || _mode == _Mode.done) {
      return (
        start: _spinBase + _spin.value * math.pi * 2,
        sweep: _arcSweep,
      );
    }
    final t = _position.value;
    return (start: _arcStart(t), sweep: _arcSweep * t.clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => _touch = switch (event.kind) {
        PointerDeviceKind.mouse || PointerDeviceKind.trackpad => false,
        _ => true,
      },
      // A trackpad's two-finger scroll is not a pointer going down.
      onPointerPanZoomStart: (_) => _touch = false,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: _handleOverscrollIndicator,
          child: Stack(
            children: [
              widget.child,
              // Nothing is built for the indicator at rest.
              if (_mode != _Mode.idle)
                Positioned.fill(child: IgnorePointer(child: _indicator())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _indicator() {
    final theme = Theme.of(context);
    final refresh = theme.refreshIndicatorTheme;
    final motion = Motion.of(context);
    final size = refresh.size ?? 40;
    final displacement = refresh.displacement ?? 16;
    final edge = widget.edgeOffset ?? MediaQuery.paddingOf(context).top;
    final refreshing = _mode == _Mode.refresh;

    final circle = PopOnChange(
      value: _armings,
      child: DecoratedBox(
        decoration: ShadowDecoration.box(
          color: refresh.backgroundColor ?? theme.colorScheme.popover,
          shape: BoxShape.circle,
          border: Border.all(
            color: refresh.borderColor ?? theme.colorScheme.border,
          ),
          shadows: theme.popoverTheme.shadows ?? const [],
        ),
        child: SizedBox.square(
          dimension: size,
          child: Padding(
            padding: EdgeInsets.all(size * .25),
            // The ring follows the pull and the spin in paint.
            child: RepaintBoundary(
              child: CustomPaint(
                painter: RingPainter(
                  color:
                      widget.color ?? refresh.color ?? theme.colorScheme.tint,
                  trackColor: const Color(0x00000000),
                  strokeWidth: refresh.strokeWidth ?? 2.5,
                  arc: _arc,
                  repaint: _ringFrame,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return ClipRect(
      child: AnimatedBuilder(
        animation: _frame,
        builder: (context, child) {
          final t = math.max(0, _position.value).toDouble();
          // Up to the trigger the circle comes down in step with the pull;
          // past it, it gives less and less.
          final over = math.max(0, t - 1);
          final travel =
              (size + displacement) * math.min(t, 1) +
              size * .6 * (1 - 1 / (1 + over * 1.2));
          final shown = 1 - _out.value;
          // With reduced motion nothing travels or grows: it fades in at
          // its resting place.
          final top = motion.reduced
              ? edge + displacement
              : edge - size + travel;
          final opacity = motion.reduced
              ? (t.clamp(0.0, 1.0) * shown)
              : ((t / .5).clamp(0.0, 1.0) * shown);
          final scale = motion.reduced
              ? 1.0
              : (.7 + .3 * (t / .8).clamp(0.0, 1.0)) * shown;
          return Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: Offset(0, top),
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Transform.scale(scale: scale, child: child),
              ),
            ),
          );
        },
        child: Semantics(
          container: true,
          liveRegion: refreshing,
          label: refreshing
              ? widget.semanticLabel ??
                    FinesseLocalizations.of(context).refreshIndicator.refreshing
              : null,
          child: circle,
        ),
      ),
    );
  }
}
