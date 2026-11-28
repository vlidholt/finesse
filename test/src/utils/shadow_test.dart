import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

// The element painted by [_render], centred in a 400x400 white canvas.
const _canvas = 400;
const _rect = Rect.fromLTRB(100, 150, 300, 250);

/// Paints [decoration] on white and returns the red channel of every pixel.
///
/// Shadows are real here: [debugDisableShadows] — which flutter_test turns on
/// — drops the mask filter, which is the whole thing under test.
Future<List<int>> _render(Decoration decoration) async {
  debugDisableShadows = false;
  try {
    final recorder = ui.PictureRecorder();
    const full = Rect.fromLTWH(0, 0, _canvas * 1.0, _canvas * 1.0);
    final canvas = Canvas(recorder, full);
    canvas.drawRect(full, Paint()..color = const Color(0xFFFFFFFF));
    // With a callback: a `ShapeDecoration` insists on one.
    decoration
        .createBoxPainter(() {})
        .paint(
          canvas,
          _rect.topLeft,
          ImageConfiguration(
            size: _rect.size,
            textDirection: TextDirection.ltr,
          ),
        );
    final image = await recorder.endRecording().toImage(_canvas, _canvas);
    final data = await image.toByteData();
    image.dispose();
    final bytes = data!.buffer.asUint8List();
    return [
      for (var i = 0; i < _canvas * _canvas; i++) bytes[i * 4],
    ];
  } finally {
    debugDisableShadows = true;
  }
}

extension on List<int> {
  int at(int x, int y) => this[y * _canvas + x];
}

