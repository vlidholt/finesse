import 'package:finesse/src/components/sheet.dart';
import 'package:finesse/src/utils/position.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    this.constraints,
    this.expandCrossSide,
    this.closeIcon,
    this.closeIconData,
    this.closeIconPosition,
    this.radius,
    this.backgroundColor,
    this.expandActionsWhenTiny,
    this.padding,
    this.gap,
    this.actionsAxis,
    this.actionsMainAxisSize,
    this.actionsMainAxisAlignment,
    this.actionsVerticalDirection,
    this.border,
    this.shadows,
    this.removeBorderRadiusWhenTiny,
    this.titleStyle,
    this.descriptionStyle,
    this.titleTextAlign,
    this.descriptionTextAlign,
    this.animateIn,
    this.animateOut,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.scrollable,
    this.scrollPadding,
    this.disabledScrollControlMaxRatio,
    this.minFlingVelocity,
    this.snapFlingVelocity,
    this.closeProgressThreshold,
    this.side,
    this.useSafeArea,
    this.titlePinned,
    this.descriptionPinned,
    this.actionsPinned,
    this.expandable,
    this.initialSize,
    this.minSize,
    this.maxSize,
    this.snap,
    this.snapSizes,
    this.snapAnimationDuration,
    this.snapAnimationCurve,
    this.showDragHandle,
    this.dragHandleColor,
    this.dragHandleWidth,
    this.dragHandleHeight,
    this.dragHandleRadius,
    this.dragHandleExtent,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Sheet.constraints}
  final BoxConstraints? constraints;

  /// {@macro Sheet.expandCrossSide}
  final bool? expandCrossSide;

  /// {@macro Sheet.closeIcon}
  final Widget? closeIcon;

  /// {@macro Sheet.closeIconData}
  final IconData? closeIconData;

  /// {@macro Sheet.closeIconPosition}
  final Position? closeIconPosition;

  /// {@macro Sheet.radius}
  final BorderRadius? radius;

  /// {@macro Sheet.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Sheet.expandActionsWhenTiny}
  final bool? expandActionsWhenTiny;

  /// {@macro Sheet.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Sheet.gap}
  final double? gap;

  /// {@macro Sheet.actionsAxis}
  final Axis? actionsAxis;

  /// {@macro Sheet.actionsMainAxisSize}
  final MainAxisSize? actionsMainAxisSize;

  /// {@macro Sheet.actionsMainAxisAlignment}
  final MainAxisAlignment? actionsMainAxisAlignment;

  /// {@macro Sheet.actionsVerticalDirection}
  final VerticalDirection? actionsVerticalDirection;

  /// {@macro Sheet.border}
  final BoxBorder? border;

  /// {@macro Sheet.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Sheet.removeBorderRadiusWhenTiny}
  final bool? removeBorderRadiusWhenTiny;

  /// {@macro Sheet.titleStyle}
  final TextStyle? titleStyle;

  /// {@macro Sheet.descriptionStyle}
  final TextStyle? descriptionStyle;

  /// {@macro Sheet.titleTextAlign}
  final TextAlign? titleTextAlign;

  /// {@macro Sheet.descriptionTextAlign}
  final TextAlign? descriptionTextAlign;

  /// The effects played when the sheet appears. Defaults to a slide in
  /// from its side.
  final List<Effect<dynamic>>? animateIn;

  /// The effects played when the sheet disappears. Defaults to a slide out
  /// to its side.
  final List<Effect<dynamic>>? animateOut;

  /// {@macro Sheet.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@macro Sheet.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro Sheet.scrollable}
  final bool? scrollable;

  /// {@macro Sheet.scrollPadding}
  final EdgeInsetsGeometry? scrollPadding;

  /// {@macro Sheet.disabledScrollControlMaxRatio}
  final double? disabledScrollControlMaxRatio;

  /// {@macro Sheet.minFlingVelocity}
  final double? minFlingVelocity;

  /// {@macro Sheet.snapFlingVelocity}
  final double? snapFlingVelocity;

  /// {@macro Sheet.closeProgressThreshold}
  final double? closeProgressThreshold;

  /// {@macro Sheet.side}
  final SheetSide? side;

  /// {@macro Dialog.useSafeArea}
  final bool? useSafeArea;

  /// {@macro Dialog.titlePinned}
  final bool? titlePinned;

  /// {@macro Dialog.descriptionPinned}
  final bool? descriptionPinned;

  /// {@macro Dialog.actionsPinned}
  final bool? actionsPinned;

  /// {@macro Sheet.expandable}
  final bool? expandable;

  /// {@macro Sheet.initialSize}
  final double? initialSize;

  /// {@macro Sheet.minSize}
  final double? minSize;

  /// {@macro Sheet.maxSize}
  final double? maxSize;

  /// {@macro Sheet.snap}
  final bool? snap;

  /// {@macro Sheet.snapSizes}
  final List<double>? snapSizes;

  /// {@macro Sheet.snapAnimationDuration}
  final Duration? snapAnimationDuration;

  /// {@macro Sheet.snapAnimationCurve}
  final Curve? snapAnimationCurve;

  /// {@macro Sheet.showDragHandle}
  final bool? showDragHandle;

  /// Color of the default drag handle pill.
  final Color? dragHandleColor;

  /// Width of the default drag handle pill. Defaults to 36.0.
  final double? dragHandleWidth;

  /// Height of the default drag handle pill. Defaults to 4.0.
  final double? dragHandleHeight;

  /// Border radius of the default drag handle pill.
  final BorderRadius? dragHandleRadius;

  /// {@macro Sheet.dragHandleExtent}
  final double? dragHandleExtent;

  /// Linearly interpolates between [a] and [b] by [t].
  static SheetTheme? lerp(
    SheetTheme? a,
    SheetTheme? b,
    double t,
  ) => _$SheetTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is SheetTheme &&
      listEquals(shadows, other.shadows) &&
      listEquals(animateIn, other.animateIn) &&
      listEquals(animateOut, other.animateOut) &&
      listEquals(snapSizes, other.snapSizes) &&
      super ==
          other.copyWith(
            shadows: shadows,
            animateIn: animateIn,
            animateOut: animateOut,
            snapSizes: snapSizes,
          );

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(shadows ?? const []),
    Object.hashAll(animateIn ?? const []),
    Object.hashAll(animateOut ?? const []),
    Object.hashAll(snapSizes ?? const []),
  );
}
