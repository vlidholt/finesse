import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/widgets.dart';

/// A customizable linear progress indicator widget.
///
/// The [ProgressBar] widget displays a styled progress bar with
/// configurable colors, height, and border radius. It integrates with
/// [Theme] for consistent styling. A determinate bar glides to a new
/// value on the theme's motion tokens; an indeterminate one is painted, not
/// rebuilt, for as long as it runs.
class ProgressBar extends StatefulWidget {
  /// Creates a progress bar widget with the specified properties.
  const ProgressBar({
    super.key,
    this.value,
    this.backgroundColor,
    this.color,
    this.valueColor,
    this.minHeight,
    this.semanticLabel,
    this.semanticValue,
    this.borderRadius,
    this.innerBorderRadius,
  });

  /// {@template ProgressBar.value}
  /// The progress value between 0.0 and 1.0.
  /// If null, displays an indeterminate progress animation.
  /// {@endtemplate}
  final double? value;

  /// {@template ProgressBar.backgroundColor}
  /// The background color of the progress bar.
  /// Defaults to the theme's secondary color if not specified.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template ProgressBar.color}
  /// The color of the progress indicator itself.
  /// Defaults to the theme's primary color if not specified; overridden by
  /// [valueColor] if set.
  /// {@endtemplate}
  final Color? color;

  /// {@template ProgressBar.valueColor}
  /// An animated color value for the progress indicator.
  /// Overrides [color] if provided; defaults to null (uses [color]).
  /// {@endtemplate}
  final Animation<Color?>? valueColor;

  /// {@template ProgressBar.minHeight}
  /// The minimum height of the progress bar.
  /// Defaults to 16 if not specified.
  /// {@endtemplate}
  final double? minHeight;

  /// {@template ProgressBar.semanticLabel}
  /// The accessibility label for the progress bar.
  /// Provides context to screen readers; defaults to null.
  /// {@endtemplate}
  final String? semanticLabel;

  /// {@template ProgressBar.semanticValue}
  /// The accessibility value for the progress bar (e.g., percentage).
  /// Provides current progress to screen readers; defaults to null.
  /// {@endtemplate}
  final String? semanticValue;

  /// {@template ProgressBar.borderRadius}
  /// The border radius of the progress bar's outer container.
  /// Defaults to a circular radius of 16 if not specified.
  /// {@endtemplate}
  final BorderRadius? borderRadius;

  /// {@template ProgressBar.innerBorderRadius}
  /// The border radius of the progress indicator itself.
  /// Defaults to zero (sharp edges) if not specified.
  /// {@endtemplate}
  final BorderRadius? innerBorderRadius;

  @override
  State<ProgressBar> createState() => _ProgressState();
}

