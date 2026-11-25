import 'package:finesse/finesse.dart';
import 'package:finesse/src/components/wheel_picker.dart' show RenderWheel;
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// A wheel that holds its own value, as most parents do.
class _Host extends StatefulWidget {
  const _Host({
    this.initial = 3,
    this.count = 10,
    this.looping = false,
    this.enabled = true,
    this.disabledRows = const {},
    this.accept,
    this.labelOf,
    this.autofocus = false,
  });

  final int initial;
  final int count;
  final bool looping;
  final bool enabled;
  final Set<int> disabledRows;
  final bool Function(int value)? accept;
  final String Function(int value)? labelOf;
  final bool autofocus;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late int value = widget.initial;
  final changes = <int>[];
  final ends = <int>[];
  int builds = 0;

  /// Changes the value from outside the wheel.
  void set(int next) => setState(() => value = next);

  @override
  Widget build(BuildContext context) {
    builds++;
    return Center(
      child: WheelPicker<int>(
        value: value,
        looping: widget.looping,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        semanticLabel: 'Row',
        onChanged: (v) {
          changes.add(v);
          if (widget.accept?.call(v) ?? true) setState(() => value = v);
        },
        onChangeEnd: ends.add,
        items: [
          for (var i = 0; i < widget.count; i++)
            WheelPickerItem(
              value: i,
              label: widget.labelOf?.call(i) ?? 'Row $i',
              enabled: !widget.disabledRows.contains(i),
            ),
        ],
      ),
    );
  }
}

