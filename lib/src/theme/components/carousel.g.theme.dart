// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'carousel.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$CarouselTheme {
  bool get canMerge => true;

  static CarouselTheme? lerp(CarouselTheme? a, CarouselTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return CarouselTheme(
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      arrowSize: lerpDouble$(a.arrowSize, b.arrowSize, t),
      arrowIconSize: lerpDouble$(a.arrowIconSize, b.arrowIconSize, t),
      arrowInset: lerpDouble$(a.arrowInset, b.arrowInset, t),
      arrowColor: Color.lerp(a.arrowColor, b.arrowColor, t),
      arrowHoverColor: Color.lerp(a.arrowHoverColor, b.arrowHoverColor, t),
      arrowForegroundColor: Color.lerp(
        a.arrowForegroundColor,
        b.arrowForegroundColor,
        t,
      ),
      arrowBorderColor: Color.lerp(a.arrowBorderColor, b.arrowBorderColor, t),
      indicatorInset: lerpDouble$(a.indicatorInset, b.indicatorInset, t),
      dotSize: lerpDouble$(a.dotSize, b.dotSize, t),
      activeDotExtent: lerpDouble$(a.activeDotExtent, b.activeDotExtent, t),
      dotSpacing: lerpDouble$(a.dotSpacing, b.dotSpacing, t),
      dotColor: Color.lerp(a.dotColor, b.dotColor, t),
      activeDotColor: Color.lerp(a.activeDotColor, b.activeDotColor, t),
      overlayColor: Color.lerp(a.overlayColor, b.overlayColor, t),
      overlayDotColor: Color.lerp(a.overlayDotColor, b.overlayDotColor, t),
      overlayActiveDotColor: Color.lerp(
        a.overlayActiveDotColor,
        b.overlayActiveDotColor,
        t,
      ),
      overlayPadding: EdgeInsetsGeometry.lerp(
        a.overlayPadding,
        b.overlayPadding,
        t,
      ),
    );
  }

  CarouselTheme copyWith({
    double? spacing,
    double? arrowSize,
    double? arrowIconSize,
    double? arrowInset,
    Color? arrowColor,
    Color? arrowHoverColor,
    Color? arrowForegroundColor,
    Color? arrowBorderColor,
    double? indicatorInset,
    double? dotSize,
    double? activeDotExtent,
    double? dotSpacing,
    Color? dotColor,
    Color? activeDotColor,
    Color? overlayColor,
    Color? overlayDotColor,
    Color? overlayActiveDotColor,
    EdgeInsetsGeometry? overlayPadding,
  }) {
    final _this = (this as CarouselTheme);

    return CarouselTheme(
      spacing: spacing ?? _this.spacing,
      arrowSize: arrowSize ?? _this.arrowSize,
      arrowIconSize: arrowIconSize ?? _this.arrowIconSize,
      arrowInset: arrowInset ?? _this.arrowInset,
      arrowColor: arrowColor ?? _this.arrowColor,
      arrowHoverColor: arrowHoverColor ?? _this.arrowHoverColor,
      arrowForegroundColor: arrowForegroundColor ?? _this.arrowForegroundColor,
      arrowBorderColor: arrowBorderColor ?? _this.arrowBorderColor,
      indicatorInset: indicatorInset ?? _this.indicatorInset,
      dotSize: dotSize ?? _this.dotSize,
      activeDotExtent: activeDotExtent ?? _this.activeDotExtent,
      dotSpacing: dotSpacing ?? _this.dotSpacing,
      dotColor: dotColor ?? _this.dotColor,
      activeDotColor: activeDotColor ?? _this.activeDotColor,
      overlayColor: overlayColor ?? _this.overlayColor,
      overlayDotColor: overlayDotColor ?? _this.overlayDotColor,
      overlayActiveDotColor:
          overlayActiveDotColor ?? _this.overlayActiveDotColor,
      overlayPadding: overlayPadding ?? _this.overlayPadding,
    );
  }

  CarouselTheme merge(CarouselTheme? other) {
    final _this = (this as CarouselTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      spacing: other.spacing,
      arrowSize: other.arrowSize,
      arrowIconSize: other.arrowIconSize,
      arrowInset: other.arrowInset,
      arrowColor: other.arrowColor,
      arrowHoverColor: other.arrowHoverColor,
      arrowForegroundColor: other.arrowForegroundColor,
      arrowBorderColor: other.arrowBorderColor,
      indicatorInset: other.indicatorInset,
      dotSize: other.dotSize,
      activeDotExtent: other.activeDotExtent,
      dotSpacing: other.dotSpacing,
      dotColor: other.dotColor,
      activeDotColor: other.activeDotColor,
      overlayColor: other.overlayColor,
      overlayDotColor: other.overlayDotColor,
      overlayActiveDotColor: other.overlayActiveDotColor,
      overlayPadding: other.overlayPadding,
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

    final _this = (this as CarouselTheme);
    final _other = (other as CarouselTheme);

    return _other.spacing == _this.spacing &&
        _other.arrowSize == _this.arrowSize &&
        _other.arrowIconSize == _this.arrowIconSize &&
        _other.arrowInset == _this.arrowInset &&
        _other.arrowColor == _this.arrowColor &&
        _other.arrowHoverColor == _this.arrowHoverColor &&
        _other.arrowForegroundColor == _this.arrowForegroundColor &&
        _other.arrowBorderColor == _this.arrowBorderColor &&
        _other.indicatorInset == _this.indicatorInset &&
        _other.dotSize == _this.dotSize &&
        _other.activeDotExtent == _this.activeDotExtent &&
        _other.dotSpacing == _this.dotSpacing &&
        _other.dotColor == _this.dotColor &&
        _other.activeDotColor == _this.activeDotColor &&
        _other.overlayColor == _this.overlayColor &&
        _other.overlayDotColor == _this.overlayDotColor &&
        _other.overlayActiveDotColor == _this.overlayActiveDotColor &&
        _other.overlayPadding == _this.overlayPadding;
  }

  @override
  int get hashCode {
    final _this = (this as CarouselTheme);

    return Object.hash(
      runtimeType,
      _this.spacing,
      _this.arrowSize,
      _this.arrowIconSize,
      _this.arrowInset,
      _this.arrowColor,
      _this.arrowHoverColor,
      _this.arrowForegroundColor,
      _this.arrowBorderColor,
      _this.indicatorInset,
      _this.dotSize,
      _this.activeDotExtent,
      _this.dotSpacing,
      _this.dotColor,
      _this.activeDotColor,
      _this.overlayColor,
      _this.overlayDotColor,
      _this.overlayActiveDotColor,
      _this.overlayPadding,
    );
  }
}
