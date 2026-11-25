import 'dart:ui' show ImageFilter;

import 'package:finesse/src/liquid_glass/liquid_glass_theme.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'toast.g.theme.dart';

/// {@template ToastTheme}
/// The theme of a `Toast`: its surface, its text and the colours its
/// variants give their icon.
///
/// Every variant shares one surface — a toast is a popover surface, glass in
/// a style whose popovers are — and differs only in the icon it leads with.
/// {@endtemplate}
@themeGen
@immutable
class ToastTheme with _$ToastTheme {
  /// {@macro ToastTheme}
  const ToastTheme({
    bool canMerge = true,
    this.liquidGlass,
    this.backgroundColor,
    this.filter,
    this.border,
    this.borderRadius,
    this.shadows,
    this.padding,
    this.gap,
    this.titleStyle,
    this.descriptionStyle,
    this.iconSize,
    this.successColor,
    this.warningColor,
    this.destructiveColor,
    this.loadingColor,
    this.duration,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// Whether toasts draw with Liquid Glass, over
  /// `ThemeData.liquidGlass.mode`; null follows the theme.
  final LiquidGlassMode? liquidGlass;

  /// The fill of the toast. Translucent in a style with glass popovers.
  final Color? backgroundColor;

  /// The filter applied to what is behind the toast, for a translucent
  /// [backgroundColor]; null in a style with solid surfaces.
  final ImageFilter? filter;

  /// The outline of the toast.
  final FinesseBorder? border;

  /// The corners of the toast.
  final BorderRadius? borderRadius;

  /// The shadows the toast casts.
  final List<BoxShadow>? shadows;

  /// The padding around the toast's content.
  final EdgeInsetsGeometry? padding;

  /// The space between the leading icon, the text and the action.
  final double? gap;

  /// The style of the title.
  final TextStyle? titleStyle;

  /// The style of the description.
  final TextStyle? descriptionStyle;

  /// The size of the leading icon or spinner.
  final double? iconSize;

  /// The colour of a success toast's icon.
  final Color? successColor;

  /// The colour of a warning toast's icon.
  final Color? warningColor;

  /// The colour of a destructive toast's icon.
  final Color? destructiveColor;

  /// The colour of a loading toast's spinner.
  final Color? loadingColor;

  /// How long a toast stays before it leaves by itself, when the toast does
  /// not say. `Duration.zero` keeps toasts until they are dismissed.
  final Duration? duration;

  /// Linearly interpolates between [a] and [b] by [t].
  static ToastTheme? lerp(
    ToastTheme? a,
    ToastTheme? b,
    double t,
  ) => _$ToastTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and the theme would
  // be switched on every build. Compare the list by value, then let the
  // generated `==` compare everything else against a copy that shares it.
  @override
  bool operator ==(Object other) =>
      other is ToastTheme &&
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(shadows: shadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(shadows ?? const []),
  );
}

/// {@template ToasterTheme}
/// The theme of the `Toaster`: where the stack of toasts sits and how it is
/// stacked.
///
/// There are no durations or curves here: the stack moves on the theme's
/// `Motion`.
/// {@endtemplate}
@themeGen
@immutable
class ToasterTheme with _$ToasterTheme {
  /// {@macro ToasterTheme}
  const ToasterTheme({
    bool canMerge = true,
    this.alignment,
    this.padding,
    this.width,
    this.maxVisible,
    this.gap,
    this.stackOffset,
    this.stackScale,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// Where the stack sits: the bottom end corner on a desktop, the bottom
  /// centre on a phone.
  final AlignmentGeometry? alignment;

  /// The space between the stack and the edges of the screen, on top of the
  /// safe area and of whatever the screen has put in the way.
  final EdgeInsetsGeometry? padding;

  /// The most a toast is wide. It is narrower where the screen, less its
  /// [padding], is: on a phone a toast spans the page.
  final double? width;

  /// How many toasts show at once. Older ones wait behind the stack and
  /// come back as newer ones leave.
  final int? maxVisible;

  /// The space between two toasts while the stack is open.
  final double? gap;

  /// How far each toast behind the front one shows past it while the stack
  /// is closed.
  final double? stackOffset;

  /// How much smaller each toast is than the one in front of it while the
  /// stack is closed: .05 makes the second 95% wide and the third 90%.
  final double? stackScale;

  /// Linearly interpolates between [a] and [b] by [t].
  static ToasterTheme? lerp(
    ToasterTheme? a,
    ToasterTheme? b,
    double t,
  ) => _$ToasterTheme.lerp(a, b, t);
}
