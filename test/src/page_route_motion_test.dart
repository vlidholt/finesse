import 'package:finesse/finesse.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// [FinessePageRoute] brings a page in with a short slide and a fade, on the
/// theme's motion tokens, and takes it out faster — without a jump when a
/// page is popped while it is still arriving.
const _frame = Duration(milliseconds: 16);

final _motion = Motion.lively.copyWith(snappy: const MotionSpring());

final _navigator = GlobalKey<NavigatorState>();

Widget _app({
  FormFactor formFactor = FormFactor.desktop,
  bool reduceMotion = false,
  Motion? motion,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return FinesseApp(
    navigatorKey: _navigator,
    theme: ThemeData(motion: motion ?? _motion),
    formFactor: formFactor,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: Directionality(textDirection: textDirection, child: child!),
    ),
    home: const SizedBox.expand(key: Key('home')),
  );
}

Future<void> _push(WidgetTester tester, {bool fullscreenDialog = false}) async {
  _navigator.currentState!.push(
    FinessePageRoute<void>(
      fullscreenDialog: fullscreenDialog,
      builder: (context) => const SizedBox.expand(key: Key('page')),
    ),
  );
  // The navigator keeps a new page offstage for its first frame, to
  // measure heroes; the next one is the first it can be seen on.
  await tester.pump();
  await tester.pump(_frame);
}

/// The opacity and offset [finder] is painted with by the route above it.
({double opacity, Offset offset}) _transition(
  WidgetTester tester,
  Finder finder,
) {
  var opacity = 1.0;
  RenderObject? node = tester.renderObject(finder);
  while (node != null) {
    if (node is RenderAnimatedOpacity) opacity *= node.opacity.value;
    node = node.parent;
  }
  // The pages fill the screen, so where one's corner is painted is how far
  // the route has moved it.
  final offset = MatrixUtils.transformPoint(
    tester.renderObject(finder).getTransformTo(null),
    Offset.zero,
  );
  return (opacity: opacity, offset: offset);
}

void _expectMonotone(List<double> values, {required String reason}) {
  final rising = values.last >= values.first;
  for (var i = 1; i < values.length; i++) {
    final step = values[i] - values[i - 1];
    expect(
      rising ? step >= -1e-9 : step <= 1e-9,
      isTrue,
      reason: '$reason turned back at frame $i: $values',
    );
  }
}

