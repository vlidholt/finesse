import 'dart:ui';

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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
    this.shadows,
    this.itemDecoration,
    this.filter,
    this.indicatorSize,
    this.labelTextStyle,
    this.labelPadding,
    this.shortcutTextStyle,
    this.dividerColor,
    this.dividerMargin,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro ContextMenu.constraints}
  final BoxConstraints? constraints;

  /// {@macro ContextMenu.padding}
  final EdgeInsetsGeometry? padding;

  /// The padding of the leading widget, defaults to
  /// `EdgeInsets.only(right: 8)`.
  final EdgeInsetsGeometry? leadingPadding;

  /// The padding of the trailing widget, defaults to
  /// `EdgeInsets.only(left: 8)`.
  final EdgeInsetsGeometry? trailingPadding;

  /// The padding of the context menu item, defaults to
  /// `EdgeInsets.symmetric(horizontal: 4)`.
  final EdgeInsetsGeometry? itemPadding;

  /// The row's own padding. Defaults to the style's item padding
  /// (`StyleTokens.itemPaddingX`, shadcn's `px-2`) on both sides, plus a
  /// 24px icon column at the start when the variant is inset.
  final EdgeInsetsGeometry? insetPadding;

  /// The anchor of the context menu item, defaults to
  /// ```dart
  /// AnchorAuto(
  ///   offset: Offset(-8, parentItemController != null ? -5 : -3),
  ///   targetAnchor: Alignment.topRight,
  ///   followerAnchor: Alignment.bottomRight,
  /// )
  /// ```
  final AnchorBase? anchor;

  /// How long an item with a submenu stays highlighted, with its submenu
  /// open, after the pointer leaves it. Defaults to 100ms.
  ///
  /// The grace period lets the pointer cross the gap to the submenu without
  /// the submenu closing under it. Reaching another row of the same menu
  /// ends it at once.
  final Duration? showDelay;

  /// The height of the context menu item, defaults to 32.
  final double? height;

  /// The variant of the button of the context menu item, defaults to
  /// [ButtonVariant.ghost].
  final ButtonVariant? buttonVariant;

  /// The decoration of the context menu item, defaults to
  /// `FinesseDecoration(secondaryBorder: FinesseBorder.none)`.
  final FinesseDecoration? itemDecoration;

  /// The text style of the context menu item, defaults to
  /// `small.copyWith(fontWeight: FontWeight.normal)`.
  final TextStyle? textStyle;

  /// The text style of the item while it is selected or hovered.
  ///
  /// Defaults to [textStyle]. It exists because a menu whose selection is a
  /// strong fill needs its label to change with it.
  final TextStyle? selectedTextStyle;

  /// The text style of the trailing widget, defaults to
  /// `muted.copyWith(fontSize: 12, height: 1)`.
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

  /// The background color of the context menu item, defaults to
  /// `null`.
  final Color? backgroundColor;

  /// The background color of the context menu item when it is selected,
  /// defaults to `theme.colorScheme.accent`.
  final Color? selectedBackgroundColor;

  /// {@macro MenuItem.closeOnTap}
  final bool? closeOnTap;

  /// {@macro Popover.shadows}
  final List<BoxShadow>? shadows;

  /// {@macro Popover.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Popover.filter}
  final ImageFilter? filter;

  /// The side of the box a checkable row keeps for its check mark or dot,
  /// and every other row of the same menu keeps empty. Defaults to 16.
  ///
  /// The check mark is drawn at this size and the dot at half of it; the
  /// gap to the label is [leadingPadding]. The box grows with the text
  /// scale, so the mark keeps its size beside an enlarged label.
  final double? indicatorSize;

  /// The style of a `MenuLabel`, the heading of a group of rows.
  final TextStyle? labelTextStyle;

  /// The space around a `MenuLabel`, inside [itemPadding].
  final EdgeInsetsGeometry? labelPadding;

  /// The style of a row's `MenuShortcut`. Its colour is taken from
  /// [trailingTextStyle], or from [selectedTrailingTextStyle] while the
  /// row is highlighted.
  final TextStyle? shortcutTextStyle;

  /// The colour of a `MenuDivider`.
  final Color? dividerColor;

  /// The space around a `MenuDivider`.
  final EdgeInsetsGeometry? dividerMargin;

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
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(shadows: shadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(shadows ?? const []),
  );
}
