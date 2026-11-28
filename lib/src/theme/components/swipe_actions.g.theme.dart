// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'swipe_actions.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$SwipeActionsTheme {
  bool get canMerge => true;

  static SwipeActionsTheme? lerp(
    SwipeActionsTheme? a,
    SwipeActionsTheme? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return SwipeActionsTheme(
      edgeShadowColor: Color.lerp(a.edgeShadowColor, b.edgeShadowColor, t),
      edgeShadowWidth: lerpDouble$(a.edgeShadowWidth, b.edgeShadowWidth, t),
    );
  }

  SwipeActionsTheme copyWith({
    Color? edgeShadowColor,
    double? edgeShadowWidth,
  }) {
    final _this = (this as SwipeActionsTheme);

    return SwipeActionsTheme(
      edgeShadowColor: edgeShadowColor ?? _this.edgeShadowColor,
      edgeShadowWidth: edgeShadowWidth ?? _this.edgeShadowWidth,
    );
  }

  SwipeActionsTheme merge(SwipeActionsTheme? other) {
    final _this = (this as SwipeActionsTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      edgeShadowColor: other.edgeShadowColor,
      edgeShadowWidth: other.edgeShadowWidth,
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

    final _this = (this as SwipeActionsTheme);
    final _other = (other as SwipeActionsTheme);

    return _other.edgeShadowColor == _this.edgeShadowColor &&
        _other.edgeShadowWidth == _this.edgeShadowWidth;
  }

  @override
  int get hashCode {
    final _this = (this as SwipeActionsTheme);

    return Object.hash(
      runtimeType,
      _this.edgeShadowColor,
      _this.edgeShadowWidth,
    );
  }
}
