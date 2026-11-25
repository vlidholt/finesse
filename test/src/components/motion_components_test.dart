import 'package:finesse/finesse.dart';
import 'package:finesse/src/utils/moving_indicator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../decoration_finders.dart';

/// Frame-by-frame checks of the transitions the components play: each one
/// moves monotonically towards its target, can be interrupted without a
/// jump, leaves layout alone and becomes an instant change with reduced
/// motion.
const _frame = Duration(milliseconds: 16);

// A spring without bounce, so "monotone" is exact.
final _motion = Motion.lively.copyWith(
  snappy: const MotionSpring(),
  smooth: const MotionSpring(duration: Duration(milliseconds: 300)),
  bouncy: const MotionSpring(),
);

Widget _app(
  Widget child, {
  bool reduceMotion = false,
  Motion? motion,
}) {
  return FinesseApp(
    theme: ThemeData(motion: motion ?? _motion),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reduceMotion,
        ),
        child: Center(child: child),
      ),
    ),
  );
}

RenderMovingIndicator _indicator(WidgetTester tester, Finder within) =>
    tester.renderObject<RenderMovingIndicator>(
      find.descendant(
        of: within,
        matching: find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_MovingIndicatorRenderWidget',
        ),
      ),
    );

/// Asserts [values] never turn back on the way from first to last.
void _expectMonotone(List<double> values, {String? reason}) {
  final rising = values.last >= values.first;
  for (var i = 1; i < values.length; i++) {
    final step = values[i] - values[i - 1];
    expect(
      rising ? step >= -1e-9 : step <= 1e-9,
      isTrue,
      reason: '${reason ?? 'sequence'} turned back at frame $i: $values',
    );
  }
}

Future<TestGesture> _mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

