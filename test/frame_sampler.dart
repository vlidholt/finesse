import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reads pixels off the screen of a widget test, one frame at a time.
///
/// Wrap the widget under test in [wrap], then [pixel] rasterises the current
/// frame and returns the colour at a point — what the user would see there,
/// after every fill, wash, ring and opacity above it has been composited.
/// That is the only honest way to assert that a transition does not flash:
/// the colour a widget was *given* says nothing about what an implicit
/// animation paints on the way to it.
class FrameSampler {
  final _key = GlobalKey();

  /// Puts [child] under the repaint boundary the sampler reads from.
  Widget wrap(Widget child) => RepaintBoundary(key: _key, child: child);

  /// The colours at [points] in the current frame, in global coordinates.
  Future<List<Color>> pixels(WidgetTester tester, List<Offset> points) async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    late List<Color> colors;
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final data = (await image.toByteData())!;
      colors = [
        for (final point in points)
          () {
            final i = (point.dy.floor() * image.width + point.dx.floor()) * 4;
            return Color.fromARGB(
              data.getUint8(i + 3),
              data.getUint8(i),
              data.getUint8(i + 1),
              data.getUint8(i + 2),
            );
          }(),
      ];
      image.dispose();
    });
    return colors;
  }

  /// The colour at [point] in the current frame.
  Future<Color> pixel(WidgetTester tester, Offset point) async =>
      (await pixels(tester, [point])).single;

  /// Pumps [frames] frames 16 ms apart and returns the colour at [point]
  /// after each, starting with the frame already on screen.
  Future<List<Color>> record(
    WidgetTester tester,
    Offset point, {
    int frames = 14,
  }) async {
    final colors = [await pixel(tester, point)];
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      colors.add(await pixel(tester, point));
    }
    return colors;
  }
}

/// The 8-bit red, green and blue of [color].
List<int> rgbOf(Color color) => [
  (color.r * 255).round(),
  (color.g * 255).round(),
  (color.b * 255).round(),
];

/// Fails unless every channel of [frames] moves in one direction only, from
/// the first frame to the last, give or take [slack] for rounding.
///
/// A transition that dips through a darker or lighter colour on the way — a
/// flash — changes direction and fails. One that jumps straight to its
/// target passes: an instant change is not a blink.
void expectMonotone(
  List<Color> frames, {
  required String reason,
  int slack = 1,
}) {
  final channels = [for (final frame in frames) rgbOf(frame)];
  for (var c = 0; c < 3; c++) {
    final values = [for (final rgb in channels) rgb[c]];
    final rising = values.last >= values.first;
    for (var i = 1; i < values.length; i++) {
      final step = values[i] - values[i - 1];
      expect(
        rising ? step >= -slack : step <= slack,
        isTrue,
        reason:
            '$reason: channel ${'RGB'[c]} changes direction at frame $i '
            '— ${[for (final f in frames) _hex(f)].join(' ')}',
      );
    }
    // Nor may it overshoot either end.
    final low = rising ? values.first : values.last;
    final high = rising ? values.last : values.first;
    for (final value in values) {
      expect(
        value >= low - slack && value <= high + slack,
        isTrue,
        reason:
            '$reason: channel ${'RGB'[c]} leaves the range between its '
            'ends — ${[for (final f in frames) _hex(f)].join(' ')}',
      );
    }
  }
}

String _hex(Color color) =>
    color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);

/// [ui.Color] composited over an opaque [backdrop].
Color over(Color color, Color backdrop) => Color.alphaBlend(color, backdrop);
