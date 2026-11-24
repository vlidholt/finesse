import 'package:finesse/src/raw_components/portal.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'breadcrumb.g.theme.dart';

/// {@template BreadcrumbTheme}
/// Theme for the `Breadcrumb` widget.
/// {@endtemplate}
@themeGen
@immutable
class BreadcrumbTheme with _$BreadcrumbTheme {
  /// {@macro BreadcrumbTheme}
  const BreadcrumbTheme({
    bool canMerge = true,
    this.separator,
    this.ellipsis,
    this.separatorSize,
    this.separatorColor,
    this.ellipsisSize,
    this.spacing,
    this.itemTextStyle,
    this.linkTextStyle,
    this.linkNormalTextColor,
    this.linkHoverTextColor,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.dropdownMenuBackgroundColor,
    this.dropdownMenuPadding,
    this.dropdownTextStyle,
    this.dropdownItemPadding,
    this.dropdownMenuAnchor,
    this.dropdownArrowGap,
    this.lastItemTextColor,
    this.showDropdownArrow,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The widget between items. Defaults to `BreadcrumbSeparator`.
  final Widget? separator;

  /// The widget `BreadcrumbEllipsis` shows for collapsed items. Defaults
  /// to Lucide's ellipsis icon at `ellipsisSize`.
  final Widget? ellipsis;

  /// {@macro Breadcrumb.separatorSize}
  final double? separatorSize;

  /// {@macro Breadcrumb.separatorColor}
  final Color? separatorColor;

  /// {@macro Breadcrumb.ellipsisSize}
  final double? ellipsisSize;

  /// {@macro Breadcrumb.spacing}
  final double? spacing;

  /// {@macro Breadcrumb.itemTextStyle}
  final TextStyle? itemTextStyle;

  /// {@macro Breadcrumb.linkTextStyle}
  final TextStyle? linkTextStyle;

  /// {@macro Breadcrumb.linkNormalTextColor}
  final Color? linkNormalTextColor;

  /// {@macro Breadcrumb.linkHoverTextColor}
  final Color? linkHoverTextColor;

  /// {@macro Breadcrumb.wrapAlignment}
  final WrapAlignment? mainAxisAlignment;

  /// {@macro Breadcrumb.wrapCrossAxisAlignment}
  final WrapCrossAlignment? crossAxisAlignment;

  /// {@macro Breadcrumb.dropdownMenuBackgroundColor}
  final Color? dropdownMenuBackgroundColor;

  /// {@macro Breadcrumb.dropdownMenuPadding}
  final EdgeInsetsGeometry? dropdownMenuPadding;

  /// {@macro Breadcrumb.dropdownTextStyle}
  final TextStyle? dropdownTextStyle;

  /// {@macro Breadcrumb.dropdownItemPadding}
  final EdgeInsetsGeometry? dropdownItemPadding;

  /// {@macro Breadcrumb.dropdownMenuAnchor}
  final AnchorBase? dropdownMenuAnchor;

  /// {@macro Breadcrumb.dropdownArrowGap}
  final double? dropdownArrowGap;

  /// {@macro Breadcrumb.lastItemTextColor}
  final Color? lastItemTextColor;

  /// {@macro Breadcrumb.showDropdownArrow}
  final bool? showDropdownArrow;

  /// Linearly interpolates between [a] and [b] by [t].
  static BreadcrumbTheme? lerp(
    BreadcrumbTheme? a,
    BreadcrumbTheme? b,
    double t,
  ) => _$BreadcrumbTheme.lerp(a, b, t);
}
