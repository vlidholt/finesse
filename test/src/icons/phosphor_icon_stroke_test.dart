import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import 'phosphor_subset_font.dart';

/// Measures what a `PhosphorIcon` actually paints.
///
/// This file loads the real regular Phosphor font (tests otherwise draw
/// every glyph as a box). It is in a file of its own so the font is loaded
/// for nothing else, and `phosphor_icon_stroke_web_test.dart` runs it again
/// in a browser, where the renderer is a different one.
///
/// Icons are rasterised at 32 device pixels per logical pixel. At that
/// scale the engine draws a glyph from its outline rather than from a
/// hinted, gamma-corrected mask, so the figures are the geometry of what is
/// painted and are the same on every platform. (At a screen's own density
/// macOS fattens a small filled glyph by a tenth of a pixel or so, which is
/// the platform's doing and is there for a plain `Icon` too.)
void main() {
  const pixelRatio = 32.0;
  const black = Color(0xFF000000);
  const white = Color(0xFFFFFFFF);

  setUpAll(loadPhosphorRegular);

  /// Rasterises [icon] on white with [padding] around it.
  Future<({Uint8List bytes, int width, int height})> rasterise(
    WidgetTester tester,
    Widget icon, {
    double padding = 0,
    ThemeData? theme,
  }) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: theme ?? ThemeData(),
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: ColoredBox(
                color: white,
                child: Padding(padding: EdgeInsets.all(padding), child: icon),
              ),
            ),
          ),
        ),
      ),
    );
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    late ({Uint8List bytes, int width, int height}) result;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final data = (await image.toByteData())!;
      result = (
        bytes: data.buffer.asUint8List(),
        width: image.width,
        height: image.height,
      );
      image.dispose();
    });
    return result;
  }

  /// The thickness, in logical pixels, of the one horizontal line `minus`
  /// is: the ink in the column through its middle.
  Future<double> strokeOf(
    WidgetTester tester,
    Widget icon, {
    ThemeData? theme,
  }) async {
    final image = await rasterise(tester, icon, padding: 2, theme: theme);
    final x = image.width ~/ 2;
    var ink = 0.0;
    for (var y = 0; y < image.height; y++) {
      // Black on white: the red channel is the paper that is left.
      ink += 1 - image.bytes[(y * image.width + x) * 4] / 255;
    }
    return ink / pixelRatio;
  }

  /// The darkest red channel in [bytes].
  int darkest(Uint8List bytes) {
    var min = 255;
    for (var i = 0; i < bytes.length; i += 4) {
      if (bytes[i] < min) min = bytes[i];
    }
    return min;
  }

  /// All the ink in [bytes], in device pixels.
  double inkIn(Uint8List bytes) {
    var ink = 0.0;
    for (var i = 0; i < bytes.length; i += 4) {
      ink += 1 - bytes[i] / 255;
    }
    return ink;
  }

  testWidgets("a plain Icon's line is a sixteenth of its size", (
    tester,
  ) async {
    for (final size in const [12.0, 16.0, 20.0, 24.0]) {
      final stroke = await strokeOf(
        tester,
        Icon(PhosphorIconsRegular.minus, size: size, color: black),
      );
      expect(stroke, closeTo(size / 16, .02), reason: 'at $size');
    }
  });

  testWidgets("a PhosphorIcon's line follows the theme, smoothly, from 12 "
      'to 24', (tester) async {
    const icons = PhosphorIconTheme();
    final strokes = <double>[];
    for (var size = 12.0; size <= 24; size++) {
      final stroke = await strokeOf(
        tester,
        PhosphorIcon(PhosphorIconsRegular.minus, size: size, color: black),
      );
      // The line the theme promises: the font's own plus the outline.
      expect(stroke, closeTo(icons.strokeAt(size), .02), reason: 'at $size');
      strokes.add(stroke);
    }
    // 1.125 at 12 and the font's own 1.5 at 24, where one weight alone
    // runs from 0.75.
    expect(strokes.first, closeTo(1.125, .02));
    expect(strokes.last, closeTo(1.5, .02));
    for (var i = 1; i < strokes.length; i++) {
      final step = strokes[i] - strokes[i - 1];
      // Monotone, and no jump between neighbouring sizes: every pixel of
      // size adds the same thirty-second of a pixel of line.
      expect(step, greaterThan(0), reason: 'at ${12 + i}');
      expect(step, closeTo(1 / 32, .02), reason: 'at ${12 + i}');
    }
  });

  testWidgets('at full strength the line is the same at every size', (
    tester,
  ) async {
    final theme = ThemeData(
      phosphorIconTheme: const PhosphorIconTheme(strength: 1),
    );
    for (final size in const [12.0, 14.0, 16.0, 20.0, 24.0]) {
      final stroke = await strokeOf(
        tester,
        PhosphorIcon(PhosphorIconsRegular.minus, size: size, color: black),
        theme: theme,
      );
      expect(stroke, closeTo(1.5, .02), reason: 'at $size');
    }
  });

  testWidgets('at strength 0, and from the reference size up, it is the '
      "font's own line", (tester) async {
    final off = await strokeOf(
      tester,
      const PhosphorIcon(PhosphorIconsRegular.minus, size: 12, color: black),
      theme: ThemeData(
        style: StyleTokens.fluid.copyWith(iconOpticalStrength: 0),
      ),
    );
    expect(off, closeTo(.75, .02));
    final large = await strokeOf(
      tester,
      const PhosphorIcon(PhosphorIconsRegular.minus, size: 32, color: black),
    );
    expect(large, closeTo(2, .02));
  });

  testWidgets('a translucent colour shows no darker rim where the outline '
      'overlaps the fill', (tester) async {
    // Half-transparent black on white is mid grey. Painted one over the
    // other, fill and outline would overlap at a quarter of white.
    Future<void> check(Widget icon, String reason) async {
      final image = await rasterise(tester, icon, padding: 2);
      final darkestInk = darkest(image.bytes);
      expect(darkestInk, inInclusiveRange(125, 131), reason: reason);
    }

    await check(
      const PhosphorIcon(
        PhosphorIconsRegular.heart,
        size: 12,
        color: Color(0x80000000),
      ),
      'a translucent colour',
    );
    await check(
      const IconTheme(
        data: IconThemeData(opacity: .5),
        child: PhosphorIcon(
          PhosphorIconsRegular.heart,
          size: 12,
          color: black,
        ),
      ),
      "the IconTheme's opacity",
    );
    // A plain Icon in the same colour is the same grey.
    final plain = await rasterise(
      tester,
      const Icon(
        PhosphorIconsRegular.heart,
        size: 12,
        color: Color(0x80000000),
      ),
      padding: 2,
    );
    expect(darkest(plain.bytes), inInclusiveRange(125, 131));
  });

  testWidgets('a blend mode is applied once, to fill and outline together', (
    tester,
  ) async {
    // Mid grey multiplied into white is mid grey; multiplied twice, where
    // the outline overlaps the fill, it would be a quarter.
    const grey = Color(0xFF808080);
    final image = await rasterise(
      tester,
      const PhosphorIcon(
        PhosphorIconsRegular.heart,
        size: 12,
        color: grey,
        blendMode: BlendMode.multiply,
      ),
      padding: 2,
    );
    expect(darkest(image.bytes), inInclusiveRange(125, 131));
    final plain = await rasterise(
      tester,
      const Icon(
        PhosphorIconsRegular.heart,
        size: 12,
        color: grey,
        blendMode: BlendMode.multiply,
      ),
      padding: 2,
    );
    expect(darkest(plain.bytes), inInclusiveRange(125, 131));
  });

  testWidgets('shadows are cast once, at their own strength, under a '
      'translucent icon too', (tester) async {
    // A hard black shadow far to the right of a faint icon: were it
    // painted inside the icon's layer it would be as faint as the icon.
    const shadows = [Shadow(offset: Offset(16, 0))];
    for (final color in const [black, Color(0x20000000)]) {
      final thick = await rasterise(
        tester,
        SizedBox(
          width: 32,
          height: 12,
          child: Align(
            alignment: Alignment.centerLeft,
            child: PhosphorIcon(
              PhosphorIconsRegular.minus,
              size: 12,
              color: color,
              shadows: shadows,
            ),
          ),
        ),
      );
      final plain = await rasterise(
        tester,
        SizedBox(
          width: 32,
          height: 12,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              PhosphorIconsRegular.minus,
              size: 12,
              color: color,
              shadows: shadows,
            ),
          ),
        ),
      );
      // The right half holds only the shadow.
      double shadowInk(({Uint8List bytes, int width, int height}) image) {
        var ink = 0.0;
        for (var y = 0; y < image.height; y++) {
          for (var x = image.width ~/ 2; x < image.width; x++) {
            ink += 1 - image.bytes[(y * image.width + x) * 4] / 255;
          }
        }
        return ink;
      }

      final expected = shadowInk(plain);
      expect(expected, greaterThan(0), reason: '$color');
      // The shadow of the glyph as the font has it, exactly as an Icon
      // casts it.
      expect(shadowInk(thick), closeTo(expected, expected * .02));
    }
  });

  testWidgets('the outline neither grows the box nor is clipped by it', (
    tester,
  ) async {
    // compassRose reaches all four edges of its em square.
    const icon = PhosphorIcon(
      PhosphorIconsRegular.compassRose,
      size: 12,
      color: black,
    );
    final tight = await rasterise(tester, icon);
    expect(tester.getSize(find.byType(PhosphorIcon)), const Size.square(12));
    expect(tight.width, 12 * pixelRatio);
    final padded = await rasterise(tester, icon, padding: 2);
    // With room around it there is more ink: the half of the outline that
    // lies outside the box is painted, not cut off at the edge.
    final spill = inkIn(padded.bytes) - inkIn(tight.bytes);

    // The glyph alone only grazes the edge, so nearly all of that is the
    // outline's.
    const plain = Icon(
      PhosphorIconsRegular.compassRose,
      size: 12,
      color: black,
    );
    final plainTight = await rasterise(tester, plain);
    final plainPadded = await rasterise(tester, plain, padding: 2);
    final plainSpill = inkIn(plainPadded.bytes) - inkIn(plainTight.bytes);
    expect(spill, greaterThan(plainSpill * 2));
    expect(inkIn(tight.bytes), greaterThan(inkIn(plainTight.bytes)));
  });

  testWidgets('a thickened glyph sits exactly where the plain one does', (
    tester,
  ) async {
    // Same box, same centre of ink: the outline is symmetric around the
    // glyph the font draws.
    ({double x, double y}) centre(
      ({Uint8List bytes, int width, int height}) image,
    ) {
      var ink = 0.0;
      var sx = 0.0;
      var sy = 0.0;
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final v = 1 - image.bytes[(y * image.width + x) * 4] / 255;
          ink += v;
          sx += v * x;
          sy += v * y;
        }
      }
      return (x: sx / ink / pixelRatio, y: sy / ink / pixelRatio);
    }

    for (final glyph in const [
      PhosphorIconsRegular.minus,
      PhosphorIconsRegular.circle,
      PhosphorIconsRegular.x,
    ]) {
      final plain = centre(
        await rasterise(
          tester,
          Icon(glyph, size: 16, color: black),
          padding: 2,
        ),
      );
      final thick = centre(
        await rasterise(
          tester,
          PhosphorIcon(glyph, size: 16, color: black),
          padding: 2,
        ),
      );
      expect(thick.x, closeTo(plain.x, .02));
      expect(thick.y, closeTo(plain.y, .02));
    }
  });
}
