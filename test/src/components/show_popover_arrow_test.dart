import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/src/components/surface.dart';
import 'package:una/una.dart';

/// `showPopover(showArrow: true)`: the arrow is on the edge that faces the
/// rectangle and points at its middle, wherever the popover had to go to
/// stay on screen.
void main() {
  final arrow = find.byKey(SurfacePainter.arrowKey);

  Future<void> open(
    WidgetTester tester,
    Rect anchor, {
    bool? showArrow = true,
    Motion motion = Motion.none,
  }) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UnaApp(
        theme: ThemeData(motion: motion),
        home: Builder(
          builder: (context) => Button(
            onPressed: () => showPopover<void>(
              context: context,
              anchorRect: anchor,
              showArrow: showArrow,
              builder: (_) => const SizedBox(
                width: 160,
                height: 80,
                child: Text('content'),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Rect surface(WidgetTester tester) => tester.getRect(
    find
        .ancestor(of: find.text('content'), matching: find.byType(Decorator))
        .first,
  );

  testWidgets('below the rectangle, pointing up at its middle', (
    tester,
  ) async {
    const anchor = Rect.fromLTWH(300, 100, 40, 20);
    await open(tester, anchor);
    final box = surface(tester);
    final tip = tester.getRect(arrow);
    expect(tip.center.dx, moreOrLessEquals(anchor.center.dx, epsilon: .5));
    // On the top edge, poking up across the gap towards the rectangle.
    expect(tip.center.dy, moreOrLessEquals(box.top + 2, epsilon: .5));
    expect(tip.top, lessThan(box.top));
    expect(tip.top, greaterThan(anchor.bottom));
  });

  testWidgets('above the rectangle when there is no room below', (
    tester,
  ) async {
    const anchor = Rect.fromLTWH(300, 560, 40, 20);
    await open(tester, anchor);
    final box = surface(tester);
    final tip = tester.getRect(arrow);
    expect(box.bottom, lessThan(anchor.top));
    expect(tip.center.dx, moreOrLessEquals(anchor.center.dx, epsilon: .5));
    expect(tip.center.dy, moreOrLessEquals(box.bottom - 2, epsilon: .5));
    expect(tip.bottom, lessThan(anchor.top));
  });

  testWidgets('pushed in from the edge, still pointing at the rectangle', (
    tester,
  ) async {
    const anchor = Rect.fromLTWH(730, 100, 30, 20);
    await open(tester, anchor);
    final box = surface(tester);
    final tip = tester.getRect(arrow);
    // The popover was moved left to stay on screen, and keeps its gap.
    expect(box.right, moreOrLessEquals(800 - 8, epsilon: .5));
    expect(box.center.dx, lessThan(anchor.center.dx - 20));
    expect(tip.center.dx, moreOrLessEquals(anchor.center.dx, epsilon: .5));
  });

  testWidgets('an arrow is room between the popover and the rectangle', (
    tester,
  ) async {
    const anchor = Rect.fromLTWH(300, 100, 40, 20);
    await open(tester, anchor, showArrow: false);
    final plain = surface(tester).top;
    expect(arrow, findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await open(tester, anchor);
    expect(surface(tester).top, greaterThan(plain));
  });

  testWidgets('no frame shows the arrow anywhere but at the rectangle', (
    tester,
  ) async {
    // Without motion the first frame it is seen in is its last.
    const anchor = Rect.fromLTWH(730, 560, 30, 20);
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UnaApp(
        theme: ThemeData(motion: Motion.none),
        home: Builder(
          builder: (context) => Button(
            onPressed: () => showPopover<void>(
              context: context,
              anchorRect: anchor,
              showArrow: true,
              builder: (_) => const SizedBox(
                width: 160,
                height: 80,
                child: Text('content'),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    var seen = 0;
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      final shown = find.text('content').evaluate().isNotEmpty;
      if (!shown) continue;
      final visible = tester
          .widgetList<Visibility>(
            find.ancestor(
              of: find.text('content'),
              matching: find.byType(Visibility),
            ),
          )
          .every((v) => v.visible);
      if (!visible) continue;
      seen++;
      final tip = tester.getRect(arrow);
      expect(
        tip.center.dx,
        moreOrLessEquals(anchor.center.dx, epsilon: .5),
        reason: 'frame $i',
      );
      expect(tip.bottom, lessThan(anchor.top), reason: 'frame $i');
    }
    expect(seen, greaterThan(3));
  });
}
