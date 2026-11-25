// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'time_picker.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$TimePickerTheme {
  bool get canMerge => true;

  static TimePickerTheme? lerp(
    TimePickerTheme? a,
    TimePickerTheme? b,
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

    return TimePickerTheme(
      buttonVariant: t < 0.5 ? a.buttonVariant : b.buttonVariant,
      width: lerpDouble$(a.width, b.width, t),
      popoverPadding: EdgeInsetsGeometry.lerp(
        a.popoverPadding,
        b.popoverPadding,
        t,
      ),
      anchor: t < 0.5 ? a.anchor : b.anchor,
      sheetWheelItems: t < 0.5 ? a.sheetWheelItems : b.sheetWheelItems,
    );
  }

  TimePickerTheme copyWith({
    ButtonVariant? buttonVariant,
    double? width,
    EdgeInsetsGeometry? popoverPadding,
    AnchorBase? anchor,
    int? sheetWheelItems,
  }) {
    final _this = (this as TimePickerTheme);

    return TimePickerTheme(
      buttonVariant: buttonVariant ?? _this.buttonVariant,
      width: width ?? _this.width,
      popoverPadding: popoverPadding ?? _this.popoverPadding,
      anchor: anchor ?? _this.anchor,
      sheetWheelItems: sheetWheelItems ?? _this.sheetWheelItems,
    );
  }

  TimePickerTheme merge(TimePickerTheme? other) {
    final _this = (this as TimePickerTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      buttonVariant: other.buttonVariant,
      width: other.width,
      popoverPadding: other.popoverPadding,
      anchor: other.anchor,
      sheetWheelItems: other.sheetWheelItems,
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

    final _this = (this as TimePickerTheme);
    final _other = (other as TimePickerTheme);

    return _other.buttonVariant == _this.buttonVariant &&
        _other.width == _this.width &&
        _other.popoverPadding == _this.popoverPadding &&
        _other.anchor == _this.anchor &&
        _other.sheetWheelItems == _this.sheetWheelItems;
  }

  @override
  int get hashCode {
    final _this = (this as TimePickerTheme);

    return Object.hash(
      runtimeType,
      _this.buttonVariant,
      _this.width,
      _this.popoverPadding,
      _this.anchor,
      _this.sheetWheelItems,
    );
  }
}
