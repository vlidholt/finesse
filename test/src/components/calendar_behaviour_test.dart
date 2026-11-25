import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// One glyph a cell: the test font is an em wide per glyph, so two digits
/// at the theme's size do not fit a cell that fits them in any real font.
const _small = CalendarTheme(
  dayButtonTextStyle: TextStyle(fontSize: 8),
  selectedDayButtonTextStyle: TextStyle(fontSize: 8),
  insideRangeDayButtonTextStyle: TextStyle(fontSize: 8),
  dayButtonOutsideMonthTextStyle: TextStyle(fontSize: 8),
);

void main() {
  Finder dayOf(int day) => find.widgetWithText(Button, '$day');

  final may = DateTime(2024, 5, 15);

  group('Calendar', () {
    testWidgets('a value written from outside is shown, null included', (
      tester,
    ) async {
      DateTime? value = may;
      late StateSetter rebuild;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Center(
              child: Calendar(
                value: value,
                initialMonth: may,
                calendarTheme: _small,
              ),
            );
          },
        ),
      );
      ButtonVariant variantOf(int day) =>
          tester.widget<Button>(dayOf(day).first).variant;
      expect(variantOf(15), ButtonVariant.primary);
      rebuild(() => value = DateTime(2024, 5, 20));
      await tester.pump();
      expect(variantOf(15), ButtonVariant.ghost);
      expect(variantOf(20), ButtonVariant.primary);
      rebuild(() => value = null);
      await tester.pump();
      expect(variantOf(20), ButtonVariant.ghost);
    });

    testWidgets('min and max disable days and stop the navigation', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(
          child: Calendar(
            initialMonth: may,
            min: DateTime(2024, 5, 10, 18),
            max: DateTime(2024, 6, 2),
            calendarTheme: _small,
          ),
        ),
      );
      expect(tester.widget<Button>(dayOf(9).first).enabled, isFalse);
      // The whole first day counts, whatever its time.
      expect(tester.widget<Button>(dayOf(10).first).enabled, isTrue);
      final nav = tester
          .widgetList<IconButton>(find.byType(IconButton))
          .toList();
      expect(nav.first.enabled, isFalse);
      expect(nav.last.enabled, isTrue);
      await tester.tap(find.byType(IconButton).last);
      await settle(tester);
      expect(find.text('June 2024'), findsOneWidget);
      expect(tester.widget<Button>(dayOf(2).first).enabled, isTrue);
      expect(tester.widget<Button>(dayOf(3).first).enabled, isFalse);
      expect(
        tester.widgetList<IconButton>(find.byType(IconButton)).last.enabled,
        isFalse,
      );
    });

    testWidgets('a range is bounded in length by minDays and maxDays', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(
          child: Calendar.range(
            initialMonth: may,
            range: DateTimeRange(start: may),
            minDays: 2,
            maxDays: 5,
            calendarTheme: _small,
          ),
        ),
      );
      expect(tester.widget<Button>(dayOf(16).first).enabled, isFalse);
      expect(tester.widget<Button>(dayOf(17).first).enabled, isTrue);
      expect(tester.widget<Button>(dayOf(20).first).enabled, isTrue);
      expect(tester.widget<Button>(dayOf(21).first).enabled, isFalse);
    });

    testWidgets('several days stop at maxSelected', (tester) async {
      final reported = <List<DateTime>>[];
      await pumpFinesse(
        tester,
        Center(
          child: Calendar.multiple(
            initialMonth: may,
            maxSelected: 2,
            onValuesChanged: reported.add,
            calendarTheme: _small,
          ),
        ),
      );
      await tester.tap(dayOf(10).first);
      await tester.pump();
      await tester.tap(dayOf(11).first);
      await tester.pump();
      expect(reported.last, hasLength(2));
      expect(tester.widget<Button>(dayOf(12).first).enabled, isFalse);
      expect(tester.widget<Button>(dayOf(11).first).enabled, isTrue);
    });

    testWidgets('calendarTheme restyles one calendar', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: Calendar(
            initialMonth: may,
            calendarTheme: _small.merge(
              CalendarTheme(
                dayButtonSize: 50,
                formatMonthYear: (date) => 'Month ${date.month}',
                todayButtonVariant: ButtonVariant.outline,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Month 5'), findsOneWidget);
      expect(tester.getSize(dayOf(15).first), const Size.square(50));
      expect(tester.getSize(find.byType(GridView)).width, 350);
    });

    testWidgets('cells grow with the text scale', (tester) async {
      await pumpFinesse(
        tester,
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: Center(child: Calendar(initialMonth: may)),
        ),
      );
      final cell = themeOf(
        tester,
        find.byType(Calendar),
      ).calendarTheme.dayButtonSize!;
      expect(tester.getSize(dayOf(15).first), Size.square(cell * 1.5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a month wider than its room is shown whole, smaller', (
      tester,
    ) async {
      // On a phone at twice the text size seven cells are wider than the
      // screen.
      await pumpFinesse(
        tester,
        MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            textScaler: TextScaler.linear(2),
          ),
          child: Center(
            child: Calendar(
              initialMonth: may,
              captionLayout: CalendarCaptionLayout.dropdown,
            ),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      expect(tester.takeException(), isNull);
      final calendar = tester.getRect(find.byType(Calendar));
      expect(calendar.left, greaterThanOrEqualTo(0));
      expect(calendar.right, lessThanOrEqualTo(390));
      // Every day is on screen and can still be tapped.
      final first = tester.getRect(dayOf(1).first);
      final last = tester.getRect(dayOf(31).first);
      expect(first.left, greaterThanOrEqualTo(0));
      expect(last.right, lessThanOrEqualTo(390));
    });

    testWidgets('builds in every layout with two months and week numbers', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => Center(
          child: Calendar.range(
            initialMonth: may,
            numberOfMonths: 2,
            showWeekNumbers: true,
            calendarTheme: _small,
          ),
        ),
      );
    });
  });
}
