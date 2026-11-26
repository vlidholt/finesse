import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../decoration_finders.dart';
import '../../una_harness.dart';

/// A thumb at the end of its track used to hang half outside the control,
/// and no box around the control hit-tests that half: a finger on the
/// outer edge of a thumb at the minimum missed the slider altogether. The
/// thumb now stays inside, as Radix keeps it (`getThumbInBoundsOffset`),
/// and can be taken hold of anywhere.
void main() {
  double thumbRadius(WidgetTester tester, Finder control) =>
      Theme.of(tester.element(control)).sliderTheme.thumbRadius ?? 10;

  Finder thumbs() => find.byWidgetPredicate(
    (widget) =>
        widget is Container &&
        boxDecorationOf(widget.decoration)?.shape == BoxShape.circle,
  );

  Future<void> dragFrom(WidgetTester tester, Offset start, Offset by) async {
    final gesture = await tester.startGesture(start);
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await gesture.moveBy(by / 4);
      await tester.pump();
    }
    await gesture.up();
    await tester.pump();
  }

  Widget host(Widget child) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: SizedBox(width: 300, child: child),
    ),
  );

  for (final end in [0.0, 1.0]) {
    final name = end == 0 ? 'minimum' : 'maximum';
    testWidgets('a slider thumb at the $name is inside the slider and is '
        'taken hold of by its outer edge', (tester) async {
      var value = end;
      await pumpUna(
        tester,
        host(
          StatefulBuilder(
            builder: (context, setState) => Slider(
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      final slider = find.byType(Slider);
      final rect = tester.getRect(slider);
      final thumb = tester.getRect(thumbs());
      expect(thumb.left, greaterThanOrEqualTo(rect.left - .01));
      expect(thumb.right, lessThanOrEqualTo(rect.right + .01));
      final r = thumbRadius(tester, slider);
      expect(thumb.width, moreOrLessEquals(2 * r));

      // Two points in from the thumb's outer edge, dragged half the
      // travel: the thumb moves with the pointer, not to it.
      final travel = rect.width - 2 * r;
      final start = end == 0
          ? Offset(thumb.left + 2, rect.center.dy)
          : Offset(thumb.right - 2, rect.center.dy);
      await dragFrom(
        tester,
        start,
        Offset(end == 0 ? travel / 2 : -travel / 2, 0),
      );
      expect(value, closeTo(.5, .01));
    });
  }

  testWidgets('both thumbs of a range at its ends are taken hold of by '
      'their outer edges', (tester) async {
    var values = const [0.0, 1.0];
    await pumpUna(
      tester,
      host(
        StatefulBuilder(
          builder: (context, setState) => RangeSlider(
            values: values,
            onChanged: (v) => setState(() => values = v),
          ),
        ),
      ),
    );
    final slider = find.byType(RangeSlider);
    final rect = tester.getRect(slider);
    final travel = rect.width - 2 * thumbRadius(tester, slider);
    final low = tester.getRect(thumbs().first);
    expect(low.left, moreOrLessEquals(rect.left));
    await dragFrom(
      tester,
      Offset(low.left + 2, rect.center.dy),
      Offset(travel / 4, 0),
    );
    expect(values.first, closeTo(.25, .01));
    final high = tester.getRect(thumbs().last);
    expect(high.right, moreOrLessEquals(rect.right));
    await dragFrom(
      tester,
      Offset(high.right - 2, rect.center.dy),
      Offset(-travel / 4, 0),
    );
    expect(values.last, closeTo(.75, .01));
  });

  testWidgets('a tap anywhere across the height of the slider moves it', (
    tester,
  ) async {
    var value = 0.0;
    await pumpUna(
      tester,
      host(
        StatefulBuilder(
          builder: (context, setState) => Slider(
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    final slider = find.byType(Slider);
    final rect = tester.getRect(slider);
    final r = thumbRadius(tester, slider);
    final travel = rect.width - 2 * r;
    // Above the thin track, still inside the slider's box.
    await tester.tapAt(Offset(rect.left + r + travel * .75, rect.top + 1));
    await tester.pump();
    expect(value, closeTo(.75, .01));
  });

  testWidgets('the thumb of the colour area stays inside it in a corner and '
      'is taken hold of by its outer edge', (tester) async {
    var color = const Color(0xFFFFFFFF);
    await pumpUna(
      tester,
      host(
        StatefulBuilder(
          builder: (context, setState) => ColorPicker(
            value: color,
            onChanged: (v) => setState(() => color = v),
          ),
        ),
      ),
    );
    final area = tester.getRect(
      find.bySemanticsLabel('Saturation and brightness'),
    );
    final r = thumbRadius(tester, find.byType(ColorPicker));
    // White is the top-left corner: no saturation, full brightness.
    final thumb = tester.getRect(thumbs().first);
    expect(thumb.topLeft, offsetMoreOrLessEquals(area.topLeft));
    final span = area.deflate(r);
    await dragFrom(
      tester,
      // Its outer edge: the left of the circle, half way down.
      Offset(thumb.left + 2, thumb.center.dy),
      Offset(span.width / 2, span.height / 2),
    );
    final hsv = HSVColor.fromColor(color);
    expect(hsv.saturation, closeTo(.5, .02));
    expect(hsv.value, closeTo(.5, .02));
  });
}
