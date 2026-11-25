import 'dart:ui';

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'menubar.g.theme.dart';

/// {@template MenubarTheme}
/// Theme for the `Menubar` widget.
/// {@endtemplate}
@themeGen
@immutable
class MenubarTheme with _$MenubarTheme {
  /// {@macro MenubarTheme}
  const MenubarTheme({
    bool canMerge = true,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.border,
    this.constraints,
    this.contextMenuPadding,
    this.effects,
    this.shadows,
    this.decoration,
    this.filter,
    this.anchor,
    this.buttonVariant,
    this.buttonSize,
    this.buttonMouseCursor,
    this.buttonWidth,
    this.buttonHeight,
    this.buttonPadding,
    this.buttonBackgroundColor,
    this.buttonSelectedBackgroundColor,
    this.buttonHoverBackgroundColor,
    this.buttonForegroundColor,
    this.buttonHoverForegroundColor,
    this.buttonPressedBackgroundColor,
    this.buttonPressedForegroundColor,
    this.buttonShadows,
    this.stripShadows,
    this.buttonGradient,
    this.buttonTextDecoration,
    this.buttonHoverTextDecoration,
    this.buttonDecoration,
    this.buttonGap,
    this.buttonMainAxisAlignment,
    this.buttonCrossAxisAlignment,
    this.buttonHoverStrategies,
    this.buttonTextDirection,
    this.buttonExpands,
    this.selectOnHover,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Menubar.borderRadius}
  final BorderRadiusGeometry? borderRadius;

  /// {@macro Menubar.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Menubar.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Menubar.border}
  final FinesseBorder? border;

  /// {@macro ContextMenu.constraints}
  final BoxConstraints? constraints;

  /// {@macro ContextMenu.padding}
  final EdgeInsetsGeometry? contextMenuPadding;

  /// {@macro Popover.effects}
  final List<Effect<dynamic>>? effects;

  /// {@macro Popover.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Popover.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Popover.filter}
  final ImageFilter? filter;

  /// {@macro MenubarItem.anchor}
  final AnchorBase? anchor;

  /// {@macro Button.variant}
  final ButtonVariant? buttonVariant;

  /// {@macro Button.size}
  final ButtonSize? buttonSize;

  /// {@macro Button.mouseCursor}
  final MouseCursor? buttonMouseCursor;

  /// {@macro Button.width}
  final double? buttonWidth;

  /// {@macro MenubarItem.height}
  final double? buttonHeight;

  /// {@macro Button.padding}
  final EdgeInsetsGeometry? buttonPadding;

  /// {@macro Button.backgroundColor}
  final Color? buttonBackgroundColor;

  /// {@macro MenubarItem.selectedBackgroundColor}
  final Color? buttonSelectedBackgroundColor;

  /// {@macro Button.hoverBackgroundColor}
  final Color? buttonHoverBackgroundColor;

  /// {@macro Button.foregroundColor}
  final Color? buttonForegroundColor;

  /// {@macro Button.hoverForegroundColor}
  final Color? buttonHoverForegroundColor;

  /// {@macro Button.pressedBackgroundColor}
  final Color? buttonPressedBackgroundColor;

  /// {@macro Button.pressedForegroundColor}
  final Color? buttonPressedForegroundColor;

  /// {@macro Button.shadows}
  final List<BoxShadow>? buttonShadows;

  /// {@macro Menubar.stripShadows}
  final List<BoxShadow>? stripShadows;

  /// {@macro Button.gradient}
  final Gradient? buttonGradient;

  /// {@macro Button.textDecoration}
  final TextDecoration? buttonTextDecoration;

  /// {@macro Button.hoverTextDecoration}
  final TextDecoration? buttonHoverTextDecoration;

  /// {@macro Button.decoration}
  final FinesseDecoration? buttonDecoration;

  /// {@macro Button.gap}
  final double? buttonGap;

  /// {@macro Button.mainAxisAlignment}
  final MainAxisAlignment? buttonMainAxisAlignment;

  /// {@macro Button.crossAxisAlignment}
  final CrossAxisAlignment? buttonCrossAxisAlignment;

  /// {@macro Button.hoverStrategies}
  final HoverStrategies? buttonHoverStrategies;

  /// {@macro Button.textDirection}
  final TextDirection? buttonTextDirection;

  /// {@macro Button.expands}
  final bool? buttonExpands;

  /// {@macro Menubar.selectOnHover}
  final bool? selectOnHover;

  /// Linearly interpolates between [a] and [b] by [t].
  static MenubarTheme? lerp(
    MenubarTheme? a,
    MenubarTheme? b,
    double t,
  ) => _$MenubarTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is MenubarTheme &&
      listEquals(effects, other.effects) &&
      listEquals(shadows, other.shadows) &&
      listEquals(buttonShadows, other.buttonShadows) &&
      listEquals(stripShadows, other.stripShadows) &&
      super ==
          other.copyWith(
            effects: effects,
            shadows: shadows,
            buttonShadows: buttonShadows,
            stripShadows: stripShadows,
          );

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(effects ?? const []),
    Object.hashAll(shadows ?? const []),
    Object.hashAll(buttonShadows ?? const []),
    Object.hashAll(stripShadows ?? const []),
  );
}
