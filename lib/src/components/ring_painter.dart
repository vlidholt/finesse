import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Paints a ring: a track and, over it, an arc with round ends.
///
/// The arc painter `Spinner` and `ProgressRing` share. Hand-painted rather
/// than a wrapped `CircularProgressIndicator` because nothing under `lib/`
/// may import `material.dart`.
///
/// Angles are in radians, clockwise from three o'clock, as `Canvas.drawArc`
/// takes them. The ring is inscribed in the smaller side of the box and
/// centred in it.
class RingPainter extends CustomPainter {
  /// Creates a painter of one ring. [arc] is asked at paint time, so a
  /// painter given a [repaint] listenable can follow an animation without
  /// being rebuilt.
  RingPainter({
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    required this.arc,
    this.trackStart = 0,
    this.trackSweep = math.pi * 2,
    super.repaint,
  });

  /// The colour of the arc.
  final Color color;

  /// The colour of the track. Fully transparent paints none.
  final Color trackColor;

  /// The thickness of track and arc.
  final double strokeWidth;

  /// Where the track starts.
  final double trackStart;

  /// How far round the track goes; a full turn for a closed ring.
  final double trackSweep;

  /// The arc to paint now: where it starts and how far it goes.
  final ({double start, double sweep}) Function() arc;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (side - strokeWidth) / 2,
    );
    if (rect.width <= 0) return;

    if (trackColor.a > 0) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = trackColor;
      if (trackSweep >= math.pi * 2) {
        canvas.drawCircle(rect.center, rect.width / 2, paint);
      } else {
        canvas.drawArc(
          rect,
          trackStart,
          trackSweep,
          false,
          paint..strokeCap = StrokeCap.round,
        );
      }
    }

    final (:start, :sweep) = arc();
    // A zero sweep with a round cap is a dot; nothing has happened yet, so
    // nothing is drawn.
    if (sweep <= 0) return;
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.trackStart != trackStart ||
      oldDelegate.trackSweep != trackSweep ||
      oldDelegate.arc != arc;
}
