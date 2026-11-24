import 'dart:math' as math;

import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:flutter/widgets.dart';

/// {@template Spinner}
/// An indeterminate circular loading indicator.
///
/// Mirrors shadcn/ui's `Spinner`. Unlike `ProgressBar`, which is a linear
/// bar, this is the small inline spinner you put inside a button or next to a
/// label while an action is in flight.
///
/// ```dart
/// Button(
///   onPressed: submitting ? null : submit,
///   leading: submitting ? const Spinner(size: 16) : null,
///   child: const Text('Save'),
/// )
/// ```
/// {@endtemplate}
class Spinner extends StatefulWidget {
  /// {@macro Spinner}
  const Spinner({
    super.key,
    this.size,
    this.color,
    this.trackColor,
    this.strokeWidth,
    this.duration,
    this.semanticLabel,
  });

  /// {@template Spinner.size}
  /// The diameter of the spinner, defaults to 16.
  /// {@endtemplate}
  final double? size;

  /// {@template Spinner.color}
  /// The color of the moving arc.
  /// {@endtemplate}
  final Color? color;

  /// {@template Spinner.trackColor}
  /// The color of the ring behind the arc.
  ///
  /// Pass a fully transparent color for an arc with no visible track.
  /// {@endtemplate}
  final Color? trackColor;

  /// {@template Spinner.strokeWidth}
  /// The thickness of the arc, defaults to 2.
  /// {@endtemplate}
  final double? strokeWidth;

  /// {@template Spinner.duration}
  /// The duration of one full rotation, defaults to 900ms.
  /// {@endtemplate}
  final Duration? duration;

  /// The accessible name announced while the spinner is visible.
  final String? semanticLabel;

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDuration();
  }

  @override
  void didUpdateWidget(Spinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) _syncDuration();
  }

  void _syncDuration() {
    _controller
      ..duration =
          widget.duration ??
          Theme.of(context).spinnerTheme.duration ??
          const Duration(milliseconds: 900)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final spinnerTheme = theme.spinnerTheme;

    final effectiveSize = widget.size ?? spinnerTheme.size ?? 16.0;
    // shadcn's spinner is an icon in `text-current`: inside a button it spins
    // in the button's own content colour. The ambient IconTheme carries that,
    // so it sits between the explicit overrides and the primary fallback.
    final effectiveColor =
        widget.color ??
        spinnerTheme.color ??
        IconTheme.of(context).color ??
        theme.colorScheme.primary;
    final effectiveTrackColor =
        widget.trackColor ??
        spinnerTheme.trackColor ??
        effectiveColor.withValues(alpha: .2);
    final effectiveStrokeWidth =
        widget.strokeWidth ?? spinnerTheme.strokeWidth ?? 2.0;

    Widget spinner = SizedBox.square(
      dimension: effectiveSize,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _SpinnerPainter(
                progress: _controller.value,
                color: effectiveColor,
                trackColor: effectiveTrackColor,
                strokeWidth: effectiveStrokeWidth,
              ),
            );
          },
        ),
      ),
    );

    if (widget.semanticLabel != null) {
      spinner = Semantics(
        label: widget.semanticLabel,
        liveRegion: true,
        child: spinner,
      );
    }
    return spinner;
  }
}

/// Paints the spinner.
///
/// Hand-painted rather than wrapping `CircularProgressIndicator` because
/// nothing under `lib/` is allowed to import `material.dart`.
class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  /// How much of the circle the moving arc covers.
  static const _sweep = math.pi * 0.6;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = strokeWidth / 2;
    final arcRect = rect.deflate(inset);

    if (trackColor.a > 0) {
      canvas.drawCircle(
        rect.center,
        (math.min(size.width, size.height) / 2) - inset,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = trackColor,
      );
    }

    canvas.drawArc(
      arcRect,
      (progress * 2 * math.pi) - (math.pi / 2),
      _sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
