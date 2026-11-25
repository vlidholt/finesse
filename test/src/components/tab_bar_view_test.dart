import 'package:finesse/finesse.dart';
import 'package:finesse/src/components/tab_bar_view.dart' show TabPages;
import 'package:finesse/src/utils/moving_indicator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// The pages of a tab bar: [TabBarView] on its own, and inside [Tabs],
/// where a finger swipes from one tab's content to the next and the bar's
/// indicator goes with it.
const _frame = Duration(milliseconds: 16);

const _values = ['a', 'b', 'c'];

/// No bounce, so "does not turn back" can be asked of every frame.
final _theme = ThemeData(
  motion: Motion.lively.copyWith(snappy: const MotionSpring()),
);

/// A bar and its pages on one controller, as an app bar and a body are.
class _Apart extends StatelessWidget {
  const _Apart({
    required this.controller,
    this.heights = const [200, 200, 200],
    this.maintainState = true,
  });

  final TabsController<String> controller;
  final List<double> heights;
  final bool maintainState;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar<String>(
              controller: controller,
              tabs: [
                for (final value in _values)
                  Tab(value: value, child: Text('tab $value')),
              ],
            ),
            TabBarView<String>(
              controller: controller,
              maintainState: maintainState,
              pages: {
                for (final (index, value) in _values.indexed)
                  value: (context) => SizedBox(
                    key: ValueKey('page $value'),
                    height: heights[index],
                    child: Text('page $value'),
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

Finder _page(String value) => find.byKey(ValueKey('page $value'));

RenderMovingIndicator _indicator(WidgetTester tester) => tester.renderObject(
  find.byWidgetPredicate(
    (w) => '${w.runtimeType}' == '_MovingIndicatorRenderWidget',
  ),
);

/// The rectangles the indicator rests on, in the indicator's coordinates.
List<Rect> _targets(WidgetTester tester) {
  final origin = tester.getTopLeft(
    find.byWidgetPredicate(
      (w) => '${w.runtimeType}' == '_MovingIndicatorRenderWidget',
    ),
  );
  return [
    for (final element in find.byType(MovingIndicatorTarget).evaluate())
      tester.getRect(find.byWidget(element.widget)).shift(-origin),
  ];
}

/// How far apart two pages are: a page's width and the gutter between
/// two.
double _apart(WidgetTester tester) =>
    300 +
    Theme.of(
      tester.element(find.byType(MovingIndicatorTarget).first),
    ).layoutTheme.gap(GapSize.lg);

void _expectMonotone(List<double> values, {required String reason}) {
  final rising = values.last >= values.first;
  for (var i = 1; i < values.length; i++) {
    final step = values[i] - values[i - 1];
    expect(
      rising ? step >= -1e-6 : step <= 1e-6,
      isTrue,
      reason: '$reason turned back at frame $i: $values',
    );
  }
}

void main() {
  late TabsController<String> controller;

  setUp(() => controller = TabsController(value: 'a'));
  tearDown(() => controller.dispose());

  group('a drag', () {
    testWidgets('moves the pages with the finger and the indicator between '
        'the tabs, and springs to the next page past the middle', (
      tester,
    ) async {
      await pumpFinesse(tester, _Apart(controller: controller), theme: _theme);
      await tester.pump(const Duration(milliseconds: 300));
      final indicator = _indicator(tester);
      final targets = _targets(tester);
      expect(indicator.indicatorRect, targets[0]);
      expect(_page('a').hitTestable(), findsOneWidget);
      expect(_page('b').hitTestable(), findsNothing);
      final pageLeft = tester.getTopLeft(_page('a')).dx;

      final gesture = await tester.startGesture(
        tester.getCenter(_page('a')),
      );
      await tester.pump();
      var dragged = 0.0;
      for (var i = 0; i < 9; i++) {
        await gesture.moveBy(const Offset(-20, 0));
        await tester.pump(_frame);
        dragged += 20;
        // The page is under the finger, the next beside it…
        expect(
          tester.getTopLeft(_page('a')).dx,
          moreOrLessEquals(pageLeft - dragged, epsilon: .01),
        );
        expect(
          tester.getTopLeft(_page('b')).dx,
          moreOrLessEquals(
            pageLeft - dragged + _apart(tester),
            epsilon: .01,
          ),
        );
        // …and the line as far between the two tabs as the pages are.
        final t = dragged / _apart(tester);
        expect(controller.swipePosition.value, moreOrLessEquals(t));
        expect(
          indicator.indicatorRect!.left,
          moreOrLessEquals(
            targets[0].left + (targets[1].left - targets[0].left) * t,
            epsilon: .01,
          ),
        );
        // Nothing is chosen until it is let go.
        expect(controller.value, 'a');
      }
      // Held still, so letting go is not a flick: past the middle decides.
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      expect(controller.value, 'b');
      final left = <double>[];
      final line = <double>[];
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        left.add(tester.getTopLeft(_page('b')).dx);
        line.add(indicator.indicatorRect!.left);
      }
      _expectMonotone(left, reason: 'the page');
      _expectMonotone(line, reason: 'the line');
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(_page('b')).dx, pageLeft);
      expect(indicator.indicatorRect, targets[1]);
      expect(controller.swipePosition.value, isNull);
      expect(_page('a').hitTestable(), findsNothing);
      expect(_page('b').hitTestable(), findsOneWidget);
    });

    testWidgets('let go before the middle goes back, and reports nothing', (
      tester,
    ) async {
      final changes = <String>[];
      controller.addListener(() => changes.add(controller.value));
      await pumpFinesse(tester, _Apart(controller: controller), theme: _theme);
      final gesture = await tester.startGesture(
        tester.getCenter(_page('a')),
      );
      await gesture.moveBy(const Offset(-80, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(tester.getTopLeft(_page('a')).dx, 0);
      expect(_indicator(tester).indicatorRect, _targets(tester)[0]);
      expect(controller.swipePosition.value, isNull);
    });

    testWidgets('a flick turns the page from anywhere', (tester) async {
      await pumpFinesse(tester, _Apart(controller: controller), theme: _theme);
      await tester.flingFrom(
        tester.getCenter(_page('a')),
        const Offset(-60, 0),
        900,
      );
      await tester.pumpAndSettle();
      expect(controller.value, 'b');
      await tester.flingFrom(
        tester.getCenter(_page('b')),
        const Offset(60, 0),
        900,
      );
      await tester.pumpAndSettle();
      expect(controller.value, 'a');
    });

    testWidgets('past the first or the last page the pages resist and come '
        'back', (tester) async {
      await pumpFinesse(tester, _Apart(controller: controller), theme: _theme);
      final gesture = await tester.startGesture(
        tester.getCenter(_page('a')),
      );
      await gesture.moveBy(const Offset(90, 0));
      await tester.pump();
      // A third as far as the finger.
      expect(tester.getTopLeft(_page('a')).dx, moreOrLessEquals(30));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(controller.value, 'a');
      expect(tester.getTopLeft(_page('a')).dx, 0);
    });

    testWidgets('is mirrored in a right-to-left layout', (tester) async {
      await pumpFinesse(
        tester,
        _Apart(controller: controller),
        theme: _theme,
        textDirection: TextDirection.rtl,
      );
      await tester.pump(const Duration(milliseconds: 300));
      final rest = tester.getTopLeft(_page('a')).dx;
      final gesture = await tester.startGesture(
        tester.getCenter(_page('a')),
      );
      // The next page is to the left: it is pulled in towards the right.
      await gesture.moveBy(const Offset(200, 0));
      await tester.pump();
      expect(tester.getTopLeft(_page('a')).dx, moreOrLessEquals(rest + 200));
      expect(
        tester.getTopLeft(_page('b')).dx,
        moreOrLessEquals(rest + 200 - _apart(tester)),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(controller.value, 'b');
    });

    testWidgets('with a mouse does nothing: it would select text', (
      tester,
    ) async {
      await pumpFinesse(tester, _Apart(controller: controller), theme: _theme);
      final mouse = await tester.startGesture(
        tester.getCenter(_page('a')),
        kind: PointerDeviceKind.mouse,
      );
      await mouse.moveBy(const Offset(-30, 0));
      await mouse.moveBy(const Offset(-200, 0));
      await tester.pump();
      expect(tester.getTopLeft(_page('a')).dx, 0);
      await mouse.up();
      await tester.pumpAndSettle();
      expect(controller.value, 'a');
    });

    testWidgets('with reduced motion still follows the finger, and is on '
        'the page at once when let go', (tester) async {
      await pumpFinesse(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _Apart(controller: controller),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(_page('a')),
      );
      await gesture.moveBy(const Offset(-200, 0));
      await tester.pump();
      expect(tester.getTopLeft(_page('a')).dx, moreOrLessEquals(-200));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pump();
      expect(controller.value, 'b');
      expect(tester.getTopLeft(_page('b')).dx, 0);
      expect(controller.swipePosition.value, isNull);
    });

    testWidgets('takes the height from one page to the next when the pages '
        'are as tall as their content', (tester) async {
      await pumpFinesse(
        tester,
        _Apart(controller: controller, heights: const [100, 300, 100]),
        theme: _theme,
      );
      final view = find.byType(TabBarView<String>);
      expect(tester.getSize(view).height, 100);
      final gesture = await tester.startGesture(
        tester.getCenter(_page('a')),
      );
      final heights = <double>[];
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(-15, 0));
        await tester.pump(_frame);
        heights.add(tester.getSize(view).height);
      }
      _expectMonotone(heights, reason: 'the height');
      // As far between the two heights as the pages are between them.
      expect(
        heights.last,
        moreOrLessEquals(100 + 200 * 150 / _apart(tester), epsilon: .01),
      );
      await gesture.moveBy(const Offset(-30, 0));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.getSize(view).height, 300);
    });

    testWidgets('caught while the pages settle, they stop under the finger', (
      tester,
    ) async {
      await pumpFinesse(tester, _Apart(controller: controller), theme: _theme);
      await tester.flingFrom(
        tester.getCenter(_page('a')),
        const Offset(-60, 0),
        900,
      );
      await tester.pump(_frame);
      await tester.pump(_frame);
      final gesture = await tester.startGesture(const Offset(150, 150));
      await tester.pump();
      final held = tester.getTopLeft(_page('b')).dx;
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getTopLeft(_page('b')).dx, held);
      // Back to where it came from.
      await gesture.moveBy(Offset(_apart(tester) - held, 0));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(controller.value, 'a');
      expect(tester.getTopLeft(_page('a')).dx, 0);
    });
  });

  group('a value chosen elsewhere', () {
    testWidgets('swaps the page with a fade from its side, and the indicator '
        'travels as it does for a tap', (tester) async {
      await pumpFinesse(tester, _Apart(controller: controller), theme: _theme);
      await tester.pump(const Duration(milliseconds: 300));
      final indicator = _indicator(tester);
      await tester.tap(find.text('tab c'));
      expect(controller.value, 'c');
      await tester.pump();
      await tester.pump(_frame);
      // The page is in place at once: no pages in between fly past.
      expect(_page('c').hitTestable(), findsOneWidget);
      expect(_page('b').hitTestable(), findsNothing);
      final fade = tester.widget<FadeTransition>(
        find
            .ancestor(of: _page('c'), matching: find.byType(FadeTransition))
            .first,
      );
      expect(fade.opacity.value, inExclusiveRange(0, 1));
      expect(tester.getTopLeft(_page('c')).dx, greaterThan(0));
      // The line is on its way, not there yet.
      final targets = _targets(tester);
      expect(
        indicator.indicatorRect!.left,
        inExclusiveRange(targets[0].left, targets[2].left),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(_page('c')).dx, 0);
      expect(indicator.indicatorRect, targets[2]);
    });

    testWidgets('the arrow keys in the bar change the page', (tester) async {
      await pumpFinesse(tester, _Apart(controller: controller), theme: _theme);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(controller.value, 'b');
      expect(_page('b').hitTestable(), findsOneWidget);
    });
  });

  group('TabBarView', () {
    testWidgets('controlled by value: a swipe that the value does not follow '
        'comes back', (tester) async {
      final asked = <String>[];
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            height: 200,
            child: TabBarView<String>(
              value: 'a',
              onChanged: asked.add,
              pages: {
                for (final value in _values)
                  value: (context) =>
                      SizedBox.expand(key: ValueKey('page $value')),
              },
            ),
          ),
        ),
        theme: _theme,
      );
      await tester.flingFrom(const Offset(150, 100), const Offset(-60, 0), 900);
      await tester.pumpAndSettle();
      expect(asked, ['b']);
      expect(tester.getTopLeft(_page('a')).dx, 0);
      expect(_page('b'), findsNothing);
    });

