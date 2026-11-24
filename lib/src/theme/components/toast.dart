import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/position.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'toast.g.theme.dart';

/// {@template ToastTheme}
/// Theme for the `Toast` widget.
/// {@endtemplate}
@themeGen
@immutable
class ToastTheme with _$ToastTheme {
  /// {@macro ToastTheme}
  const ToastTheme({
    bool canMerge = true,
    this.backgroundColor,
    this.closeIconData,
    this.alignment,
    this.offset,
    this.displayDuration,
    this.animateIn,
    this.animateOut,
    this.textDirection,
    this.crossAxisAlignment,
    this.showCloseIconOnlyWhenHovered,
    this.titleStyle,
    this.descriptionStyle,
    this.actionPadding,
    this.border,
    this.radius,
    this.shadows,
    this.padding,
    this.closeIconPosition,
    this.constraints,
    this.closeIcon,
    this.mainAxisAlignment,
    this.mainAxisSize,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Toast.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Toast.closeIconData}
  final IconData? closeIconData;

  /// {@macro Toast.alignment}
  final Alignment? alignment;

  /// {@macro Toast.offset}
  final Offset? offset;

  /// {@macro Toast.displayDuration}
  final Duration? displayDuration;

  /// {@macro Toast.animateIn}
  final List<Effect<dynamic>>? animateIn;

  /// {@macro Toast.animateOut}
  final List<Effect<dynamic>>? animateOut;

  /// {@macro Toast.textDirection}
  final TextDirection? textDirection;

  /// {@macro Toast.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro Toast.showCloseIconOnlyWhenHovered}
  final bool? showCloseIconOnlyWhenHovered;

  /// {@macro Toast.titleStyle}
  final TextStyle? titleStyle;

  /// {@macro Toast.descriptionStyle}
  final TextStyle? descriptionStyle;

  /// {@macro Toast.actionPadding}
  final EdgeInsetsGeometry? actionPadding;

  /// {@macro Toast.border}
  final FinesseBorder? border;

  /// {@macro Toast.radius}
  final BorderRadius? radius;

  /// {@macro Toast.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Toast.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Toast.closeIconPosition}
  final Position? closeIconPosition;

  /// {@macro Toast.constraints}
  final BoxConstraints? constraints;

  /// {@macro Toast.closeIcon}
  final Widget? closeIcon;

  /// {@macro Toast.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@macro Toast.mainAxisSize}
  final MainAxisSize? mainAxisSize;

  /// Linearly interpolates between [a] and [b] by [t].
  static ToastTheme? lerp(
    ToastTheme? a,
    ToastTheme? b,
    double t,
  ) => _$ToastTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is ToastTheme &&
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
