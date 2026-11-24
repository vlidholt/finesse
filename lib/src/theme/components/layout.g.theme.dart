// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'layout.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$LayoutTheme {
  bool get canMerge => true;

  static LayoutTheme? lerp(LayoutTheme? a, LayoutTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return LayoutTheme(
      pagePadding: EdgeInsetsGeometry.lerp(a.pagePadding, b.pagePadding, t),
      pageMaxWidth: lerpDouble$(a.pageMaxWidth, b.pageMaxWidth, t),
      gapXs: lerpDouble$(a.gapXs, b.gapXs, t),
      gapSm: lerpDouble$(a.gapSm, b.gapSm, t),
      gapMd: lerpDouble$(a.gapMd, b.gapMd, t),
      gapLg: lerpDouble$(a.gapLg, b.gapLg, t),
      gapXl: lerpDouble$(a.gapXl, b.gapXl, t),
    );
  }

  LayoutTheme copyWith({
    EdgeInsetsGeometry? pagePadding,
    double? pageMaxWidth,
    double? gapXs,
    double? gapSm,
    double? gapMd,
    double? gapLg,
    double? gapXl,
  }) {
    final _this = (this as LayoutTheme);

    return LayoutTheme(
      pagePadding: pagePadding ?? _this.pagePadding,
      pageMaxWidth: pageMaxWidth ?? _this.pageMaxWidth,
      gapXs: gapXs ?? _this.gapXs,
      gapSm: gapSm ?? _this.gapSm,
      gapMd: gapMd ?? _this.gapMd,
      gapLg: gapLg ?? _this.gapLg,
      gapXl: gapXl ?? _this.gapXl,
    );
  }

  LayoutTheme merge(LayoutTheme? other) {
    final _this = (this as LayoutTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      pagePadding: other.pagePadding,
      pageMaxWidth: other.pageMaxWidth,
      gapXs: other.gapXs,
      gapSm: other.gapSm,
      gapMd: other.gapMd,
      gapLg: other.gapLg,
      gapXl: other.gapXl,
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

    final _this = (this as LayoutTheme);
    final _other = (other as LayoutTheme);

    return _other.pagePadding == _this.pagePadding &&
        _other.pageMaxWidth == _this.pageMaxWidth &&
        _other.gapXs == _this.gapXs &&
        _other.gapSm == _this.gapSm &&
        _other.gapMd == _this.gapMd &&
        _other.gapLg == _this.gapLg &&
        _other.gapXl == _this.gapXl;
  }

  @override
  int get hashCode {
    final _this = (this as LayoutTheme);

    return Object.hash(
      runtimeType,
      _this.pagePadding,
      _this.pageMaxWidth,
      _this.gapXs,
      _this.gapSm,
      _this.gapMd,
      _this.gapLg,
      _this.gapXl,
    );
  }
}
