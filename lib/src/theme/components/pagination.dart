import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'pagination.g.theme.dart';

/// {@template PaginationTheme}
/// Theme for the `Pagination` widget.
/// {@endtemplate}
@themeGen
@immutable
class PaginationTheme with _$PaginationTheme {
  /// {@macro PaginationTheme}
  const PaginationTheme({
    bool canMerge = true,
    this.gap,
    this.mainAxisAlignment,
    this.siblingCount,
    this.boundaryCount,
    this.showEdges,
    this.ellipsisTextStyle,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The gap between pagination items.
  final double? gap;

  /// {@macro Pagination.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@macro Pagination.siblingCount}
  final int? siblingCount;

  /// {@macro Pagination.boundaryCount}
  final int? boundaryCount;

  /// {@macro Pagination.showEdges}
  final bool? showEdges;

  /// The style of the ellipsis shown in place of skipped pages.
  final TextStyle? ellipsisTextStyle;

  /// Linearly interpolates between [a] and [b] by [t].
  static PaginationTheme? lerp(
    PaginationTheme? a,
    PaginationTheme? b,
    double t,
  ) => _$PaginationTheme.lerp(a, b, t);
}
