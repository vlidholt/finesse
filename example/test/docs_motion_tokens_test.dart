import 'package:example/docs/examples/motion/motion_tokens.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The "Tokens" example of the Motion page: the code a reader copies to
// scope a motion vocabulary to a subtree.

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    FinesseApp(
      theme: ThemeData(),
      home: const Scaffold(body: Center(child: MotionTokensExample())),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

ThemeData _scoped(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Tabs<String>)));

void main() {
  testWidgets('tapping the vocabulary that is already selected keeps it '
      'selected', (tester) async {
    await _pump(tester);
    expect(_scoped(tester).motion, Motion.lively);

    // A single-selection ToggleGroup lets its selected item be switched
    // off unless told otherwise, and would then report null.
    await tester.tap(find.text('Lively'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.takeException(), isNull);
    expect(
      tester
          .widget<ToggleGroup<String>>(find.byType(ToggleGroup<String>))
          .value,
      'Lively',
    );
    expect(_scoped(tester).motion, Motion.lively);
  });

  testWidgets('choosing a vocabulary changes the motion of the subtree', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('Calm'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_scoped(tester).motion, Motion.calm);
    await tester.tap(find.text('None'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_scoped(tester).motion, Motion.none);
    // The theme outside the scope is untouched.
    expect(
      Theme.of(tester.element(find.byType(MotionTokensExample))).motion,
      isNot(Motion.none),
    );
  });

  testWidgets('the scoped theme is derived when the choice changes, not on '
      'every build', (tester) async {
    await _pump(tester);
    final before = _scoped(tester);
    // Something that has nothing to do with motion rebuilds the example.
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.text('Activity'));
    await tester.pump();
    expect(identical(_scoped(tester), before), isTrue);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('the scoped theme follows the theme above it', (tester) async {
    await _pump(tester);
    expect(_scoped(tester).brightness, Brightness.light);
    await tester.pumpWidget(
      FinesseApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const Scaffold(body: Center(child: MotionTokensExample())),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(_scoped(tester).brightness, Brightness.dark);
    expect(_scoped(tester).motion, Motion.lively);
  });
}
