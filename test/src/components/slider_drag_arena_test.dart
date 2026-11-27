import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// A slider inside something that swipes sideways — a pager, a carousel,
/// the docs' preview/code pages — takes the finger itself. It listened for
/// a pan, which waits for twice the slop on a touch screen, so the pager's
/// horizontal drag won and the page moved instead of the thumb.
void main() {
  for (final range in [false, true]) {
    testWidgets('a touch drag on a ${range ? 'range ' : ''}slider in a '
        'pager moves the slider, not the page', (tester) async {
      final pages = PageController();
      addTearDown(pages.dispose);
      var value = .5;
      var values = const [.2, .8];
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) => PageView(
            controller: pages,
            children: [
              Center(
                child: SizedBox(
                  width: 300,
                  child: range
                      ? RangeSlider(
                          values: values,
                          onChanged: (v) => setState(() => values = v),
                        )
                      : Slider(
                          value: value,
                          onChanged: (v) => setState(() => value = v),
                        ),
                ),
              ),
              const Center(child: Text('Second page')),
            ],
          ),
        ),
      );

      // From the middle of the track, on the thumb or beside it.
      final start = tester.getCenter(find.byType(range ? RangeSlider : Slider));
      // A finger: the default kind.
      final gesture = await tester.startGesture(start);
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(-10, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(pages.page, 0, reason: 'the page did not move');
      if (range) {
        expect(values.first, lessThan(.2));
      } else {
        expect(value, lessThan(.5));
      }
    });
  }

  testWidgets('a vertical swipe on a slider still scrolls the page', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    var value = .5;
    await pumpUna(
      tester,
      StatefulBuilder(
        builder: (context, setState) => ListView(
          controller: scroll,
          children: [
            const SizedBox(height: 200),
            SizedBox(
              width: 300,
              child: Slider(
                value: value,
                onChanged: (v) => setState(() => value = v),
              ),
            ),
            const SizedBox(height: 2000),
          ],
        ),
      ),
    );
    await tester.dragFrom(
      tester.getCenter(find.byType(Slider)),
      const Offset(0, -150),
    );
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(50));
    expect(value, .5);
  });
}
