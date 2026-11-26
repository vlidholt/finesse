import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';
import 'package:una/src/theme/motion.dart';

part 'stepper.g.theme.dart';

/// The theme of `Stepper`: every value the widget does not set itself.
///
/// [connectorSpring] is null by default and resolved from the theme's
/// motion when the stepper builds, so it follows `ThemeData(motion: ...)`
/// and the platform's reduced-motion setting.
@themeGen
@immutable
class StepperTheme with _$StepperTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const StepperTheme({
    bool canMerge = true,
    this.indicatorSize,
    this.indicatorColor,
    this.indicatorBorderColor,
    this.indicatorForegroundColor,
    this.activeColor,
    this.completeColor,
    this.completeForegroundColor,
    this.errorColor,
    this.connectorColor,
    this.connectorThickness,
    this.connectorGap,
    this.indicatorTextStyle,
    this.titleStyle,
    this.subtitleStyle,
    this.gap,
    this.spacing,
    this.contentPadding,
    this.connectorSpring,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The diameter of a step's circle.
  final double? indicatorSize;

  /// The fill of the circle of a step that is still to come.
  final Color? indicatorColor;

  /// The outline of the circle of a step that is still to come.
  final Color? indicatorBorderColor;

  /// The colour of the number, and of the title, of a step that is still
  /// to come.
  final Color? indicatorForegroundColor;

  /// The colour of the current step's ring and number, and of the part of
  /// a connector that is behind the current step. It is drawn on the page,
  /// so it is the scheme's `tint`.
  final Color? activeColor;

  /// The fill of the circle of a completed step.
  final Color? completeColor;

  /// The colour of the check on a completed step.
  final Color? completeForegroundColor;

  /// The colour of the ring, the mark and the title of a step in error.
  final Color? errorColor;

  /// The colour of the line between two steps.
  final Color? connectorColor;

  /// The thickness of the line between two steps, and of the current
  /// step's ring.
  final double? connectorThickness;

  /// The space left between a circle and the line.
  final double? connectorGap;

  /// The style of the number in a circle.
  final TextStyle? indicatorTextStyle;

  /// The style of a step's title.
  final TextStyle? titleStyle;

  /// The style of a step's subtitle.
  final TextStyle? subtitleStyle;

  /// The space between a circle and its title.
  final double? gap;

  /// The space between one step and the next in a vertical stepper.
  final double? spacing;

  /// The padding around the current step's content and its controls.
  final EdgeInsetsGeometry? contentPadding;

  /// The spring a connector fills on and a vertical step's content opens
  /// on. Null uses the theme motion's smooth spring.
  final MotionSpring? connectorSpring;

  /// Linearly interpolates between two themes.
  static StepperTheme? lerp(StepperTheme? a, StepperTheme? b, double t) =>
      _$StepperTheme.lerp(a, b, t);
}
