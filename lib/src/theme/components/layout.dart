import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'layout.g.theme.dart';

/// A named step on the theme's gap scale.
///
/// Layout code names the relationship between two things rather than a pixel
/// count, and the theme decides what that is on each form factor.
enum GapSize {
  /// No space.
  none,

  /// Between an icon and its label.
  xs,

  /// Between related controls.
  sm,

  /// Between the rows of a group.
  md,

  /// Between cards and sections.
  lg,

  /// Between the columns of a page.
  xl,
}

/// The theme's layout metrics: page margins and the gap scale that
/// `Gap`, `UnaRow`, `UnaColumn` and `PageContainer` read.
@themeGen
@immutable
class LayoutTheme with _$LayoutTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const LayoutTheme({
    bool canMerge = true,
    this.pagePadding,
    this.pageMaxWidth,
    this.gapXs,
    this.gapSm,
    this.gapMd,
    this.gapLg,
    this.gapXl,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// Padding between the window edge and page content.
  final EdgeInsetsGeometry? pagePadding;

  /// The widest page content grows before it is centred.
  final double? pageMaxWidth;

  /// The `xs` step of the gap scale.
  final double? gapXs;

  /// The `sm` step of the gap scale.
  final double? gapSm;

  /// The `md` step of the gap scale.
  final double? gapMd;

  /// The `lg` step of the gap scale.
  final double? gapLg;

  /// The `xl` step of the gap scale.
  final double? gapXl;

  /// The extent of [size] in logical pixels.
  double gap(GapSize size) => switch (size) {
    GapSize.none => 0,
    GapSize.xs => gapXs ?? 4,
    GapSize.sm => gapSm ?? 8,
    GapSize.md => gapMd ?? 12,
    GapSize.lg => gapLg ?? 16,
    GapSize.xl => gapXl ?? 24,
  };

  /// Linearly interpolates between two themes.
  static LayoutTheme? lerp(LayoutTheme? a, LayoutTheme? b, double t) =>
      _$LayoutTheme.lerp(a, b, t);
}
