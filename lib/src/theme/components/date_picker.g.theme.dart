// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'date_picker.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$DatePickerTheme {
  bool get canMerge => true;

  static DatePickerTheme? lerp(
    DatePickerTheme? a,
    DatePickerTheme? b,
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

    return DatePickerTheme(
      buttonVariant: t < 0.5 ? a.buttonVariant : b.buttonVariant,
      width: lerpDouble$(a.width, b.width, t),
      popoverPadding: EdgeInsetsGeometry.lerp(
        a.popoverPadding,
        b.popoverPadding,
        t,
      ),
      anchor: t < 0.5 ? a.anchor : b.anchor,
      allowDeselection: t < 0.5 ? a.allowDeselection : b.allowDeselection,
      closeOnSelection: t < 0.5 ? a.closeOnSelection : b.closeOnSelection,
      sheetMaxWidth: lerpDouble$(a.sheetMaxWidth, b.sheetMaxWidth, t),
      sheetWheelItems: t < 0.5 ? a.sheetWheelItems : b.sheetWheelItems,
    );
  }

  DatePickerTheme copyWith({
    ButtonVariant? buttonVariant,
    double? width,
    EdgeInsetsGeometry? popoverPadding,
    AnchorBase? anchor,
    bool? allowDeselection,
    bool? closeOnSelection,
    double? sheetMaxWidth,
    int? sheetWheelItems,
  }) {
    final _this = (this as DatePickerTheme);

    return DatePickerTheme(
      buttonVariant: buttonVariant ?? _this.buttonVariant,
      width: width ?? _this.width,
      popoverPadding: popoverPadding ?? _this.popoverPadding,
      anchor: anchor ?? _this.anchor,
      allowDeselection: allowDeselection ?? _this.allowDeselection,
      closeOnSelection: closeOnSelection ?? _this.closeOnSelection,
      sheetMaxWidth: sheetMaxWidth ?? _this.sheetMaxWidth,
      sheetWheelItems: sheetWheelItems ?? _this.sheetWheelItems,
    );
  }

  DatePickerTheme merge(DatePickerTheme? other) {
    final _this = (this as DatePickerTheme);

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
      allowDeselection: other.allowDeselection,
      closeOnSelection: other.closeOnSelection,
      sheetMaxWidth: other.sheetMaxWidth,
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

    final _this = (this as DatePickerTheme);
    final _other = (other as DatePickerTheme);

    return _other.buttonVariant == _this.buttonVariant &&
        _other.width == _this.width &&
        _other.popoverPadding == _this.popoverPadding &&
        _other.anchor == _this.anchor &&
        _other.allowDeselection == _this.allowDeselection &&
        _other.closeOnSelection == _this.closeOnSelection &&
        _other.sheetMaxWidth == _this.sheetMaxWidth &&
        _other.sheetWheelItems == _this.sheetWheelItems;
  }

  @override
  int get hashCode {
    final _this = (this as DatePickerTheme);

    return Object.hash(
      runtimeType,
      _this.buttonVariant,
      _this.width,
      _this.popoverPadding,
      _this.anchor,
      _this.allowDeselection,
      _this.closeOnSelection,
      _this.sheetMaxWidth,
      _this.sheetWheelItems,
    );
  }
}