void main() {
  test(
    'an outer shadow fades away from the element without a hard edge',
    () async {
      final pixels = await _render(
        ShadowDecoration.box(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10),
          shadows: Shadows.lg,
        ),
      );

      // Directly under the element the shadow is at its darkest, and from
      // there it only ever gets lighter. BlurStyle.outer cut the shadow out
      // along `rect.shift(offset).inflate(spread)` rather than the element,
      // which put a step back to full strength 7px below a `shadow-lg` box.
      final below = [
        for (var y = _rect.bottom.toInt(); y < _rect.bottom + 60; y++)
          pixels.at(200, y),
      ];
      expect(below.first, lessThan(250), reason: 'no shadow under the element');
      expect(below.last, 255, reason: 'shadow reaches past its own extent');
      for (var i = 1; i < below.length; i++) {
        expect(
          below[i],
          greaterThanOrEqualTo(below[i - 1]),
          reason: 'shadow gets darker again ${i}px below the element',
        );
      }

      // The same going up and sideways.
      final above = [
        for (var y = _rect.top.toInt() - 1; y > _rect.top - 40; y--)
          pixels.at(200, y),
      ];
      for (var i = 1; i < above.length; i++) {
        expect(above[i], greaterThanOrEqualTo(above[i - 1]));
      }
      final left = [
        for (var x = _rect.left.toInt() - 1; x > _rect.left - 40; x--)
          pixels.at(x, 200),
      ];
      for (var i = 1; i < left.length; i++) {
        expect(left[i], greaterThanOrEqualTo(left[i - 1]));
      }
    },
  );

  test('an outer shadow never paints inside the element', () async {
    // A translucent surface (the menu finish) would otherwise show the shadow
    // through it as a grey wash.
    final pixels = await _render(
      ShadowDecoration.box(
        borderRadius: BorderRadius.circular(10),
        shadows: Shadows.xl2,
      ),
    );

    for (final point in [
      const Offset(200, 200), // centre
      Offset(_rect.left + 20, _rect.top + 20), // just inside each corner
      Offset(_rect.right - 20, _rect.top + 20),
      Offset(_rect.left + 20, _rect.bottom - 20),
      Offset(_rect.right - 20, _rect.bottom - 20),
    ]) {
      expect(
        pixels.at(point.dx.toInt(), point.dy.toInt()),
        255,
        reason: 'shadow shows through the fill at $point',
      );
    }
  });

  test('the shadow follows a rounded corner on both sides of it', () async {
    // The outside of a rounded box is painted as the outside of its
    // bounding rectangle plus the sliver between each square corner and
    // its arc. Leave the slivers out and every corner shows a notch of
    // bare page; let them reach past the arc and the shadow is back inside
    // a translucent fill.
    const radius = 40.0;
    final pixels = await _render(
      ShadowDecoration.box(
        borderRadius: BorderRadius.circular(radius),
        shadows: const [BoxShadow(blurRadius: 24, spreadRadius: 4)],
      ),
    );
    for (final (corner, inwards) in [
      (_rect.topLeft, const Offset(1, 1)),
      (_rect.topRight, const Offset(-1, 1)),
      (_rect.bottomLeft, const Offset(1, -1)),
      (_rect.bottomRight, const Offset(-1, -1)),
    ]) {
      // 4px in from the square corner: inside the bounding rectangle,
      // outside the arc (which is 40·(1 − 1/√2) ≈ 11.7px in).
      final sliver = corner + inwards * 4;
      expect(
        pixels.at(sliver.dx.toInt(), sliver.dy.toInt()),
        lessThan(250),
        reason: 'no shadow between the corner at $corner and its arc',
      );
      // 16px in: past the arc, inside the element.
      final inside = corner + inwards * 16;
      expect(
        pixels.at(inside.dx.toInt(), inside.dy.toInt()),
        255,
        reason: 'shadow inside the arc of the corner at $corner',
      );
    }
    // No seam where the two clips meet, along an edge next to a corner:
    // just outside the top edge the shadow is as dark above the sliver as
    // above the straight part beside it, give or take the corner's own
    // falloff.
    final y = _rect.top.toInt() - 1;
    for (var x = _rect.left.toInt() + 2; x < _rect.left + radius + 8; x++) {
      expect(
        (pixels.at(x, y) - pixels.at(x + 1, y)).abs(),
        lessThanOrEqualTo(6),
        reason: 'a step in the shadow at x=$x above the top edge',
      );
    }
  });

  test('a circle keeps its shadow outside the circle', () async {
    final pixels = await _render(
      ShadowDecoration.box(
        shape: BoxShape.circle,
        shadows: const [BoxShadow(blurRadius: 24, spreadRadius: 4)],
      ),
    );
    // The circle is 100 across, centred in the 200x100 box.
    final centre = _rect.center;
    expect(pixels.at(centre.dx.toInt(), centre.dy.toInt()), 255);
    expect(pixels.at(centre.dx.toInt() + 30, centre.dy.toInt() + 30), 255);
    expect(
      pixels.at(centre.dx.toInt() + 44, centre.dy.toInt() + 44),
      lessThan(250),
    );
    expect(pixels.at(centre.dx.toInt(), _rect.top.toInt() - 3), lessThan(250));
    // Inside the box but outside the circle, to the side.
    expect(pixels.at(centre.dx.toInt() + 56, centre.dy.toInt()), lessThan(250));
  });

  test('only a translucent box pays for a clip, and never a large one', () {
    List<Symbol> callsOf(Decoration decoration) {
      final canvas = TestRecordingCanvas();
      decoration
          .createBoxPainter(() {})
          .paint(
            canvas,
            _rect.topLeft,
            ImageConfiguration(
              size: _rect.size,
              textDirection: TextDirection.ltr,
            ),
          );
      return [
        for (final call in canvas.invocations) call.invocation.memberName,
      ];
    }

    // An opaque fill hides whatever is under it: no clip at all.
    final opaque = callsOf(
      ShadowDecoration.box(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        shadows: Shadows.lg,
      ),
    );
    expect(opaque, isNot(contains(#clipPath)));
    expect(opaque, isNot(contains(#clipRect)));

    // So does an opaque gradient, and an opaque fill of any other shape
    // (a superellipse control), whose clip would be the costly kind.
    for (final decoration in [
      ShadowDecoration.box(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFF000000)],
        ),
        borderRadius: BorderRadius.circular(10),
        shadows: Shadows.lg,
      ),
      ShadowDecoration(
        shadows: Shadows.lg,
        decoration: ShapeDecoration(
          color: const Color(0xFFFFFFFF),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ]) {
      final calls = callsOf(decoration);
      expect(calls, isNot(contains(#clipPath)));
      expect(calls, isNot(contains(#clipRect)));
    }
    // A gradient that fades out is not opaque.
    expect(
      callsOf(
        ShadowDecoration.box(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
          ),
          borderRadius: BorderRadius.circular(10),
          shadows: Shadows.lg,
        ),
      ),
      contains(#clipRect),
    );

    // A translucent one is clipped — by the bounding rectangle, which
    // needs no mask, and by four slivers a corner radius across. A single
    // path the size of the shadow is rasterised on the CPU on every frame
    // the surface moves; see `_paintOutsideBox`.
    for (final decoration in [
      ShadowDecoration.box(
        color: const Color(0xE0FFFFFF),
        borderRadius: BorderRadius.circular(10),
        shadows: Shadows.lg,
      ),
      ShadowDecoration.box(
        borderRadius: BorderRadius.circular(10),
        shadows: Shadows.lg,
      ),
    ]) {
      final canvas = TestRecordingCanvas();
      decoration
          .createBoxPainter(() {})
          .paint(
            canvas,
            _rect.topLeft,
            ImageConfiguration(
              size: _rect.size,
              textDirection: TextDirection.ltr,
            ),
          );
      final clips = [
        for (final call in canvas.invocations)
          if (call.invocation.memberName == #clipPath)
            (call.invocation.positionalArguments.first as Path).getBounds(),
      ];
      expect(clips, hasLength(4));
      for (final bounds in clips) {
        expect(bounds.width, closeTo(10, .01));
        expect(bounds.height, closeTo(10, .01));
      }
      expect(
        canvas.invocations.where(
          (call) => call.invocation.memberName == #clipRect,
        ),
        hasLength(1),
      );
    }

    // Square corners have no slivers.
    final square = callsOf(ShadowDecoration.box(shadows: Shadows.lg));
    expect(square, isNot(contains(#clipPath)));
    expect(square.where((call) => call == #clipRect), hasLength(1));
  });

  test(
    'a shape of overlapping contours keeps the shadow out of all of it',
    () async {
      // A tooltip's outline is its bubble and its arrow, two contours that
      // overlap. Cut out together as the holes of one even-odd path, the
      // overlap would count twice and be left *in* — a patch of shadow in
      // the middle of the surface.
      final pixels = await _render(
        const ShadowDecoration(
          decoration: ShapeDecoration(shape: _TwoBoxes()),
          shadows: Shadows.xl2,
        ),
      );
      for (final point in [
        // In the first box only, in both, and in the second only.
        Offset(_rect.left + 20, _rect.top + 20),
        _rect.center,
        Offset(_rect.right - 20, _rect.bottom - 20),
      ]) {
        expect(
          pixels.at(point.dx.toInt(), point.dy.toInt()),
          255,
          reason: 'shadow shows through the shape at $point',
        );
      }
      // And the shadow is there, under the shape.
      expect(pixels.at(200, _rect.bottom.toInt() + 4), lessThan(250));
    },
  );

  test(
    'a spread-only shadow is a crisp hairline outside the element',
    () async {
      // `shadow-[0_0_0_1px_...]`, which the sidebar's outline menu button uses
      // as a border that does not take part in layout.
      final pixels = await _render(
        ShadowDecoration.box(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10),
          shadows: const [BoxShadow(spreadRadius: 1)],
        ),
      );

      expect(pixels.at(_rect.left.toInt() - 1, 200), 0, reason: 'the hairline');
      expect(pixels.at(_rect.left.toInt() - 2, 200), 255, reason: 'outside it');
      expect(pixels.at(_rect.left.toInt() + 1, 200), 255, reason: 'inside it');
      expect(pixels.at(200, _rect.top.toInt() - 1), 0);
      expect(pixels.at(200, _rect.bottom.toInt()), 0);
    },
  );
}

/// Two rectangles that overlap in the middle of the box, as one path of two
/// contours.
class _TwoBoxes extends ShapeBorder {
  const _TwoBoxes();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()
    ..addRect(
      Rect.fromLTRB(rect.left, rect.top, rect.right - 60, rect.bottom - 30),
    )
    ..addRect(
      Rect.fromLTRB(rect.left + 60, rect.top + 30, rect.right, rect.bottom),
    );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
