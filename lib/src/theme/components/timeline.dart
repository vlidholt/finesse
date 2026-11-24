import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'timeline.g.theme.dart';

/// The theme of `Timeline`: every value the widget does not set itself.
@themeGen
@immutable
class TimelineTheme with _$TimelineTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const TimelineTheme({
    bool canMerge = true,
    this.lineColor,
    this.lineWidth,
    this.gap,
    this.spacing,
    this.lineGap,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The colour of the line joining the entries.
  final Color? lineColor;

  /// The width of that line.
  final double? lineWidth;

  /// The gap between an entry's marker and its content.
  final double? gap;

  /// The space between one entry and the next.
  final double? spacing;

  /// The space left between a marker and the line.
  final double? lineGap;

  /// Linearly interpolates between two themes.
  static TimelineTheme? lerp(TimelineTheme? a, TimelineTheme? b, double t) =>
      _$TimelineTheme.lerp(a, b, t);
}
