// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'chat_bubble.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$ChatBubbleTheme {
  bool get canMerge => true;

  static ChatBubbleTheme? lerp(
    ChatBubbleTheme? a,
    ChatBubbleTheme? b,
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

    return ChatBubbleTheme(
      radius: lerpDouble$(a.radius, b.radius, t),
      tailRadius: lerpDouble$(a.tailRadius, b.tailRadius, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      incomingColor: Color.lerp(a.incomingColor, b.incomingColor, t),
      incomingForegroundColor: Color.lerp(
        a.incomingForegroundColor,
        b.incomingForegroundColor,
        t,
      ),
      outgoingColor: Color.lerp(a.outgoingColor, b.outgoingColor, t),
      outgoingForegroundColor: Color.lerp(
        a.outgoingForegroundColor,
        b.outgoingForegroundColor,
        t,
      ),
      maxWidthFactor: lerpDouble$(a.maxWidthFactor, b.maxWidthFactor, t),
      sizeSpring: t < 0.5 ? a.sizeSpring : b.sizeSpring,
    );
  }

  ChatBubbleTheme copyWith({
    double? radius,
    double? tailRadius,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    Color? incomingColor,
    Color? incomingForegroundColor,
    Color? outgoingColor,
    Color? outgoingForegroundColor,
    double? maxWidthFactor,
    MotionSpring? sizeSpring,
  }) {
    final _this = (this as ChatBubbleTheme);

    return ChatBubbleTheme(
      radius: radius ?? _this.radius,
      tailRadius: tailRadius ?? _this.tailRadius,
      padding: padding ?? _this.padding,
      textStyle: textStyle ?? _this.textStyle,
      incomingColor: incomingColor ?? _this.incomingColor,
      incomingForegroundColor:
          incomingForegroundColor ?? _this.incomingForegroundColor,
      outgoingColor: outgoingColor ?? _this.outgoingColor,
      outgoingForegroundColor:
          outgoingForegroundColor ?? _this.outgoingForegroundColor,
      maxWidthFactor: maxWidthFactor ?? _this.maxWidthFactor,
      sizeSpring: sizeSpring ?? _this.sizeSpring,
    );
  }

  ChatBubbleTheme merge(ChatBubbleTheme? other) {
    final _this = (this as ChatBubbleTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      radius: other.radius,
      tailRadius: other.tailRadius,
      padding: other.padding,
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
      incomingColor: other.incomingColor,
      incomingForegroundColor: other.incomingForegroundColor,
      outgoingColor: other.outgoingColor,
      outgoingForegroundColor: other.outgoingForegroundColor,
      maxWidthFactor: other.maxWidthFactor,
      sizeSpring: other.sizeSpring,
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

    final _this = (this as ChatBubbleTheme);
    final _other = (other as ChatBubbleTheme);

    return _other.radius == _this.radius &&
        _other.tailRadius == _this.tailRadius &&
        _other.padding == _this.padding &&
        _other.textStyle == _this.textStyle &&
        _other.incomingColor == _this.incomingColor &&
        _other.incomingForegroundColor == _this.incomingForegroundColor &&
        _other.outgoingColor == _this.outgoingColor &&
        _other.outgoingForegroundColor == _this.outgoingForegroundColor &&
        _other.maxWidthFactor == _this.maxWidthFactor &&
        _other.sizeSpring == _this.sizeSpring;
  }

  @override
  int get hashCode {
    final _this = (this as ChatBubbleTheme);

    return Object.hash(
      runtimeType,
      _this.radius,
      _this.tailRadius,
      _this.padding,
      _this.textStyle,
      _this.incomingColor,
      _this.incomingForegroundColor,
      _this.outgoingColor,
      _this.outgoingForegroundColor,
      _this.maxWidthFactor,
      _this.sizeSpring,
    );
  }
}
