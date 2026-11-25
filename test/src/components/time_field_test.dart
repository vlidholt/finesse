import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  Finder fields() => find.descendant(
    of: find.byType(TimeField),
    matching: find.byType(TextField),
  );

  String textOf(WidgetTester tester, int index) =>
      tester.widget<TextField>(fields().at(index)).controller!.text;

  group('TimeOfDay', () {
    test('knows its period and its hour on the 12-hour clock', () {
      const midnight = TimeOfDay(hour: 0, minute: 5);
      const noon = TimeOfDay(hour: 12, minute: 0);
      const evening = TimeOfDay(hour: 19, minute: 30, second: 15);
      expect(midnight.period, DayPeriod.am);
      expect(midnight.hourOfPeriod, 12);
      expect(noon.period, DayPeriod.pm);
      expect(noon.hourOfPeriod, 12);
      expect(evening.hourOfPeriod, 7);
      expect(evening.withPeriod(DayPeriod.am).hour, 7);
      expect(midnight.withPeriod(DayPeriod.pm).hour, 12);
      expect(evening.inSeconds, 19 * 3600 + 30 * 60 + 15);
      expect(TimeOfDay.fromSeconds(evening.inSeconds), evening);
      expect(TimeOfDay.fromSeconds(-60), const TimeOfDay(hour: 23, minute: 59));
    });

    test('orders and clamps', () {
      const a = TimeOfDay(hour: 9, minute: 0);
      const b = TimeOfDay(hour: 17, minute: 30);
      expect(a.isBefore(b), isTrue);
      expect(b.isAfter(a), isTrue);
      expect(a.compareTo(a), 0);
      expect(const TimeOfDay(hour: 7, minute: 0).clamp(a, b), a);
      expect(const TimeOfDay(hour: 22, minute: 0).clamp(a, b), b);
      expect(const TimeOfDay(hour: 12, minute: 0).clamp(a, b).hour, 12);
      expect(a, const TimeOfDay(hour: 9, minute: 0));
      expect(a.hashCode, const TimeOfDay(hour: 9, minute: 0).hashCode);
    });
  });

  group('uses24HourFormat', () {
    Future<bool> ask(
      WidgetTester tester,
      Locale locale, {
      bool always = false,
    }) async {
      late bool result;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(alwaysUse24HourFormat: always),
          child: Localizations(
            locale: locale,
            delegates: const [DefaultWidgetsLocalizations.delegate],
            child: Builder(
              builder: (context) {
                result = uses24HourFormat(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      return result;
    }

    testWidgets('follows the locale and the platform', (tester) async {
      expect(await ask(tester, const Locale('en', 'US')), isFalse);
      expect(await ask(tester, const Locale('en', 'GB')), isTrue);
      expect(await ask(tester, const Locale('sv')), isTrue);
      expect(await ask(tester, const Locale('hi')), isFalse);
      expect(await ask(tester, const Locale('en', 'US'), always: true), isTrue);
    });
  });

  group('TimeField', () {
    testWidgets('shows its value in two fields, three with seconds', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: TimeField(
            value: TimeOfDay(hour: 14, minute: 5, second: 9),
            use24HourFormat: true,
          ),
        ),
      );
      expect(fields(), findsNWidgets(2));
      expect(textOf(tester, 0), '14');
      expect(textOf(tester, 1), '05');
      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Minutes'), findsOneWidget);

      await pumpFinesse(
        tester,
        const Center(
          child: TimeField(
            value: TimeOfDay(hour: 14, minute: 5, second: 9),
            use24HourFormat: true,
            showSeconds: true,
            showLabels: false,
          ),
        ),
      );
      expect(fields(), findsNWidgets(3));
      expect(textOf(tester, 2), '09');
      expect(find.text('Hours'), findsNothing);
    });

    testWidgets('reports once every field is filled and moves the focus on', (
      tester,
    ) async {
      final reported = <TimeOfDay?>[];
      await pumpFinesse(
        tester,
        Center(
          child: TimeField(use24HourFormat: true, onChanged: reported.add),
        ),
      );
      await tester.tap(fields().first);
      await tester.pump();
      tester.testTextInput.enterText('09');
      await tester.pump();
      expect(reported, isEmpty);
      // Two digits: the focus is in the minutes now.
      tester.testTextInput.enterText('41');
      await tester.pump();
      expect(textOf(tester, 0), '09');
      expect(textOf(tester, 1), '41');
      expect(reported, [const TimeOfDay(hour: 9, minute: 41)]);
    });

    testWidgets('holds each field inside its range', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: TimeField(use24HourFormat: true)),
      );
      await tester.enterText(fields().at(0), '77');
      await tester.enterText(fields().at(1), '99');
      await tester.pump();
      expect(textOf(tester, 0), '23');
      expect(textOf(tester, 1), '59');
    });

    testWidgets('the 12-hour clock has a period and reports 24-hour times', (
      tester,
    ) async {
      final reported = <TimeOfDay?>[];
      await pumpFinesse(
        tester,
        Center(
          child: TimeField(
            initialValue: const TimeOfDay(hour: 15, minute: 20),
            use24HourFormat: false,
            onChanged: reported.add,
          ),
        ),
      );
      expect(textOf(tester, 0), '03');
      expect(find.text('PM'), findsOneWidget);
      await tester.enterText(fields().at(0), '12');
      await tester.pump();
      expect(reported.last, const TimeOfDay(hour: 12, minute: 20));
      await tester.enterText(fields().at(0), '7');
      await tester.pump();
      expect(reported.last, const TimeOfDay(hour: 19, minute: 20));
    });

    testWidgets('a new value from outside replaces what is typed', (
      tester,
    ) async {
      TimeOfDay? value = const TimeOfDay(hour: 8, minute: 0);
      late StateSetter rebuild;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Center(
              child: TimeField(
                value: value,
                use24HourFormat: true,
                onChanged: (v) => setState(() => value = v),
              ),
            );
          },
        ),
      );
      await tester.enterText(fields().at(1), '45');
      await tester.pump();
      expect(value, const TimeOfDay(hour: 8, minute: 45));
      rebuild(() => value = const TimeOfDay(hour: 21, minute: 10));
      await tester.pump();
      expect(textOf(tester, 0), '21');
      expect(textOf(tester, 1), '10');
      rebuild(() => value = null);
      await tester.pump();
      expect(textOf(tester, 0), '');
      expect(tester.takeException(), isNull);
    });

    testWidgets('emptying a field of a complete time reports null, and a '
        'field that does not show keeps its part', (tester) async {
      final reported = <TimeOfDay?>[];
      await pumpFinesse(
        tester,
        Center(
          child: TimeField(
            initialValue: const TimeOfDay(hour: 9, minute: 30, second: 15),
            use24HourFormat: true,
            onChanged: reported.add,
          ),
        ),
      );
      await tester.enterText(fields().at(1), '');
      await tester.pump();
      expect(reported, [null]);
      await tester.enterText(fields().at(1), '45');
      await tester.pump();
      expect(reported, [null, const TimeOfDay(hour: 9, minute: 45, second: 15)]);
    });

    testWidgets('a time outside its bounds is moved in when focus leaves', (
      tester,
    ) async {
      final reported = <TimeOfDay?>[];
      final other = FocusNode();
      addTearDown(other.dispose);
      await pumpFinesse(
        tester,
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TimeField(
                use24HourFormat: true,
                min: const TimeOfDay(hour: 9, minute: 0),
                max: const TimeOfDay(hour: 17, minute: 0),
                onChanged: reported.add,
              ),
              Button(
                focusNode: other,
                onPressed: () {},
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      );
      await tester.tap(fields().first);
      await tester.pump();
      tester.testTextInput.enterText('06');
      await tester.pump();
      tester.testTextInput.enterText('30');
      await tester.pump();
      // While it is being typed the time is left alone.
      expect(reported.last, const TimeOfDay(hour: 6, minute: 30));
      other.requestFocus();
      await tester.pump();
      expect(textOf(tester, 0), '09');
      expect(textOf(tester, 1), '00');
      expect(reported.last, const TimeOfDay(hour: 9, minute: 0));
    });

    testWidgets('hours, minutes, seconds stay in that order in RTL', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: TimeField(
            value: TimeOfDay(hour: 1, minute: 2, second: 3),
            use24HourFormat: true,
            showSeconds: true,
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      final xs = [
        for (var i = 0; i < 3; i++) tester.getCenter(fields().at(i)).dx,
      ];
      expect(xs[0], lessThan(xs[1]));
      expect(xs[1], lessThan(xs[2]));
      expect(textOf(tester, 0), '01');
    });

    testWidgets('a field is as tall as a text field and grows with the scale', (
      tester,
    ) async {
      for (final formFactor in FormFactor.values) {
        await pumpFinesse(
          tester,
          const Center(child: TimeField(use24HourFormat: true)),
          formFactor: formFactor,
        );
        final theme = themeOf(tester, find.byType(TimeField));
        expect(tester.getSize(fields().first).height, theme.style.inputHeight);
      }
      await pumpFinesse(
        tester,
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Center(child: TimeField(use24HourFormat: true)),
        ),
      );
      expect(tester.getSize(fields().first).width, 96);
      expect(tester.takeException(), isNull);
    });

    testWidgets('every field has a name, shown or not, and is one node', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      for (final showLabels in [true, false]) {
        await pumpFinesse(
          tester,
          Center(
            child: TimeField(
              use24HourFormat: true,
              showSeconds: true,
              showLabels: showLabels,
            ),
          ),
        );
        for (final name in ['Hours', 'Minutes', 'Seconds']) {
          // The label is the text field's name, not a node of its own
          // beside a nameless field.
          final node = find.bySemanticsLabel(RegExp('^$name'));
          expect(node, findsOneWidget, reason: '$name, labels $showLabels');
          expect(
            tester
                .getSemantics(node)
                .getSemanticsData()
                .flagsCollection
                .isTextField,
            isTrue,
            reason: '$name, labels $showLabels',
          );
        }
      }
      handle.dispose();
    });

    testWidgets('leading and trailing are centred on the fields, not on the '
        'fields and their names', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: TimeField(
            use24HourFormat: true,
            leading: Text('From'),
            trailing: Text('UTC'),
          ),
        ),
      );
      final field = tester.getCenter(fields().first).dy;
      expect(tester.getCenter(find.text('From')).dy, closeTo(field, .5));
      expect(tester.getCenter(find.text('UTC')).dy, closeTo(field, .5));
      // And the names still stand above their fields.
      expect(
        tester.getBottomLeft(find.text('Hours')).dy,
        lessThanOrEqualTo(tester.getTopLeft(fields().first).dy),
      );
    });

    testWidgets('disabled fields take no text', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: TimeField(use24HourFormat: true, enabled: false)),
      );
      expect(tester.widget<TextField>(fields().first).enabled, isFalse);
    });

    testWidgets('builds in every layout, both clocks', (tester) async {
      for (final twentyFour in [true, false]) {
        await expectBuildsInEveryLayout(
          tester,
          (_) => Center(
            child: TimeField(
              use24HourFormat: twentyFour,
              showSeconds: true,
              value: const TimeOfDay(hour: 9, minute: 5),
            ),
          ),
        );
      }
    });

    testWidgets('matches goldens', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: TimeField(use24HourFormat: true)),
      );
      await expectLater(
        find.byType(TimeField),
        matchesGoldenFile('goldens/time_field.png'),
      );
    });
  });

  group('TimeFormField', () {
    testWidgets('a value the form sets is written into the fields', (
      tester,
    ) async {
      final formKey = GlobalKey<FinesseFormState>();
      await pumpFinesse(
        tester,
        Center(
          child: FinesseForm(
            key: formKey,
            child: TimeFormField(id: 'start', use24HourFormat: true),
          ),
        ),
      );
      formKey.currentState!.setValue({
        'start': const TimeOfDay(hour: 9, minute: 30),
      });
      await tester.pump();
      expect(textOf(tester, 0), '09');
      expect(textOf(tester, 1), '30');
    });

    testWidgets('emptied, its value is null and a required time fails', (
      tester,
    ) async {
      final formKey = GlobalKey<FinesseFormState>();
      await pumpFinesse(
        tester,
        Center(
          child: FinesseForm(
            key: formKey,
            child: TimeFormField(
              id: 'start',
              use24HourFormat: true,
              initialValue: const TimeOfDay(hour: 9, minute: 30),
              validator: (v) => v == null ? 'Enter a time' : null,
            ),
          ),
        ),
      );
      await tester.enterText(fields().at(0), '');
      await tester.enterText(fields().at(1), '');
      await tester.pump();
      expect(textOf(tester, 0), '');
      expect(textOf(tester, 1), '');
      expect(formKey.currentState!.value['start'], isNull);
      expect(formKey.currentState!.validate(), isFalse);
    });


    testWidgets('validates, saves and resets', (tester) async {
      final formKey = GlobalKey<FinesseFormState>();
      await pumpFinesse(
        tester,
        Center(
          child: FinesseForm(
            key: formKey,
            child: TimeFormField(
              id: 'start',
              use24HourFormat: true,
              initialValue: const TimeOfDay(hour: 8, minute: 15),
              validator: (v) => v == null
                  ? 'Enter a time'
                  : v.hour < 9
                  ? 'Too early'
                  : null,
            ),
          ),
        ),
      );
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Too early'), findsOneWidget);
      await tester.enterText(fields().at(0), '10');
      await tester.pump();
      expect(formKey.currentState!.saveAndValidate(), isTrue);
      expect(
        formKey.currentState!.value['start'],
        const TimeOfDay(hour: 10, minute: 15),
      );
      formKey.currentState!.reset();
      await tester.pump();
      expect(textOf(tester, 0), '08');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    });
  });
}