class _ProgressState extends State<ProgressBar>
    with SingleTickerProviderStateMixin {
  static const int _kIndeterminateLinearDuration = 1800;

  static const Curve line1HeadCurve = Interval(
    0,
    750 / _kIndeterminateLinearDuration,
    curve: Cubic(0.2, 0, 0.8, 1),
  );

  static const Curve line1TailCurve = Interval(
    333 / _kIndeterminateLinearDuration,
    (333 + 750) / _kIndeterminateLinearDuration,
    curve: Cubic(0.4, 0, 1, 1),
  );

  static const Curve line2HeadCurve = Interval(
    1000 / _kIndeterminateLinearDuration,
    (1000 + 567) / _kIndeterminateLinearDuration,
    curve: Cubic(0, 0, 0.65, 1),
  );

  static const Curve line2TailCurve = Interval(
    1267 / _kIndeterminateLinearDuration,
    (1267 + 533) / _kIndeterminateLinearDuration,
    curve: Cubic(0.10, 0, 0.45, 1),
  );

  /// Drives the indeterminate bar. Made the first time the bar is
  /// indeterminate and kept: a single-ticker state can make only one.
  AnimationController? _controller;

  /// Runs the indeterminate loop while there is no value, and stops it
  /// while there is one.
  void _syncController() {
    if (widget.value == null) {
      (_controller ??= AnimationController(
        duration: const Duration(milliseconds: _kIndeterminateLinearDuration),
        vsync: this,
      )).repeat();
    } else {
      _controller?.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    _syncController();
    if (widget.valueColor != null) {
      widget.valueColor!.addListener(_handleColorChange);
    }
  }

  @override
  void didUpdateWidget(ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.value == null) != (oldWidget.value == null)) {
      _syncController();
    }
    if (widget.valueColor != oldWidget.valueColor) {
      oldWidget.valueColor?.removeListener(_handleColorChange);
      widget.valueColor?.addListener(_handleColorChange);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    widget.valueColor?.removeListener(_handleColorChange);
    super.dispose();
  }

  void _handleColorChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveMinHeight =
        widget.minHeight ?? theme.progressBarTheme.minHeight ?? 16.0;
    final effectiveColor =
        widget.color ??
        theme.progressBarTheme.color ??
        theme.colorScheme.primary;
    final currentColor = widget.valueColor?.value ?? effectiveColor;
    final effectiveBackgroundColor =
        widget.backgroundColor ??
        theme.progressBarTheme.backgroundColor ??
        theme.colorScheme.secondary;
    final effectiveBorderRadius =
        widget.borderRadius ??
        theme.progressBarTheme.borderRadius ??
        const BorderRadius.all(Radius.circular(16));
    final effectiveInnerBorderRadius =
        widget.innerBorderRadius ??
        theme.progressBarTheme.innerBorderRadius ??
        BorderRadius.zero;

    return Semantics(
      label: widget.semanticLabel,
      value: widget.semanticValue,
      child: SizedBox(
        width: double.infinity,
        height: effectiveMinHeight,
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: Container(
            width: double.infinity,
            height: effectiveMinHeight,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              borderRadius: effectiveInnerBorderRadius,
            ),
            child: widget.value != null
                // A new value is glided to rather than jumped to; the bar
                // starts on its first value without animating.
                ? SpringBuilder(
                    value: widget.value!.clamp(0, 1).toDouble(),
                    spring:
                        theme.progressBarTheme.spring ??
                        Motion.of(context).smooth,
                    builder: (context, value, _) => _DeterminateBar(
                      value: value,
                      color: currentColor,
                      borderRadius: effectiveInnerBorderRadius,
                    ),
                  )
                // It never stops, so it is painted in a layer of its own:
                // a frame of it builds and lays out nothing.
                : RepaintBoundary(
                    child: CustomPaint(
                      painter: _IndeterminateBarPainter(
                        progress: _controller!,
                        color: currentColor,
                        borderRadius: effectiveInnerBorderRadius,
                        textDirection: Directionality.of(context),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Paints the two lines of an indeterminate bar as they chase each other
/// across it, from the start edge to the end edge.
class _IndeterminateBarPainter extends CustomPainter {
  _IndeterminateBarPainter({
    required this.progress,
    required this.color,
    required this.borderRadius,
    required this.textDirection,
  }) : super(repaint: progress);

  /// Where one cycle has got to, from 0 to 1.
  final Animation<double> progress;

  final Color color;
  final BorderRadius borderRadius;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    void line(Curve tail, Curve head) {
      final t = progress.value;
      final start = tail.transform(t) * size.width;
      final width = head.transform(t) * size.width - start;
      if (width <= 0) return;
      final left = textDirection == TextDirection.ltr
          ? start
          : size.width - start - width;
      final rect = Rect.fromLTWH(left, 0, width, size.height);
      if (borderRadius == BorderRadius.zero) {
        canvas.drawRect(rect, paint);
      } else {
        canvas.drawRRect(borderRadius.toRRect(rect), paint);
      }
    }

    line(_ProgressState.line1TailCurve, _ProgressState.line1HeadCurve);
    line(_ProgressState.line2TailCurve, _ProgressState.line2HeadCurve);
  }

  @override
  bool shouldRepaint(_IndeterminateBarPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      borderRadius != oldDelegate.borderRadius ||
      textDirection != oldDelegate.textDirection;
}

/// The filled part of a determinate bar.
class _DeterminateBar extends StatelessWidget {
  const _DeterminateBar({
    required this.value,
    required this.color,
    required this.borderRadius,
  });

  /// The progress, from 0 to 1.
  final double value;

  final Color color;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0, 1).toDouble();
    return FractionallySizedBox(
      // Fills from the start edge, so the bar grows right-to-left in RTL.
      alignment: AlignmentDirectional.centerStart,
      widthFactor: clampedValue,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
