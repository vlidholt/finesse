import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'phosphor_icon.g.theme.dart';

/// The theme of `PhosphorIcon`: how much a small icon's line is thickened.
///
/// The regular Phosphor weight draws its line a sixteenth of the icon's
/// size: 1.5 logical pixels at 24, 1 at 16, 0.75 at 12. A small icon
/// therefore looks thinner than a large one. `PhosphorIcon` adds to the
/// line of an icon smaller than [referenceSize], by [strength] times what
/// it is short of the reference's.
///
/// ```dart
/// ThemeData(
///   // Hold the line at a 20-pixel icon's all the way down.
///   phosphorIconTheme: const PhosphorIconTheme(
///     referenceSize: 20,
///     strength: 1,
///   ),
/// )
/// ```
@themeGen
@immutable
class PhosphorIconTheme with _$PhosphorIconTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const PhosphorIconTheme({
    bool canMerge = true,
    this.referenceSize,
    this.strength,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The regular weight's line as a share of the icon's size: 16 units of
  /// Phosphor's 256-unit grid.
  static const double regularStroke = 16 / 256;

  /// The size, in logical pixels, at which a regular icon is drawn exactly
  /// as the font has it; larger icons are too. 24 where no theme gives one.
  final double? referenceSize;

  /// How much of the difference a smaller icon's line makes up, from 0 to
  /// 1. 0.5 where no theme gives one.
  ///
  /// At 1 every icon below [referenceSize] has the line an icon of that
  /// size has, 1.5 logical pixels at the default. At 0.5 it loses half as
  /// much on the way down as the font does: 1.25 at 16 and 1.125 at 12,
  /// where the font alone gives 1 and 0.75. At 0 nothing is added, and a
  /// `PhosphorIcon` is a plain `Icon`.
  final double? strength;

  /// What is added to the line of a regular icon [size] logical pixels
  /// tall, in logical pixels: nothing at [referenceSize] and above.
  double extraStroke(double size) {
    final reference = referenceSize ?? 24;
    final share = (strength ?? .5).clamp(0.0, 1.0);
    if (!(size > 0) || !(size < reference) || !(share > 0)) return 0;
    return share * (reference - size) * regularStroke;
  }

  /// The width of the line of a regular icon [size] logical pixels tall as
  /// a `PhosphorIcon` draws it, in logical pixels.
  double strokeAt(double size) => size * regularStroke + extraStroke(size);

  /// Linearly interpolates between two themes.
  static PhosphorIconTheme? lerp(
    PhosphorIconTheme? a,
    PhosphorIconTheme? b,
    double t,
  ) => _$PhosphorIconTheme.lerp(a, b, t);
}
