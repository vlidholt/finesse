import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'command.g.theme.dart';

/// {@template CommandTheme}
/// Theme for the `Command` widget.
/// {@endtemplate}
@themeGen
@immutable
class CommandTheme with _$CommandTheme {
  /// {@macro CommandTheme}
  const CommandTheme({
    bool canMerge = true,
    this.backgroundColor,
    this.decoration,
    this.padding,
    this.searchPadding,
    this.optionsPadding,
    this.groupHeadingStyle,
    this.groupHeadingPadding,
    this.itemPadding,
    this.itemTextStyle,
    this.itemSelectedBackgroundColor,
    this.itemSelectedForegroundColor,
    this.itemForegroundColor,
    this.itemRadius,
    this.itemGap,
    this.height,
    this.width,
    this.emptyPadding,
    this.emptyTextStyle,
    this.searchDecoration,
    this.searchHeight,
    this.searchIconColor,
    this.searchIconSize,
    this.searchGap,
    this.searchInputPadding,
    this.listMaxHeight,
    this.groupPadding,
    this.dialogItemRadius,
    this.itemIconSize,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Command.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Command.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Command.padding}
  final EdgeInsetsGeometry? padding;

  /// The padding around the search field.
  final EdgeInsetsGeometry? searchPadding;

  /// The padding around the scrollable option list.
  final EdgeInsetsGeometry? optionsPadding;

  /// The style of a `CommandGroup` heading.
  final TextStyle? groupHeadingStyle;

  /// The padding around a `CommandGroup` heading.
  final EdgeInsetsGeometry? groupHeadingPadding;

  /// The padding inside a `CommandItem`.
  final EdgeInsetsGeometry? itemPadding;

  /// The text style of a `CommandItem`.
  final TextStyle? itemTextStyle;

  /// The background color of the highlighted item.
  final Color? itemSelectedBackgroundColor;

  /// The content color of the highlighted item.
  final Color? itemSelectedForegroundColor;

  /// The content color of a non-highlighted item.
  final Color? itemForegroundColor;

  /// The corner radius of an item.
  final BorderRadiusGeometry? itemRadius;

  /// The gap between an item's leading widget, label and trailing widget.
  final double? itemGap;

  /// {@macro Command.height}
  final double? height;

  /// {@macro Command.width}
  final double? width;

  /// The padding around the empty state.
  final EdgeInsetsGeometry? emptyPadding;

  /// The style of the empty state's text, `.cn-command-empty`'s `text-sm`.
  final TextStyle? emptyTextStyle;

  /// The decoration of the box around the search field — shadcn's
  /// `.cn-command-input-group`: an `--input` wash inside a soft outline,
  /// with no focus ring.
  final FinesseDecoration? searchDecoration;

  /// The height of the search box, `.cn-command-input-group`'s `h-8!`.
  final double? searchHeight;

  /// The colour of the search icon (`.cn-command-input-icon`'s `opacity-50`
  /// over the addon's muted foreground).
  final Color? searchIconColor;

  /// The size of the search icon, `size-4`.
  final double? searchIconSize;

  /// The gap between the search icon and the input's text.
  final double? searchGap;

  /// The padding inside the search box, around icon and text.
  final EdgeInsetsGeometry? searchInputPadding;

  /// The tallest the scrollable list may grow, `.cn-command-list`'s
  /// `max-h-72`. The palette shrinks below it when the results are shorter.
  final double? listMaxHeight;

  /// The padding around each group of items, `.cn-command-group`'s `p-1`.
  final EdgeInsetsGeometry? groupPadding;

  /// The corner radius of an item inside a command *dialog*, where shadcn
  /// rounds a step past the inline [itemRadius]
  /// (`in-data-[slot=dialog-content]:rounded-lg!`).
  final BorderRadiusGeometry? dialogItemRadius;

  /// The size of an item's leading icon,
  /// `[&_svg:not([class*='size-'])]:size-4`.
  final double? itemIconSize;

  /// Linearly interpolates between [a] and [b] by [t].
  static CommandTheme? lerp(
    CommandTheme? a,
    CommandTheme? b,
    double t,
  ) => _$CommandTheme.lerp(a, b, t);
}
