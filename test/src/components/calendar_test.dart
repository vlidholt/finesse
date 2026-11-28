import 'dart:math' as math;

import 'package:flutter/material.dart' hide DateTimeRange, IconButton;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:una/material.dart';
import 'package:una/src/app.dart';
import 'package:una/src/components/button.dart';
import 'package:una/src/components/calendar.dart'; // Adjust import path based on your project structure
import 'package:una/src/components/icon_button.dart';
import 'package:una/src/icons/phosphor_icons.dart';
import 'package:una/src/theme/components/calendar.dart';
import 'package:una/src/utils/extensions/date_time.dart';

/// The calendar's grid of days.
final _dayGrid = find.byWidgetPredicate(
  (w) => '${w.runtimeType}' == '_DayGrid',
);

void main() {
  // Helper method to create a test widget wrapped in UnaApp and Scaffold
  Widget createTestWidget(Widget child) {
    return UnaApp(
      builder: (context, child) => UnaMaterial(child: child!),
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('Calendar', () {
    testWidgets('renders single variant correctly', (
      WidgetTester tester,
    ) async {
      final now = DateTime.now();
      final initialMonth = DateTime(now.year, now.month);
      await tester.pumpWidget(
        createTestWidget(
          Calendar(
            initialMonth: initialMonth,
          ),
        ),
      );

      // Check if the current month is displayed in the header
      final monthYearText = DateFormat('MMMM y').format(initialMonth);
      expect(find.text(monthYearText), findsOneWidget);

      // Check navigation buttons are present
      expect(find.byType(IconButton), findsNWidgets(2));

      // Check weekday names are rendered (default 7 days)
      expect(_dayGrid, findsOneWidget);

      // Find the Column containing the calendar month (header, weekdays, grid)
      final monthColumnFinder = find.ancestor(
        of: _dayGrid.first,
        matching: find.byType(Column),
      );
      expect(monthColumnFinder, findsOneWidget);

      // Find the Row within the Column that has exactly 7 Text children
      // (weekdays)
      final weekdayRowFinder = find.descendant(
        of: monthColumnFinder,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Row &&
              // A week of days is a row of seven as well, as wide as the
              // month.
              widget.mainAxisSize == MainAxisSize.min &&
              tester
                      .widgetList(
                        find.descendant(
                          of: find.byWidget(widget),
                          matching: find.byType(Text),
                        ),
                      )
                      .length ==
                  7,
          description: 'Row with 7 Text children (weekdays)',
        ),
      );
      expect(weekdayRowFinder, findsOneWidget);

      final weekdayTexts = tester.widgetList(
        find.descendant(
          of: weekdayRowFinder,
          matching: find.byType(Text),
        ),
      );
      expect(weekdayTexts.length, 7); // 7 weekdays
    });

    testWidgets('renders multiple variant correctly', (
      WidgetTester tester,
    ) async {
      final now = DateTime(2024);
      await tester.pumpWidget(
        createTestWidget(
          Calendar.multiple(
            initialMonth: DateTime(2024),
            values: const [],
          ),
        ),
      );

      // Check if the current month is displayed
      final monthYearText = DateFormat('MMMM y').format(now.startOfMonth);
      expect(find.text(monthYearText), findsOneWidget);

      // Check basic layout (the grid of days)
      expect(_dayGrid, findsOneWidget);
    });

    testWidgets('renders range variant correctly', (WidgetTester tester) async {
      final now = DateTime(2024);
      await tester.pumpWidget(
        createTestWidget(
          Calendar.range(
            initialMonth: DateTime(2024),
          ),
        ),
      );

      // Check if the current month is displayed
      final monthYearText = DateFormat('MMMM y').format(now.startOfMonth);
      expect(find.text(monthYearText), findsOneWidget);

      // Check basic layout (the grid of days)
      expect(_dayGrid, findsOneWidget);
    });

    testWidgets('displays initial month correctly', (
      WidgetTester tester,
    ) async {
      final initialMonth = DateTime(2023, 10);
      await tester.pumpWidget(
        createTestWidget(
          Calendar(
            initialMonth: initialMonth,
          ),
        ),
      );

      // Check if the initial month is displayed
      final monthYearText = DateFormat('MMMM y').format(initialMonth);
      expect(find.text(monthYearText), findsOneWidget);

      // Check a specific date from October 2023 is rendered
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('selects date in single variant', (WidgetTester tester) async {
      DateTime? selectedDate;
      await tester.pumpWidget(
        createTestWidget(
          Calendar(
            initialMonth: DateTime(2024),
            onChanged: (date) => selectedDate = date,
          ),
        ),
      );

      // Tap a day button (e.g., day 15)
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      // Verify onChanged was called with the selected date
      expect(selectedDate, isNotNull);
      expect(selectedDate!.day, 15);

      // Check the selected day button has the primary variant
      final selectedButtonFinder = find.ancestor(
        of: find.text('15'),
        matching: find.byType(Button),
      );
      final selectedButton = tester.widget<Button>(selectedButtonFinder);
      expect(selectedButton.variant, ButtonVariant.primary);
    });

    testWidgets('selects multiple dates in multiple variant', (
      WidgetTester tester,
    ) async {
      var selectedDates = <DateTime>[];
      await tester.pumpWidget(
        createTestWidget(
          Calendar.multiple(
            initialMonth: DateTime(2024),
            onValuesChanged: (dates) => selectedDates = dates,
          ),
        ),
      );

      // Tap two days (e.g., 15 and 16)
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('16'));
      await tester.pumpAndSettle();

      // Verify onMultipleChanged was called with both dates
      expect(selectedDates.length, 2);
      expect(selectedDates.any((d) => d.day == 15), true);
      expect(selectedDates.any((d) => d.day == 16), true);
    });

    testWidgets('selects date range in range variant', (
      WidgetTester tester,
    ) async {
      DateTimeRange? selectedRange;
      await tester.pumpWidget(
        createTestWidget(
          Calendar.range(
            initialMonth: DateTime(2024),
            onRangeChanged: (range) => selectedRange = range,
          ),
        ),
      );

      // Tap start and end days (e.g., 10 and 15)
      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      // Verify onRangeChanged was called with the range
      expect(selectedRange, isNotNull);
      expect(selectedRange!.start!.day, 10);
      expect(selectedRange!.end!.day, 15);

      // Check start and end buttons have the selected variant
      final startButtonFinder = find.ancestor(
        of: find.text('10'),
        matching: find.byType(Button),
      );
      final endButtonFinder = find.ancestor(
        of: find.text('15'),
        matching: find.byType(Button),
      );
      expect(
        tester.widget<Button>(startButtonFinder).variant,
        ButtonVariant.primary,
      );
      expect(
        tester.widget<Button>(endButtonFinder).variant,
        ButtonVariant.primary,
      );
    });

    testWidgets('navigates to previous and next months', (
      WidgetTester tester,
    ) async {
      final initialMonth = DateTime(2023, 10);
      await tester.pumpWidget(
        createTestWidget(
          Calendar(
            initialMonth: initialMonth,
          ),
        ),
      );

      // Check initial month
      expect(find.text('October 2023'), findsOneWidget);

      // Tap forward navigation button
      final forwardButtonFinder = find.byIcon(PhosphorIconsRegular.caretRight);
      await tester.tap(forwardButtonFinder);
      await tester.pumpAndSettle();

      // Check next month
      expect(find.text('November 2023'), findsOneWidget);

      // Tap back navigation button
      final backButtonFinder = find.byIcon(PhosphorIconsRegular.caretLeft);
      await tester.tap(backButtonFinder);
      await tester.pumpAndSettle();

      // Check previous month
      expect(find.text('October 2023'), findsOneWidget);
    });
    group('Keyboard navigation', () {
      /// Press Tab until the target day button is focused
      Future<void> focusDay(
        WidgetTester tester,
        String dayText, {
        int maxTabs = 31,
      }) async {
        final finder = find.text(dayText).first;

        for (var i = 0; i < maxTabs; i++) {
          final semantics = tester.getSemantics(finder);
          if (semantics.flagsCollection.isFocused.toBoolOrNull() ?? false) {
            return;
          }
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
        }

        // Final check
        final finalSemantics = tester.getSemantics(finder);
        expect(
          finalSemantics.flagsCollection.isFocused,
          isTrue,
          reason: 'Could not focus day $dayText after $maxTabs tabs',
        );
      }

      /// Press a key and pump
      Future<void> pressKey(WidgetTester tester, LogicalKeyboardKey key) async {
        await tester.sendKeyEvent(key);
        await tester.pumpAndSettle();
      }

      /// Check if a day is focused
      bool isFocused(WidgetTester tester, String dayText) {
        final finder = find.text(dayText).first;
        final semantics = tester.getSemantics(finder);
        return semantics.flagsCollection.isFocused.toBoolOrNull() ?? false;
      }

      testWidgets('GIVEN a day button is focused '
          'AND right arrow key is pressed '
          'THEN focus moves to the next day', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            Calendar(initialMonth: DateTime(2025, 9)),
          ),
        );

        await focusDay(tester, '1');

        expect(isFocused(tester, '1'), isTrue);

        await pressKey(tester, LogicalKeyboardKey.arrowRight);

        expect(isFocused(tester, '2'), isTrue);
      });

      testWidgets('GIVEN a day button is focused '
          'AND left arrow key is pressed '
          'THEN focus moves to the previous day', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            Calendar(initialMonth: DateTime(2025, 9)),
          ),
        );

        await focusDay(tester, '1');

        expect(isFocused(tester, '1'), isTrue);

        await pressKey(tester, LogicalKeyboardKey.arrowRight);
        await pressKey(tester, LogicalKeyboardKey.arrowLeft);

        expect(isFocused(tester, '1'), isTrue);
      });

      testWidgets('GIVEN a day button is focused '
          'AND there is a day right above it '
          'AND arrow-up is pressed '
          'THEN focus moves to the day right above', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            Calendar(initialMonth: DateTime(2025, 9)),
          ),
        );

        // The days are one Tab stop: Tab reaches the first, the arrows the
        // others.
        await focusDay(tester, '1');
        await pressKey(tester, LogicalKeyboardKey.arrowDown);

        expect(isFocused(tester, '8'), isTrue);

        await pressKey(tester, LogicalKeyboardKey.arrowUp);

        expect(isFocused(tester, '1'), isTrue);
      });

      testWidgets('GIVEN a day button is focused '
          'AND there is a day right below it '
          'AND arrow-down is pressed '
          'THEN focus moves to the day below below', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            Calendar(
              initialMonth: DateTime(2025, 9),
            ),
          ),
        );

        await focusDay(tester, '1');

        expect(isFocused(tester, '1'), isTrue);

        await pressKey(tester, LogicalKeyboardKey.arrowDown);

        expect(isFocused(tester, '8'), isTrue);
      });
    });

    testWidgets('applies custom day button size correctly', (
      WidgetTester tester,
    ) async {
      const customDayButtonSize = 50.0;
      await tester.pumpWidget(
        createTestWidget(
          Calendar(
            initialMonth: DateTime(2024),
            calendarTheme: const CalendarTheme(
              dayButtonSize: customDayButtonSize,
            ),
          ),
        ),
      );

      // Check a day button has the custom size
      final dayButtonFinder = find.ancestor(
        of: find.text('15'),
        matching: find.byType(Button),
      );
      expect(dayButtonFinder, findsOneWidget);
      final dayButton = tester.widget<Button>(dayButtonFinder);
      expect(dayButton.style?.width, customDayButtonSize);
      expect(dayButton.style?.height, customDayButtonSize);
    });

    testWidgets('displays week numbers when enabled', (
      WidgetTester tester,
    ) async {
      final date = DateTime(2025, 2);
      await tester.pumpWidget(
        createTestWidget(
          Calendar(
            value: DateTime(2024, 12),
            showWeekNumbers: true,
            initialMonth: DateTime(2024),
          ),
        ),
      );

      // Check week numbers header (#) is rendered
      expect(find.text('#'), findsOneWidget);

      // Check a week number is rendered (e.g., for the current week)
      final weekNumber = date.weekNumber.toString();
      // 2 because there is also the day button with the same text
      expect(find.text(weekNumber), findsNWidgets(2));

      // Check grid has 8 columns (7 days + 1 for week numbers)
      expect(_dayGrid, findsOneWidget);
      final firstWeek = find
          .descendant(of: _dayGrid, matching: find.byType(Row))
          .first;
      expect(
        find.descendant(of: firstWeek, matching: find.byType(Expanded)),
        findsNWidgets(8),
      );
    });

    testWidgets('Calendar matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Calendar(
            initialMonth: DateTime(2024),
            min: DateTime(2023),
            max: DateTime(2024, 12, 31),
            showNavigation: false,
            captionLayout: CalendarCaptionLayout.label,
            showWeekNumbers: false,
            showOutsideDays: false,
            fixedWeeks: false,
            showWeekdayNames: true,
          ),
        ),
      );

      await expectLater(
        find.byType(Calendar),
        matchesGoldenFile('goldens/calendar.png'),
      );
    });

    testWidgets('showNavigation and showWeekdayNames default to true', (
      tester,
    ) async {
      Iterable<Offstage> hidden() => tester
          .widgetList<Offstage>(
            find.descendant(
              of: find.byType(Calendar),
              matching: find.byType(Offstage, skipOffstage: false),
            ),
          )
          .where((offstage) => offstage.offstage);

      await tester.pumpWidget(
        createTestWidget(Calendar(initialMonth: DateTime(2024))),
      );
      expect(find.byIcon(PhosphorIconsRegular.caretLeft), findsOneWidget);
      expect(find.byIcon(PhosphorIconsRegular.caretRight), findsOneWidget);
      expect(hidden(), isEmpty);

      await tester.pumpWidget(
        createTestWidget(
          Calendar(
            initialMonth: DateTime(2024),
            showNavigation: false,
            showWeekdayNames: false,
          ),
        ),
      );
      expect(find.byIcon(PhosphorIconsRegular.caretLeft), findsNothing);
      expect(find.byIcon(PhosphorIconsRegular.caretRight), findsNothing);
      // The row of weekday names is kept for the column widths, off stage.
      expect(hidden(), hasLength(1));
    });

    testWidgets('Calendar showNavigation true matches goldens', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          Calendar(
            initialMonth: DateTime(2024),
            min: DateTime(2023),
            max: DateTime(2024, 12, 31),
            showNavigation: true,
          ),
        ),
      );

      await expectLater(
        find.byType(Calendar),
        matchesGoldenFile('goldens/calendar_no_hide_navigation.png'),
      );
    });

    testWidgets('Calendar showWeekNumbers matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Calendar(
            initialMonth: DateTime(2024),
            min: DateTime(2023),
            max: DateTime(2024, 12, 31),
            showWeekNumbers: true,
          ),
        ),
      );

      await expectLater(
        find.byType(Calendar),
        matchesGoldenFile('goldens/calendar_show_week_numbers.png'),
      );
    });

    testWidgets('Calendar fixedWeeks matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Calendar(
            initialMonth: DateTime(2024),
            min: DateTime(2023),
            max: DateTime(2024, 12, 31),
            captionLayout: CalendarCaptionLayout.label,
            fixedWeeks: true,
          ),
        ),
      );

      await expectLater(
        find.byType(Calendar),
        matchesGoldenFile('goldens/calendar_fixed_weeks.png'),
      );
    });

    testWidgets('Calendar without weekday names matches goldens', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          Calendar(
            initialMonth: DateTime(2024),
            min: DateTime(2023),
            max: DateTime(2024, 12, 31),
            captionLayout: CalendarCaptionLayout.label,
            showWeekdayNames: false,
          ),
        ),
      );

      await expectLater(
        find.byType(Calendar),
        matchesGoldenFile('goldens/calendar_hide_weekday_names.png'),
      );
    });

    testWidgets('Calendar.multiple matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Calendar.multiple(
            initialMonth: DateTime(2024),
            numberOfMonths: 2,
            min: DateTime(2024),
            max: DateTime(2024, 12, 31),
            minSelected: 5,
            maxSelected: 10,
          ),
        ),
      );

      await expectLater(
        find.byType(Calendar),
        matchesGoldenFile('goldens/calendar_multiple.png'),
      );
    });

    testWidgets('Calendar.range matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Calendar.range(
            initialMonth: DateTime(2024),
            numberOfMonths: 2,
            min: DateTime(2024),
            max: DateTime(2024, 12, 31),
            minDays: 5,
            maxDays: 10,
          ),
        ),
      );

      await expectLater(
        find.byType(Calendar),
        matchesGoldenFile('goldens/calendar_range.png'),
      );
    });

    testWidgets('a range rounds its ends at the edges of each row, right to '
        'left as well', (tester) async {
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(
          createTestWidget(
            Directionality(
              textDirection: direction,
              child: Calendar.range(
                initialMonth: DateTime(2024, 3),
                range: DateTimeRange(
                  start: DateTime(2024, 3, 2),
                  end: DateTime(2024, 3, 28),
                ),
              ),
            ),
          ),
        );
        final days = find.descendant(
          of: _dayGrid,
          matching: find.byType(Button),
        );
        final rects = [
          for (final e in days.evaluate())
            tester.getRect(
              find.byElementPredicate((x) => x == e),
            ),
        ];
        final left = rects.map((r) => r.left).reduce(math.min);
        final right = rects.map((r) => r.right).reduce(math.max);
        var rounded = 0;
        for (final (i, element) in days.evaluate().indexed) {
          final button = element.widget as Button;
          final radius = button.style?.decoration?.border?.borderRadius
              ?.resolve(direction);
          if (radius == null) continue;
          final roundsLeft = radius.topLeft != Radius.zero;
          final roundsRight = radius.topRight != Radius.zero;
          // A cell rounded on one side only is a row's end in the range.
          if (roundsLeft == roundsRight) continue;
          rounded++;
          if (roundsLeft) {
            expect(rects[i].left, moreOrLessEquals(left, epsilon: 1));
          } else {
            expect(rects[i].right, moreOrLessEquals(right, epsilon: 1));
          }
        }
        expect(rounded, greaterThan(4), reason: '$direction');
      }
    });
  });
}
