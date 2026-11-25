import 'dart:math' as math;

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

import 'harness.dart';

/// A soft wash of colour: a few large radial glows over a base colour.
///
/// It is what glass is shown over, so the blur has something to blur.
class Aurora extends StatelessWidget {
  /// Creates a wash of [glows] over [base].
  const Aurora({
    required this.base,
    required this.glows,
    this.child,
    super.key,
  });

  /// The colour under the glows.
  final Color base;

  /// Each glow: its colour, centre (as a fraction of the size) and radius
  /// (as a fraction of the longer side).
  final List<(Color, Alignment, double)> glows;

  /// Drawn over the wash.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AuroraPainter(base, glows),
      child: child,
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.base, this.glows);

  final Color base;
  final List<(Color, Alignment, double)> glows;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = base);
    final side = math.max(size.width, size.height);
    for (final (color, alignment, radius) in glows) {
      final centre = alignment.withinRect(rect);
      final r = radius * side;
      canvas.drawCircle(
        centre,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0, 1],
          ).createShader(Rect.fromCircle(center: centre, radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) => false;
}

/// A desktop window around [child]: rounded, with a title bar and a shadow.
class DesktopWindow extends StatelessWidget {
  /// Creates a window of [size] (the content area) under [theme].
  const DesktopWindow({
    required this.theme,
    required this.size,
    required this.child,
    this.title,
    super.key,
  });

  /// The theme of the window and its content.
  final ThemeData theme;

  /// The size of the content area, below the title bar.
  final Size size;

  /// The window's title, in the middle of its title bar.
  final String? title;

  /// The content.
  final Widget child;

  static const _titleBarHeight = 36.0;
  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    Widget light(Color color) => Container(
      width: 12,
      height: 12,
      margin: const EdgeInsetsDirectional.only(end: 8),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    final titleBar = Container(
      height: _titleBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          scheme.foreground.withValues(alpha: dark ? .04 : .025),
          scheme.background,
        ),
        border: Border(bottom: BorderSide(color: scheme.border)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                light(const Color(0xFFFF5F57)),
                light(const Color(0xFFFEBC2E)),
                light(const Color(0xFF28C840)),
              ],
            ),
          ),
          if (title case final title?)
            Text(
              title,
              style: theme.textTheme.small.copyWith(
                color: scheme.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
    return DecoratedBox(
      decoration: ShadowDecoration.box(
        borderRadius: _radius,
        shadows: [
          BoxShadow(
            color: const Color(0xFF0B1A1A).withValues(alpha: .18),
            blurRadius: 60,
            offset: const Offset(0, 24),
          ),
          BoxShadow(
            color: const Color(0xFF0B1A1A).withValues(alpha: .10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: Panel(
          theme: theme,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: size.width, child: titleBar),
              Panel(theme: theme, size: size, child: child),
            ],
          ),
        ),
      ),
    ).withForegroundBorder(
      borderRadius: _radius,
      color: dark
          ? const Color(0x33FFFFFF)
          : const Color(0xFF0B1A1A).withValues(alpha: .12),
    );
  }
}

/// A phone around [child]: a 390 × 844 screen in a dark bezel, with a
/// status bar and the system's safe area.
class PhoneFrame extends StatelessWidget {
  /// Creates a phone under [theme].
  const PhoneFrame({
    required this.theme,
    required this.child,
    super.key,
  });

  /// The theme of the screen, resolved for a phone.
  final ThemeData theme;

  /// The screen's content.
  final Widget child;

  /// The size of the screen.
  static const screen = Size(390, 844);

  static const _bezel = 12.0;
  static const _screenRadius = 52.0;

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    final statusStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: scheme.foreground,
    );
    final statusBar = SizedBox(
      height: 54,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(44, 18, 34, 0),
        child: Row(
          children: [
            Text('9:41', style: statusStyle),
            const Spacer(),
            PhosphorIcon(
              PhosphorIconsFill.cellSignalFull,
              size: 17,
              color: scheme.foreground,
            ),
            const SizedBox(width: 5),
            PhosphorIcon(
              PhosphorIconsBold.wifiHigh,
              size: 17,
              color: scheme.foreground,
            ),
            const SizedBox(width: 5),
            PhosphorIcon(
              PhosphorIconsFill.batteryFull,
              size: 22,
              color: scheme.foreground,
            ),
          ],
        ),
      ),
    );
    final island = Container(
      width: 122,
      height: 36,
      margin: const EdgeInsets.only(top: 11),
      decoration: const BoxDecoration(
        color: Color(0xFF000000),
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    );
    final homeIndicator = Container(
      width: 136,
      height: 5,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.foreground,
        borderRadius: const BorderRadius.all(Radius.circular(3)),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(_bezel),
      decoration: ShadowDecoration.box(
        color: const Color(0xFF111314),
        borderRadius: const BorderRadius.all(
          Radius.circular(_screenRadius + _bezel),
        ),
        border: Border.all(color: const Color(0xFF3A3F42), width: 1.5),
        shadows: [
          BoxShadow(
            color: const Color(0xFF0B1A1A).withValues(alpha: .28),
            blurRadius: 70,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(_screenRadius)),
        child: Stack(
          children: [
            Panel(
              theme: theme,
              formFactor: FormFactor.mobile,
              size: screen,
              padding: const EdgeInsets.only(top: 54, bottom: 34),
              child: child,
            ),
            Positioned(top: 0, left: 0, right: 0, child: statusBar),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(child: island),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(child: homeIndicator),
            ),
          ],
        ),
      ),
    );
  }
}

extension on Widget {
  Widget withForegroundBorder({
    required BorderRadius borderRadius,
    required Color color,
  }) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: color),
      ),
      child: this,
    );
  }
}

/// A small label over an image's panel, like a caption chip.
class SceneLabel extends StatelessWidget {
  /// Creates a label reading [text].
  const SceneLabel(this.text, {this.dark = false, super.key});

  /// The label.
  final String text;

  /// Whether it is set on a dark background.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -.1,
        color: dark ? const Color(0xFFF2F5F5) : const Color(0xFF14201F),
      ),
    );
  }
}