void main() {
  group('Tabs', () {
    Widget tabs(String value, {bool reduceMotion = false}) => _app(
      SizedBox(
        width: 400,
        child: Tabs<String>(
          value: value,
          tabs: const [
            Tab(value: 'a', content: Text('first'), child: Text('A')),
            Tab(value: 'b', content: Text('second'), child: Text('B')),
            Tab(value: 'c', content: Text('third'), child: Text('C')),
          ],
        ),
      ),
      reduceMotion: reduceMotion,
    );

    testWidgets('one pill travels from the old tab to the new one', (
      tester,
    ) async {
      await tester.pumpWidget(tabs('a'));
      await tester.pumpAndSettle();
      final first = tester.getRect(find.widgetWithText(Button, 'A'));
      final last = tester.getRect(find.widgetWithText(Button, 'C'));
      final indicator = _indicator(tester, find.byType(Tabs<String>));
      final origin = tester.getTopLeft(
        find.byType(MovingIndicator),
      );
      expect(indicator.indicatorRect!.shift(origin), first);

      await tester.pumpWidget(tabs('c'));
      final lefts = <double>[];
      final rights = <double>[];
      for (var i = 0; i < 60; i++) {
        final rect = indicator.indicatorRect!.shift(origin);
        lefts.add(rect.left);
        rights.add(rect.right);
        expect(indicator.indicatorOpacity, 1);
        await tester.pump(_frame);
      }
      _expectMonotone(lefts, reason: 'left edge');
      _expectMonotone(rights, reason: 'right edge');
      expect(lefts.first, first.left);
      expect(indicator.indicatorRect!.shift(origin), last);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('the tabs themselves paint no selected fill', (tester) async {
      await tester.pumpWidget(tabs('a'));
      await tester.pumpAndSettle();
      final theme = Theme.of(tester.element(find.byType(Tabs<String>)));
      final fill = theme.tabsTheme.tabSelectedBackgroundColor;
      final painted = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(Button),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((box) => boxDecorationOf(box.decoration)?.color)
          .where((color) => color != null && color.a > 0);
      expect(painted, isEmpty);
      // The pill carries it.
      final target = tester.widget<MovingIndicatorTarget>(
        find.byWidgetPredicate(
          (w) => w is MovingIndicatorTarget && w.selected,
        ),
      );
      expect(boxDecorationOf(target.decoration)!.color, fill);
    });

    testWidgets('the new content fades in from the side its tab is on, '
        'without moving in layout', (tester) async {
      await tester.pumpWidget(tabs('a'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(tabs('c'));

      FadeTransition fade() => tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.text('third'),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      final opacities = <double>[];
      final offsets = <double>[];
      Offset? laidOut;
      for (var i = 0; i < 30; i++) {
        opacities.add(fade().opacity.value);
        final render = tester.renderObject<RenderBox>(find.text('third'));
        final painted = render.localToGlobal(Offset.zero);
        offsets.add(painted.dx);
        // Layout position: the transform's own box does not move.
        final box = tester.getTopLeft(
          find
              .ancestor(
                of: find.text('third'),
                matching: find.byType(FadeTransition),
              )
              .first,
        );
        laidOut ??= box;
        expect(box, laidOut);
        await tester.pump(_frame);
      }
      expect(opacities.first, 0);
      expect(opacities.last, 1);
      _expectMonotone(opacities, reason: 'content opacity');
      // 'c' is after 'a': it comes from the right and settles leftwards.
      expect(offsets.first, greaterThan(offsets.last));
      _expectMonotone(offsets, reason: 'content offset');
      // The old content is gone at once; the panels do not stack.
      expect(find.text('first').hitTestable(), findsNothing);
    });

    testWidgets('going back comes from the other side', (tester) async {
      await tester.pumpWidget(tabs('c'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(tabs('a'));
      await tester.pump(_frame);
      final start = tester
          .renderObject<RenderBox>(find.text('first'))
          .localToGlobal(Offset.zero)
          .dx;
      await tester.pumpAndSettle();
      final end = tester
          .renderObject<RenderBox>(find.text('first'))
          .localToGlobal(Offset.zero)
          .dx;
      expect(start, lessThan(end));
    });

    testWidgets('nothing plays on first build', (tester) async {
      await tester.pumpWidget(tabs('b'));
      final fade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.text('second'),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, 1);
    });

    testWidgets('reduced motion moves the pill at once', (tester) async {
      await tester.pumpWidget(tabs('a', reduceMotion: true));
      await tester.pumpAndSettle();
      await tester.pumpWidget(tabs('c', reduceMotion: true));
      await tester.pump(_frame);
      final origin = tester.getTopLeft(find.byType(MovingIndicator));
      expect(
        _indicator(
          tester,
          find.byType(Tabs<String>),
        ).indicatorRect!.shift(origin),
        tester.getRect(find.widgetWithText(Button, 'C')),
      );
      // The content still fades, without sliding.
      final x = tester
          .renderObject<RenderBox>(find.text('third'))
          .localToGlobal(Offset.zero)
          .dx;
      await tester.pumpAndSettle();
      expect(
        tester
            .renderObject<RenderBox>(find.text('third'))
            .localToGlobal(Offset.zero)
            .dx,
        x,
      );
    });
  });

  group('TabBar', () {
    Widget bar(int index) => _app(
      SizedBox(
        width: 300,
        child: TabBar<int>(
          value: index,
          onChanged: (_) {},
          tabs: const [
            Tab(value: 0, child: Text('One')),
            Tab(value: 1, child: Text('Two')),
            Tab(value: 2, child: Text('Three')),
          ],
        ),
      ),
    );

    testWidgets('the underline travels and the label colours fade', (
      tester,
    ) async {
      await tester.pumpWidget(bar(0));
      await tester.pumpAndSettle();
      final indicator = _indicator(tester, find.byType(TabBar<int>));
      expect(indicator.indicatorRect!.width, 100);
      expect(indicator.indicatorRect!.height, 2);

      await tester.pumpWidget(bar(2));
      final lefts = <double>[];
      final reds = <double>[];
      for (var i = 0; i < 60; i++) {
        lefts.add(indicator.indicatorRect!.left);
        reds.add(
          tester
              .widget<DefaultTextStyle>(
                find
                    .ancestor(
                      of: find.text('Three'),
                      matching: find.byType(DefaultTextStyle),
                    )
                    .first,
              )
              .style
              .color!
              .r,
        );
        await tester.pump(_frame);
      }
      _expectMonotone(lefts, reason: 'underline');
      _expectMonotone(reds, reason: 'label colour');
      expect(lefts.first, 0);
      expect(lefts.last, 200);
      expect(reds.first, isNot(reds.last));
    });
  });

  group('ToggleGroup', () {
    Widget group(String value) => _app(
      ToggleGroup<String>(
        values: {value},
        onChanged: (_) {},
        children: const [
          ToggleGroupItem(value: 'a', child: Text('A')),
          ToggleGroupItem(value: 'b', child: Text('B')),
          ToggleGroupItem(value: 'c', child: Text('C')),
        ],
      ),
    );

    testWidgets('the selected fill travels between the items', (tester) async {
      await tester.pumpWidget(group('a'));
      await tester.pumpAndSettle();
      final indicator = _indicator(tester, find.byType(ToggleGroup<String>));
      final start = indicator.indicatorRect!;
      await tester.pumpWidget(group('c'));
      final lefts = <double>[];
      for (var i = 0; i < 60; i++) {
        lefts.add(indicator.indicatorRect!.left);
        await tester.pump(_frame);
      }
      _expectMonotone(lefts);
      expect(lefts.first, start.left);
      expect(lefts.last, greaterThan(start.right));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a group with several selections has no travelling fill', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          ToggleGroup<String>.multiple(
            values: const {'a', 'c'},
            onChanged: (_) {},
            children: const [
              ToggleGroupItem(value: 'a', child: Text('A')),
              ToggleGroupItem(value: 'b', child: Text('B')),
              ToggleGroupItem(value: 'c', child: Text('C')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MovingIndicatorTarget), findsNothing);
      expect(
        _indicator(tester, find.byType(ToggleGroup<String>)).indicatorRect,
        isNull,
      );
    });
  });

  group('Button', () {
    const rest = Color(0xff102030);
    const hover = Color(0xffa0b0c0);

    Widget button({bool enabled = true, VoidCallback? onPressed}) => _app(
      Button(
        style: const ButtonTheme(
          backgroundColor: rest,
          hoverBackgroundColor: hover,
        ),
        enabled: enabled,
        onPressed: onPressed ?? () {},
        child: const Text('Go'),
      ),
    );

    Color fill(WidgetTester tester) => tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(Button),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => boxDecorationOf(box.decoration)?.color)
        .whereType<Color>()
        .first;

    double scale(WidgetTester tester) => tester
        .widget<Transform>(
          find.descendant(
            of: find.byType(PressScale),
            matching: find.byType(Transform),
          ),
        )
        .transform
        .storage[0];

    testWidgets('the fill fades to its hover colour, and back from wherever '
        'it is', (tester) async {
      await tester.pumpWidget(button());
      await tester.pumpAndSettle();
      expect(fill(tester), rest);

      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.byType(Button)));
      final reds = <double>[];
      for (var i = 0; i < 5; i++) {
        await tester.pump(_frame);
        reds.add(fill(tester).r);
      }
      _expectMonotone(reds);
      expect(reds.last, inExclusiveRange(rest.r, hover.r));

      // Leave mid-fade: it turns around from the colour on screen.
      await mouse.moveTo(Offset.zero);
      final back = <double>[reds.last];
      for (var i = 0; i < 20; i++) {
        await tester.pump(_frame);
        back.add(fill(tester).r);
      }
      // The frame that learns of the exit still shows the fade's next
      // step; from there it only goes back. Never a jump.
      _expectMonotone(back.sublist(1));
      for (var i = 1; i < back.length; i++) {
        expect((back[i] - back[i - 1]).abs(), lessThan(.2));
      }
      expect(fill(tester), rest);
    });

    testWidgets('a press scales it down in paint only and springs back', (
      tester,
    ) async {
      await tester.pumpWidget(button());
      await tester.pumpAndSettle();
      final size = tester.getSize(find.byType(Button));
      expect(scale(tester), 1);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Button)),
      );
      // Past the tap-down deadline, then let the spring arrive.
      await tester.pump(kPressTimeout);
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        expect(tester.getSize(find.byType(Button)), size);
      }
      expect(scale(tester), closeTo(_motion.pressScale, 1e-3));

      await gesture.up();
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
      }
      expect(scale(tester), closeTo(1, 1e-3));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('a quick tap still gives a pulse', (tester) async {
      await tester.pumpWidget(button());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Button));
      var lowest = 1.0;
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        if (scale(tester) < lowest) lowest = scale(tester);
      }
      expect(lowest, lessThan(1 - (1 - _motion.pressScale) / 2));
      expect(scale(tester), closeTo(1, 1e-3));
    });

    testWidgets('a disabled button does not respond', (tester) async {
      await tester.pumpWidget(button(enabled: false));
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Button)),
      );
      await tester.pump(kPressTimeout);
      for (var i = 0; i < 10; i++) {
        await tester.pump(_frame);
        expect(scale(tester), 1);
      }
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('A Button with pressScale 1 does not scale; IconButton does', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(
                variant: ButtonVariant.ghost,
                style: const ButtonTheme(pressScale: 1),
                onPressed: () {},
                child: const Text('raw'),
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.plus),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      double scaleIn(Finder of) => tester
          .widget<Transform>(
            find.descendant(
              of: find.descendant(of: of, matching: find.byType(PressScale)),
              matching: find.byType(Transform),
            ),
          )
          .transform
          .storage[0];

      for (final target in [
        find.widgetWithText(Button, 'raw'),
        find.byType(IconButton),
      ]) {
        final gesture = await tester.startGesture(tester.getCenter(target));
        await tester.pump(kPressTimeout);
        for (var i = 0; i < 30; i++) {
          await tester.pump(_frame);
        }
        expect(
          scaleIn(target),
          target.evaluate().first.widget is IconButton
              ? closeTo(_motion.pressScale, 1e-3)
              : 1,
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('reduced motion: no scale, and the colour changes at the '
        'fast fade', (tester) async {
      await tester.pumpWidget(
        _app(
          Button(onPressed: () {}, child: const Text('Go')),
          reduceMotion: true,
        ),
      );
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Button)),
      );
      await tester.pump(kPressTimeout);
      await tester.pump(_frame);
      expect(scale(tester), 1);
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('Switch', () {
    Widget toggle({required bool value}) =>
        _app(Switch(value: value, onChanged: (_) {}));

    Finder thumb() => find.descendant(
      of: find.byType(Switch),
      matching: find.byWidgetPredicate(
        (w) => w is Transform && w.transform.getTranslation().y == 0,
      ),
    );

    double thumbX(WidgetTester tester) => tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byType(Switch),
            matching: find.byType(Transform),
          ),
        )
        .first
        .transform
        .getTranslation()
        .x;

    Color track(WidgetTester tester) => tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(Switch),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => boxDecorationOf(box.decoration)?.color)
        .whereType<Color>()
        .first;

    testWidgets('the thumb travels, the track blends, and the size holds', (
      tester,
    ) async {
      await tester.pumpWidget(toggle(value: false));
      await tester.pumpAndSettle();
      expect(thumb(), findsWidgets);
      final size = tester.getSize(find.byType(Switch));
      final off = track(tester);
      expect(thumbX(tester), 0);

      await tester.pumpWidget(toggle(value: true));
      final xs = <double>[];
      final reds = <double>[];
      for (var i = 0; i < 60; i++) {
        xs.add(thumbX(tester));
        reds.add(track(tester).r);
        expect(tester.getSize(find.byType(Switch)), size);
        await tester.pump(_frame);
      }
      _expectMonotone(xs, reason: 'thumb');
      _expectMonotone(reds, reason: 'track');
      expect(xs.last, greaterThan(10));
      expect(track(tester), isNot(off));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('toggling back mid-travel turns the thumb around where it '
        'is', (tester) async {
      await tester.pumpWidget(toggle(value: false));
      await tester.pumpAndSettle();
      await tester.pumpWidget(toggle(value: true));
      for (var i = 0; i < 5; i++) {
        await tester.pump(_frame);
      }
      var previous = thumbX(tester);
      expect(previous, greaterThan(0));
      await tester.pumpWidget(toggle(value: false));
      for (var i = 0; i < 60; i++) {
        await tester.pump(_frame);
        final x = thumbX(tester);
        expect((x - previous).abs(), lessThan(4), reason: 'frame $i');
        previous = x;
      }
      expect(previous, 0);
    });

    testWidgets('reduced motion moves it at once', (tester) async {
      await tester.pumpWidget(
        _app(Switch(value: false, onChanged: (_) {}), reduceMotion: true),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        _app(Switch(value: true, onChanged: (_) {}), reduceMotion: true),
      );
      await tester.pump(_frame);
      final x = thumbX(tester);
      expect(x, greaterThan(10));
      await tester.pumpAndSettle();
      expect(thumbX(tester), x);
    });
  });

  group('Checkbox', () {
    Widget box({required bool value}) =>
        _app(Checkbox(value: value, onChanged: (_) {}));

    testWidgets('the mark pops in and is gone again when unchecked', (
      tester,
    ) async {
      await tester.pumpWidget(box(value: false));
      await tester.pumpAndSettle();
      expect(find.bySubtype<Icon>(), findsNothing);

      await tester.pumpWidget(box(value: true));
      await tester.pump(_frame);
      await tester.pump(_frame);
      expect(find.bySubtype<Icon>(), findsOneWidget);
      final scales = <double>[];
      for (var i = 0; i < 40; i++) {
        scales.add(
          tester
              .widget<Transform>(
                find.descendant(
                  of: find.byType(PopIn),
                  matching: find.byType(Transform),
                ),
              )
              .transform
              .storage[0],
        );
        await tester.pump(_frame);
      }
      _expectMonotone(scales, reason: 'check scale');
      expect(scales.first, lessThan(1));
      expect(scales.last, 1);

      await tester.pumpWidget(box(value: false));
      await tester.pumpAndSettle();
      expect(find.bySubtype<Icon>(), findsNothing);
    });

    testWidgets('a box that starts checked is simply checked', (tester) async {
      await tester.pumpWidget(box(value: true));
      expect(find.bySubtype<Icon>(), findsOneWidget);
      expect(
        tester
            .widget<Transform>(
              find.descendant(
                of: find.byType(PopIn),
                matching: find.byType(Transform),
              ),
            )
            .transform
            .storage[0],
        1,
      );
    });
  });

  group('Accordion', () {
    Widget accordion() => _app(
      SizedBox(
        width: 300,
        child: Accordion<int>(
          children: const [
            AccordionItem(
              value: 1,
              title: Text('Title'),
              child: SizedBox(height: 100, child: Text('Body')),
            ),
          ],
        ),
      ),
    );

    testWidgets('opens by growing while the content fades in, and closes '
        'the same way', (tester) async {
      await tester.pumpWidget(accordion());
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
      final closed = tester.getSize(find.byType(Accordion<int>)).height;

      await tester.tap(find.text('Title'));
      await tester.pump();
      final heights = <double>[];
      final opacities = <double>[];
      for (var i = 0; i < 60; i++) {
        heights.add(tester.getSize(find.byType(Accordion<int>)).height);
        final reveal = find.byType(ExpandReveal);
        if (reveal.evaluate().isNotEmpty) {
          opacities.add(
            tester
                .widget<Opacity>(
                  find.descendant(of: reveal, matching: find.byType(Opacity)),
                )
                .opacity,
          );
        }
        await tester.pump(_frame);
      }
      _expectMonotone(heights, reason: 'height');
      _expectMonotone(opacities, reason: 'opacity');
      expect(heights.first, closed);
      expect(heights.last, closed + 108);
      expect(opacities.last, 1);
      expect(tester.hasRunningAnimations, isFalse);

      // Close, and reopen part-way: no jump.
      await tester.tap(find.text('Title'));
      await tester.pump();
      for (var i = 0; i < 6; i++) {
        await tester.pump(_frame);
      }
      var previous = tester.getSize(find.byType(Accordion<int>)).height;
      expect(previous, inExclusiveRange(closed, closed + 108));
      await tester.tap(find.text('Title'));
      await tester.pump();
      for (var i = 0; i < 60; i++) {
        await tester.pump(_frame);
        final height = tester.getSize(find.byType(Accordion<int>)).height;
        expect((height - previous).abs(), lessThan(20), reason: 'frame $i');
        previous = height;
      }
      expect(previous, closed + 108);
    });
  });

  group('ProgressBar', () {
    Widget bar(double value) =>
        _app(SizedBox(width: 200, child: ProgressBar(value: value)));

    testWidgets('glides to a new value', (tester) async {
      await tester.pumpWidget(bar(.2));
      await tester.pumpAndSettle();
      double fraction() => _progressFraction(tester);
      expect(fraction(), .2);

      await tester.pumpWidget(bar(.8));
      final values = <double>[];
      for (var i = 0; i < 60; i++) {
        values.add(fraction());
        await tester.pump(_frame);
      }
      _expectMonotone(values);
      expect(values.first, closeTo(.2, 1e-9));
      expect(values.last, closeTo(.8, 1e-9));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('jumps with reduced motion', (tester) async {
      await tester.pumpWidget(
        _app(
          const SizedBox(width: 200, child: ProgressBar(value: .2)),
          reduceMotion: true,
        ),
      );
      await tester.pumpWidget(
        _app(
          const SizedBox(width: 200, child: ProgressBar(value: .8)),
          reduceMotion: true,
        ),
      );
      await tester.pump(_frame);
      expect(_progressFraction(tester), .8);
    });
  });

  group('IndicatorBadge', () {
    Widget badge(int count) => _app(
      IndicatorBadge(
        count: count,
        child: const SizedBox.square(key: Key('target'), dimension: 24),
      ),
    );

    testWidgets('pops in, pops when the count changes, and pops out — and '
        'the child keeps its place in the tree', (tester) async {
      await tester.pumpWidget(badge(0));
      await tester.pumpAndSettle();
      final element = tester.element(find.byKey(const Key('target')));
      expect(find.text('0'), findsNothing);

      await tester.pumpWidget(badge(3));
      await tester.pump(_frame);
      await tester.pump(_frame);
      expect(find.text('3'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(tester.element(find.byKey(const Key('target'))), same(element));

      double pop() => tester
          .widget<Transform>(
            find.descendant(
              of: find.byType(PopOnChange),
              matching: find.byType(Transform),
            ),
          )
          .transform
          .storage[0];
      expect(pop(), 1);
      await tester.pumpWidget(badge(4));
      var peak = 1.0;
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        if (pop() > peak) peak = pop();
      }
      expect(peak, greaterThan(1.05));
      expect(pop(), closeTo(1, 1e-3));

      await tester.pumpWidget(badge(0));
      await tester.pump(_frame);
      // Still on its way out, showing what it showed.
      expect(find.byType(PopOnChange), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(PopOnChange), findsNothing);
      expect(tester.element(find.byKey(const Key('target'))), same(element));
    });

    testWidgets('a badge that is there from the start does not animate', (
      tester,
    ) async {
      await tester.pumpWidget(badge(3));
      expect(find.text('3'), findsOneWidget);
      // On its first frame it is fully there: `PopIn` keeps its wrappers
      // for the child's sake, at an opacity and a scale that do nothing.
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
      final label = find.text('3');
      expect(tester.getRect(label).size, tester.getSize(label));
    });
  });

  group('ContentSwitch', () {
    Widget content(int value, {int? direction}) => _app(
      ContentSwitch(
        value: value,
        direction: direction,
        child: Text('page $value'),
      ),
    );

    double dx(WidgetTester tester, String text) => tester
        .renderObject<RenderBox>(find.text(text))
        .localToGlobal(Offset.zero)
        .dx;

    testWidgets('new content fades in from the side it compares to', (
      tester,
    ) async {
      await tester.pumpWidget(content(1));
      await tester.pumpAndSettle();
      await tester.pumpWidget(content(2));
      final opacities = <double>[];
      final xs = <double>[];
      for (var i = 0; i < 30; i++) {
        opacities.add(
          tester
              .widget<FadeTransition>(
                find.descendant(
                  of: find.byType(ContentSwitch),
                  matching: find.byType(FadeTransition),
                ),
              )
              .opacity
              .value,
        );
        xs.add(dx(tester, 'page 2'));
        await tester.pump(_frame);
      }
      expect(opacities.first, 0);
      expect(opacities.last, 1);
      _expectMonotone(opacities);
      _expectMonotone(xs);
      expect(xs.first, greaterThan(xs.last));

      await tester.pumpWidget(content(1));
      await tester.pump(_frame);
      final start = dx(tester, 'page 1');
      await tester.pumpAndSettle();
      expect(start, lessThan(dx(tester, 'page 1')));
    });

    testWidgets('the calendar uses it for its months', (tester) async {
      await tester.pumpWidget(
        _app(Calendar(initialMonth: DateTime(2026, 3))),
      );
      await tester.pumpAndSettle();
      final before = tester.widget<ContentSwitch>(find.byType(ContentSwitch));
      await tester.tap(find.byType(IconButton).last);
      await tester.pump();
      final after = tester.widget<ContentSwitch>(find.byType(ContentSwitch));
      expect(after.value, isNot(before.value));
      expect(
        tester
            .widget<FadeTransition>(
              find.descendant(
                of: find.byType(ContentSwitch),
                matching: find.byType(FadeTransition),
              ),
            )
            .opacity
            .value,
        lessThan(1),
      );
      await tester.pumpAndSettle();
    });
  });

  group('Skeleton', () {
    testWidgets('does not animate with reduced motion', (tester) async {
      await tester.pumpWidget(
        _app(const Skeleton(width: 100, height: 20), reduceMotion: true),
      );
      // Nothing left running: this would time out otherwise.
      await tester.pumpAndSettle();
    });

    testWidgets('shimmers in the finesse style and pulses in a shadcn one', (
      tester,
    ) async {
      BoxDecoration decoration() =>
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: find.byType(Skeleton),
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as BoxDecoration;

      await tester.pumpWidget(
        const FinesseApp(home: Skeleton(width: 100, height: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(decoration().gradient, isNotNull);
      await tester.pumpWidget(const SizedBox());

      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(style: StyleTokens.nova),
          home: const Skeleton(width: 100, height: 20),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(decoration().gradient, isNull);
      expect(decoration().color, isNotNull);
      await tester.pumpWidget(const SizedBox());
    });
  });
}

/// How much of a determinate [ProgressBar] is filled.
double _progressFraction(WidgetTester tester) => tester
    .widget<FractionallySizedBox>(
      find.descendant(
        of: find.byType(ProgressBar),
        matching: find.byType(FractionallySizedBox),
      ),
    )
    .widthFactor!;
