import 'dart:ui' show ImageFilter;

import 'package:finesse/src/components/sheet.dart';
import 'package:finesse/src/utils/position.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'sheet.g.theme.dart';

/// {@template SheetTheme}
/// Theme for the `Sheet` widget.
/// {@endtemplate}
@themeGen
@immutable
class SheetTheme with _$SheetTheme {
  /// {@macro SheetTheme}
  const SheetTheme({
    bool canMerge = true,
    this.side,
    this.constraints,
    this.backgroundColor,
    this.filter,
    this.borderRadius,
    this.border,
    this.shadows,
    this.padding,
    this.gap,
    this.actionsGap,
    this.titleStyle,
    this.descriptionStyle,
    this.scrollable,
    this.useSafeArea,
    this.titlePinned,
    this.descriptionPinned,
    this.actionsPinned,
    this.showCloseButton,
    this.closeIcon,
    this.closeIconPosition,
    this.draggable,
    this.showDragHandle,
    this.dragHandleColor,
    this.dragHandleWidth,
    this.dragHandleHeight,
    this.dragHandleBorderRadius,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Sheet.side}
  final SheetSide? side;

  /// {@macro Sheet.constraints}
  final BoxConstraints? constraints;

  /// {@macro Sheet.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Sheet.filter}
  final ImageFilter? filter;

  /// The corners of a sheet that comes from the top or the bottom, on the
  /// edge that faces the page. A sheet from a side is square unless it is
  /// given a radius of its own.
  final BorderRadius? borderRadius;

  /// {@macro Sheet.border}
  final BoxBorder? border;

  /// {@macro Sheet.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Sheet.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Sheet.gap}
  final double? gap;

  /// The gap between two actions.
  final double? actionsGap;

  /// {@macro Sheet.titleStyle}
  final TextStyle? titleStyle;

  /// {@macro Sheet.descriptionStyle}
  final TextStyle? descriptionStyle;

  /// {@macro Sheet.scrollable}
  final bool? scrollable;

  /// {@macro Sheet.useSafeArea}
  final bool? useSafeArea;

  /// {@macro Sheet.titlePinned}
  final bool? titlePinned;

  /// {@macro Sheet.descriptionPinned}
  final bool? descriptionPinned;

  /// {@macro Sheet.actionsPinned}
  final bool? actionsPinned;

  /// {@macro Sheet.showCloseButton}
  final bool? showCloseButton;

  /// {@macro Sheet.closeIcon}
  ///
  /// A theme is compared on every rebuild, so a widget given here has to be
  /// a constant.
  final Widget? closeIcon;

  /// {@macro Sheet.closeIconPosition}
  final Position? closeIconPosition;

  /// {@macro Sheet.draggable}
  final bool? draggable;

  /// {@macro Sheet.showDragHandle}
  final bool? showDragHandle;

  /// The colour of the drag handle's pill.
  final Color? dragHandleColor;

  /// The length of the drag handle's pill. Defaults to 36.
  final double? dragHandleWidth;

  /// The thickness of the drag handle's pill. Defaults to 4.
  final double? dragHandleHeight;

  /// The corners of the drag handle's pill. Defaults to a full pill.
  final BorderRadius? dragHandleBorderRadius;

  /// Linearly interpolates between [a] and [b] by [t].
  static SheetTheme? lerp(
    SheetTheme? a,
    SheetTheme? b,
    double t,
  ) => _$SheetTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and the app would
  // rebuild under a "new" theme on every frame. Compare the list by value,
  // then let the generated `==` compare everything else against a copy that
  // shares it.
  @override
  bool operator ==(Object other) =>
      other is SheetTheme &&
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(shadows: shadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(shadows ?? const []),
  );
}
