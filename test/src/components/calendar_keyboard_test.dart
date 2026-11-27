import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// One glyph a cell: the test font is an em wide per glyph.
const _smallDays = CalendarTheme(
  dayButtonTextStyle: TextStyle(fontSize: 8),
  selectedDayButtonTextStyle: TextStyle(fontSize: 8),
  insideRangeDayButtonTextStyle: TextStyle(fontSize: 8),
  dayButtonOutsideMonthTextStyle: TextStyle(fontSize: 8),
);

/// The day whose button has the primary focus, read from its node's label.
DateTime? _focusedDay() {
  final label = FocusManager.instance.primaryFocus?.debugLabel;
  const prefix = 'Calendar day ';
  if (label == null || !label.startsWith(prefix)) return null;
  return DateTime.parse(label.substring(prefix.length));
}

Future<void> _key(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
}) async {
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.pump();
  await tester.pump();
}

void main() {
  final before = FocusNode(debugLabel: 'before');
  tearDownAll(before.dispose);

  Future<void> pump(
    WidgetTester tester,
    Widget calendar, {
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    await pumpUna(
      tester,
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(
              focusNode: before,
              onPressed: () {},
              child: const Text('Before'),
            ),
            calendar,
            Button(onPressed: () {}, child: const Text('After')),
          ],
        ),
      ),
      textDirection: textDirection,
    );
  }

  /// Focuses the button before the calendar and tabs into it, through the
  /// navigation buttons, onto the day that is its Tab stop.
  Future<void> tabIntoDays(WidgetTester tester) async {
    before.requestFocus();
    await tester.pump();
    for (var i = 0; i < 6 && _focusedDay() == null; i++) {
      await _key(tester, LogicalKeyboardKey.tab);
    }
    expect(_focusedDay(), isNotNull, reason: 'Tab never reached a day');
  }

  // 1 September 2025 is a Monday, the week's first day by default.
  final sept17 = DateTime(2025, 9, 17);

  group('Calendar keyboard', () {
    testWidgets('the days are one Tab stop, the selected day', (tester) async {
      await pump(
        tester,
        Calendar(
          value: sept17,
          initialMonth: sept17,
          onChanged: (_) {},
          calendarTheme: _smallDays,
        ),
      );
      before.requestFocus();
      await tester.pump();
      // Round the whole page once, back to where it started.
      final days = <DateTime>[];
      for (var i = 0; i < 12; i++) {
        await _key(tester, LogicalKeyboardKey.tab);
        if (before.hasPrimaryFocus) break;
        final day = _focusedDay();
        if (day != null) days.add(day);
      }
      expect(before.hasPrimaryFocus, isTrue);
      expect(days, [sept17]);
    });

    testWidgets('with nothing selected, the Tab stop is the first day '
        'that can be chosen', (tester) async {
      await pump(
        tester,
        Calendar(
          initialMonth: DateTime(2025, 9),
          min: DateTime(2025, 9, 3),
          onChanged: (_) {},
          calendarTheme: _smallDays,
        ),
      );
      await tabIntoDays(tester);
      expect(_focusedDay(), DateTime(2025, 9, 3));
    });

    testWidgets('the arrows move a day and a week, Home and End to the '
        'ends of the week', (tester) async {
      await pump(
        tester,
        Calendar(
          value: sept17,
          initialMonth: sept17,
          onChanged: (_) {},
          calendarTheme: _smallDays,
        ),
      );
      await tabIntoDays(tester);
      expect(_focusedDay(), sept17);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      expect(_focusedDay(), DateTime(2025, 9, 18));
      await _key(tester, LogicalKeyboardKey.arrowLeft);
      expect(_focusedDay(), sept17);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(_focusedDay(), DateTime(2025, 9, 24));
      await _key(tester, LogicalKeyboardKey.arrowUp);
      expect(_focusedDay(), sept17);
      await _key(tester, LogicalKeyboardKey.home);
      expect(_focusedDay(), DateTime(2025, 9, 15));
      await _key(tester, LogicalKeyboardKey.end);
      expect(_focusedDay(), DateTime(2025, 9, 21));

      // The day last focused stays the Tab stop: Shift+Tab out and Tab
      // back in lands on it.
      await _key(tester, LogicalKeyboardKey.tab);
      expect(_focusedDay(), isNull);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(_focusedDay(), DateTime(2025, 9, 21));
    });

    testWidgets('in right-to-left text the left arrow is the next day', (
      tester,
    ) async {
      await pump(
        tester,
        Calendar(
          value: sept17,
          initialMonth: sept17,
          onChanged: (_) {},
          calendarTheme: _smallDays,
        ),
        textDirection: TextDirection.rtl,
      );
      await tabIntoDays(tester);
      await _key(tester, LogicalKeyboardKey.arrowLeft);
      expect(_focusedDay(), DateTime(2025, 9, 18));
      await _key(tester, LogicalKeyboardKey.arrowRight);
      expect(_focusedDay(), sept17);
    });

    testWidgets('leaving the month turns it, and Page Up and Down move a '
        'month, a year with Shift', (tester) async {
      final months = <DateTime>[];
      await pump(
        tester,
        Calendar(
          value: DateTime(2025, 9, 30),
          initialMonth: DateTime(2025, 9),
          onChanged: (_) {},
          onMonthChanged: months.add,
          calendarTheme: _smallDays,
        ),
      );
      await tabIntoDays(tester);
      expect(_focusedDay(), DateTime(2025, 9, 30));
      await _key(tester, LogicalKeyboardKey.arrowRight);
      expect(_focusedDay(), DateTime(2025, 10));
      expect(find.text('October 2025'), findsOneWidget);
      expect(months, [DateTime(2025, 10)]);

      await _key(tester, LogicalKeyboardKey.pageDown);
      expect(_focusedDay(), DateTime(2025, 11));
      expect(find.text('November 2025'), findsOneWidget);
      await _key(tester, LogicalKeyboardKey.pageUp, shift: true);
      expect(_focusedDay(), DateTime(2024, 11));
      expect(find.text('November 2024'), findsOneWidget);
      await _key(tester, LogicalKeyboardKey.arrowLeft);
      expect(_focusedDay(), DateTime(2024, 10, 31));
      expect(find.text('October 2024'), findsOneWidget);
    });

    testWidgets('a day that cannot be chosen is skipped, and the bounds '
        'stop the focus', (tester) async {
      await pump(
        tester,
        Calendar(
          value: sept17,
          initialMonth: sept17,
          max: DateTime(2025, 9, 20),
          selectableDayPredicate: (day) => day.day != 18,
          onChanged: (_) {},
          calendarTheme: _smallDays,
        ),
      );
      await tabIntoDays(tester);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      expect(_focusedDay(), DateTime(2025, 9, 19));
      await _key(tester, LogicalKeyboardKey.arrowRight);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      expect(_focusedDay(), DateTime(2025, 9, 20));
      await _key(tester, LogicalKeyboardKey.pageDown);
      expect(_focusedDay(), DateTime(2025, 9, 20));
      expect(find.text('September 2025'), findsOneWidget);
    });

    testWidgets('Enter and Space on a focused day choose it', (tester) async {
      final chosen = <DateTime?>[];
      await pump(
        tester,
        Calendar(
          value: sept17,
          initialMonth: sept17,
          onChanged: chosen.add,
          calendarTheme: _smallDays,
        ),
      );
      await tabIntoDays(tester);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      await _key(tester, LogicalKeyboardKey.enter);
      expect(chosen, [DateTime(2025, 9, 18)]);
    });
  });

  group('Calendar semantics', () {
    testWidgets('a day is named in full, with whether it is selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        Calendar(
          value: sept17,
          initialMonth: sept17,
          onChanged: (_) {},
          calendarTheme: _smallDays,
        ),
      );
      final selected = tester.getSemantics(
        find.bySemanticsLabel('Wednesday, September 17, 2025'),
      );
      expect(
        selected,
        matchesSemantics(
          label: 'Wednesday, September 17, 2025',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasSelectedState: true,
          isSelected: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      final other = tester
          .getSemantics(find.bySemanticsLabel('Thursday, September 18, 2025'))
          .getSemanticsData();
      expect(other.flagsCollection.isSelected, Tristate.isFalse);
      expect(
        find.bySemanticsLabel('Previous month'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Next month'), findsOneWidget);
      handle.dispose();
    });

    testWidgets("today is hinted, and a range's ends are its value", (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      await pump(
        tester,
        Calendar(initialMonth: today, onChanged: (_) {}),
      );
      final label = DateFormat.yMMMMEEEEd().format(today);
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)).getSemanticsData(),
        isA<SemanticsData>().having((data) => data.hint, 'hint', 'Today'),
      );

      await pump(
        tester,
        Calendar.range(
          range: DateTimeRange(start: sept17, end: DateTime(2025, 9, 19)),
          initialMonth: sept17,
          onRangeChanged: (_) {},
          calendarTheme: _smallDays,
        ),
      );
      SemanticsData day(int day) => tester
          .getSemantics(
            find.bySemanticsLabel(
              DateFormat.yMMMMEEEEd().format(DateTime(2025, 9, day)),
            ),
          )
          .getSemanticsData();
      expect(day(17).value, 'Start of range');
      expect(day(19).value, 'End of range');
      expect(day(18).value, '');
      expect(day(18).flagsCollection.isSelected, Tristate.isTrue);
      expect(day(20).flagsCollection.isSelected, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('the month is announced when a button turns it', (
      tester,
    ) async {
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
      await pump(
        tester,
        Calendar(
          initialMonth: DateTime(2025, 9),
          onChanged: (_) {},
          calendarTheme: _smallDays,
        ),
      );
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is IconButton && widget.semanticLabel == 'Next month',
        ),
      );
      await tester.pump();
      expect(announced, ['October 2025']);
    });

    testWidgets("the caption's dropdowns are named Month and Year", (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        Calendar(
          initialMonth: DateTime(2025, 9),
          captionLayout: CalendarCaptionLayout.dropdown,
          onChanged: (_) {},
          calendarTheme: _smallDays,
        ),
      );
      final month = tester
          .getSemantics(find.bySemanticsLabel('Month'))
          .getSemanticsData();
      expect(month.value, 'September');
      expect(month.flagsCollection.isButton, isTrue);
      expect(month.flagsCollection.isExpanded, Tristate.isFalse);
      final year = tester
          .getSemantics(find.bySemanticsLabel('Year'))
          .getSemanticsData();
      expect(year.value, '2025');
      handle.dispose();
    });
  });
}
