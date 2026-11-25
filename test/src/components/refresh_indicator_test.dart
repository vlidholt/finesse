import 'dart:async';

import 'package:finesse/finesse.dart';
import 'package:finesse/src/components/ring_painter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  late List<Completer<void>> refreshes;
  final key = GlobalKey<RefreshIndicatorState>();

  setUp(() => refreshes = []);

  Future<void> onRefresh() {
    final completer = Completer<void>();
    refreshes.add(completer);
    return completer.future;
  }

  Widget list({
    ScrollPhysics physics = const ClampingScrollPhysics(),
    int count = 40,
    double? edgeOffset,
    double? triggerDistance,
    bool reverse = false,
    Axis axis = Axis.vertical,
    ScrollController? controller,
  }) => RefreshIndicator(
    key: key,
    onRefresh: onRefresh,
    edgeOffset: edgeOffset,
    triggerDistance: triggerDistance,
    child: ListView.builder(
      controller: controller,
      reverse: reverse,
      scrollDirection: axis,
      physics: AlwaysScrollableScrollPhysics(parent: physics),
      itemCount: count,
      itemBuilder: (context, index) =>
          SizedBox(height: 50, width: 50, child: Text('Row $index')),
    ),
  );

  /// The circle, when the indicator is showing.
  final circle = find.descendant(
    of: find.byType(RefreshIndicator),
    matching: find.byType(PopOnChange),
  );

  double opacityOf(WidgetTester tester) => tester
      .widget<Opacity>(
        find.ancestor(of: circle, matching: find.byType(Opacity)).first,
      )
      .opacity;

  RingPainter ringOf(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.descendant(of: circle, matching: find.byType(CustomPaint)),
              )
              .painter!
          as RingPainter;

  /// Drags the list down by [distance] in steps and leaves the finger down.
  Future<TestGesture> pull(
    WidgetTester tester,
    double distance, {
    PointerDeviceKind kind = PointerDeviceKind.touch,
  }) async {
    final gesture = await tester.startGesture(
      const Offset(200, 200),
      kind: kind,
    );
    // Past the slop first, then the pull proper.
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump();
    for (var moved = 0.0; moved < distance; moved += 10) {
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump(const Duration(milliseconds: 16));
    }
    return gesture;
  }

  List<MethodCall> hapticCalls(WidgetTester tester) {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') calls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return calls;
  }

  group('RefreshIndicatorTheme', () {
    test('is fed by the scheme and survives copyWith', () {
      final theme = ThemeData();
      final refresh = theme.refreshIndicatorTheme;
      expect(refresh.size, 40);
      expect(refresh.color, theme.colorScheme.tint);
      expect(refresh.backgroundColor, theme.colorScheme.popover);
      expect(refresh.triggerDistance, 80);
      final custom = ThemeData(
        refreshIndicatorTheme: const RefreshIndicatorTheme(
          triggerDistance: 120,
        ),
      );
      expect(custom.refreshIndicatorTheme.triggerDistance, 120);
      expect(
        custom
            .copyWith(radius: BorderRadius.circular(3))
            .refreshIndicatorTheme
            .triggerDistance,
        120,
      );
      expect(ThemeData(), ThemeData());
    });
  });

  group('RefreshIndicator at rest', () {
    testWidgets('builds nothing and schedules nothing', (tester) async {
      await pumpFinesse(tester, list());
      expect(circle, findsNothing);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('an ordinary scroll from the top shows nothing', (
      tester,
    ) async {
      await pumpFinesse(tester, list());
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(circle, findsNothing);
      expect(refreshes, isEmpty);
    });
  });

  for (final (name, physics) in [
    ('clamping', const ClampingScrollPhysics() as ScrollPhysics),
    ('bouncing', const BouncingScrollPhysics() as ScrollPhysics),
  ]) {
    group('RefreshIndicator with $name physics', () {
      testWidgets('a pull past the trigger and a release refreshes; the '
          'circle rests, spins, and leaves when the future completes', (
        tester,
      ) async {
        await pumpFinesse(
          tester,
          list(physics: physics),
          formFactor: FormFactor.mobile,
        );
        final gesture = await pull(tester, 240);
        expect(circle, findsOneWidget);
        expect(refreshes, isEmpty, reason: 'not before the release');
        await gesture.up();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        expect(refreshes, hasLength(1));

        // It settles under the top edge and spins there.
        await tester.pump(const Duration(milliseconds: 600));
        final theme = themeOf(tester, find.byType(RefreshIndicator));
        final rect = tester.getRect(circle);
        expect(
          rect.top,
          moreOrLessEquals(
            theme.refreshIndicatorTheme.displacement!,
            epsilon: 1,
          ),
        );
        expect(rect.center.dx, moreOrLessEquals(195, epsilon: .5));
        final first = ringOf(tester).arc().start;
        await tester.pump(const Duration(milliseconds: 100));
        expect(ringOf(tester).arc().start, isNot(first));
        expect(tester.hasRunningAnimations, isTrue);

        refreshes.single.complete();
        await tester.pump();
        await tester.pump();
        await tester.pumpAndSettle();
        expect(circle, findsNothing);
        expect(tester.hasRunningAnimations, isFalse);
      });

      testWidgets('a short pull goes back and refreshes nothing', (
        tester,
      ) async {
        await pumpFinesse(tester, list(physics: physics));
        final gesture = await pull(tester, 30);
        expect(circle, findsOneWidget);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(circle, findsNothing);
        expect(refreshes, isEmpty);
      });

      testWidgets('the circle comes down with the pull, monotone, and the '
          'ring fills', (tester) async {
        await pumpFinesse(tester, list(physics: physics));
        final gesture = await tester.startGesture(const Offset(200, 200));
        await gesture.moveBy(const Offset(0, 20));
        await tester.pump();
        final tops = <double>[];
        final sweeps = <double>[];
        for (var i = 0; i < 20; i++) {
          await gesture.moveBy(const Offset(0, 8));
          await tester.pump(const Duration(milliseconds: 16));
          if (circle.evaluate().isEmpty) continue;
          tops.add(tester.getRect(circle).center.dy);
          sweeps.add(ringOf(tester).arc().sweep);
        }
        expect(tops.length, greaterThan(10));
        for (var i = 1; i < tops.length; i++) {
          expect(tops[i], greaterThanOrEqualTo(tops[i - 1] - 1e-6));
          expect(sweeps[i], greaterThanOrEqualTo(sweeps[i - 1] - 1e-6));
        }
        expect(tops.last, greaterThan(tops.first));
        expect(sweeps.last, greaterThan(sweeps.first));
        expect(opacityOf(tester), greaterThan(0));
        await gesture.up();
        await tester.pump();
        for (final refresh in refreshes) {
          refresh.complete();
        }
        await tester.pumpAndSettle();
      });
    });
  }

  group('RefreshIndicator', () {
    testWidgets('arming pops with a haptic on touch, and not for a '
        'trackpad', (tester) async {
      final calls = hapticCalls(tester);
      await pumpFinesse(tester, list());
      final gesture = await pull(tester, 140);
      expect(calls, hasLength(1));
      expect(calls.single.arguments, 'HapticFeedbackType.mediumImpact');
      await gesture.up();
      await tester.pump();
      refreshes.single.complete();
      await tester.pumpAndSettle();

      calls.clear();
      final stylusFree = await pull(
        tester,
        140,
        kind: PointerDeviceKind.trackpad,
      );
      await stylusFree.up();
      await tester.pump();
      expect(calls, isEmpty);
      if (refreshes.length > 1) refreshes.last.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('pulling back under the trigger disarms', (tester) async {
      await pumpFinesse(tester, list(physics: const BouncingScrollPhysics()));
      final gesture = await pull(tester, 240);
      // Back up: the content returns towards the top.
      for (var i = 0; i < 30; i++) {
        await gesture.moveBy(const Offset(0, -8));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(refreshes, isEmpty);
      expect(circle, findsNothing);
    });

    testWidgets('a mouse wheel cannot pull', (tester) async {
      await pumpFinesse(tester, list());
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(tester.getCenter(find.byType(ListView))),
      );
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, -300)));
      await tester.pumpAndSettle();
      expect(circle, findsNothing);
      expect(refreshes, isEmpty);
    });

    testWidgets('a horizontal or a reversed list is not followed', (
      tester,
    ) async {
      await pumpFinesse(tester, list(axis: Axis.horizontal));
      await tester.drag(find.byType(ListView), const Offset(200, 0));
      await tester.pumpAndSettle();
      expect(refreshes, isEmpty);

      await pumpFinesse(tester, const SizedBox());
      await pumpFinesse(tester, list(reverse: true));
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(refreshes, isEmpty);
    });

    testWidgets('a drag that reaches the top from within the list pulls '
        'too', (tester) async {
      final controller = ScrollController(initialScrollOffset: 60);
      addTearDown(controller.dispose);
      await pumpFinesse(tester, list(controller: controller));
      final gesture = await pull(tester, 260);
      expect(circle, findsOneWidget);
      await gesture.up();
      await tester.pump();
      expect(refreshes, hasLength(1));
      refreshes.single.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('show() refreshes without a pull and returns the '
        "refresh's future", (tester) async {
      await pumpFinesse(tester, list());
      var done = false;
      unawaited(key.currentState!.show().then((_) => done = true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(circle, findsOneWidget);
      expect(refreshes, hasLength(1));
      // A second call joins the first.
      unawaited(key.currentState!.show());
      await tester.pump();
      expect(refreshes, hasLength(1));
      expect(done, isFalse);
      refreshes.single.complete();
      await tester.pumpAndSettle();
      expect(done, isTrue);
      expect(circle, findsNothing);
    });

    testWidgets('a refresh that throws still leaves, and the error is '
        'reported', (tester) async {
      await pumpFinesse(tester, list());
      unawaited(key.currentState!.show());
      await tester.pump();
      refreshes.single.completeError(StateError('offline'));
      await tester.pump();
      expect(tester.takeException(), isStateError);
      await tester.pumpAndSettle();
      expect(circle, findsNothing);
    });

    testWidgets('it starts below edgeOffset, by default the top padding', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: 64)),
          child: list(),
        ),
      );
      unawaited(key.currentState!.show());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final theme = themeOf(tester, find.byType(RefreshIndicator));
      expect(
        tester.getRect(circle).top,
        moreOrLessEquals(
          64 + theme.refreshIndicatorTheme.displacement!,
          epsilon: 1,
        ),
      );
      refreshes.single.complete();
      await tester.pumpAndSettle();

      await pumpFinesse(tester, list(edgeOffset: 100));
      unawaited(key.currentState!.show());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.getRect(circle).top, greaterThan(100));
      refreshes.last.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('triggerDistance moves the trigger', (tester) async {
      await pumpFinesse(tester, list(triggerDistance: 300));
      final gesture = await pull(tester, 200);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(refreshes, isEmpty);
    });

    testWidgets('with reduced motion it fades in at its resting place', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: list(),
        ),
      );
      final gesture = await tester.startGesture(const Offset(200, 200));
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump();
      final tops = <double>{};
      final opacities = <double>[];
      for (var i = 0; i < 8; i++) {
        await gesture.moveBy(const Offset(0, 8));
        await tester.pump(const Duration(milliseconds: 16));
        tops.add(tester.getRect(circle).top);
        opacities.add(opacityOf(tester));
      }
      expect(tops, hasLength(1));
      expect(opacities.last, greaterThan(opacities.first));
      await gesture.up();
      await tester.pump();
      for (final refresh in refreshes) {
        refresh.complete();
      }
      await tester.pumpAndSettle();
    });

    testWidgets('under Motion.none a refresh still shows and leaves', (
      tester,
    ) async {
      await pumpFinesse(tester, list(), theme: ThemeData(motion: Motion.none));
      final gesture = await pull(tester, 140);
      await gesture.up();
      await tester.pump();
      expect(refreshes, hasLength(1));
      expect(circle, findsOneWidget);
      refreshes.single.complete();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(circle, findsNothing);
    });

    testWidgets('it announces "Refreshing" as a live region while it '
        'spins', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, list());
      unawaited(key.currentState!.show());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final node = tester.getSemantics(find.bySemanticsLabel('Refreshing'));
      expect(node.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
      refreshes.single.complete();
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Refreshing'), findsNothing);
      handle.dispose();
    });

    testWidgets('the circle is the popover colour with the tint ring, in '
        'every style and brightness', (tester) async {
      for (final style in [StyleTokens.finesse, StyleTokens.nova]) {
        for (final scheme in <ColorScheme>[
          const TealColorScheme.light(),
          const TealColorScheme.dark(),
        ]) {
          await pumpFinesse(tester, const SizedBox());
          await pumpFinesse(
            tester,
            list(),
            theme: ThemeData(style: style, colorScheme: scheme),
          );
          unawaited(key.currentState!.show());
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(ringOf(tester).color, scheme.tint);
          expect(tester.getSize(circle), const Size(40, 40));
          refreshes.last.complete();
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('the list keeps its state while the indicator comes and '
        'goes', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpFinesse(tester, list(controller: controller));
      final state = tester.state(find.byType(Scrollable));
      unawaited(key.currentState!.show());
      await tester.pump();
      expect(tester.state(find.byType(Scrollable)), same(state));
      refreshes.single.complete();
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(Scrollable)), same(state));
    });
  });
}
