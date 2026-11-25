import 'dart:ui' show Tristate;

import 'package:finesse/finesse.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../frame_sampler.dart';

/// `Stepper`: numbered steps with the current one opened.
void main() {
  const desktop = Size(1000, 700);
  const phone = Size(390, 800);

  List<Step> steps({
    int count = 4,
    Map<int, StepState> states = const {},
    bool content = true,
  }) => [
    for (var i = 0; i < count; i++)
      Step(
        title: Text('T$i'),
        state: states[i] ?? StepState.auto,
        content: content ? Text('C$i') : null,
      ),
  ];

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Size size = desktop,
    ThemeData? theme,
    TextDirection direction = TextDirection.ltr,
    double textScale = 1,
    bool reduceMotion = false,
    FrameSampler? sampler,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    final app = FinesseApp(
      theme: theme,
      darkTheme: theme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reduceMotion,
        ),
        child: Directionality(textDirection: direction, child: child!),
      ),
      home: Align(
        alignment: Alignment.topCenter,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
    await tester.pumpWidget(sampler == null ? app : sampler.wrap(app));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  /// A stepper the test drives: `rebuild(() => step = n)`.
  late StateSetter rebuild;
  var step = 0;
  final tapped = <int>[];
  var continued = 0;
  var cancelled = 0;

  setUp(() {
    step = 0;
    tapped.clear();
    continued = 0;
    cancelled = 0;
  });

  Widget driven({
    Axis? axis,
    int count = 4,
    Map<int, StepState> states = const {},
    bool tappable = true,
    bool controls = true,
    bool content = true,
  }) => StatefulBuilder(
    builder: (context, setState) {
      rebuild = setState;
      return Stepper(
        axis: axis,
        currentStep: step,
        onStepTapped: tappable ? tapped.add : null,
        onContinue: controls ? () => continued++ : null,
        onCancel: controls ? () => cancelled++ : null,
        steps: steps(count: count, states: states, content: content),
      );
    },
  );

  group('arrangement', () {
    testWidgets('a desktop: the steps across the top, the content below', (
      tester,
    ) async {
      step = 1;
      await pump(tester, driven());
      final tops = [
        for (var i = 0; i < 4; i++) tester.getCenter(find.text('T$i')),
      ];
      expect(tops.map((p) => p.dy).toSet().length, 1);
      expect(tops[0].dx, lessThan(tops[1].dx));
      expect(tops[2].dx, lessThan(tops[3].dx));
      // Equal columns.
      expect(
        tops[1].dx - tops[0].dx,
        moreOrLessEquals(tops[3].dx - tops[2].dx),
      );
      expect(tester.getTopLeft(find.text('C1')).dy, greaterThan(tops[0].dy));
    });

    testWidgets('a phone: the steps down the page, the content under the '
        'current title', (tester) async {
      step = 1;
      await pump(tester, driven(), size: phone);
      final lefts = [
        for (var i = 0; i < 4; i++) tester.getTopLeft(find.text('T$i')),
      ];
      expect(lefts.map((p) => p.dx).toSet().length, 1);
      final content = tester.getTopLeft(find.text('C1'));
      expect(content.dy, greaterThan(lefts[1].dy));
      expect(content.dy, lessThan(lefts[2].dy));
      // Indented under the title, clear of the line.
      expect(content.dx, lefts[1].dx);
    });

    testWidgets('axis decides it either way', (tester) async {
      await pump(tester, driven(axis: Axis.vertical));
      expect(
        tester.getTopLeft(find.text('T0')).dx,
        tester.getTopLeft(find.text('T1')).dx,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await pump(tester, driven(axis: Axis.horizontal), size: phone);
      expect(
        tester.getCenter(find.text('T0')).dy,
        tester.getCenter(find.text('T1')).dy,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('right to left the first step is on the right', (
      tester,
    ) async {
      await pump(tester, driven(), direction: TextDirection.rtl);
      expect(
        tester.getCenter(find.text('T0')).dx,
        greaterThan(tester.getCenter(find.text('T3')).dx),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await pump(
        tester,
        driven(axis: Axis.vertical),
        direction: TextDirection.rtl,
      );
      // The circle is at the start: to the right of its title.
      expect(
        tester.getCenter(find.text('1')).dx,
        greaterThan(tester.getCenter(find.text('T0')).dx),
      );
    });

    testWidgets('twice the text size: nothing overflows, in either '
        'arrangement', (tester) async {
      for (final (size, axis) in [
        (desktop, Axis.horizontal),
        (phone, Axis.vertical),
        (phone, Axis.horizontal),
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        step = 1;
        await pump(
          tester,
          SingleChildScrollView(child: driven(axis: axis)),
          size: size,
          textScale: 2,
        );
        expect(tester.takeException(), isNull, reason: '$size $axis');
      }
    });
  });

  group('steps', () {
    testWidgets('before the current step: a check; on it and after it: the '
        'number', (tester) async {
      step = 2;
      await pump(tester, driven());
      expect(find.byIcon(PhosphorIconsBold.check), findsNWidgets(2));
      expect(find.text('1'), findsNothing);
      expect(find.text('2'), findsNothing);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('the colours come from the theme: the current step ringed '
        'in the tint, a completed one filled with the primary', (tester) async {
      step = 1;
      await pump(tester, driven());
      final theme = Theme.of(tester.element(find.byType(Stepper)));
      final stepper = theme.stepperTheme;
      List<AnimatedFill> fills() =>
          tester.widgetList<AnimatedFill>(find.byType(AnimatedFill)).toList();
      final [done, current, next, _] = fills();
      expect(done.color, stepper.completeColor);
      expect(done.color, theme.colorScheme.primary);
      expect(current.color!.a, 0);
      expect(current.borderColor, stepper.activeColor);
      expect(current.borderColor, theme.colorScheme.tint);
      expect(next.color, stepper.indicatorColor);
      expect(next.borderColor, stepper.indicatorBorderColor);
      expect(
        tester.getSize(find.byType(AnimatedFill).first),
        Size.square(stepper.indicatorSize!),
      );
      // An upcoming title is quieter than the current one.
      Color? colourOf(String text) => DefaultTextStyle.of(
        tester.element(find.text(text)),
      ).style.color;
      expect(colourOf('T1'), stepper.titleStyle!.color);
      expect(colourOf('T2'), stepper.indicatorForegroundColor);
    });

    testWidgets('a theme override reaches it', (tester) async {
      await pump(
        tester,
        driven(),
        theme: ThemeData(
          stepperTheme: const StepperTheme(
            indicatorSize: 40,
            activeColor: Color(0xff123456),
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(AnimatedFill).first),
        const Size.square(40),
      );
      expect(
        tester
            .widget<AnimatedFill>(find.byType(AnimatedFill).first)
            .borderColor,
        const Color(0xff123456),
      );
    });

    testWidgets('a phone has the larger circle', (tester) async {
      await pump(tester, driven());
      final small = tester.getSize(find.byType(AnimatedFill).first);
      await tester.pumpWidget(const SizedBox.shrink());
      await pump(tester, driven(), size: phone);
      expect(
        tester.getSize(find.byType(AnimatedFill).first).width,
        greaterThan(small.width),
      );
    });

    testWidgets('error, complete and disabled are what they say, whatever '
        'the place', (tester) async {
      step = 0;
      await pump(
        tester,
        driven(
          states: const {
            1: StepState.error,
            2: StepState.complete,
            3: StepState.disabled,
          },
        ),
      );
      final theme = Theme.of(tester.element(find.byType(Stepper)));
      expect(find.byIcon(PhosphorIconsBold.exclamationMark), findsOneWidget);
      expect(find.byIcon(PhosphorIconsBold.check), findsOneWidget);
      expect(
        DefaultTextStyle.of(tester.element(find.text('T1'))).style.color,
        theme.stepperTheme.errorColor,
      );
      // The disabled step is dimmed and cannot be tapped.
      final opacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('T3'), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, .5);
      await tester.tap(find.text('T3'));
      await tester.tap(find.text('T2'));
      expect(tapped, [2]);
    });

    testWidgets('an icon takes the place of the number', (tester) async {
      await pump(
        tester,
        const Stepper(
          currentStep: 0,
          steps: [
            Step(
              title: Text('Cart'),
              icon: PhosphorIcon(PhosphorIconsRegular.shoppingCart),
            ),
            Step(title: Text('Pay')),
          ],
        ),
      );
      expect(find.byIcon(PhosphorIconsRegular.shoppingCart), findsOneWidget);
      expect(find.text('1'), findsNothing);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('a current step past the end is the last one', (tester) async {
      step = 9;
      await pump(tester, driven());
      expect(tester.takeException(), isNull);
      expect(find.text('C3'), findsOneWidget);
    });

    testWidgets('steps can come and go', (tester) async {
      var count = 4;
      late StateSetter set;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return Stepper(currentStep: 1, steps: steps(count: count));
          },
        ),
      );
      set(() => count = 2);
      await settle(tester);
      set(() => count = 6);
      await settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('T5'), findsOneWidget);
    });
  });

  group('what the user asks for', () {
    testWidgets('a tap on a step is reported; the stepper does not move by '
        'itself', (tester) async {
      await pump(tester, driven());
      await tester.tap(find.text('T2'));
      await settle(tester);
      expect(tapped, [2]);
      expect(find.text('C0'), findsOneWidget);
      expect(find.text('C2'), findsNothing);
    });

    testWidgets('without onStepTapped the steps are labels', (tester) async {
      await pump(tester, driven(tappable: false));
      expect(
        find.descendant(
          of: find.byType(Stepper),
          matching: find.byWidgetPredicate(
            (widget) => widget is Pressable && widget.onPressed != null,
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('Continue and Cancel; Finish on the last step', (tester) async {
      await pump(tester, driven());
      await tester.tap(find.text('Continue'));
      await tester.tap(find.text('Cancel'));
      expect((continued, cancelled), (1, 1));
      expect(find.text('Finish'), findsNothing);
      rebuild(() => step = 3);
      await settle(tester);
      expect(find.text('Finish'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('no callbacks, no controls; a builder replaces them', (
      tester,
    ) async {
      await pump(tester, driven(controls: false));
      expect(find.byType(Button), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      StepperControls? seen;
      await pump(
        tester,
        Stepper(
          currentStep: 2,
          onContinue: () {},
          steps: steps(count: 3),
          controlsBuilder: (context, controls) {
            seen = controls;
            return const Text('mine');
          },
        ),
      );
      expect(find.text('mine'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
      expect(seen!.currentStep, 2);
      expect(seen!.stepCount, 3);
      expect(seen!.isLast, isTrue);
      expect(seen!.isFirst, isFalse);
      expect(seen!.onContinue, isNotNull);
      expect(seen!.onCancel, isNull);
    });

    testWidgets('every step is a Tab stop and Enter asks for it; the ring '
        'is on the circle', (tester) async {
      await pump(tester, driven(controls: false, content: false));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(tapped, [1]);
      final rings = tester
          .widgetList<FocusRing>(find.byType(FocusRing))
          .map((ring) => ring.visible)
          .toList();
      expect(rings, [false, true, false, false]);
    });
  });

  group('motion', () {
    testWidgets('horizontal: only the current step is built, and the line '
        'behind a completed step fills from its start', (tester) async {
      final sampler = FrameSampler();
      await pump(tester, driven(), sampler: sampler);
      expect(find.text('C0'), findsOneWidget);
      expect(find.text('C1'), findsNothing);
      final theme = Theme.of(tester.element(find.byType(Stepper)));
      final from = tester.getRect(find.byType(AnimatedFill).at(0));
      final to = tester.getRect(find.byType(AnimatedFill).at(1));
      final y = from.center.dy;
      final span = to.left - from.right;
      final near = Offset(from.right + span * .25, y);
      final far = Offset(from.right + span * .75, y);
      final line = rgbOf(
        over(theme.stepperTheme.connectorColor!, theme.colorScheme.background),
      );
      final active = rgbOf(theme.stepperTheme.activeColor!);
      expect(rgbOf((await sampler.pixels(tester, [near])).single), line);

      rebuild(() => step = 1);
      await tester.pump();
      int? nearAt;
      int? farAt;
      for (var frame = 0; frame < 60; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        final seen = await sampler.pixels(tester, [near, far]);
        if (nearAt == null && rgbOf(seen[0]).toString() == active.toString()) {
          nearAt = frame;
        }
        if (farAt == null && rgbOf(seen[1]).toString() == active.toString()) {
          farAt = frame;
        }
        // Once filled, a point stays filled.
        if (nearAt != null) expect(rgbOf(seen[0]), active);
      }
      expect(nearAt, isNotNull);
      expect(farAt, isNotNull);
      expect(nearAt, lessThan(farAt!));
      expect(find.text('C1'), findsOneWidget);
      expect(find.text('C0'), findsNothing);
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('vertical: the new step opens as the old one closes, each '
        'without turning back, and then only the new one is there', (
      tester,
    ) async {
      await pump(tester, driven(), size: phone);
      final first = tester.getTopLeft(find.text('T2')).dy;
      rebuild(() => step = 1);
      await tester.pump();
      final t1 = <double>[];
      final t2 = <double>[];
      for (var frame = 0; frame < 60; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        // The old content is still there while it closes, as a picture.
        if (frame == 2) {
          expect(find.text('C0'), findsOneWidget);
          expect(find.text('C1'), findsOneWidget);
        }
        t1.add(tester.getTopLeft(find.text('T1')).dy);
        t2.add(tester.getTopLeft(find.text('T2')).dy);
      }
      // T1 rises as the step above it closes; never back down.
      for (var i = 1; i < t1.length; i++) {
        expect(t1[i], lessThanOrEqualTo(t1[i - 1] + .01), reason: 'frame $i');
      }
      expect(t1.first, greaterThan(t1.last));
      // T2 ends where it began: one body's height above it, as before.
      expect(t2.last, moreOrLessEquals(first, epsilon: .5));
      expect(find.text('C0'), findsNothing);
      expect(find.text('C1'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('a closing step cannot be pressed', (tester) async {
      await pump(tester, driven(), size: phone);
      final button = tester.getCenter(find.text('Continue'));
      rebuild(() => step = 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.tapAt(button);
      expect(continued, 0);
      await settle(tester);
    });

    for (final (name, motion, reduce) in <(String, Motion?, bool)>[
      ('reduced motion', null, true),
      ('Motion.none', Motion.none, false),
    ]) {
      testWidgets('$name: the step changes at once', (tester) async {
        for (final size in [desktop, phone]) {
          await tester.pumpWidget(const SizedBox.shrink());
          step = 0;
          await pump(
            tester,
            driven(),
            size: size,
            reduceMotion: reduce,
            theme: motion == null ? null : ThemeData(motion: motion),
          );
          rebuild(() => step = 2);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 16));
          final at = tester.getTopLeft(find.text('C2'));
          await tester.pump(const Duration(milliseconds: 16));
          await settle(tester);
          expect(tester.takeException(), isNull);
          expect(find.text('C0'), findsNothing);
          expect(tester.getTopLeft(find.text('C2')), at);
        }
      });
    }
  });

  group('semantics', () {
    testWidgets('a step says where it is, what it is called and how it '
        'stands', (tester) async {
      final handle = tester.ensureSemantics();
      step = 1;
      await pump(tester, driven(states: const {3: StepState.error}));
      SemanticsData dataOf(String title) =>
          tester.getSemantics(find.text(title)).getSemanticsData();

      final done = dataOf('T0');
      expect(done.label, 'Step 1 of 4\nT0');
      expect(done.value, 'Completed');
      expect(done.flagsCollection.isButton, isTrue);
      expect(done.hasAction(SemanticsAction.tap), isTrue);

      final current = dataOf('T1');
      expect(current.label, 'Step 2 of 4\nT1');
      expect(current.flagsCollection.isSelected, Tristate.isTrue);
      expect(current.value, isEmpty);

      expect(dataOf('T2').flagsCollection.isSelected, Tristate.isFalse);
      expect(dataOf('T3').value, 'Needs attention');
      handle.dispose();
    });

    testWidgets('a change of step is announced', (tester) async {
      final announced = <String>[];
      tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (
            message,
          ) async {
            final map = message as Map<dynamic, dynamic>;
            if (map['type'] == 'announce') {
              announced.add(
                (map['data'] as Map<dynamic, dynamic>)['message'] as String,
              );
            }
          });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockDecodedMessageHandler<dynamic>(
              SystemChannels.accessibility,
              null,
            ),
      );
      await pump(tester, driven());
      expect(announced, isEmpty);
      rebuild(() => step = 2);
      await settle(tester);
      expect(announced, ['Step 3 of 4']);
    });
  });
}
