// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stepper.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StepperTheme {
  bool get canMerge => true;

  static StepperTheme? lerp(StepperTheme? a, StepperTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return StepperTheme(
      indicatorSize: lerpDouble$(a.indicatorSize, b.indicatorSize, t),
      indicatorColor: Color.lerp(a.indicatorColor, b.indicatorColor, t),
      indicatorBorderColor: Color.lerp(
        a.indicatorBorderColor,
        b.indicatorBorderColor,
        t,
      ),
      indicatorForegroundColor: Color.lerp(
        a.indicatorForegroundColor,
        b.indicatorForegroundColor,
        t,
      ),
      activeColor: Color.lerp(a.activeColor, b.activeColor, t),
      completeColor: Color.lerp(a.completeColor, b.completeColor, t),
      completeForegroundColor: Color.lerp(
        a.completeForegroundColor,
        b.completeForegroundColor,
        t,
      ),
      errorColor: Color.lerp(a.errorColor, b.errorColor, t),
      connectorColor: Color.lerp(a.connectorColor, b.connectorColor, t),
      connectorThickness: lerpDouble$(
        a.connectorThickness,
        b.connectorThickness,
        t,
      ),
      connectorGap: lerpDouble$(a.connectorGap, b.connectorGap, t),
      indicatorTextStyle: TextStyle.lerp(
        a.indicatorTextStyle,
        b.indicatorTextStyle,
        t,
      ),
      titleStyle: TextStyle.lerp(a.titleStyle, b.titleStyle, t),
      subtitleStyle: TextStyle.lerp(a.subtitleStyle, b.subtitleStyle, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      contentPadding: EdgeInsetsGeometry.lerp(
        a.contentPadding,
        b.contentPadding,
        t,
      ),
      connectorSpring: t < 0.5 ? a.connectorSpring : b.connectorSpring,
    );
  }

  StepperTheme copyWith({
    double? indicatorSize,
    Color? indicatorColor,
    Color? indicatorBorderColor,
    Color? indicatorForegroundColor,
    Color? activeColor,
    Color? completeColor,
    Color? completeForegroundColor,
    Color? errorColor,
    Color? connectorColor,
    double? connectorThickness,
    double? connectorGap,
    TextStyle? indicatorTextStyle,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    double? gap,
    double? spacing,
    EdgeInsetsGeometry? contentPadding,
    MotionSpring? connectorSpring,
  }) {
    final _this = (this as StepperTheme);

    return StepperTheme(
      indicatorSize: indicatorSize ?? _this.indicatorSize,
      indicatorColor: indicatorColor ?? _this.indicatorColor,
      indicatorBorderColor: indicatorBorderColor ?? _this.indicatorBorderColor,
      indicatorForegroundColor:
          indicatorForegroundColor ?? _this.indicatorForegroundColor,
      activeColor: activeColor ?? _this.activeColor,
      completeColor: completeColor ?? _this.completeColor,
      completeForegroundColor:
          completeForegroundColor ?? _this.completeForegroundColor,
      errorColor: errorColor ?? _this.errorColor,
      connectorColor: connectorColor ?? _this.connectorColor,
      connectorThickness: connectorThickness ?? _this.connectorThickness,
      connectorGap: connectorGap ?? _this.connectorGap,
      indicatorTextStyle: indicatorTextStyle ?? _this.indicatorTextStyle,
      titleStyle: titleStyle ?? _this.titleStyle,
      subtitleStyle: subtitleStyle ?? _this.subtitleStyle,
      gap: gap ?? _this.gap,
      spacing: spacing ?? _this.spacing,
      contentPadding: contentPadding ?? _this.contentPadding,
      connectorSpring: connectorSpring ?? _this.connectorSpring,
    );
  }

  StepperTheme merge(StepperTheme? other) {
    final _this = (this as StepperTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      indicatorSize: other.indicatorSize,
      indicatorColor: other.indicatorColor,
      indicatorBorderColor: other.indicatorBorderColor,
      indicatorForegroundColor: other.indicatorForegroundColor,
      activeColor: other.activeColor,
      completeColor: other.completeColor,
      completeForegroundColor: other.completeForegroundColor,
      errorColor: other.errorColor,
      connectorColor: other.connectorColor,
      connectorThickness: other.connectorThickness,
      connectorGap: other.connectorGap,
      indicatorTextStyle:
          _this.indicatorTextStyle?.merge(other.indicatorTextStyle) ??
          other.indicatorTextStyle,
      titleStyle: _this.titleStyle?.merge(other.titleStyle) ?? other.titleStyle,
      subtitleStyle:
          _this.subtitleStyle?.merge(other.subtitleStyle) ??
          other.subtitleStyle,
      gap: other.gap,
      spacing: other.spacing,
      contentPadding: other.contentPadding,
      connectorSpring: other.connectorSpring,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    final _this = (this as StepperTheme);
    final _other = (other as StepperTheme);

    return _other.indicatorSize == _this.indicatorSize &&
        _other.indicatorColor == _this.indicatorColor &&
        _other.indicatorBorderColor == _this.indicatorBorderColor &&
        _other.indicatorForegroundColor == _this.indicatorForegroundColor &&
        _other.activeColor == _this.activeColor &&
        _other.completeColor == _this.completeColor &&
        _other.completeForegroundColor == _this.completeForegroundColor &&
        _other.errorColor == _this.errorColor &&
        _other.connectorColor == _this.connectorColor &&
        _other.connectorThickness == _this.connectorThickness &&
        _other.connectorGap == _this.connectorGap &&
        _other.indicatorTextStyle == _this.indicatorTextStyle &&
        _other.titleStyle == _this.titleStyle &&
        _other.subtitleStyle == _this.subtitleStyle &&
        _other.gap == _this.gap &&
        _other.spacing == _this.spacing &&
        _other.contentPadding == _this.contentPadding &&
        _other.connectorSpring == _this.connectorSpring;
  }

  @override
  int get hashCode {
    final _this = (this as StepperTheme);

    return Object.hash(
      runtimeType,
      _this.indicatorSize,
      _this.indicatorColor,
      _this.indicatorBorderColor,
      _this.indicatorForegroundColor,
      _this.activeColor,
      _this.completeColor,
      _this.completeForegroundColor,
      _this.errorColor,
      _this.connectorColor,
      _this.connectorThickness,
      _this.connectorGap,
      _this.indicatorTextStyle,
      _this.titleStyle,
      _this.subtitleStyle,
      _this.gap,
      _this.spacing,
      _this.contentPadding,
      _this.connectorSpring,
    );
  }
}
