import 'package:finesse/finesse.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  late List<String> calls;

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            calls.add(
              (call.arguments as String).replaceFirst(
                'HapticFeedbackType.',
                '',
              ),
            );
          }
          return null;
        });
  });

  tearDown(() {
    Haptics.debugEnabledInTests = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  /// Pumps an app (with [theme]) and hands back a context below it, under
  /// an optional [wrap]per.
  Future<BuildContext> contextUnder(
    WidgetTester tester, {
    ThemeData? theme,
    Widget Function(Widget child)? wrap,
  }) async {
    late BuildContext context;
    final probe = Builder(
      builder: (c) {
        context = c;
        return const SizedBox();
      },
    );
    await pumpFinesse(tester, wrap?.call(probe) ?? probe, theme: theme);
    return context;
  }

  void everyCall(BuildContext context) {
    Haptics.selection(context);
    Haptics.impact(context);
    Haptics.impact(context, HapticImpact.medium);
    Haptics.impact(context, HapticImpact.heavy);
  }

  const all = ['selectionClick', 'lightImpact', 'mediumImpact', 'heavyImpact'];

  group('Haptics', () {
    for (final platform in TargetPlatform.values) {
      final ticks =
          platform == TargetPlatform.android || platform == TargetPlatform.iOS;
      testWidgets(
        '$platform ${ticks ? 'ticks' : 'is silent'}',
        (tester) async {
          Haptics.debugEnabledInTests = true;
          final context = await contextUnder(tester);
          expect(Haptics.enabledOf(context), ticks);
          everyCall(context);
          expect(calls, ticks ? all : isEmpty);
        },
        variant: TargetPlatformVariant.only(platform),
      );
    }

    testWidgets('a test hears nothing unless it asks', (tester) async {
      final context = await contextUnder(tester);
      expect(defaultTargetPlatform, TargetPlatform.android);
      expect(Haptics.enabledOf(context), isFalse);
      everyCall(context);
      expect(calls, isEmpty);

      Haptics.debugEnabledInTests = true;
      expect(Haptics.enabledOf(context), isTrue);
      everyCall(context);
      expect(calls, all);
    });

    testWidgets('ThemeData(haptics: false) silences the app', (tester) async {
      Haptics.debugEnabledInTests = true;
      final context = await contextUnder(
        tester,
        theme: ThemeData(haptics: false),
      );
      expect(Theme.of(context).haptics, isFalse);
      expect(Haptics.enabledOf(context), isFalse);
      everyCall(context);
      expect(calls, isEmpty);
    });

    testWidgets('a Theme switches a subtree off, and back on', (tester) async {
      Haptics.debugEnabledInTests = true;
      late BuildContext outside;
      late BuildContext off;
      late BuildContext on;
      final quiet = ThemeData(haptics: false);
      final loud = ThemeData();
      await pumpFinesse(
        tester,
        Column(
          children: [
            Builder(
              builder: (context) {
                outside = context;
                return const SizedBox();
              },
            ),
            Theme(
              data: quiet,
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      off = context;
                      return const SizedBox();
                    },
                  ),
                  Theme(
                    data: loud,
                    child: Builder(
                      builder: (context) {
                        on = context;
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      Haptics.selection(outside);
      expect(calls, ['selectionClick']);
      Haptics.selection(off);
      Haptics.impact(off, HapticImpact.medium);
      expect(calls, ['selectionClick']);
      Haptics.impact(on);
      expect(calls, ['selectionClick', 'lightImpact']);
    });

    testWidgets('asking does not subscribe the caller to the theme', (
      tester,
    ) async {
      Haptics.debugEnabledInTests = true;
      _Probe.builds = 0;
      Widget app(ThemeData theme) =>
          FinesseApp(theme: theme, home: const _Probe());
      await tester.pumpWidget(app(ThemeData()));
      await tester.pump(const Duration(milliseconds: 400));
      final context = tester.element(find.byType(_Probe));
      Haptics.selection(context);
      expect(calls, ['selectionClick']);
      final before = _Probe.builds;
      await tester.pumpWidget(app(ThemeData(haptics: false)));
      await tester.pump(const Duration(milliseconds: 400));
      expect(_Probe.builds, before);
      expect(Haptics.enabledOf(context), isFalse);
    });

    testWidgets('a context that is gone asks for nothing', (tester) async {
      Haptics.debugEnabledInTests = true;
      final context = await contextUnder(tester);
      await tester.pumpWidget(const SizedBox());
      expect(context.mounted, isFalse);
      everyCall(context);
      expect(calls, isEmpty);
    });

    test('ThemeData carries the setting through copyWith, lerp and ==', () {
      final on = ThemeData();
      final off = ThemeData(haptics: false);
      expect(on.haptics, isTrue);
      expect(off.haptics, isFalse);
      expect(on == off, isFalse);
      expect(off, ThemeData(haptics: false));
      expect(on.copyWith(haptics: false).haptics, isFalse);
      // A copy that changes something else keeps it.
      expect(off.copyWith(disabledOpacity: .3).haptics, isFalse);
      expect(off.copyWith(radius: BorderRadius.zero).haptics, isFalse);
      expect(ThemeData.lerp(on, off, .25)!.haptics, isTrue);
      expect(ThemeData.lerp(on, off, .75)!.haptics, isFalse);
    });
  });

  group('controls tick through Haptics', () {
    setUp(() => Haptics.debugEnabledInTests = true);

    testWidgets('Switch: a light impact per toggle, none when switched off', (
      tester,
    ) async {
      var value = false;
      Widget host() => StatefulBuilder(
        builder: (context, setState) => Center(
          child: Switch(
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      );
      await pumpFinesse(tester, host());
      await tester.tap(find.byType(Switch));
      await settle(tester);
      expect(value, isTrue);
      expect(calls, ['lightImpact']);

      calls.clear();
      await pumpFinesse(tester, host(), theme: ThemeData(haptics: false));
      await tester.tap(find.byType(Switch));
      await settle(tester);
      expect(value, isFalse);
      expect(calls, isEmpty);
    });

    testWidgets('ContextMenuRegion: a medium impact as a long press opens '
        'the menu', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: ContextMenuRegion(
            longPressEnabled: true,
            items: [MenuItem(child: Text('Copy'))],
            child: SizedBox(width: 200, height: 100, child: Text('Hold me')),
          ),
        ),
      );
      await tester.longPress(find.text('Hold me'));
      await settle(tester);
      expect(find.text('Copy'), findsOneWidget);
      expect(calls, ['mediumImpact']);
    });

    testWidgets('Checkbox: a selection tick per toggle', (tester) async {
      var value = false;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: Checkbox(
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Checkbox));
      await settle(tester);
      expect(value, isTrue);
      expect(calls, ['selectionClick']);
    });

    testWidgets(
      'Switch and Checkbox are silent on a desktop platform',
      (tester) async {
        await pumpFinesse(
          tester,
          Column(
            children: [
              Switch(value: false, onChanged: (_) {}),
              Checkbox(value: false, onChanged: (_) {}),
            ],
          ),
        );
        await tester.tap(find.byType(Switch));
        await tester.tap(find.byType(Checkbox));
        await settle(tester);
        expect(calls, isEmpty);
      },
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets('Slider: a light impact as a finger reaches either end', (
      tester,
    ) async {
      var value = 50.0;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: SizedBox(
              width: 400,
              child: Slider(
                value: value,
                max: 100,
                onChanged: (v) => setState(() => value = v),
              ),
            ),
          ),
        ),
      );
      final rect = tester.getRect(find.byType(Slider));
      final finger = await tester.startGesture(rect.center);
      // A continuous slider is silent on the way.
      await finger.moveBy(const Offset(60, 0));
      await tester.pump();
      await finger.moveBy(const Offset(60, 0));
      await tester.pump();
      expect(calls, isEmpty);
      // Arriving at the end ticks once, however far past it the finger goes.
      await finger.moveBy(const Offset(200, 0));
      await tester.pump();
      await finger.moveBy(const Offset(50, 0));
      await tester.pump();
      expect(value, 100);
      expect(calls, ['lightImpact']);
      // And once more at the other end.
      await finger.moveBy(const Offset(-900, 0));
      await tester.pump();
      expect(value, 0);
      expect(calls, ['lightImpact', 'lightImpact']);
      await finger.up();
      await settle(tester);
    });

    testWidgets('Slider: a mouse drag to the end is silent', (tester) async {
      var value = 50.0;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: SizedBox(
              width: 400,
              child: Slider(
                value: value,
                max: 100,
                divisions: 10,
                onChanged: (v) => setState(() => value = v),
              ),
            ),
          ),
        ),
      );
      final rect = tester.getRect(find.byType(Slider));
      final mouse = await tester.startGesture(
        rect.center,
        kind: PointerDeviceKind.mouse,
      );
      await mouse.moveBy(const Offset(30, 0));
      await tester.pump();
      await mouse.moveBy(const Offset(400, 0));
      await tester.pump();
      await mouse.up();
      await settle(tester);
      expect(value, 100);
      expect(calls, isEmpty);
    });

    testWidgets('SegmentedControl: a tick per segment a finger slides onto', (
      tester,
    ) async {
      var value = 'a';
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: SegmentedControl<String>(
              value: value,
              onChanged: (v) => setState(() => value = v),
              segments: const [
                Segment(value: 'a', label: Text('One')),
                Segment(value: 'b', label: Text('Two')),
                Segment(value: 'c', label: Text('Three')),
              ],
            ),
          ),
        ),
      );
      final from = tester.getCenter(find.text('One'));
      final to = tester.getCenter(find.text('Three'));
      final finger = await tester.startGesture(from);
      for (var i = 1; i <= 10; i++) {
        await finger.moveTo(Offset.lerp(from, to, i / 10)!);
        await tester.pump();
      }
      await finger.up();
      await settle(tester);
      expect(value, 'c');
      expect(calls, ['selectionClick', 'selectionClick']);
    });
  });
}

/// A constant widget that counts its builds: it is rebuilt only by what it
/// depends on.
class _Probe extends StatelessWidget {
  const _Probe();

  static int builds = 0;

  @override
  Widget build(BuildContext context) {
    builds++;
    return const SizedBox();
  }
}
