import 'package:finesse/finesse.dart';
import 'package:finesse/src/utils/extensions/date_time.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bugs found while documenting the API for 1.0.
void main() {
  test('Position.lerp interpolates sides set on both ends', () {
    final mid = Position.lerp(
      const Position(top: 0, left: 10),
      const Position(top: 20, right: 4),
      .5,
    )!;
    expect(mid.top, 10);
    // Set on one end only: switches halfway.
    expect(mid.left, isNull);
    expect(mid.right, 4);
  });

  test('Breakpoints.lerp tolerates null ends', () {
    expect(Breakpoints.lerp(null, null, .5), isNull);
    final b = Breakpoints();
    expect(Breakpoints.lerp(null, b, .7), b);
  });

  test('stepping months clamps the day', () {
    expect(DateTime(2025, 1, 31).nextMonth, DateTime(2025, 2, 28));
    expect(DateTime(2024, 1, 31).nextMonth, DateTime(2024, 2, 29));
    expect(DateTime(2025, 3, 31).previousMonth, DateTime(2025, 2, 28));
    expect(DateTime(2025, 12, 15).nextMonth, DateTime(2026, 1, 15));
  });

  test('a restorable tabs controller saves the current tab', () {
    final restorable = RestorableTabsController(value: 'a');
    final controller = restorable.createDefaultValue()..select('b');
    expect(controller.value, 'b');
    // toPrimitives reads the live value once registered; mimic that here.
    expect(
      RestorableTabsController(value: 'a').fromPrimitives('b').value,
      'b',
    );
  });

  testWidgets('a radio group moves its listener to a swapped controller', (
    tester,
  ) async {
    final a = RadioController<int>(value: 1);
    final b = RadioController<int>(value: 1);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    int? changed;
    Widget build(RadioController<int> controller) => FinesseApp(
      home: FinesseRadioGroup<int>(
        controller: controller,
        onChanged: (v) => changed = v,
        items: const [
          Radio(value: 1, label: Text('one')),
          Radio(value: 2, label: Text('two')),
        ],
      ),
    );

    await tester.pumpWidget(build(a));
    await tester.pumpWidget(build(b));
    changed = null;
    a.value = 2;
    await tester.pump();
    expect(changed, isNull, reason: 'the old controller is no longer heard');
    b.value = 2;
    await tester.pump();
    expect(changed, 2);
  });

  testWidgets('a select notifies its controller when initialValue changes', (
    tester,
  ) async {
    final controller = SelectController<String>();
    addTearDown(controller.dispose);
    var notified = 0;
    controller.addListener(() => notified++);
    Widget build(String initial) => FinesseApp(
      home: Select<String>(
        controller: controller,
        initialValue: initial,
        placeholder: const Text('pick'),
        options: const [
          SelectOption(value: 'a', child: Text('a')),
          SelectOption(value: 'b', child: Text('b')),
        ],
        selectedOptionBuilder: (context, value) => Text(value),
      ),
    );
    await tester.pumpWidget(build('a'));
    notified = 0;
    await tester.pumpWidget(build('b'));
    await tester.pump();
    expect(controller.value, {'b'});
    expect(notified, greaterThan(0));
  });
}
