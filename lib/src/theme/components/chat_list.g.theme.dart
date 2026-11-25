// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'chat_list.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$ChatListTheme {
  bool get canMerge => true;

  static ChatListTheme? lerp(ChatListTheme? a, ChatListTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return ChatListTheme(
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      groupSpacing: lerpDouble$(a.groupSpacing, b.groupSpacing, t),
      followDistance: lerpDouble$(a.followDistance, b.followDistance, t),
      enterSpring: t < 0.5 ? a.enterSpring : b.enterSpring,
      exitSpring: t < 0.5 ? a.exitSpring : b.exitSpring,
      enterScale: lerpDouble$(a.enterScale, b.enterScale, t),
      enterTravel: lerpDouble$(a.enterTravel, b.enterTravel, t),
      stagger: lerpDuration$(a.stagger, b.stagger, t),
      maxStaggerSteps: t < 0.5 ? a.maxStaggerSteps : b.maxStaggerSteps,
      jumpToLatestMargin: lerpDouble$(
        a.jumpToLatestMargin,
        b.jumpToLatestMargin,
        t,
      ),
    );
  }

  ChatListTheme copyWith({
    EdgeInsetsGeometry? padding,
    double? spacing,
    double? groupSpacing,
    double? followDistance,
    MotionSpring? enterSpring,
    MotionSpring? exitSpring,
    double? enterScale,
    double? enterTravel,
    Duration? stagger,
    int? maxStaggerSteps,
    double? jumpToLatestMargin,
  }) {
    final _this = (this as ChatListTheme);

    return ChatListTheme(
      padding: padding ?? _this.padding,
      spacing: spacing ?? _this.spacing,
      groupSpacing: groupSpacing ?? _this.groupSpacing,
      followDistance: followDistance ?? _this.followDistance,
      enterSpring: enterSpring ?? _this.enterSpring,
      exitSpring: exitSpring ?? _this.exitSpring,
      enterScale: enterScale ?? _this.enterScale,
      enterTravel: enterTravel ?? _this.enterTravel,
      stagger: stagger ?? _this.stagger,
      maxStaggerSteps: maxStaggerSteps ?? _this.maxStaggerSteps,
      jumpToLatestMargin: jumpToLatestMargin ?? _this.jumpToLatestMargin,
    );
  }

  ChatListTheme merge(ChatListTheme? other) {
    final _this = (this as ChatListTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      padding: other.padding,
      spacing: other.spacing,
      groupSpacing: other.groupSpacing,
      followDistance: other.followDistance,
      enterSpring: other.enterSpring,
      exitSpring: other.exitSpring,
      enterScale: other.enterScale,
      enterTravel: other.enterTravel,
      stagger: other.stagger,
      maxStaggerSteps: other.maxStaggerSteps,
      jumpToLatestMargin: other.jumpToLatestMargin,
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

    final _this = (this as ChatListTheme);
    final _other = (other as ChatListTheme);

    return _other.padding == _this.padding &&
        _other.spacing == _this.spacing &&
        _other.groupSpacing == _this.groupSpacing &&
        _other.followDistance == _this.followDistance &&
        _other.enterSpring == _this.enterSpring &&
        _other.exitSpring == _this.exitSpring &&
        _other.enterScale == _this.enterScale &&
        _other.enterTravel == _this.enterTravel &&
        _other.stagger == _this.stagger &&
        _other.maxStaggerSteps == _this.maxStaggerSteps &&
        _other.jumpToLatestMargin == _this.jumpToLatestMargin;
  }

  @override
  int get hashCode {
    final _this = (this as ChatListTheme);

    return Object.hash(
      runtimeType,
      _this.padding,
      _this.spacing,
      _this.groupSpacing,
      _this.followDistance,
      _this.enterSpring,
      _this.exitSpring,
      _this.enterScale,
      _this.enterTravel,
      _this.stagger,
      _this.maxStaggerSteps,
      _this.jumpToLatestMargin,
    );
  }
}
