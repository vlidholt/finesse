import 'dart:ui' as ui;

import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/widgets.dart';

/// The surface of a bar at the bottom of a screen, shared by
/// `BottomNavigationBar` and `Toolbar`: a floating glass pill above the
/// page, or a bar docked along the bottom edge with a hairline over it.
///
/// It is styled by the theme's `BottomNavigationBarTheme` — fill, blur,
/// outline, rim, shadow, padding, margin — and keeps clear of the bottom
/// safe area either way. Internal.
class BottomBarSurface extends StatelessWidget {
  /// Creates a bar surface around [child].
  const BottomBarSurface({
    required this.floating,
    required this.child,
    super.key,
  });

  /// Whether the bar floats as a pill rather than spanning the edge.
  final bool floating;

  /// The bar's content, inside its padding.
  final Widget child;

  /// Whether a bar in [context] floats when it is not told.
  static bool floatsIn(BuildContext context) =>
      Theme.of(context).bottomNavigationBarTheme.floating ?? true;

  /// How much height the surface adds around its content in [context]:
  /// padding, margin, outline and the bottom safe area.
  static double extentAround(BuildContext context, {required bool floating}) {
    final bar = Theme.of(context).bottomNavigationBarTheme;
    final direction = Directionality.of(context);
    final padding = (bar.padding ?? const EdgeInsets.all(6)).resolve(
      direction,
    );
    final margin = floating
        ? (bar.margin ?? const EdgeInsets.only(bottom: 22)).resolve(direction)
        : EdgeInsets.zero;
    return padding.vertical +
        margin.vertical +
        MediaQuery.paddingOf(context).bottom +
        // The outline: all round a floating pill, along the top of a docked
        // bar.
        (floating ? 2 : 1);
  }

  /// The corner radius of the surface in [context].
  static BorderRadius radiusIn(BuildContext context, {required bool floating}) {
    final theme = Theme.of(context);
    return floating
        ? theme.bottomNavigationBarTheme.radius ?? theme.radii.full
        : BorderRadius.zero;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bar = theme.bottomNavigationBarTheme;
    final radius = radiusIn(context, floating: floating);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final borderColor = bar.borderColor ?? theme.colorScheme.border;
    // A floating bar's hairline can catch the light along its top edge;
    // see `BottomNavigationBarTheme.rimColor`.
    final rimColor = floating ? bar.rimColor : null;
    Widget content = Container(
      padding: (bar.padding ?? const EdgeInsets.all(6)).add(
        EdgeInsets.only(bottom: floating ? 0 : bottomInset),
      ),
      decoration: BoxDecoration(
        color: bar.backgroundColor ?? theme.colorScheme.card,
        borderRadius: radius,
        border: floating
            // With a rim the hairline is painted over the bar, below; the
            // border still takes its point of layout.
            ? Border.all(
                color: rimColor == null ? borderColor : const Color(0x00000000),
              )
            : Border(top: BorderSide(color: borderColor)),
      ),
      child: child,
    );
    if (rimColor != null) {
      content = CustomPaint(
        foregroundPainter: _RimPainter(
          radius: radius,
          color: borderColor,
          rimColor: rimColor,
        ),
        child: content,
      );
    }
    final surface = Backdrop(
      blur: bar.blur ?? 0,
      saturation: bar.saturation ?? 1,
      borderRadius: radius,
      child: content,
    );

    final semantic = Semantics(
      container: true,
      explicitChildNodes: true,
      child: surface,
    );
    if (!floating) return semantic;
    return Padding(
      padding: (bar.margin ?? const EdgeInsets.only(bottom: 22)).add(
        EdgeInsets.only(bottom: bottomInset),
      ),
      child: Center(
        heightFactor: 1,
        child: DecoratedBox(
          // Outside the clip, and after the bar: a shadow painted first
          // would be sampled by the filter and blurred back into the glass.
          position: DecorationPosition.foreground,
          decoration: ShadowDecoration.box(
            borderRadius: radius,
            shadows: bar.shadows ?? theme.style.floatingShadow,
          ),
          child: semantic,
        ),
      ),
    );
  }
}

/// The hairline of a floating bar, brighter along its top edge: [rimColor]
/// at the top, fading into [color] by the middle of the bar — the way light
/// from above catches the rim of a sheet of glass.
class _RimPainter extends CustomPainter {
  const _RimPainter({
    required this.radius,
    required this.color,
    required this.rimColor,
  });

  final BorderRadius radius;
  final Color color;
  final Color rimColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    // A one-point stroke centred half a point inside the edge: where
    // `Border.all` paints its hairline.
    final outline = radius.toRRect(Offset.zero & size).deflate(.5);
    canvas.drawRRect(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          [rimColor, color],
          const [0, .55],
        ),
    );
  }

  @override
  bool shouldRepaint(_RimPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.color != color ||
      oldDelegate.rimColor != rimColor;
}
