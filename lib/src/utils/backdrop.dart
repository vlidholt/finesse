import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Blurs and saturates whatever is painted behind [child], clipped to
/// [borderRadius].
///
/// This is the filter half of a frosted-glass surface: `Glass`, `AppBar`,
/// `BottomNavigationBar` and translucent `Card`s put their tint on top of
/// one. With no [blur] and a [saturation] of 1 it builds nothing and returns
/// [child] as is, so an opaque style pays for no backdrop layer.
///
/// [blur] is the Gaussian sigma in logical pixels, the same number CSS takes
/// in `backdrop-filter: blur(24px)`.
class Backdrop extends StatelessWidget {
  /// Creates a backdrop filter around [child].
  const Backdrop({
    required this.child,
    this.blur = 0,
    this.saturation = 1,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  /// The sigma of the Gaussian blur; 0 or less disables it.
  final double blur;

  /// How much the backdrop is saturated; 1 leaves it alone.
  final double saturation;

  /// The corners the filtered area is clipped to.
  final BorderRadiusGeometry borderRadius;

  /// The widget painted over the filtered backdrop.
  final Widget child;

  static final _filters = <(double, double), ImageFilter>{};

  /// The filter for [blur] and [saturation], or null when neither does
  /// anything.
  ///
  /// Filters are cached per pair of values: a theme holds a handful of them
  /// and every glass surface on screen would otherwise allocate its own on
  /// each build.
  static ImageFilter? filterFor({required double blur, double saturation = 1}) {
    final blurs = blur > 0;
    final saturates = saturation != 1;
    if (!blurs && !saturates) return null;
    return _filters.putIfAbsent((blur, saturation), () {
      final blurFilter = blurs
          ? ImageFilter.blur(
              sigmaX: blur,
              sigmaY: blur,
              tileMode: TileMode.mirror,
            )
          : null;
      if (!saturates) return blurFilter!;
      // The luminance-preserving saturation matrix CSS's `saturate()` uses.
      final s = saturation;
      final matrix = ColorFilter.matrix([
        .213 + .787 * s, .715 - .715 * s, .072 - .072 * s, 0, 0, //
        .213 - .213 * s, .715 + .285 * s, .072 - .072 * s, 0, 0,
        .213 - .213 * s, .715 - .715 * s, .072 + .928 * s, 0, 0,
        0, 0, 0, 1, 0,
      ]);
      if (blurFilter == null) return matrix;
      return ImageFilter.compose(outer: matrix, inner: blurFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = filterFor(blur: blur, saturation: saturation);
    if (filter == null) return child;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(filter: filter, child: child),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('blur', blur))
      ..add(DoubleProperty('saturation', saturation));
  }
}
