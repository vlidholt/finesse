import 'dart:ui';

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'context_menu.g.theme.dart';

/// {@template ContextMenuTheme}
/// Theme for the `ContextMenu` widget.
/// {@endtemplate}
@themeGen
@immutable
class ContextMenuTheme with _$ContextMenuTheme {
  /// {@macro ContextMenuTheme}
  const ContextMenuTheme({
    bool canMerge = true,
    this.constraints,
    this.padding,
    this.leadingPadding,
    this.trailingPadding,
    this.itemPadding,
    this.insetPadding,
    this.anchor,
    this.showDelay,
    this.height,
    this.buttonVariant,
    this.decoration,
    this.textStyle,
    this.selectedTextStyle,
    this.trailingTextStyle,
    this.selectedTrailingTextStyle,
    this.destructiveForegroundColor,
    this.destructiveSelectedBackgroundColor,
    this.itemConstraints,
    this.subMenuPadding,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.closeOnTap,
    this.effects,
    this.shadows,
    this.itemDecoration,
    this.filter,
    this.popoverReverseDuration,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Popover.reverseDuration}
  final Duration? popoverReverseDuration;

  /// {@macro ContextMenu.constraints}
  final BoxConstraints? constraints;

  /// {@macro ContextMenu.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro ContextMenuItem.leadingPadding}
  final EdgeInsetsGeometry? leadingPadding;

  /// {@macro ContextMenuItem.trailingPadding}
  final EdgeInsetsGeometry? trailingPadding;

  /// {@macro ContextMenuItem.padding}
  final EdgeInsetsGeometry? itemPadding;

  /// {@macro ContextMenuItem.insetPadding}
  final EdgeInsetsGeometry? insetPadding;

  /// {@macro ContextMenuItem.anchor}
  final AnchorBase? anchor;

  /// {@macro ContextMenuItem.showDelay}
  final Duration? showDelay;

  /// {@macro ContextMenuItem.height}
  final double? height;

  /// {@macro ContextMenuItem.buttonVariant}
  final ButtonVariant? buttonVariant;

  /// {@macro ContextMenuItem.decoration}
  final FinesseDecoration? itemDecoration;

  /// {@macro ContextMenuItem.textStyle}
  final TextStyle? textStyle;

  /// {@macro ContextMenuItem.selectedTextStyle}
  final TextStyle? selectedTextStyle;

  /// {@macro ContextMenuItem.trailingTextStyle}
  final TextStyle? trailingTextStyle;

  /// The style of an item's trailing widget while the item is hovered or its
  /// submenu is open — shadcn's shortcut going
  /// `group-focus:text-accent-foreground`.
  final TextStyle? selectedTrailingTextStyle;

  /// The text and icon colour of a destructive item,
  /// `data-[variant=destructive]:text-destructive`.
  final Color? destructiveForegroundColor;

  /// The highlight behind a hovered destructive item,
  /// `data-[variant=destructive]:focus:bg-destructive/10`
  /// (`/20` in dark mode).
  final Color? destructiveSelectedBackgroundColor;

  /// Constraints applied to every item row.
  final BoxConstraints? itemConstraints;

  /// {@macro ContextMenu.padding}
  final EdgeInsetsGeometry? subMenuPadding;

  /// {@macro ContextMenuItem.backgroundColor}
  final Color? backgroundColor;

  /// {@macro ContextMenuItem.selectedBackgroundColor}
  final Color? selectedBackgroundColor;

  /// {@macro ContextMenuItem.closeOnTap}
  final bool? closeOnTap;

  /// {@macro Popover.effects}
  final List<Effect<dynamic>>? effects;

  /// {@macro Popover.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Popover.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Popover.filter}
  final ImageFilter? filter;

  /// Linearly interpolates between [a] and [b] by [t].
  static ContextMenuTheme? lerp(
    ContextMenuTheme? a,
    ContextMenuTheme? b,
    double t,
  ) => _$ContextMenuTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is ContextMenuTheme &&
      listEquals(effects, other.effects) &&
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(effects: effects, shadows: shadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(effects ?? const []),
    Object.hashAll(shadows ?? const []),
  );
}