void main() {
  const page = Key('page');
  const home = Key('home');

  testWidgets('on a desktop the page rises a few pixels while it fades in, '
      'and leaves faster', (tester) async {
    await tester.pumpWidget(_app());
    await _push(tester);
    final opacity = <double>[];
    final rise = <double>[];
    var arriving = 0;
    while (arriving < 60) {
      final now = _transition(tester, find.byKey(page));
      opacity.add(now.opacity);
      rise.add(now.offset.dy);
      expect(now.offset.dx, 0);
      if (now.opacity == 1 && now.offset == Offset.zero && arriving > 2) break;
      await tester.pump(_frame);
      arriving++;
    }
    expect(opacity.first, lessThan(.25));
    expect(rise.first, greaterThan(_motion.overlayTravel * 2 * .8));
    expect(rise.first, lessThanOrEqualTo(_motion.overlayTravel * 2));
    _expectMonotone(opacity, reason: 'opacity');
    _expectMonotone(rise, reason: 'rise');
    expect(opacity.last, 1);
    expect(rise.last, 0);
    // The page under it stays where it is.
    expect(
      _transition(tester, find.byKey(home, skipOffstage: false)).offset,
      Offset.zero,
    );
    await tester.pump(const Duration(milliseconds: 400));

    _navigator.currentState!.pop();
    await tester.pump();
    final leaving = <double>[];
    var frames = 0;
    while (find.byKey(page).evaluate().isNotEmpty && frames < 60) {
      leaving.add(_transition(tester, find.byKey(page)).opacity);
      await tester.pump(_frame);
      frames++;
    }
    _expectMonotone(leaving, reason: 'leaving');
    expect(leaving.last, lessThan(.3));
    expect(frames, lessThan(arriving));
  });

  testWidgets('on a phone it comes in from the end side, and the page under '
      'it gives way', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    for (final direction in TextDirection.values) {
      await tester.pumpWidget(
        _app(formFactor: FormFactor.mobile, textDirection: direction),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await _push(tester);
      final first = _transition(tester, find.byKey(page));
      final sign = direction == TextDirection.ltr ? 1 : -1;
      // A fifth of the width, from the end.
      expect(first.offset.dx * sign, greaterThan(78.0 * .8));
      expect(first.offset.dx * sign, lessThanOrEqualTo(78.0));
      expect(first.offset.dy, 0);
      final slide = <double>[];
      final under = <double>[];
      for (var i = 0; i < 30; i++) {
        slide.add(_transition(tester, find.byKey(page)).offset.dx);
        under.add(
          _transition(tester, find.byKey(home, skipOffstage: false)).offset.dx,
        );
        await tester.pump(_frame);
      }
      _expectMonotone(slide, reason: 'slide ($direction)');
      _expectMonotone(under, reason: 'the page under ($direction)');
      expect(slide.last, 0);
      // The other way, and less far.
      expect(under.last * sign, lessThan(0));
      expect(under.last.abs(), lessThan(78));
      await tester.pump(const Duration(milliseconds: 400));
      _navigator.currentState!.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      // Uncovered again, the page under it is back in place.
      expect(
        _transition(tester, find.byKey(home, skipOffstage: false)).offset,
        Offset.zero,
      );
    }
  });

  testWidgets('a full-screen dialog rises from below', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(formFactor: FormFactor.mobile));
    await _push(tester, fullscreenDialog: true);
    final first = _transition(tester, find.byKey(page));
    expect(first.offset.dx, 0);
    expect(first.offset.dy, greaterThan(0));
    await tester.pump(_frame);
    // The page under a dialog does not give way.
    expect(
      _transition(tester, find.byKey(home, skipOffstage: false)).offset,
      Offset.zero,
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(_transition(tester, find.byKey(page)).offset, Offset.zero);
  });

  testWidgets('popped while it is still arriving, it turns around where it '
      'is', (tester) async {
    await tester.pumpWidget(_app());
    await _push(tester);
    final opacity = <double>[];
    final rise = <double>[];
    void sample() {
      final now = _transition(tester, find.byKey(page));
      opacity.add(now.opacity);
      rise.add(now.offset.dy);
    }

    for (var i = 0; i < 5; i++) {
      await tester.pump(_frame);
      sample();
    }
    _navigator.currentState!.pop();
    for (var i = 0; i < 20; i++) {
      await tester.pump(_frame);
      if (find.byKey(page).evaluate().isEmpty) break;
      sample();
    }
    for (var i = 1; i < opacity.length; i++) {
      expect(
        (opacity[i] - opacity[i - 1]).abs(),
        lessThan(.4),
        reason: 'opacity jumps at frame $i: $opacity',
      );
      expect(
        (rise[i] - rise[i - 1]).abs(),
        lessThan(_motion.overlayTravel),
        reason: 'the page jumps at frame $i: $rise',
      );
    }
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(page), findsNothing);
  });

  testWidgets('with reduced motion it only fades; with no motion it is '
      'simply there', (tester) async {
    await tester.pumpWidget(_app(reduceMotion: true));
    await tester.pump(const Duration(milliseconds: 300));
    await _push(tester);
    final opacity = <double>[];
    for (var i = 0; i < 12; i++) {
      final now = _transition(tester, find.byKey(page));
      expect(now.offset, Offset.zero);
      opacity.add(now.opacity);
      await tester.pump(_frame);
    }
    _expectMonotone(opacity, reason: 'opacity');
    expect(opacity.where((o) => o > 0 && o < 1), isNotEmpty);
    expect(opacity.last, 1);
    _navigator.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pumpWidget(_app(motion: Motion.none));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await _push(tester);
    final now = _transition(tester, find.byKey(page));
    expect(now.opacity, 1);
    expect(now.offset, Offset.zero);
    _navigator.currentState!.pop();
    await tester.pump();
    await tester.pump();
    expect(find.byKey(page), findsNothing);
  });
}
