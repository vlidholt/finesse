import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../finesse_harness.dart';

void main() {
  Finder wheelOf(String label) => find.byWidgetPredicate(
    (w) => w is WheelPicker && w.semanticLabel == label,
  );

  Future<void> rest(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Turns the wheel named [label] by [rows] rows.
  Future<void> turn(WidgetTester tester, String label, int rows) async {
    final wheel = wheelOf(label);
    final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
    final gesture = await tester.startGesture(tester.getCenter(wheel));
    await gesture.moveBy(Offset(0, -20.0 * rows.sign));
    for (var i = 0; i < 12; i++) {
      await gesture.moveBy(Offset(0, -extent * rows / 12));
      await tester.pump(const Duration(milliseconds: 8));
    }
    await gesture.up();
    await rest(tester);
  }

  Widget wheels({
    required List<DateTime> reported,
    required DateTime value,
    DateWheelMode mode = DateWheelMode.date,
    DateTime? min,
    DateTime? max,
    Locale? locale,
  }) {
    var date = value;
    Widget picker = StatefulBuilder(
      builder: (context, setState) => Center(
        child: DateWheelPicker(
          value: date,
          mode: mode,
          min: min,
          max: max,
          use24HourFormat: true,
          onChanged: (v) {
            setState(() => date = v);
            reported.add(v);
          },
        ),
      ),
    );
    if (locale != null) {
      final inner = picker;
      picker = Builder(
        builder: (context) => Localizations.override(
          context: context,
          locale: locale,
          child: inner,
        ),
      );
    }
    return picker;
  }

  group('DateWheelPicker', () {
    testWidgets('has a wheel for the day, the month and the year under one '
        'lens', (tester) async {
      await pumpFinesse(
        tester,
        wheels(reported: [], value: DateTime(2024, 5, 15)),
      );
      expect(wheelOf('Day'), findsOneWidget);
      expect(wheelOf('Month'), findsOneWidget);
      expect(wheelOf('Year'), findsOneWidget);
      expect(find.byType(Glass), findsOneWidget);
      expect(tester.getSemantics(wheelOf('Month')).value, 'May');
      expect(tester.getSemantics(wheelOf('Day')).value, '15');
      expect(tester.getSemantics(wheelOf('Year')).value, '2024');
      // American English writes the month first.
      expect(
        tester.getCenter(wheelOf('Month')).dx,
        lessThan(tester.getCenter(wheelOf('Day')).dx),
      );
      expect(
        tester.getCenter(wheelOf('Day')).dx,
        lessThan(tester.getCenter(wheelOf('Year')).dx),
      );
    });

    testWidgets('each wheel changes its part of the date', (tester) async {
      final reported = <DateTime>[];
      await pumpFinesse(
        tester,
        wheels(reported: reported, value: DateTime(2024, 5, 15)),
      );
      await turn(tester, 'Day', 2);
      expect(reported.last, DateTime(2024, 5, 17));
      await turn(tester, 'Month', -1);
      expect(reported.last, DateTime(2024, 4, 17));
      await turn(tester, 'Year', 1);
      expect(reported.last, DateTime(2025, 4, 17));
    });

    testWidgets('the rows stay put while a wheel turns', (tester) async {
      // The years are laid out around the date the picker started with,
      // not around the one it has now.
      final reported = <DateTime>[];
      await pumpFinesse(
        tester,
        wheels(reported: reported, value: DateTime(2024, 5, 15)),
      );
      final years = tester.widget<WheelPicker<int>>(wheelOf('Year'));
      final count = years.itemCount;
      final first = years.itemBuilder!(0).value;
      await turn(tester, 'Year', 4);
      expect(reported.last.year, 2028);
      final after = tester.widget<WheelPicker<int>>(wheelOf('Year'));
      expect(after.itemCount, count);
      expect(after.itemBuilder!(0).value, first);
    });

    testWidgets('a locale with no date symbols loaded is written in English', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        wheels(
          reported: [],
          value: DateTime(2024, 5, 15),
          locale: const Locale('tlh'),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSemantics(wheelOf('Month')).value, 'May');
    });

    testWidgets('a day the month does not have is moved into it', (
      tester,
    ) async {
      final reported = <DateTime>[];
      await pumpFinesse(
        tester,
        wheels(reported: reported, value: DateTime(2024, 1, 31)),
      );
      await turn(tester, 'Month', 1);
      // 2024 is a leap year.
      expect(reported.last, DateTime(2024, 2, 29));
      await rest(tester);
      expect(tester.getSemantics(wheelOf('Day')).value, '29');
      // The 30th and 31st are dimmed rows the wheel will not rest on.
      await turn(tester, 'Day', 1);
      expect(reported.last, DateTime(2024, 2, 29));
    });

    testWidgets('dates outside the bounds cannot be rested on', (
      tester,
    ) async {
      final reported = <DateTime>[];
      await pumpFinesse(
        tester,
        wheels(
          reported: reported,
          value: DateTime(2024, 5, 15),
          min: DateTime(2024, 5, 10),
          max: DateTime(2024, 6, 20),
        ),
      );
      await turn(tester, 'Day', -8);
      expect(reported.last, DateTime(2024, 5, 10));
      // July is out of bounds: the months wheel comes back to June, and
      // the day is held to the last one allowed.
      await turn(tester, 'Day', 15);
      await turn(tester, 'Month', 2);
      expect(reported.last.month, 6);
      expect(reported.last.isAfter(DateTime(2024, 6, 20)), isFalse);
      // The years wheel has one row.
      await turn(tester, 'Year', 3);
      expect(reported.last.year, 2024);
    });

    testWidgets('monthYear has no day wheel and keeps the day', (
      tester,
    ) async {
      final reported = <DateTime>[];
      await pumpFinesse(
        tester,
        wheels(
          reported: reported,
          value: DateTime(2024, 5, 15),
          mode: DateWheelMode.monthYear,
        ),
      );
      expect(wheelOf('Day'), findsNothing);
      await turn(tester, 'Month', 2);
      expect(reported.last, DateTime(2024, 7, 15));
    });

    testWidgets('dateAndTime has a day wheel and the time wheels under one '
        'lens', (tester) async {
      final reported = <DateTime>[];
      await pumpFinesse(
        tester,
        wheels(
          reported: reported,
          value: DateTime(2024, 5, 15, 9, 30),
          mode: DateWheelMode.dateAndTime,
        ),
      );
      expect(find.byType(Glass), findsOneWidget);
      expect(tester.getSemantics(wheelOf('Day')).value, 'Wed 15 May');
      await turn(tester, 'Day', 3);
      expect(reported.last, DateTime(2024, 5, 18, 9, 30));
      await turn(tester, 'Hours', 2);
      expect(reported.last, DateTime(2024, 5, 18, 11, 30));
      await turn(tester, 'Minutes', -5);
      expect(reported.last, DateTime(2024, 5, 18, 11, 25));
    });

    testWidgets('dateAndTime bounds the time on the first day', (
      tester,
    ) async {
      final reported = <DateTime>[];
      final min = DateTime(2024, 5, 15, 9, 30);
      await pumpFinesse(
        tester,
        wheels(
          reported: reported,
          value: DateTime(2024, 5, 15, 12),
          mode: DateWheelMode.dateAndTime,
          min: min,
        ),
      );
      await turn(tester, 'Hours', -5);
      expect(reported.last.isBefore(min), isFalse);
      expect(reported.last.hour, 9);
      // Nothing before the first day.
      await turn(tester, 'Day', -2);
      expect(reported.last.day, 15);
    });

    testWidgets('the wheels follow the order the locale writes a date in', (
      tester,
    ) async {
      await tester.runAsync(() => initializeDateFormatting('en_GB'));
      await pumpFinesse(
        tester,
        wheels(
          reported: [],
          value: DateTime(2024, 5, 15),
          locale: const Locale('en', 'GB'),
        ),
      );
      final day = tester.getCenter(wheelOf('Day')).dx;
      final month = tester.getCenter(wheelOf('Month')).dx;
      final year = tester.getCenter(wheelOf('Year')).dx;
      expect(day, lessThan(month));
      expect(month, lessThan(year));
    });

    testWidgets('builds in every layout and at a doubled text scale', (
      tester,
    ) async {
      for (final mode in DateWheelMode.values) {
        await expectBuildsInEveryLayout(
          tester,
          (_) => wheels(
            reported: [],
            value: DateTime(2024, 9, 25, 14, 30),
            mode: mode,
          ),
        );
        await pumpFinesse(
          tester,
          MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(2),
            ),
            child: KeyedSubtree(
              key: ValueKey(mode),
              child: wheels(
                reported: [],
                value: DateTime(2024, 9, 25, 14, 30),
                mode: mode,
              ),
            ),
          ),
          formFactor: FormFactor.mobile,
        );
        expect(tester.takeException(), isNull, reason: mode.name);
      }
    });
  });
}
