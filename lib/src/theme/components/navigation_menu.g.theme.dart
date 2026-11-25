// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'navigation_menu.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$NavigationMenuTheme {
  bool get canMerge => true;

  static NavigationMenuTheme? lerp(
    NavigationMenuTheme? a,
    NavigationMenuTheme? b,
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

    return NavigationMenuTheme(
      gap: lerpDouble$(a.gap, b.gap, t),
      selectedColor: Color.lerp(a.selectedColor, b.selectedColor, t),
      panelOffset: lerpDouble$(a.panelOffset, b.panelOffset, t),
      panelPadding: EdgeInsetsGeometry.lerp(a.panelPadding, b.panelPadding, t),
      panelMargin: lerpDouble$(a.panelMargin, b.panelMargin, t),
      linkPadding: EdgeInsetsGeometry.lerp(a.linkPadding, b.linkPadding, t),
      linkBorderRadius: BorderRadius.lerp(
        a.linkBorderRadius,
        b.linkBorderRadius,
        t,
      ),
      linkGap: lerpDouble$(a.linkGap, b.linkGap, t),
      linkHoverColor: Color.lerp(a.linkHoverColor, b.linkHoverColor, t),
      linkSelectedColor: Color.lerp(
        a.linkSelectedColor,
        b.linkSelectedColor,
        t,
      ),
      linkTitleStyle: TextStyle.lerp(a.linkTitleStyle, b.linkTitleStyle, t),
      linkDescriptionStyle: TextStyle.lerp(
        a.linkDescriptionStyle,
        b.linkDescriptionStyle,
        t,
      ),
      sheetLabelStyle: TextStyle.lerp(a.sheetLabelStyle, b.sheetLabelStyle, t),
      openDelay: lerpDuration$(a.openDelay, b.openDelay, t),
      closeDelay: lerpDuration$(a.closeDelay, b.closeDelay, t),
    );
  }

  NavigationMenuTheme copyWith({
    double? gap,
    Color? selectedColor,
    double? panelOffset,
    EdgeInsetsGeometry? panelPadding,
    double? panelMargin,
    EdgeInsetsGeometry? linkPadding,
    BorderRadius? linkBorderRadius,
    double? linkGap,
    Color? linkHoverColor,
    Color? linkSelectedColor,
    TextStyle? linkTitleStyle,
    TextStyle? linkDescriptionStyle,
    TextStyle? sheetLabelStyle,
    Duration? openDelay,
    Duration? closeDelay,
  }) {
    final _this = (this as NavigationMenuTheme);

    return NavigationMenuTheme(
      gap: gap ?? _this.gap,
      selectedColor: selectedColor ?? _this.selectedColor,
      panelOffset: panelOffset ?? _this.panelOffset,
      panelPadding: panelPadding ?? _this.panelPadding,
      panelMargin: panelMargin ?? _this.panelMargin,
      linkPadding: linkPadding ?? _this.linkPadding,
      linkBorderRadius: linkBorderRadius ?? _this.linkBorderRadius,
      linkGap: linkGap ?? _this.linkGap,
      linkHoverColor: linkHoverColor ?? _this.linkHoverColor,
      linkSelectedColor: linkSelectedColor ?? _this.linkSelectedColor,
      linkTitleStyle: linkTitleStyle ?? _this.linkTitleStyle,
      linkDescriptionStyle: linkDescriptionStyle ?? _this.linkDescriptionStyle,
      sheetLabelStyle: sheetLabelStyle ?? _this.sheetLabelStyle,
      openDelay: openDelay ?? _this.openDelay,
      closeDelay: closeDelay ?? _this.closeDelay,
    );
  }

  NavigationMenuTheme merge(NavigationMenuTheme? other) {
    final _this = (this as NavigationMenuTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      gap: other.gap,
      selectedColor: other.selectedColor,
      panelOffset: other.panelOffset,
      panelPadding: other.panelPadding,
      panelMargin: other.panelMargin,
      linkPadding: other.linkPadding,
      linkBorderRadius: other.linkBorderRadius,
      linkGap: other.linkGap,
      linkHoverColor: other.linkHoverColor,
      linkSelectedColor: other.linkSelectedColor,
      linkTitleStyle:
          _this.linkTitleStyle?.merge(other.linkTitleStyle) ??
          other.linkTitleStyle,
      linkDescriptionStyle:
          _this.linkDescriptionStyle?.merge(other.linkDescriptionStyle) ??
          other.linkDescriptionStyle,
      sheetLabelStyle:
          _this.sheetLabelStyle?.merge(other.sheetLabelStyle) ??
          other.sheetLabelStyle,
      openDelay: other.openDelay,
      closeDelay: other.closeDelay,
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

    final _this = (this as NavigationMenuTheme);
    final _other = (other as NavigationMenuTheme);

    return _other.gap == _this.gap &&
        _other.selectedColor == _this.selectedColor &&
        _other.panelOffset == _this.panelOffset &&
        _other.panelPadding == _this.panelPadding &&
        _other.panelMargin == _this.panelMargin &&
        _other.linkPadding == _this.linkPadding &&
        _other.linkBorderRadius == _this.linkBorderRadius &&
        _other.linkGap == _this.linkGap &&
        _other.linkHoverColor == _this.linkHoverColor &&
        _other.linkSelectedColor == _this.linkSelectedColor &&
        _other.linkTitleStyle == _this.linkTitleStyle &&
        _other.linkDescriptionStyle == _this.linkDescriptionStyle &&
        _other.sheetLabelStyle == _this.sheetLabelStyle &&
        _other.openDelay == _this.openDelay &&
        _other.closeDelay == _this.closeDelay;
  }

  @override
  int get hashCode {
    final _this = (this as NavigationMenuTheme);

    return Object.hash(
      runtimeType,
      _this.gap,
      _this.selectedColor,
      _this.panelOffset,
      _this.panelPadding,
      _this.panelMargin,
      _this.linkPadding,
      _this.linkBorderRadius,
      _this.linkGap,
      _this.linkHoverColor,
      _this.linkSelectedColor,
      _this.linkTitleStyle,
      _this.linkDescriptionStyle,
      _this.sheetLabelStyle,
      _this.openDelay,
      _this.closeDelay,
    );
  }
}
