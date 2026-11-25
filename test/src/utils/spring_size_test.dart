import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

const _frame = Duration(milliseconds: 16);

void main() {
  late StateSetter rebuild;
  var inner = const Size(100, 40);
  var outerWidth = 400.0;
  var rigid = 0.0;
  var enabled = true;

  setUp(() {
    inner = const Size(100, 40);
    outerWidth = 400;
    rigid = 0;
    enabled = true;
  });

  Widget host() => Align(
    alignment: Alignment.topLeft,
    child: StatefulBuilder(
      builder: (context, setState) {
        rebuild = setState;
        return SizedBox(
          width: outerWidth,
          child: Align(
            alignment: Alignment.topLeft,
            child: SpringSize(
              rigidDistance: rigid,
              enabled: enabled,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                key: const ValueKey('inner'),
                width: inner.width,
                height: inner.height,
              ),
            ),
          ),
        );
      },
    ),
  );

  Size box(WidgetTester tester) => tester.getSize(find.byType(SpringSize));

  testWidgets("takes its child's size at once when first laid out", (
    tester,
  ) async {
    await pumpFinesse(tester, host());
    expect(box(tester), const Size(100, 40));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('follows a larger child monotonically and lands exactly', (
    tester,
  ) async {
    await pumpFinesse(tester, host());
    rebuild(() => inner = const Size(220, 120));
    await tester.pump();
    // The child is its new size at once; the box is on its way.
    expect(tester.getSize(find.byKey(const ValueKey('inner'))).width, 220);
    expect(box(tester), const Size(100, 40));

    var last = box(tester);
    var frames = 0;
    while (tester.binding.hasScheduledFrame) {
      await tester.pump(_frame);
      final size = box(tester);
      expect(size.width, greaterThanOrEqualTo(last.width));
      expect(size.height, greaterThanOrEqualTo(last.height));
      expect(size.width, lessThanOrEqualTo(220));
      expect(size.height, lessThanOrEqualTo(120));
      last = size;
      expect(++frames, lessThan(120));
    }
    expect(frames, greaterThan(6));
    expect(last, const Size(220, 120));
  });

  testWidgets('follows a smaller child the same way', (tester) async {
    await pumpFinesse(tester, host());
    rebuild(() => inner = const Size(60, 20));
    await tester.pump();
    var last = box(tester);
    for (var i = 0; i < 60; i++) {
      await tester.pump(_frame);
      final size = box(tester);
      expect(size.width, lessThanOrEqualTo(last.width));
      expect(size.height, lessThanOrEqualTo(last.height));
      last = size;
    }
    expect(last, const Size(60, 20));
    await tester.pumpAndSettle();
  });

  testWidgets('clips the child, with its radius, only while it is smaller', (
    tester,
  ) async {
    await pumpFinesse(tester, host());
    final box = tester.renderObject(find.byType(SpringSize));
    expect(box, isNot(paints..clipRRect()));

    rebuild(() => inner = const Size(220, 120));
    await tester.pump();
    await tester.pump(_frame);
    final size = tester.getSize(find.byType(SpringSize));
    expect(
      box,
      paints..clipRRect(
        rrect: RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(8),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(box, isNot(paints..clipRRect()));
  });

  testWidgets('a change of mind mid-flight turns around without a jump', (
    tester,
  ) async {
    await pumpFinesse(tester, host());
    rebuild(() => inner = const Size(100, 240));
    await tester.pump();
    for (var i = 0; i < 6; i++) {
      await tester.pump(_frame);
    }
    final turning = box(tester).height;
    expect(turning, inExclusiveRange(40, 240));

    rebuild(() => inner = const Size(100, 40));
    await tester.pump();
    // The frame of the turn starts from where it was.
    expect(box(tester).height, closeTo(turning, .01));
    var last = turning;
    var largestStep = 0.0;
    for (var i = 0; i < 80; i++) {
      await tester.pump(_frame);
      final height = box(tester).height;
      if ((height - last).abs() > largestStep) {
        largestStep = (height - last).abs();
      }
      last = height;
    }
    expect(last, 40);
    // It kept its speed through the turn rather than snapping back.
    expect(largestStep, lessThan(40));
    await tester.pumpAndSettle();
  });

  testWidgets('a change of the constraints is followed rigidly', (
    tester,
  ) async {
    await pumpFinesse(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return SizedBox(
              width: outerWidth,
              child: const SpringSize(
                child: SizedBox(width: double.infinity, height: 30),
              ),
            );
          },
        ),
      ),
    );
    expect(box(tester).width, 400);
    // The window got narrower: nothing to animate.
    rebuild(() => outerWidth = 250);
    await tester.pump();
    expect(box(tester).width, 250);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('a step within rigidDistance is followed at once', (
    tester,
  ) async {
    rigid = 12;
    await pumpFinesse(tester, host());
    // Text revealed a glyph at a time: a few pixels a frame.
    for (var width = 108.0; width <= 180; width += 8) {
      rebuild(() => inner = Size(width, 40));
      await tester.pump(_frame);
      expect(box(tester).width, width);
    }
    expect(tester.binding.hasScheduledFrame, isFalse);

    // A new line is a jump, and takes the spring.
    rebuild(() => inner = const Size(180, 62));
    await tester.pump();
    expect(box(tester).height, 40);
    await tester.pump(_frame);
    await tester.pump(_frame);
    expect(box(tester).height, inExclusiveRange(40, 62));
    // A small step on the other axis rides along without disturbing it.
    rebuild(() => inner = const Size(188, 62));
    await tester.pump(_frame);
    expect(box(tester).width, 188);
    expect(box(tester).height, inExclusiveRange(40, 62));
    await tester.pumpAndSettle();
    expect(box(tester), const Size(188, 62));
  });

  testWidgets('enabled: false, reduced motion and Motion.none do not animate', (
    tester,
  ) async {
    enabled = false;
    await pumpFinesse(tester, host());
    rebuild(() => inner = const Size(220, 120));
    await tester.pump();
    expect(box(tester), const Size(220, 120));

    enabled = true;
    inner = const Size(100, 40);
    await pumpFinesse(
      tester,
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: host(),
      ),
    );
    rebuild(() => inner = const Size(220, 120));
    await tester.pump();
    expect(box(tester), const Size(220, 120));

    inner = const Size(100, 40);
    await pumpFinesse(tester, host(), theme: ThemeData(motion: Motion.none));
    await tester.pump();
    rebuild(() => inner = const Size(220, 120));
    await tester.pump();
    expect(box(tester), const Size(220, 120));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('pins the child to its alignment while it catches up', (
    tester,
  ) async {
    await pumpFinesse(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return SpringSize(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                key: const ValueKey('inner'),
                width: inner.width,
                height: inner.height,
              ),
            );
          },
        ),
      ),
    );
    rebuild(() => inner = const Size(200, 100));
    await tester.pump();
    await tester.pump(_frame);
    await tester.pump(_frame);
    final outer = tester.getRect(find.byType(SpringSize));
    final child = tester.getRect(find.byKey(const ValueKey('inner')));
    expect(child.bottomRight, outer.bottomRight);
    expect(child.width, 200);
    expect(outer.width, lessThan(200));
    await tester.pumpAndSettle();
  });
}
