import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// [UnaPageRoute] brings a page in with a short slide and a fade, on the
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
  return UnaApp(
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
    UnaPageRoute<void>(
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

  testWidgets('a tap lands on the page where it is painted, part-way in', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(formFactor: FormFactor.mobile));
    await tester.pump(const Duration(milliseconds: 300));
    var taps = 0;
    _navigator.currentState!.push(
      UnaPageRoute<void>(
        builder: (context) => Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap: () => taps++,
            child: const ColoredBox(
              key: page,
              color: Color(0xFF000000),
              child: SizedBox.square(dimension: 20),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(_frame);
    await tester.pump(_frame);
    final shift = _transition(tester, find.byKey(page)).offset;
    // Still well off its place: a tap where it will be misses it, a tap
    // where it is drawn hits it.
    expect(shift.dx, greaterThan(30));
    await tester.tapAt(const Offset(10, 10));
    expect(taps, 0);
    await tester.tapAt(shift + const Offset(10, 10));
    expect(taps, 1);
  });

  testWidgets('a transition is set up once, not on every tick', (
    tester,
  ) async {
    // The framework calls `buildTransitions` each time either animation of
    // a route moves — for the page coming in and the one under it. What it
    // returns used to be made from scratch every time: new animation objects
    // (so every render object below dropped its listener and subscribed
    // again) around a `LayoutBuilder` with a new callback (so both pages
    // were laid out again). Now the animations are kept with the route and
    // the movement is paint.
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(formFactor: FormFactor.mobile));
    await tester.pump(const Duration(milliseconds: 300));

    final route = _CountingRoute<void>(
      builder: (context) => const SizedBox.expand(key: page),
    );
    _navigator.currentState!.push(route);
    await tester.pump();
    await tester.pump(_frame);

    RenderAnimatedOpacity fadeOf(Key key) => tester.renderObject(
      find
          .ancestor(
            of: find.byKey(key, skipOffstage: false),
            matching: find.byType(FadeTransition, skipOffstage: false),
          )
          .first,
    );
    final fades = {page: fadeOf(page).opacity, home: fadeOf(home).opacity};
    final subscribed = (route.primary!.adds, route.secondary!.adds);
    final calls = route.calls;

    final moved = <double>[];
    for (var i = 0; i < 8; i++) {
      await tester.pump(_frame);
      moved.add(_transition(tester, find.byKey(page)).offset.dx);
      // The same animation objects, on the page coming in and on the one
      // giving way under it.
      expect(fadeOf(page).opacity, same(fades[page]));
      expect(fadeOf(home).opacity, same(fades[home]));
    }
    // It was called on every one of those ticks, and it is moving…
    expect(route.calls - calls, 8);
    expect(moved.toSet().length, greaterThan(4));
    // …without anything subscribing to the route's animations again.
    expect((route.primary!.adds, route.secondary!.adds), subscribed);
    expect(route.primary!.removes, 0);
    expect(route.secondary!.removes, 0);
    // And no layout pass is forced on the pages to find out their width.
    for (final key in [page, home]) {
      expect(
        find.ancestor(
          of: find.byKey(key, skipOffstage: false),
          matching: find.descendant(
            of: find.byType(Navigator),
            matching: find.byType(LayoutBuilder, skipOffstage: false),
            skipOffstage: false,
          ),
        ),
        findsNothing,
      );
    }

    await tester.pump(const Duration(milliseconds: 600));
    _navigator.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(page), findsNothing);
    // Everything that subscribed has let go.
    expect(route.primary!.removes, route.primary!.adds);
    expect(route.secondary!.removes, route.secondary!.adds);
  });
}

/// A page route that hands its transition animations on through
/// [_CountingAnimation]s.
class _CountingRoute<T> extends UnaPageRoute<T> {
  _CountingRoute({required super.builder});

  _CountingAnimation? primary;
  _CountingAnimation? secondary;
  int calls = 0;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    calls++;
    if (primary?.parent != animation) primary = _CountingAnimation(animation);
    if (secondary?.parent != secondaryAnimation) {
      secondary = _CountingAnimation(secondaryAnimation);
    }
    return super.buildTransitions(context, primary!, secondary!, child);
  }
}

/// An animation that counts who subscribes to it.
class _CountingAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  _CountingAnimation(this.parent);

  @override
  final Animation<double> parent;

  int adds = 0;
  int removes = 0;

  @override
  void addListener(VoidCallback listener) {
    adds++;
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    removes++;
    super.removeListener(listener);
  }

  @override
  double get value => parent.value;
}
