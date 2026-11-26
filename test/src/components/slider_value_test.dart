import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

void main() {
  // Haptics are silent under `flutter test` unless a test asks.
  setUp(() => Haptics.debugEnabledInTests = true);
  tearDown(() => Haptics.debugEnabledInTests = false);

  Widget boxed(Widget child) =>
      Center(child: SizedBox(width: 400, child: child));

  /// What assistive technology reads as the value of the (first) thumb.
  String thumbValue(WidgetTester tester) => tester
      .getSemantics(
        find
            .descendant(
              of: find.bySubtype<StatefulWidget>(),
              matching: find.byWidgetPredicate(
                (w) => w is Semantics && (w.properties.slider ?? false),
              ),
            )
            .first,
      )
      .value;

  Rect sliderRect(WidgetTester tester) => tester.getRect(find.byType(Slider));

  /// How far the thumb's centre travels: the slider's width less a thumb
  /// radius at each end, where the thumb stays inside the track.
  double travel(WidgetTester tester, [Type type = Slider]) {
    final slider = find.byType(type);
    final r = Theme.of(tester.element(slider)).sliderTheme.thumbRadius!;
    return tester.getSize(slider).width - 2 * r;
  }

  /// The centre of the thumb for [fraction] of the track.
  Offset at(WidgetTester tester, double fraction, [Type type = Slider]) {
    final rect = tester.getRect(find.byType(type));
    final inset = (rect.width - travel(tester, type)) / 2;
    return Offset(
      rect.left + inset + travel(tester, type) * fraction,
      rect.center.dy,
    );
  }

  group('Slider value', () {
    testWidgets('controlled: shows the value it is given and waits for it', (
      tester,
    ) async {
      var value = 20.0;
      final reported = <double>[];
      late StateSetter rebuild;
      var accept = false;
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return boxed(
              Slider(
                value: value,
                max: 100,
                semanticLabel: 'Volume',
                onChanged: (v) {
                  reported.add(v);
                  if (accept) setState(() => value = v);
                },
              ),
            );
          },
        ),
      );
      expect(thumbValue(tester), '20.0');
      // A tap the parent refuses moves nothing.
      await tester.tapAt(at(tester, .75));
      await tester.pump();
      expect(reported, [75]);
      expect(thumbValue(tester), '20.0');
      // One it takes does.
      accept = true;
      await tester.tapAt(at(tester, .5));
      await tester.pump();
      expect(thumbValue(tester), '50.0');
      // And a value written from outside.
      rebuild(() => value = 90);
      await tester.pump();
      expect(thumbValue(tester), '90.0');
      expect(find.bySemanticsLabel('Volume'), findsOneWidget);
    });

    testWidgets('uncontrolled: keeps its own value from initialValue', (
      tester,
    ) async {
      final reported = <double>[];
      await pumpUna(
        tester,
        boxed(Slider(initialValue: 20, max: 100, onChanged: reported.add)),
      );
      await tester.tapAt(at(tester, .75));
      await tester.pump();
      expect(reported, [75]);
      await tester.tapAt(at(tester, .25));
      await tester.pump();
      expect(reported, [75, 25]);
    });

    test('asks for exactly one of value and initialValue', () {
      expect(Slider.new, throwsAssertionError);
      expect(() => Slider(value: 1, initialValue: 1), throwsAssertionError);
      expect(RangeSlider.new, throwsAssertionError);
    });

    testWidgets('a range is controlled the same way', (tester) async {
      var values = const [20.0, 60.0];
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) => boxed(
            RangeSlider(
              values: values,
              max: 100,
              onChanged: (v) => setState(() => values = v),
            ),
          ),
        ),
      );
      await tester.tapAt(at(tester, .9, RangeSlider));
      await tester.pump();
      expect(values.first, 20);
      expect(values.last, closeTo(90, 1e-9));
      await tester.tapAt(at(tester, .1, RangeSlider));
      await tester.pump();
      expect(values.first, closeTo(10, 1e-9));
      expect(values.last, closeTo(90, 1e-9));
    });
  });

  group('Slider value indicator', () {
    Finder bubble(String text) => find.text(text);

    Future<void> rest(WidgetTester tester) async {
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets('never: there is no bubble, whatever happens', (tester) async {
      await pumpUna(
        tester,
        boxed(const Slider(initialValue: 40, max: 100)),
      );
      final gesture = await tester.startGesture(at(tester, .4));
      await gesture.moveBy(const Offset(30, 0));
      await rest(tester);
      expect(bubble('48'), findsNothing);
      expect(find.byType(OverlayPortal), findsNothing);
      await gesture.up();
    });

    testWidgets('always: the bubble sits above the thumb and follows it', (
      tester,
    ) async {
      await pumpUna(
        tester,
        boxed(
          Slider(
            initialValue: 40,
            max: 100,
            valueIndicator: SliderValueIndicator.always,
            valueLabel: (v) => '${v.round()}%',
          ),
        ),
      );
      await rest(tester);
      expect(bubble('40%'), findsOneWidget);
      final before = tester.getRect(bubble('40%'));
      expect(before.bottom, lessThan(sliderRect(tester).top));
      expect(before.center.dx, closeTo(at(tester, .4).dx, 1));
      await tester.tapAt(at(tester, .8));
      await rest(tester);
      final after = tester.getRect(bubble('80%'));
      expect(after.center.dx, closeTo(at(tester, .8).dx, 1));
      // What the bubble says is what assistive technology reads.
      expect(thumbValue(tester), '80%');
    });

    testWidgets('whileDragging: it pops up for a drag and leaves after it', (
      tester,
    ) async {
      await pumpUna(
        tester,
        boxed(
          const Slider(
            initialValue: 40,
            max: 100,
            valueIndicator: SliderValueIndicator.whileDragging,
          ),
        ),
      );
      expect(bubble('40'), findsNothing);
      final gesture = await tester.startGesture(at(tester, .4));
      await tester.pump();
      // A hundredth of the travel per step of the value.
      final unit = travel(tester) / 100;
      // The first move is the slop: it starts the drag.
      await gesture.moveBy(const Offset(20, 0));
      await gesture.moveBy(Offset(6 * unit - 20, 0));
      await rest(tester);
      expect(bubble('46'), findsOneWidget);
      await gesture.moveBy(Offset(4 * unit, 0));
      await tester.pump();
      expect(bubble('50'), findsOneWidget);
      await gesture.up();
      await rest(tester);
      // Gone from the overlay, not merely transparent.
      expect(bubble('50'), findsNothing);
      // And nothing is left running.
      await rest(tester);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('whileDragging: hover and keyboard focus show it too', (
      tester,
    ) async {
      await pumpUna(
        tester,
        boxed(
          const Slider(
            initialValue: 40,
            max: 100,
            valueIndicator: SliderValueIndicator.whileDragging,
          ),
        ),
      );
      final mouse = await hoverAt(tester, at(tester, .4));
      await rest(tester);
      expect(bubble('40'), findsOneWidget);
      await mouse.moveTo(const Offset(5, 5));
      await rest(tester);
      expect(bubble('40'), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await rest(tester);
      expect(bubble('40'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await rest(tester);
      expect(bubble('41'), findsOneWidget);
    });

    testWidgets('the bubble is the tooltip surface', (tester) async {
      await pumpUna(
        tester,
        boxed(
          const Slider(
            initialValue: 0.5,
            valueIndicator: SliderValueIndicator.always,
          ),
        ),
      );
      await rest(tester);
      // A value with decimals keeps them, without trailing zeros.
      final text = tester.widget<Text>(bubble('0.5'));
      final theme = themeOf(tester, find.byType(Slider));
      expect(text.style!.color, theme.tooltipTheme.textStyle!.color);
      expect(text.style!.fontSize, theme.tooltipTheme.textStyle!.fontSize);
    });

    testWidgets('with motion off it appears and leaves at once', (
      tester,
    ) async {
      await pumpUna(
        tester,
        boxed(
          const Slider(
            initialValue: 40,
            max: 100,
            valueIndicator: SliderValueIndicator.whileDragging,
          ),
        ),
        theme: ThemeData(motion: Motion.none),
      );
      final gesture = await tester.startGesture(at(tester, .4));
      await tester.pump();
      await tester.pump();
      expect(bubble('40'), findsOneWidget);
      await gesture.up();
      await tester.pump();
      await tester.pump();
      expect(bubble('40'), findsNothing);
    });

    testWidgets('every thumb of a range has its own', (tester) async {
      await pumpUna(
        tester,
        boxed(
          const RangeSlider(
            initialValues: [20, 70],
            max: 100,
            valueIndicator: SliderValueIndicator.always,
          ),
        ),
      );
      await rest(tester);
      expect(bubble('20'), findsOneWidget);
      expect(bubble('70'), findsOneWidget);
    });
  });

  group('Slider haptics', () {
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

    Future<void> drag(WidgetTester tester, PointerDeviceKind kind) async {
      final gesture = await tester.startGesture(at(tester, .5), kind: kind);
      await gesture.moveBy(const Offset(20, 0));
      // Three stops of a ten-stop track, 40 pixels apart.
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(12, 0));
        await tester.pump();
      }
      await gesture.up();
      await tester.pump();
    }

    testWidgets('a finger feels each stop of a stepped slider', (tester) async {
      final stops = <double>[];
      await pumpUna(
        tester,
        boxed(
          Slider(
            initialValue: 50,
            max: 100,
            divisions: 10,
            onChanged: stops.add,
          ),
        ),
      );
      await drag(tester, PointerDeviceKind.touch);
      expect(stops.length, greaterThanOrEqualTo(3));
      expect(calls, hasLength(stops.length));
      expect(calls.first.arguments, 'HapticFeedbackType.selectionClick');
    });

    testWidgets('a mouse does not, nor does a smooth slider', (tester) async {
      await pumpUna(
        tester,
        boxed(const Slider(initialValue: 50, max: 100, divisions: 10)),
      );
      await drag(tester, PointerDeviceKind.mouse);
      expect(calls, isEmpty);

      await pumpUna(
        tester,
        boxed(const Slider(key: ValueKey(2), initialValue: 50, max: 100)),
      );
      await drag(tester, PointerDeviceKind.touch);
      expect(calls, isEmpty);
    });
  });

  group('SliderFormField', () {
    testWidgets('validates, saves and resets', (tester) async {
      final formKey = GlobalKey<UnaFormState>();
      await pumpUna(
        tester,
        boxed(
          UnaForm(
            key: formKey,
            child: SliderFormField(
              id: 'volume',
              initialValue: 20,
              max: 100,
              validator: (v) => v < 30 ? 'Too quiet' : null,
            ),
          ),
        ),
      );
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Too quiet'), findsOneWidget);
      await tester.tapAt(at(tester, .6));
      await tester.pump();
      expect(formKey.currentState!.saveAndValidate(), isTrue);
      expect(
        formKey.currentState!.value['volume'] as double,
        closeTo(60, 1e-9),
      );
      formKey.currentState!.reset();
      await tester.pump();
      expect(tester.widget<Slider>(find.byType(Slider)).value, 20);
    });
  });
}