void main() {
  final wheel = find.byType(WheelPicker<int>);

  _HostState host(WidgetTester tester) => tester.state(find.byType(_Host));

  RenderWheel renderWheel(WidgetTester tester) => tester.renderObject(
    find.byWidgetPredicate((w) => '${w.runtimeType}' == '_WheelViewport'),
  );

  /// What assistive technology reads as the wheel's value.
  String valueOf(WidgetTester tester) => tester.getSemantics(wheel.first).value;

  /// Drags the wheel by [rows] rows in small moves, as a finger does, and
  /// leaves the pointer down.
  Future<TestGesture> dragRows(
    WidgetTester tester,
    double rows, {
    PointerDeviceKind kind = PointerDeviceKind.touch,
  }) async {
    final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
    final gesture = await tester.startGesture(
      tester.getCenter(wheel),
      kind: kind,
    );
    // The slop first: it moves nothing.
    await gesture.moveBy(Offset(0, -20 * rows.sign));
    const steps = 24;
    for (var i = 0; i < steps; i++) {
      await gesture.moveBy(Offset(0, -extent * rows / steps));
      await tester.pump(const Duration(milliseconds: 8));
    }
    return gesture;
  }

  Future<void> rest(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 16));
  }

  group('WheelPickerTheme', () {
    test('a row is the control height of each form factor', () {
      final desktop = ThemeData();
      final mobile = ThemeData(formFactor: FormFactor.mobile);
      expect(
        desktop.wheelPickerTheme.itemExtent,
        desktop.style.inputHeight,
      );
      expect(mobile.wheelPickerTheme.itemExtent, mobile.style.inputHeight);
      expect(mobile.wheelPickerTheme.itemExtent, greaterThanOrEqualTo(44));
      expect(desktop.wheelPickerTheme.lensBorderRadius, isNotNull);
      expect(
        desktop.wheelPickerTheme.selectedTextStyle!.color,
        desktop.colorScheme.foreground,
      );
      expect(
        desktop.wheelPickerTheme.textStyle!.color,
        desktop.colorScheme.mutedForeground,
      );
    });

    test('the lens is a wash on glass and the muted fill on a solid style', () {
      final glass = ThemeData();
      final solid = ThemeData(style: StyleTokens.nova);
      expect(glass.wheelPickerTheme.lensColor!.a, lessThan(.2));
      expect(glass.wheelPickerTheme.lensBorderWidth, 1);
      expect(solid.wheelPickerTheme.lensColor, solid.colorScheme.muted);
      expect(solid.wheelPickerTheme.lensBorderWidth, 0);
    });

    testWidgets('an override restyles the wheel', (tester) async {
      await pumpFinesse(
        tester,
        const _Host(),
        theme: ThemeData(
          wheelPickerTheme: const WheelPickerTheme(itemExtent: 50),
        ),
      );
      expect(tester.getSize(wheel).height, 250);
    });
  });

  group('WheelPicker', () {
    testWidgets('rests on its value and is five rows tall', (tester) async {
      await pumpFinesse(tester, const _Host());
      final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
      expect(tester.getSize(wheel).height, extent * 5);
      expect(valueOf(tester), 'Row 3');
      expect(host(tester).changes, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('builds in every layout', (tester) async {
      await expectBuildsInEveryLayout(tester, (_) => const _Host());
    });

    testWidgets('a drag reports each row passed and settles on one', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host(), formFactor: FormFactor.mobile);
      final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
      final gesture = await dragRows(tester, 2.2);
      expect(host(tester).changes, [4, 5]);
      expect(host(tester).ends, isEmpty);
      await gesture.up();
      await rest(tester);
      expect(valueOf(tester), 'Row 5');
      expect(host(tester).ends, [5]);
      // On the row exactly.
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      expect(position.pixels, 5 * extent);
    });

    testWidgets('a fling carries on and still lands on a row', (tester) async {
      await pumpFinesse(tester, const _Host(count: 60));
      final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
      await tester.fling(wheel, const Offset(0, -80), 1500);
      await rest(tester);
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      final row = position.pixels / extent;
      expect(row, greaterThan(6));
      expect(row, row.roundToDouble());
      expect(host(tester).value, row.round());
      // Every row on the way was reported, in order.
      expect(host(tester).changes, [for (var i = 4; i <= row.round(); i++) i]);
      expect(host(tester).ends, [row.round()]);
    });

    testWidgets('a parent that refuses a value gets the wheel back', (
      tester,
    ) async {
      await pumpFinesse(tester, _Host(accept: (v) => v < 5));
      final gesture = await dragRows(tester, 4);
      await gesture.up();
      await rest(tester);
      expect(host(tester).changes, [4, 5, 6, 7]);
      expect(host(tester).value, 4);
      expect(valueOf(tester), 'Row 4');
    });

    testWidgets('a value changed from outside is rolled to', (tester) async {
      await pumpFinesse(tester, const _Host());
      final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      host(tester).set(7);
      await tester.pump();
      await tester.pump();
      // Monotone, never past the target, and it arrives.
      var last = position.pixels;
      expect(last, closeTo(3 * extent, .01));
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(position.pixels, greaterThanOrEqualTo(last - .01));
        expect(position.pixels, lessThanOrEqualTo(7 * extent + .5));
        last = position.pixels;
      }
      await rest(tester);
      expect(position.pixels, closeTo(7 * extent, .01));
      expect(valueOf(tester), 'Row 7');
      // The parent's own change is not reported back as a rest.
      expect(host(tester).ends, isEmpty);
    });

    testWidgets('with motion off a change from outside is a jump', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(),
        theme: ThemeData(motion: Motion.none),
      );
      host(tester).set(8);
      await tester.pump();
      expect(valueOf(tester), 'Row 8');
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('reduced motion jumps too', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await pumpFinesse(tester, const _Host());
      host(tester).set(8);
      await tester.pump();
      expect(valueOf(tester), 'Row 8');
    });

    testWidgets('a disabled row is passed over and never reported', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host(disabledRows: {4, 5}));
      final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
      // Dragged onto a disabled row: the wheel returns to the last enabled.
      await tester.drag(wheel, Offset(0, -extent - 20));
      await rest(tester);
      expect(host(tester).changes, isEmpty);
      expect(valueOf(tester), 'Row 3');
      // A key steps over both.
      await tester.tap(wheel, kind: PointerDeviceKind.mouse);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await rest(tester);
      expect(host(tester).changes, [6]);
      expect(valueOf(tester), 'Row 6');
    });

    testWidgets('a looping wheel goes round', (tester) async {
      await pumpFinesse(tester, const _Host(initial: 0, looping: true));
      final gesture = await dragRows(tester, -2);
      await gesture.up();
      await rest(tester);
      expect(host(tester).changes, [9, 8]);
      expect(valueOf(tester), 'Row 8');
      // Home takes the short way round to the first row.
      await tester.tap(wheel, kind: PointerDeviceKind.mouse);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await rest(tester);
      expect(valueOf(tester), 'Row 0');
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      expect(position.pixels, closeTo(0, .01));
    });

    testWidgets('a tap on a row brings it under the lens', (tester) async {
      await pumpFinesse(tester, const _Host());
      final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
      await tester.tapAt(tester.getCenter(wheel) + Offset(0, extent));
      await rest(tester);
      expect(valueOf(tester), 'Row 4');
      await tester.tapAt(tester.getCenter(wheel) - Offset(0, extent * 1.9));
      await rest(tester);
      expect(valueOf(tester), 'Row 2');
    });

    testWidgets('a touch on a turning wheel stops it and chooses nothing', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host(count: 100));
      final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
      await tester.fling(wheel, const Offset(0, -80), 3000);
      await tester.pump(const Duration(milliseconds: 100));
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      final before = position.pixels;
      await tester.tapAt(tester.getCenter(wheel) + Offset(0, extent * 2));
      await rest(tester);
      // It stopped near where it was touched, not two rows on.
      expect((position.pixels - before).abs(), lessThan(extent));
    });

    group('keyboard', () {
      testWidgets('arrows, pages, home and end', (tester) async {
        useTraditionalHighlights();
        await pumpFinesse(tester, const _Host(count: 30, autofocus: true));
        await tester.pump();
        Future<void> press(LogicalKeyboardKey key) async {
          await tester.sendKeyEvent(key);
          await rest(tester);
        }

        await press(LogicalKeyboardKey.arrowDown);
        expect(valueOf(tester), 'Row 4');
        await press(LogicalKeyboardKey.arrowUp);
        await press(LogicalKeyboardKey.arrowUp);
        expect(valueOf(tester), 'Row 2');
        await press(LogicalKeyboardKey.pageDown);
        expect(valueOf(tester), 'Row 6');
        await press(LogicalKeyboardKey.pageUp);
        expect(valueOf(tester), 'Row 2');
        await press(LogicalKeyboardKey.end);
        expect(valueOf(tester), 'Row 29');
        await press(LogicalKeyboardKey.arrowDown);
        expect(valueOf(tester), 'Row 29');
        await press(LogicalKeyboardKey.home);
        expect(valueOf(tester), 'Row 0');
      });

      testWidgets('a held key keeps rolling without a stop', (tester) async {
        await pumpFinesse(tester, const _Host(count: 30, autofocus: true));
        await tester.pump();
        final position = tester
            .state<ScrollableState>(find.byType(Scrollable))
            .position;
        await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
        var last = position.pixels;
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 48));
          await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowDown);
          expect(position.pixels, greaterThanOrEqualTo(last));
          last = position.pixels;
        }
        await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
        await rest(tester);
        expect(valueOf(tester), 'Row 10');
      });

      testWidgets('typing finds the row that starts with it', (tester) async {
        const names = ['Ada', 'Bo', 'Cy', 'Dee', 'Di', 'Eve'];
        await pumpFinesse(
          tester,
          _Host(
            initial: 0,
            count: names.length,
            labelOf: (i) => names[i],
            autofocus: true,
          ),
        );
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.keyD, character: 'd');
        await rest(tester);
        expect(valueOf(tester), 'Dee');
        await tester.sendKeyEvent(LogicalKeyboardKey.keyI, character: 'i');
        await rest(tester);
        expect(valueOf(tester), 'Di');
        // After a pause the search starts again.
        await tester.pump(const Duration(seconds: 2));
        await tester.sendKeyEvent(LogicalKeyboardKey.keyE, character: 'e');
        await rest(tester);
        expect(valueOf(tester), 'Eve');
        // A letter no row starts with is left to whoever wants it.
        final handled = await tester.sendKeyEvent(
          LogicalKeyboardKey.keyZ,
          character: 'z',
        );
        expect(handled, isFalse);
        await tester.pump(const Duration(seconds: 2));
      });

      testWidgets('"7" finds "07"', (tester) async {
        await pumpFinesse(
          tester,
          _Host(
            initial: 0,
            count: 24,
            labelOf: (i) => i.toString().padLeft(2, '0'),
            autofocus: true,
          ),
        );
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit7, character: '7');
        await rest(tester);
        expect(valueOf(tester), '07');
        await tester.pump(const Duration(seconds: 2));
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1, character: '1');
        await tester.sendKeyEvent(LogicalKeyboardKey.digit9, character: '9');
        await rest(tester);
        expect(valueOf(tester), '19');
        await tester.pump(const Duration(seconds: 2));
      });

      testWidgets('the lens shows the focus ring', (tester) async {
        useTraditionalHighlights();
        await pumpFinesse(tester, const _Host());
        FocusRing ring() => tester.widget<FocusRing>(
          find.descendant(of: wheel, matching: find.byType(FocusRing)),
        );
        expect(ring().visible, isFalse);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(ring().visible, isTrue);
        final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
        expect(
          tester
              .getSize(
                find.descendant(of: wheel, matching: find.byType(FocusRing)),
              )
              .height,
          extent,
        );
      });
    });

    group('mouse wheel', () {
      Future<void> notch(
        WidgetTester tester,
        double dy, {
        required Duration at,
      }) async {
        final pointer = TestPointer(1, PointerDeviceKind.mouse)
          ..hover(tester.getCenter(wheel));
        await tester.sendEventToBinding(
          pointer.scroll(Offset(0, dy), timeStamp: at),
        );
      }

      testWidgets('moves one row per notch', (tester) async {
        await pumpFinesse(tester, const _Host());
        await notch(tester, 120, at: const Duration(seconds: 1));
        await rest(tester);
        expect(valueOf(tester), 'Row 4');
        await notch(tester, -53, at: const Duration(seconds: 2));
        await notch(tester, -53, at: const Duration(seconds: 3));
        await rest(tester);
        expect(valueOf(tester), 'Row 2');
      });

      testWidgets('small steps of a free wheel add up to rows', (tester) async {
        await pumpFinesse(tester, const _Host());
        final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
        // One row at once, then a row for each row height of travel.
        var at = const Duration(seconds: 1);
        for (var travelled = 0.0; travelled < extent * 2.5; travelled += 4) {
          at += const Duration(milliseconds: 4);
          await notch(tester, 4, at: at);
        }
        await rest(tester);
        expect(valueOf(tester), 'Row 6');
      });

      testWidgets('at an end the scroll is left to what is around', (
        tester,
      ) async {
        final outer = ScrollController();
        addTearDown(outer.dispose);
        await pumpFinesse(
          tester,
          SingleChildScrollView(
            controller: outer,
            child: const SizedBox(
              height: 2000,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(height: 400, child: _Host(initial: 9)),
              ),
            ),
          ),
        );
        await notch(tester, 100, at: const Duration(seconds: 1));
        await rest(tester);
        expect(valueOf(tester), 'Row 9');
        expect(outer.offset, 100);
      });
    });

    group('semantics', () {
      testWidgets('is one adjustable control', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpFinesse(tester, const _Host());
        expect(
          tester.getSemantics(wheel),
          matchesSemantics(
            label: 'Row',
            value: 'Row 3',
            increasedValue: 'Row 4',
            decreasedValue: 'Row 2',
            hasIncreaseAction: true,
            hasDecreaseAction: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasFocusAction: true,
          ),
        );
        tester.semantics.increase(find.semantics.byLabel('Row'));
        await rest(tester);
        expect(valueOf(tester), 'Row 4');
        tester.semantics.decrease(find.semantics.byLabel('Row'));
        tester.semantics.decrease(find.semantics.byLabel('Row'));
        await rest(tester);
        expect(valueOf(tester), 'Row 2');
        handle.dispose();
      });

      testWidgets('offers no step past an end', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpFinesse(tester, const _Host(initial: 9));
        final data = tester.getSemantics(wheel).getSemanticsData();
        expect(data.hasAction(SemanticsAction.increase), isFalse);
        expect(data.hasAction(SemanticsAction.decrease), isTrue);
        handle.dispose();
      });
    });

    group('haptics', () {
      late List<MethodCall> calls;

      setUp(() {
        calls = [];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
              if (call.method == 'HapticFeedback.vibrate') calls.add(call);
              return null;
            });
      });

      tearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      testWidgets('a finger feels each row pass', (tester) async {
        await pumpFinesse(tester, const _Host());
        final gesture = await dragRows(tester, 3);
        await gesture.up();
        await rest(tester);
        expect(calls, hasLength(3));
        expect(calls.first.arguments, 'HapticFeedbackType.selectionClick');
      });

      testWidgets('a mouse, a key and the parent do not', (tester) async {
        await pumpFinesse(tester, const _Host(autofocus: true));
        final gesture = await dragRows(
          tester,
          2,
          kind: PointerDeviceKind.mouse,
        );
        await gesture.up();
        await rest(tester);
        expect(valueOf(tester), 'Row 5');
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await rest(tester);
        host(tester).set(0);
        await rest(tester);
        expect(valueOf(tester), 'Row 0');
        expect(calls, isEmpty);
      });
    });

    group('cost', () {
      testWidgets('spinning paints and neither builds nor lays out', (
        tester,
      ) async {
        await pumpFinesse(tester, const _Host(count: 200, initial: 0));
        final render = renderWheel(tester);
        final layouts = render.debugLayoutCount;
        final builds = host(tester).builds;
        final paints = render.debugPaintCount;
        final gesture = await tester.startGesture(tester.getCenter(wheel));
        for (var i = 0; i < 20; i++) {
          await gesture.moveBy(const Offset(0, -7));
          await tester.pump(const Duration(milliseconds: 16));
        }
        // The parent was rebuilt by each report and by nothing else.
        expect(render.debugLayoutCount, layouts);
        expect(render.debugPaintCount, greaterThan(paints + 15));
        expect(
          host(tester).builds - builds,
          host(tester).changes.length,
        );
        await gesture.up();
        await rest(tester);
        expect(render.debugLayoutCount, layouts);
      });

      testWidgets('at rest nothing is scheduled', (tester) async {
        await pumpFinesse(tester, const _Host());
        await tester.fling(wheel, const Offset(0, -80), 800);
        await rest(tester);
        final render = renderWheel(tester);
        final paints = render.debugPaintCount;
        expect(tester.binding.hasScheduledFrame, isFalse);
        expect(SchedulerBinding.instance.transientCallbackCount, 0);
        await tester.pump(const Duration(seconds: 1));
        expect(render.debugPaintCount, paints);
      });
    });

    testWidgets('a disabled wheel cannot be turned', (tester) async {
      await pumpFinesse(tester, const _Host(enabled: false, autofocus: true));
      await tester.drag(wheel, const Offset(0, -120), warnIfMissed: false);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await rest(tester);
      expect(host(tester).changes, isEmpty);
      expect(valueOf(tester), 'Row 3');
      final data = tester.getSemantics(wheel).getSemanticsData();
      expect(data.hasAction(SemanticsAction.increase), isFalse);
    });

    testWidgets('a row grows with the text scale', (tester) async {
      await pumpFinesse(
        tester,
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: _Host(),
        ),
      );
      final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
      expect(tester.getSize(wheel).height, extent * 2 * 5);
      expect(tester.takeException(), isNull);
    });

    testWidgets('is as wide as its widest label, or as told', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              WheelPicker<int>(
                key: const ValueKey('short'),
                value: 0,
                onChanged: (_) {},
                items: const [WheelPickerItem(value: 0, label: 'A')],
              ),
              WheelPicker<int>(
                key: const ValueKey('long'),
                value: 0,
                onChanged: (_) {},
                items: const [WheelPickerItem(value: 0, label: 'A long row')],
              ),
              WheelPicker<int>(
                key: const ValueKey('fixed'),
                value: 0,
                width: 200,
                onChanged: (_) {},
                items: const [WheelPickerItem(value: 0, label: 'A')],
              ),
            ],
          ),
        ),
      );
      final short = tester.getSize(find.byKey(const ValueKey('short'))).width;
      final long = tester.getSize(find.byKey(const ValueKey('long'))).width;
      expect(long, greaterThan(short * 3));
      expect(tester.getSize(find.byKey(const ValueKey('fixed'))).width, 200);
    });

    testWidgets('a list that changes under the same value does not move', (
      tester,
    ) async {
      var from = 0;
      late StateSetter rebuild;
      final reported = <int>[];
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Center(
              child: WheelPicker<int>(
                value: 5,
                semanticLabel: 'Row',
                onChanged: reported.add,
                items: [
                  for (var i = from; i < 10; i++)
                    WheelPickerItem(value: i, label: 'Row $i'),
                ],
              ),
            );
          },
        ),
      );
      final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      expect(position.pixels, 5 * extent);
      rebuild(() => from = 3);
      await tester.pump();
      // Row 5 is now the third row, and it is under the lens at once.
      expect(position.pixels, 2 * extent);
      expect(valueOf(tester), 'Row 5');
      expect(reported, isEmpty);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('builder: rows are made on demand', (tester) async {
      final built = <int>{};
      var year = 2026;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: WheelPicker<int>.builder(
              itemCount: 2000,
              itemBuilder: (index) {
                built.add(index);
                return WheelPickerItem(value: 1000 + index, label: '$index');
              },
              indexOf: (value) => value - 1000,
              value: year,
              onChanged: (value) => setState(() => year = value),
            ),
          ),
        ),
      );
      expect(valueOf(tester), '1026');
      // A sample for the width and the rows in view; not two thousand.
      expect(built.length, lessThan(100));
      final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
      await tester.drag(wheel, Offset(0, -extent * 2 - 20));
      await rest(tester);
      expect(year, 2028);
    });
  });

  group('WheelPickerGroup', () {
    Widget group({int visibleItems = 5, double? itemExtent}) => Center(
      child: WheelPickerGroup(
        visibleItems: visibleItems,
        itemExtent: itemExtent,
        children: [
          WheelPicker<int>(
            value: 1,
            // The group's values win.
            visibleItems: 9,
            itemExtent: 10,
            onChanged: (_) {},
            items: const [
              WheelPickerItem(value: 0, label: 'A'),
              WheelPickerItem(value: 1, label: 'B'),
            ],
          ),
          const Text(':'),
          WheelPicker<int>(
            value: 0,
            onChanged: (_) {},
            items: const [
              WheelPickerItem(value: 0, label: 'C'),
              WheelPickerItem(value: 1, label: 'D'),
            ],
          ),
        ],
      ),
    );

    testWidgets('draws one lens across its wheels', (tester) async {
      await pumpFinesse(tester, group());
      expect(find.byType(Glass), findsOneWidget);
      final lens = tester.getRect(find.byType(Glass));
      final whole = tester.getRect(find.byType(WheelPickerGroup));
      expect(lens.width, whole.width);
      expect(lens.center.dy, whole.center.dy);
      final extent = themeOf(
        tester,
        find.byType(WheelPickerGroup),
      ).wheelPickerTheme.itemExtent!;
      expect(lens.height, extent);
      for (final element in wheel.evaluate()) {
        expect(
          tester.getSize(find.byWidget(element.widget)).height,
          5 * extent,
        );
      }
    });

    testWidgets('gives its wheels one row height and row count', (
      tester,
    ) async {
      await pumpFinesse(tester, group(visibleItems: 3, itemExtent: 30));
      for (final element in wheel.evaluate()) {
        expect(tester.getSize(find.byWidget(element.widget)).height, 90);
      }
      expect(tester.getSize(find.byType(Glass)).height, 30);
    });

    testWidgets('builds in every layout', (tester) async {
      await expectBuildsInEveryLayout(tester, (_) => group());
    });
  });
}
