import 'dart:ui' show ImageFilter;

import 'package:finesse/src/components/sheet.dart';
import 'package:finesse/src/liquid_glass/liquid_glass_theme.dart';
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
    this.liquidGlass,
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

  /// Whether sheets draw with Liquid Glass, over
  /// `ThemeData.liquidGlass.mode`; null follows the theme.
  final LiquidGlassMode? liquidGlass;

  /// {@macro Sheet.side}
  final SheetSide? side;

  /// Limits on the sheet's size. Across its axis the largest size is the
  /// cap that keeps a sheet from the top or bottom readable on a wide
  /// window (640 on a desktop by default) or that gives a sheet from a
  /// side its width (three quarters of the page, at most 384, by default);
  /// along its axis the detents decide, within these.
  final BoxConstraints? constraints;

  /// The colour of the sheet's surface.
  final Color? backgroundColor;

  /// A filter applied to what is behind the sheet, for a translucent
  /// [backgroundColor]: the blur of a glass surface. Null, the default,
  /// applies none.
  final ImageFilter? filter;

  /// The corners of a sheet that comes from the top or the bottom, on the
  /// edge that faces the page. A sheet from a side is square unless it is
  /// given a radius of its own.
  final BorderRadius? borderRadius;

  /// The outline of the sheet.
  final BoxBorder? border;

  /// The shadows the sheet casts on the page.
  final List<BoxShadow>? shadows;

  /// The space around the content. The safe area — the home indicator, the
  /// status bar under a full-height sheet — is added to it.
  final EdgeInsetsGeometry? padding;

  /// The space between the title, the description, the content and the
  /// actions.
  final double? gap;

  /// The gap between two actions.
  final double? actionsGap;

  /// The text style of the title.
  final TextStyle? titleStyle;

  /// The text style of the description, and of text in the content that
  /// has none of its own.
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

  /// Where the close button sits in the sheet; 8 from the top and from the
  /// end by default.
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
