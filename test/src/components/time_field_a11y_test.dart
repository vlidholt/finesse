import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// A time field from the keyboard and to a screen reader: the arrows step
/// a part and move between parts, every part (the day period too) is one
/// named node, and an empty part does not read as "00".
void main() {
  Finder fields() => find.descendant(
    of: find.byType(TimeField),
    matching: find.byType(EditableText),
  );

  String textOf(WidgetTester tester, int index) =>
      tester.widget<EditableText>(fields().at(index)).controller.text;

  FocusNode nodeOf(WidgetTester tester, int index) =>
      tester.widget<EditableText>(fields().at(index)).focusNode;

  Widget field({
    TimeOfDay? initial,
    bool use24 = true,
    bool showLabels = true,
    bool showSeconds = false,
    ValueChanged<TimeOfDay?>? onChanged,
  }) => Center(
    child: TimeField(
      initialValue: initial,
      use24HourFormat: use24,
      showLabels: showLabels,
      showSeconds: showSeconds,
      onChanged: onChanged,
    ),
  );

  testWidgets('up and down step a part, wrapping at its ends', (tester) async {
    final changes = <TimeOfDay?>[];
    await pumpUna(
      tester,
      field(
        initial: const TimeOfDay(hour: 23, minute: 0),
        onChanged: changes.add,
      ),
    );
    await tester.tap(fields().at(0));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(textOf(tester, 0), '00');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(textOf(tester, 0), '23');

    nodeOf(tester, 1).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(textOf(tester, 1), '59');
    expect(changes.last, const TimeOfDay(hour: 23, minute: 59));
  });

  testWidgets('on the 12-hour clock the hours run from 1 to 12', (
    tester,
  ) async {
    await pumpUna(
      tester,
      field(initial: const TimeOfDay(hour: 12, minute: 0), use24: false),
    );
    await tester.tap(fields().at(0));
    await tester.pump();
    expect(textOf(tester, 0), '12');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(textOf(tester, 0), '01');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(textOf(tester, 0), '11');
  });

  testWidgets('left and right move between the parts', (tester) async {
    await pumpUna(
      tester,
      field(initial: const TimeOfDay(hour: 9, minute: 30), showSeconds: true),
    );
    await tester.tap(fields().at(0));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodeOf(tester, 1).hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodeOf(tester, 2).hasFocus, isTrue);
    // Past the last part there is nowhere to go.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodeOf(tester, 2).hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(nodeOf(tester, 0).hasFocus, isTrue);
  });

  testWidgets('right reaches the day period, and left comes back', (
    tester,
  ) async {
    await pumpUna(
      tester,
      field(initial: const TimeOfDay(hour: 9, minute: 30), use24: false),
    );
    nodeOf(tester, 1).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodeOf(tester, 1).hasFocus, isFalse);
    final select = tester.widget<Select<DayPeriod>>(
      find.byType(Select<DayPeriod>),
    );
    expect(select.focusNode!.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(nodeOf(tester, 1).hasFocus, isTrue);
  });

  testWidgets('each part is a node with its name and no "00"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    for (final showLabels in [true, false]) {
      await pumpUna(
        tester,
        field(use24: false, showLabels: showLabels),
      );
      final hours = tester.getSemantics(fields().at(0)).getSemanticsData();
      expect(hours.label, 'Hours');
      expect(hours.value, isEmpty);
      expect(tester.getSemantics(fields().at(1)).label, 'Minutes');
      // The painted names are not read a second time.
      expect(find.bySemanticsLabel('Hours'), findsOneWidget);

      final period = tester
          .getSemantics(find.byType(Select<DayPeriod>))
          .getSemanticsData();
      expect(period.label, contains('Period'));
      // The placeholder is a sample, not a value.
      expect(period.label, isNot(contains('AM')));
      expect(period.value, isNot(contains('AM')));
      await tester.pumpWidget(const SizedBox.shrink());
    }
    handle.dispose();
  });

  testWidgets('in a form field each part takes the field label', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpUna(
      tester,
      Center(
        child: TimeFormField(
          label: const Text('Alarm'),
          description: const Text('On weekdays'),
          use24HourFormat: false,
        ),
      ),
    );
    final hours = tester.getSemantics(fields().at(0));
    expect(hours.label, 'Alarm, Hours');
    expect(hours.hint, 'On weekdays');
    final period = tester
        .getSemantics(find.byType(Select<DayPeriod>))
        .getSemanticsData();
    expect(period.label, contains('Alarm, Period'));
    expect(find.bySemanticsLabel('Alarm'), findsNothing);
    handle.dispose();
  });

  testWidgets('the day period grows with scaled text instead of clipping', (
    tester,
  ) async {
    Future<double> periodHeight(double scale) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpUna(
        tester,
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: field(use24: false),
          ),
        ),
      );
      return tester.getSize(find.byType(Select<DayPeriod>)).height;
    }

    final unscaled = await periodHeight(1);
    final context = tester.element(find.byType(TimeField));
    // The style's height, exactly, at the platform's own text size.
    expect(unscaled, Theme.of(context).timeFieldTheme.periodHeight);
    expect(tester.takeException(), isNull);
    final scaled = await periodHeight(3);
    expect(scaled, greaterThan(unscaled));
    expect(tester.takeException(), isNull);
  });
}
