import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:una/src/components/ring_painter.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/debug_check.dart';
import 'package:una/src/utils/progress_semantics.dart';
import 'package:una/src/utils/spring.dart';

/// A ring that fills as something progresses: an upload, a quota, a goal —
/// the circular counterpart of `ProgressBar`.
///
/// ```dart
/// ProgressRing(
///   value: uploaded / total,
///   semanticLabel: 'Uploading',
///   child: Text('${(uploaded / total * 100).round()}%'),
/// )
/// ```
///
/// [value] runs from 0 to 1 and eases to each new value on the theme's
/// smooth spring. A null [value] spins instead: progress of unknown length,
/// at any size and with a [child] in the middle. (`Spinner` stays the small
/// inline indicator for a button or a line of text.)
///
/// With a [sweepAngle] of less than a full turn the ring is a gauge: an
/// open arc, its gap at the bottom.
///
/// ```dart
/// ProgressRing(
///   value: .72,
///   sweepAngle: math.pi * 1.5,
///   size: 96,
///   child: const Text('72'),
/// )
/// ```
///
/// The arc takes the progress bar's colour, the track its track colour and
/// a new value its spring, so the two read as one family.
class ProgressRing extends StatefulWidget {
  /// Creates a progress ring.
  const ProgressRing({
    required this.value,
    this.size,
    this.strokeWidth,
    this.color,
    this.trackColor,
    this.child,
    this.sweepAngle = math.pi * 2,
    this.semanticLabel,
    this.semanticValue,
    super.key,
  }) : assert(
         sweepAngle > 0 && sweepAngle <= math.pi * 2,
         'sweepAngle is between 0 and a full turn',
       );

  /// The progress, from 0 to 1; values outside are clamped. Null spins.
  final double? value;

  /// The ring's diameter. Defaults to 40.
  final double? size;

  /// The thickness of the ring. Defaults to a tenth of [size], between 2
  /// and 6.
  final double? strokeWidth;

  /// The colour of the arc. Defaults to the progress bar theme's.
  final Color? color;

  /// The colour of the track behind the arc. Defaults to the progress bar
  /// theme's `trackColor`; pass a transparent colour for none.
  final Color? trackColor;

  /// A widget centred in the ring: a percentage, an icon.
  final Widget? child;

  /// How far round the ring goes, in radians. A full turn by default; less
  /// makes a gauge, open at the bottom.
  final double sweepAngle;

  /// What the progress is of, for assistive technology.
  final String? semanticLabel;

  /// The progress as assistive technology reads it. Defaults to [value] as
  /// a percentage.
  final String? semanticValue;

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with TickerProviderStateMixin {
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _value = SpringController(
    vsync: this,
    value: _clamped(widget.value),
  );
  late final _repaint = Listenable.merge([_spin, _value.animation]);

  static double _clamped(double? value) => (value ?? 0).clamp(0.0, 1.0);

  bool get _spinning => widget.value == null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _spin.duration =
        Theme.of(context).spinnerTheme.duration ??
        const Duration(milliseconds: 900);
    _syncSpin();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final value = widget.value;
      if (value == null) {
        _syncSpin();
      } else if (oldWidget.value == null) {
        // Out of the spin there is no arc to grow from.
        _syncSpin();
        _value.jumpTo(_clamped(value));
      } else {
        // The bar's spring, so the two read as one family.
        _value.animateTo(
          _clamped(value),
          spring:
              Theme.of(context).progressBarTheme.spring ??
              Motion.of(context).smooth,
        );
      }
    }
  }

  void _syncSpin() {
    if (_spinning) {
      if (!_spin.isAnimating) _spin.repeat();
    } else if (_spin.isAnimating) {
      _spin
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _value.dispose();
    super.dispose();
  }

  /// Where the track starts: the top for a closed ring, and for a gauge the
  /// point that leaves its gap centred at the bottom.
  double get _trackStart => widget.sweepAngle >= math.pi * 2
      ? -math.pi / 2
      : -math.pi / 2 - widget.sweepAngle / 2;

  ({double start, double sweep}) _arc() {
    if (_spinning) {
      // The spinner's arc, kept inside a gauge's sweep by its own length.
      final sweep = math.min(math.pi * .6, widget.sweepAngle);
      return (
        start: _trackStart + _spin.value * math.pi * 2,
        sweep: sweep,
      );
    }
    return (
      start: _trackStart,
      sweep: widget.sweepAngle * _value.value.clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final bar = theme.progressBarTheme;
    final size = widget.size ?? 40.0;
    final strokeWidth = widget.strokeWidth ?? (size / 10).clamp(2.0, 6.0);
    final value = widget.value;

    return progressSemantics(
      determinate: value != null,
      label: widget.semanticLabel,
      value:
          widget.semanticValue ??
          (value == null ? null : '${(_clamped(value) * 100).round()}%'),
      // A spinner with a name is news; a percentage is read on demand.
      liveRegion: value == null && widget.semanticLabel != null,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Painted, not built: the arc follows the spring and the spin
            // in a layer of its own.
            RepaintBoundary(
              child: CustomPaint(
                painter: RingPainter(
                  color: widget.color ?? bar.color ?? theme.colorScheme.tint,
                  trackColor:
                      widget.trackColor ??
                      bar.trackColor ??
                      theme.colorScheme.muted,
                  strokeWidth: strokeWidth,
                  trackStart: _trackStart,
                  trackSweep: widget.sweepAngle,
                  arc: _arc,
                  repaint: _repaint,
                ),
              ),
            ),
            if (widget.child != null)
              Padding(
                padding: EdgeInsets.all(strokeWidth * 2),
                child: Center(
                  child: DefaultTextStyle.merge(
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.foreground,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    textAlign: TextAlign.center,
                    child: IconTheme.merge(
                      data: IconThemeData(size: size * .4),
                      child: widget.child!,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
