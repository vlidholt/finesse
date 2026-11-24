import 'dart:ui' as ui;

import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Applies [data] to [child] and, when it changes, fades from what was on
/// screen to the new look.
///
/// This is how `FinesseApp` moves between themes — light to dark, one
/// palette to another. The new theme is applied **at once**, in one build,
/// and a picture of the last frame painted under the old one is laid over
/// the result and faded out. On screen that is the same cross-fade as
/// interpolating every colour, at a fraction of the cost: `AnimatedTheme`
/// builds a new [ThemeData] on every frame of its 200 ms and with it
/// rebuilds, lays out and paints every widget that reads the theme, which
/// is every widget — a dozen full rebuilds of the app in a row, each of
/// them several frames long on a phone.
///
/// Two things are not faded, and switch at once:
///
/// * a change that arrives while the app is being resized, so that the
///   picture no longer fits (a form factor following the window width);
/// * changes that follow each other closely — a slider in a theme editor
///   being dragged. The first of them fades; while they keep coming the
///   theme follows the pointer directly.
///
/// With `MediaQuery.disableAnimations` nothing fades.
class CrossFadeTheme extends StatefulWidget {
  /// Creates a theme that cross-fades when [data] changes.
  const CrossFadeTheme({
    required this.data,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.linear,
    super.key,
  });

  /// The theme for [child].
  final ThemeData data;

  /// How long the previous look takes to fade away.
  final Duration duration;

  /// The curve of the fade.
  final Curve curve;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<CrossFadeTheme> createState() => _CrossFadeThemeState();
}

class _CrossFadeThemeState extends State<CrossFadeTheme>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..addStatusListener(_onStatus);

  final _fadeKey = GlobalKey();

  /// When the theme last changed, on the frame clock.
  Duration? _lastChange;

  /// How many fades have been started; a later one overtakes an earlier
  /// one that has not begun.
  int _fades = 0;

  /// A second change this soon after the last one is a drag, not a switch.
  static const _settle = Duration(milliseconds: 350);

  _RenderThemeFade? get _fade =>
      _fadeKey.currentContext?.findRenderObject() as _RenderThemeFade?;

  void _onStatus(AnimationStatus status) {
    if (status.isCompleted) _fade?.snapshot = null;
  }

  @override
  void didUpdateWidget(CrossFadeTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (widget.data == oldWidget.data) return;

    final now = SchedulerBinding.instance.currentSystemFrameTimeStamp;
    final last = _lastChange;
    _lastChange = now;
    final streaming = last != null && now - last < _settle;
    final fade = _fade;
    if (fade == null ||
        streaming ||
        widget.duration <= Duration.zero ||
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false)) {
      return;
    }
    // What is on screen now — the frame painted under the old theme, with
    // whatever is left of an earlier fade — before this build replaces it.
    final snapshot = fade.capture(
      View.maybeOf(context)?.devicePixelRatio ?? 1,
    );
    if (snapshot == null) return;
    fade.snapshot = snapshot;
    // The fade starts with the *next* frame. This one builds the whole app
    // under the new theme and is the longest frame the app has; an
    // animation started in it is timed from its beginning, and on a phone
    // would be over before the frame is on screen.
    _controller.value = 0;
    final serial = ++_fades;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && serial == _fades) _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ThemeFade(
      key: _fadeKey,
      progress: _controller,
      curve: widget.curve,
      // A layer of its own, so a frame of the fade moves no paint but the
      // picture's.
      child: RepaintBoundary(
        child: Theme(data: widget.data, child: widget.child),
      ),
    );
  }
}

class _ThemeFade extends SingleChildRenderObjectWidget {
  const _ThemeFade({
    required this.progress,
    required this.curve,
    super.child,
    super.key,
  });

  /// How far the fade has come: the picture is all there at 0, gone at 1.
  final Animation<double> progress;
  final Curve curve;

  @override
  _RenderThemeFade createRenderObject(BuildContext context) =>
      _RenderThemeFade(progress, curve);

  @override
  void updateRenderObject(BuildContext context, _RenderThemeFade renderObject) {
    renderObject
      ..progress = progress
      ..curve = curve;
  }
}

/// Paints its child and, over it, a fading picture of an earlier frame.
///
/// A repaint boundary, so that the picture can be taken from its layer:
/// child and overlay together, which keeps a fade that is interrupted by
/// another one continuous.
class _RenderThemeFade extends RenderProxyBox {
  _RenderThemeFade(this._progress, this.curve);

  /// The curve [progress] is read through.
  Curve curve;

  Animation<double> _progress;

  /// How far the fade has come, from 0 to 1.
  Animation<double> get progress => _progress;
  set progress(Animation<double> value) {
    if (identical(value, _progress)) return;
    if (attached) {
      _progress.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _progress = value;
    markNeedsPaint();
  }

  ui.Image? _snapshot;
  Size _snapshotSize = Size.zero;

  /// The picture fading out over the child; this object owns it.
  ui.Image? get snapshot => _snapshot;
  set snapshot(ui.Image? value) {
    if (identical(value, _snapshot)) return;
    _snapshot?.dispose();
    _snapshot = value;
    _snapshotSize = size;
    markNeedsPaint();
  }

  /// A picture of what this object last painted, or null when it has not
  /// painted yet.
  ///
  /// Taken from the layer the last frame was composited from, so it is
  /// valid in the middle of a build, before anything has been painted
  /// again.
  ui.Image? capture(double pixelRatio) {
    final layer = this.layer;
    if (!attached || !hasSize || size.isEmpty || layer is! OffsetLayer) {
      return null;
    }
    return layer.toImageSync(Offset.zero & size, pixelRatio: pixelRatio);
  }

  @override
  bool get isRepaintBoundary => true;

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

  @override
  void dispose() {
    _snapshot?.dispose();
    _snapshot = null;
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final snapshot = _snapshot;
    if (snapshot == null) return;
    final opacity = 1 - curve.transform(_progress.value).clamp(0.0, 1.0);
    // A picture of another size is a picture of another layout: the window
    // was resized under the fade.
    if (opacity <= 0 || _snapshotSize != size) return;
    context.canvas.drawImageRect(
      snapshot,
      Rect.fromLTWH(
        0,
        0,
        snapshot.width.toDouble(),
        snapshot.height.toDouble(),
      ),
      offset & size,
      Paint()
        ..color = Color.fromRGBO(0, 0, 0, opacity)
        ..filterQuality = FilterQuality.low,
    );
  }
}