    testWidgets('two fingers on a trackpad swipe the pages', (tester) async {
      await pumpFinesse(tester, _Apart(controller: controller), theme: _theme);
      final start = tester.getCenter(_page('a'));
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.trackpad,
      );
      await gesture.panZoomStart(start);
      for (var i = 1; i <= 10; i++) {
        await gesture.panZoomUpdate(start, pan: Offset(-20.0 * i, 0));
        await tester.pump(_frame);
      }
      await gesture.panZoomEnd();
      await tester.pumpAndSettle();
      expect(controller.value, 'b');
    });

    test('takes a value or a controller', () {
      final pages = <String, WidgetBuilder>{
        'a': (context) => const SizedBox.shrink(),
      };
      expect(() => TabBarView<String>(pages: pages), throwsAssertionError);
    });

    testWidgets('given a height it fills it and so does each page', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            height: 240,
            child: TabBarView<String>(
              value: 'a',
              pages: {
                'a': (context) => const ColoredBox(
                  key: ValueKey('page a'),
                  color: Color(0xFF000000),
                ),
                'b': (context) => const SizedBox.shrink(),
              },
            ),
          ),
        ),
      );
      expect(tester.getSize(_page('a')), const Size(300, 240));
    });

    testWidgets('keeps the state of a page that is not showing, or builds '
        'only what shows with maintainState: false', (tester) async {
      for (final maintain in [true, false]) {
        final controller = TabsController<String>(value: 'a');
        addTearDown(controller.dispose);
        await pumpFinesse(
          tester,
          _Apart(controller: controller, maintainState: maintain),
          theme: _theme,
        );
        expect(
          find.byKey(const ValueKey('page b'), skipOffstage: false),
          maintain ? findsOneWidget : findsNothing,
        );
        // Dragged in, it is built either way.
        final gesture = await tester.startGesture(
          tester.getCenter(_page('a')),
        );
        await gesture.moveBy(const Offset(-50, 0));
        await tester.pump();
        expect(_page('b'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('page c'), skipOffstage: false),
          maintain ? findsOneWidget : findsNothing,
        );
        await gesture.up();
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('a page that is not showing takes no focus, runs no '
        'animation and is not read', (tester) async {
      final handle = tester.ensureSemantics();
      final ticking = <String, bool>{};
      final controller = TabsController<String>(value: 'a');
      addTearDown(controller.dispose);
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            height: 200,
            child: TabBarView<String>(
              controller: controller,
              pages: {
                for (final value in _values)
                  value: (context) {
                    ticking[value] = TickerMode.of(context);
                    return Focus(child: Text('page $value'));
                  },
              },
            ),
          ),
        ),
        theme: _theme,
      );
      expect(ticking, {'a': true, 'b': false, 'c': false});
      expect(find.bySemanticsLabel('page a'), findsOneWidget);
      expect(find.bySemanticsLabel('page b'), findsNothing);
      // There is one stop in the view, and Tab does not find the others.
      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(
          find.descendant(
            of: find.byElementPredicate(
              (e) => e == FocusManager.instance.primaryFocus!.context,
            ),
            matching: find.text('page a'),
          ),
          findsOneWidget,
        );
      }
      controller.value = 'b';
      await tester.pumpAndSettle();
      expect(ticking, {'a': false, 'b': true, 'c': false});
      expect(find.bySemanticsLabel('page b'), findsOneWidget);
      expect(find.bySemanticsLabel('page a'), findsNothing);
      handle.dispose();
    });
  });

  group('Tabs', () {
    Widget tabs({
      String value = 'a',
      ValueChanged<String>? onChanged,
      bool swipeable = true,
      bool disableB = false,
    }) {
      return Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 300,
          child: Tabs<String>(
            value: value,
            onChanged: onChanged,
            swipeable: swipeable,
            tabs: [
              for (final v in _values)
                Tab(
                  value: v,
                  enabled: !(disableB && v == 'b'),
                  content: SizedBox(
                    key: ValueKey('page $v'),
                    width: 300,
                    height: 120,
                    child: Text('page $v'),
                  ),
                  child: Text(v.toUpperCase()),
                ),
            ],
          ),
        ),
      );
    }

    testWidgets('its content swipes to the next tab, the pill following the '
        'finger', (tester) async {
      var value = 'a';
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => tabs(
            value: value,
            onChanged: (next) => setState(() => value = next),
          ),
        ),
        theme: _theme,
      );
      await tester.pump(const Duration(milliseconds: 300));
      final indicator = _indicator(tester);
      final targets = _targets(tester);
      final gesture = await tester.startGesture(
        tester.getCenter(_page('a')),
      );
      await gesture.moveBy(const Offset(-150, 0));
      await tester.pump();
      expect(
        indicator.indicatorRect!.left,
        moreOrLessEquals(
          targets[0].left +
              (targets[1].left - targets[0].left) * 150 / _apart(tester),
          epsilon: .01,
        ),
      );
      await gesture.moveBy(const Offset(-30, 0));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(value, 'b');
      expect(indicator.indicatorRect, targets[1]);
    });

    testWidgets('swipeable: false leaves the content where it is', (
      tester,
    ) async {
      final changes = <String>[];
      await pumpFinesse(
        tester,
        tabs(onChanged: changes.add, swipeable: false),
        theme: _theme,
      );
      await tester.flingFrom(
        tester.getCenter(_page('a')),
        const Offset(-80, 0),
        900,
      );
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(tester.getTopLeft(_page('a')).dx, 0);
    });

    testWidgets('a disabled tab is not swiped to', (tester) async {
      final changes = <String>[];
      await pumpFinesse(
        tester,
        tabs(onChanged: changes.add, disableB: true),
        theme: _theme,
      );
      await tester.flingFrom(
        tester.getCenter(_page('a')),
        const Offset(-80, 0),
        900,
      );
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(tester.getTopLeft(_page('a')).dx, 0);
    });

    testWidgets('a horizontal scrollable in the content scrolls first', (
      tester,
    ) async {
      final changes = <String>[];
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            child: Tabs<String>(
              value: 'a',
              onChanged: changes.add,
              tabs: [
                Tab(
                  value: 'a',
                  content: SizedBox(
                    height: 100,
                    child: ListView(
                      controller: scroll,
                      scrollDirection: Axis.horizontal,
                      children: const [SizedBox(width: 1000)],
                    ),
                  ),
                  child: const Text('A'),
                ),
                const Tab(value: 'b', content: Text('B'), child: Text('B')),
              ],
            ),
          ),
        ),
        theme: _theme,
      );
      await tester.dragFrom(const Offset(150, 100), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(scroll.offset, greaterThan(100));
      expect(changes, isEmpty);
    });

    testWidgets('controlled by a controller shared with nothing else', (
      tester,
    ) async {
      final controller = TabsController<String>(value: 'b');
      addTearDown(controller.dispose);
      await pumpFinesse(
        tester,
        Tabs<String>(
          controller: controller,
          tabs: const [
            Tab(value: 'a', content: Text('page a'), child: Text('A')),
            Tab(value: 'b', content: Text('page b'), child: Text('B')),
          ],
        ),
      );
      expect(find.text('page b').hitTestable(), findsOneWidget);
      controller.value = 'a';
      await tester.pumpAndSettle();
      expect(find.text('page a').hitTestable(), findsOneWidget);
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(controller.value, 'b');
    });

    testWidgets('controlled by value: a parent that does not follow keeps '
        'its tab', (tester) async {
      final changes = <String>[];
      await pumpFinesse(tester, tabs(onChanged: changes.add), theme: _theme);
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(changes, ['b']);
      expect(find.text('page a').hitTestable(), findsOneWidget);
      expect(find.text('page b').hitTestable(), findsNothing);
      // Swiped, the pages come back to the tab the value names.
      await tester.flingFrom(
        tester.getCenter(_page('a')),
        const Offset(-80, 0),
        900,
      );
      await tester.pumpAndSettle();
      expect(changes, ['b', 'b']);
      expect(tester.getTopLeft(_page('a')).dx, 0);
      expect(find.text('page b').hitTestable(), findsNothing);
    });

    testWidgets('with a value and no onChanged is inert, as TabBar is', (
      tester,
    ) async {
      await pumpFinesse(tester, tabs(), theme: _theme);
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(find.text('page a').hitTestable(), findsOneWidget);
      await tester.flingFrom(
        tester.getCenter(_page('a')),
        const Offset(-80, 0),
        900,
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(_page('a')).dx, 0);
      expect(find.text('page b').hitTestable(), findsNothing);
    });

    testWidgets('restores a selection whose values are not primitives', (
      tester,
    ) async {
      var value = TabBarVariant.segmented;
      await tester.pumpWidget(
        FinesseApp(
          restorationScopeId: 'app',
          home: StatefulBuilder(
            builder: (context, setState) => Tabs<TabBarVariant>(
              value: value,
              onChanged: (next) => setState(() => value = next),
              restorationId: 'tabs',
              tabs: const [
                Tab(
                  value: TabBarVariant.segmented,
                  content: Text('page segmented'),
                  child: Text('Segmented'),
                ),
                Tab(
                  value: TabBarVariant.underline,
                  content: Text('page underline'),
                  child: Text('Underline'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Underline'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('page underline').hitTestable(), findsOneWidget);
      value = TabBarVariant.segmented;
      await tester.restartAndRestore();
      expect(find.text('page underline').hitTestable(), findsOneWidget);
    });

    testWidgets('expandContent in a scrolling page is as tall as its '
        'content', (tester) async {
      await pumpFinesse(
        tester,
        SingleChildScrollView(
          child: Tabs<String>(
            value: 'a',
            expandContent: true,
            tabs: const [
              Tab(
                value: 'a',
                content: SizedBox(height: 120, child: Text('page a')),
                child: Text('A'),
              ),
              Tab(value: 'b', content: Text('page b'), child: Text('B')),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(TabPages)).height, 120);
    });

    testWidgets('the underline variant is the same widget with the other '
        'bar', (tester) async {
      await pumpFinesse(
        tester,
        const SizedBox(
          width: 300,
          child: Tabs<String>(
            value: 'a',
            variant: TabBarVariant.underline,
            tabs: [
              Tab(value: 'a', content: Text('page a'), child: Text('A')),
              Tab(value: 'b', content: Text('page b'), child: Text('B')),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      // A line, not a pill.
      final target = tester.widget<MovingIndicatorTarget>(
        find.byType(MovingIndicatorTarget).first,
      );
      expect(tester.getSize(find.byWidget(target)).height, 2);
    });
  });
}
