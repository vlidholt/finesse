import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

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
      await pumpUna(
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
      ButtonVariant? variantOf(int day) =>
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
      await pumpUna(
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
      await pumpUna(
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

    testWidgets('a range with both its days starts over on the next tap', (
      tester,
    ) async {
      final reported = <DateTimeRange?>[];
      await pumpUna(
        tester,
        Center(
          child: Calendar.range(
            initialMonth: may,
            range: DateTimeRange(start: DateTime(2024, 5, 10), end: may),
            minDays: 2,
            maxDays: 5,
            onRangeChanged: reported.add,
            calendarTheme: _small,
          ),
        ),
      );
      // Too far from the 10th for an end, but a range that is done does
      // not bound the day a new one starts on.
      expect(tester.widget<Button>(dayOf(25).first).enabled, isTrue);
      await tester.tap(dayOf(25).first);
      await tester.pump();
      expect(reported.single, DateTimeRange(start: DateTime(2024, 5, 25)));
      // Waiting for its end, the new range bounds it again.
      expect(tester.widget<Button>(dayOf(26).first).enabled, isFalse);
      expect(tester.widget<Button>(dayOf(28).first).enabled, isTrue);
      await tester.tap(dayOf(28).first);
      await tester.pump();
      expect(
        reported.last,
        DateTimeRange(start: DateTime(2024, 5, 25), end: DateTime(2024, 5, 28)),
      );
    });

    testWidgets('a day takes the hover at once, with no fade', (tester) async {
      await pumpUna(
        tester,
        Center(
          child: Calendar(initialMonth: may, calendarTheme: _small),
        ),
      );
      for (final day in [1, 15, 31]) {
        expect(
          tester.widget<Button>(dayOf(day).first).style?.transitionDuration,
          Duration.zero,
        );
      }
    });

    testWidgets('several days stop at maxSelected', (tester) async {
      final reported = <List<DateTime>>[];
      await pumpUna(
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
      await pumpUna(
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

    for (final direction in TextDirection.values) {
      testWidgets('the header reads in the text direction: ${direction.name}', (
        tester,
      ) async {
        final rtl = direction == TextDirection.rtl;
        final months = <DateTime>[];
        await pumpUna(
          tester,
          Center(
            child: Calendar(
              initialMonth: may,
              calendarTheme: _small,
              onMonthChanged: months.add,
            ),
          ),
          textDirection: direction,
        );
        // Earlier days are towards the start, in the grid…
        final first = tester.getCenter(dayOf(1).first).dx;
        final second = tester.getCenter(dayOf(2).first).dx;
        expect(second > first, !rtl);

        // …and so is the button that goes to earlier months, with a caret
        // that points the way it leads.
        final towardsLeft = find.byIcon(PhosphorIconsRegular.caretLeft);
        final towardsRight = find.byIcon(PhosphorIconsRegular.caretRight);
        expect(towardsLeft, findsOneWidget);
        expect(towardsRight, findsOneWidget);
        final calendar = tester.getRect(find.byType(Calendar));
        expect(tester.getCenter(towardsLeft).dx, lessThan(calendar.center.dx));
        expect(
          tester.getCenter(towardsRight).dx,
          greaterThan(calendar.center.dx),
        );

        final back = rtl ? towardsRight : towardsLeft;
        final forward = rtl ? towardsLeft : towardsRight;
        await tester.tap(back);
        await settle(tester);
        expect((months.last.year, months.last.month), (2024, 4));
        await tester.tap(forward);
        await settle(tester);
        await tester.tap(forward);
        await settle(tester);
        expect((months.last.year, months.last.month), (2024, 6));
      });
    }

    testWidgets("a theme's own navigation icons are drawn as given", (
      tester,
    ) async {
      await pumpUna(
        tester,
        Center(
          child: Calendar(
            initialMonth: may,
            calendarTheme: _small.copyWith(
              backNavigationButtonIcon: const PhosphorIcon(
                PhosphorIconsRegular.arrowLeft,
              ),
              forwardNavigationButtonIcon: const PhosphorIcon(
                PhosphorIconsRegular.arrowRight,
              ),
            ),
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      expect(find.byIcon(PhosphorIconsRegular.caretLeft), findsNothing);
      final calendar = tester.getRect(find.byType(Calendar));
      // Back is at the start, which is the right.
      expect(
        tester.getCenter(find.byIcon(PhosphorIconsRegular.arrowLeft)).dx,
        greaterThan(calendar.center.dx),
      );
    });

    testWidgets('cells grow with the text scale', (tester) async {
      await pumpUna(
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
      await pumpUna(
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
