import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/animate.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A customizable linear progress indicator widget.
///
/// The [ProgressBar] widget displays a styled progress bar with
/// configurable colors, height, and border radius. It integrates with
/// [Theme] for consistent styling and uses Container-based implementation
/// instead of Material's LinearProgressIndicator.
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

  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.value == null) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: _kIndeterminateLinearDuration),
        vsync: this,
      )..repeat();
    }
    if (widget.valueColor != null) {
      widget.valueColor!.addListener(_handleColorChange);
    }
  }

  @override
  void didUpdateWidget(ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && oldWidget.value != null) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: _kIndeterminateLinearDuration),
        vsync: this,
      )..repeat();
    } else if (widget.value != null && oldWidget.value == null) {
      _controller?.dispose();
      _controller = null;
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
                    builder: (context, value, _) => DeterminateProgressBar(
                      value: value,
                      color: currentColor,
                      borderRadius: effectiveInnerBorderRadius,
                    ),
                  )
                : _IndeterminateProgressBar(
                    controller: _controller,
                    indeterminateLinearDuration: _kIndeterminateLinearDuration,
                    line1TailCurve: line1TailCurve,
                    line1HeadCurve: line1HeadCurve,
                    line2TailCurve: line2TailCurve,
                    line2HeadCurve: line2HeadCurve,
                    color: currentColor,
                    borderRadius: effectiveInnerBorderRadius,
                  ),
          ),
        ),
      ),
    );
  }
}

/// The indeterminate state of a [ProgressBar].
class _IndeterminateProgressBar extends StatelessWidget {
  const _IndeterminateProgressBar({
    required this.controller,
    required this.indeterminateLinearDuration,
    required this.line1TailCurve,
    required this.line1HeadCurve,
    required this.line2TailCurve,
    required this.line2HeadCurve,
    required this.color,
    required this.borderRadius,
  });

  /// Drives the animation. When null, the animation runs on its own.
  final AnimationController? controller;

  /// The length of one animation cycle, in milliseconds.
  final int indeterminateLinearDuration;

  /// Maps the cycle progress to the position of the first bar's start edge,
  /// as a fraction of the width.
  final Curve line1TailCurve;

  /// Maps the cycle progress to the position of the first bar's end edge, as a
  /// fraction of the width.
  final Curve line1HeadCurve;

  /// Maps the cycle progress to the position of the second bar's start edge,
  /// as a fraction of the width.
  final Curve line2TailCurve;

  /// Maps the cycle progress to the position of the second bar's end edge, as
  /// a fraction of the width.
  final Curve line2HeadCurve;

  /// The color of the bars.
  final Color color;

  /// The corner radius of the bars.
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final bar = Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
          ),
        );

        return Stack(
          children: [
            FinesseAnimate(
              controller: controller,
              onPlay: (controller) => controller.repeat(),
              effects: [
                CustomEffect(
                  duration: Duration(milliseconds: indeterminateLinearDuration),
                  curve: Curves.linear,
                  builder: (context, value, child) {
                    final start =
                        line1TailCurve.transform(value) * containerWidth;
                    final end =
                        line1HeadCurve.transform(value) * containerWidth;
                    final w = (end - start)
                        .clamp(0, double.infinity)
                        .toDouble();
                    if (w <= 0) {
                      return const SizedBox.shrink();
                    }
                    return PositionedDirectional(
                      start: start,
                      top: 0,
                      bottom: 0,
                      width: w,
                      child: child,
                    );
                  },
                ),
              ],
              child: bar,
            ),
            FinesseAnimate(
              controller: controller,
              onPlay: (controller) => controller.repeat(),
              effects: [
                CustomEffect(
                  duration: Duration(milliseconds: indeterminateLinearDuration),
                  curve: Curves.linear,
                  builder: (context, value, child) {
                    final start =
                        line2TailCurve.transform(value) * containerWidth;
                    final end =
                        line2HeadCurve.transform(value) * containerWidth;
                    final w = (end - start)
                        .clamp(0, double.infinity)
                        .toDouble();
                    if (w <= 0) {
                      return const SizedBox.shrink();
                    }
                    return PositionedDirectional(
                      start: start,
                      top: 0,
                      bottom: 0,
                      width: w,
                      child: child,
                    );
                  },
                ),
              ],
              child: bar,
            ),
          ],
        );
      },
    );
  }
}

/// {@template DeterminateProgressBar}
/// A widget that represents the determinate state of the progress bar.
/// {@endtemplate}
class DeterminateProgressBar extends StatelessWidget {
  /// {@macro DeterminateProgressBar}
  const DeterminateProgressBar({
    super.key,
    required this.value,
    required this.color,
    required this.borderRadius,
  });

  /// The filled fraction, from 0 to 1. Values outside that range are clamped.
  final double value;

  /// The color of the filled part.
  final Color color;

  /// The corner radius of the filled part.
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
