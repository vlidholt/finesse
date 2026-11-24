import 'package:finesse/src/utils/position.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'dialog.g.theme.dart';

/// {@template DialogTheme}
/// Theme for the `Dialog` widget.
/// {@endtemplate}
@themeGen
@immutable
class DialogTheme with _$DialogTheme {
  /// {@macro DialogTheme}
  const DialogTheme({
    bool canMerge = true,
    this.closeIconData,
    this.closeIconPosition,
    this.radius,
    this.backgroundColor,
    this.expandActionsWhenTiny,
    this.padding,
    this.gap,
    this.animateIn,
    this.animateOut,
    this.constraints,
    this.border,
    this.shadows,
    this.removeBorderRadiusWhenTiny,
    this.actionsAxis,
    this.actionsMainAxisSize,
    this.actionsMainAxisAlignment,
    this.actionsVerticalDirection,
    this.titleStyle,
    this.descriptionStyle,
    this.titleTextAlign,
    this.descriptionTextAlign,
    this.alignment,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.scrollable,
    this.scrollPadding,
    this.actionsGap,
    this.useSafeArea,
    this.titlePinned,
    this.descriptionPinned,
    this.actionsPinned,
    this.barrierColor,
    this.barrierBlurSigma,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Dialog.closeIconData}
  final IconData? closeIconData;

  /// {@macro Dialog.closeIconPosition}
  final Position? closeIconPosition;

  /// {@macro Dialog.radius}
  final BorderRadius? radius;

  /// {@macro Dialog.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Dialog.expandActionsWhenTiny}
  final bool? expandActionsWhenTiny;

  /// {@macro Dialog.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Dialog.gap}
  final double? gap;

  /// The effects played when the dialog appears. Null, the default, is a
  /// fade and zoom in on the theme's motion tokens.
  final List<Effect<dynamic>>? animateIn;

  /// The effects played when the dialog disappears. Null, the default, is
  /// a quicker fade and zoom out on the theme's motion tokens.
  final List<Effect<dynamic>>? animateOut;

  /// {@macro Dialog.constraints}
  final BoxConstraints? constraints;

  /// {@macro Dialog.actionsAxis}
  final Axis? actionsAxis;

  /// {@macro Dialog.actionsMainAxisSize}
  final MainAxisSize? actionsMainAxisSize;

  /// {@macro Dialog.actionsMainAxisAlignment}
  final MainAxisAlignment? actionsMainAxisAlignment;

  /// {@macro Dialog.actionsVerticalDirection}
  final VerticalDirection? actionsVerticalDirection;

  /// {@macro Dialog.border}
  final BoxBorder? border;

  /// {@macro Dialog.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Dialog.removeBorderRadiusWhenTiny}
  final bool? removeBorderRadiusWhenTiny;

  /// {@macro Dialog.titleStyle}
  final TextStyle? titleStyle;

  /// {@macro Dialog.descriptionStyle}
  final TextStyle? descriptionStyle;

  /// {@macro Dialog.titleTextAlign}
  final TextAlign? titleTextAlign;

  /// {@macro Dialog.descriptionTextAlign}
  final TextAlign? descriptionTextAlign;

  /// {@macro Dialog.alignment}
  final Alignment? alignment;

  /// {@macro Dialog.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@macro Dialog.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro Dialog.scrollable}
  final bool? scrollable;

  /// {@macro Dialog.scrollPadding}
  final EdgeInsetsGeometry? scrollPadding;

  /// {@macro Dialog.actionsGap}
  final double? actionsGap;

  /// {@macro Dialog.useSafeArea}
  final bool? useSafeArea;

  /// {@macro Dialog.titlePinned}
  final bool? titlePinned;

  /// {@macro Dialog.descriptionPinned}
  final bool? descriptionPinned;

  /// {@macro Dialog.actionsPinned}
  final bool? actionsPinned;

  /// The colour of the barrier behind the dialog. Defaults to shadcn's
  /// `bg-black/10`, which reads because the barrier is also blurred.
  final Color? barrierColor;

  /// {@macro Dialog.barrierBlurSigma}
  final double? barrierBlurSigma;

  /// Linearly interpolates between [a] and [b] by [t].
  static DialogTheme? lerp(
    DialogTheme? a,
    DialogTheme? b,
    double t,
  ) => _$DialogTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is DialogTheme &&
      listEquals(animateIn, other.animateIn) &&
      listEquals(animateOut, other.animateOut) &&
      listEquals(shadows, other.shadows) &&
      super ==
          other.copyWith(
            animateIn: animateIn,
            animateOut: animateOut,
            shadows: shadows,
          );

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(animateIn ?? const []),
    Object.hashAll(animateOut ?? const []),
    Object.hashAll(shadows ?? const []),
  );
}
