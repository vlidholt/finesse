import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../finesse_harness.dart';

/// [child] in [locale], whatever the app's is.
Widget inLocale(Locale locale, Widget child) => Builder(
  builder: (context) =>
      Localizations.override(context: context, locale: locale, child: child),
);

void main() {
  late List<DateTime?> changes;

  setUp(() => changes = []);

  Widget field({
    DateTime? initialValue,
    DateTime? min,
    DateTime? max,
    bool showLabels = true,
    bool showCalendarButton = true,
    bool enabled = true,
    Locale locale = const Locale('en', 'GB'),
  }) {
    return inLocale(
      locale,
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DateField(
              initialValue: initialValue,
              min: min,
              max: max,
              showLabels: showLabels,
              showCalendarButton: showCalendarButton,
              enabled: enabled,
              onChanged: changes.add,
            ),
            // Somewhere else for the focus to go.
            Button(onPressed: () {}, child: const Text('Next')),
          ],
        ),
      ),
    );
  }

  /// The three fields' texts as shown, in their order on screen.
  List<String> shown(WidgetTester tester) => [
    for (final element in find.byType(EditableText).evaluate())
      (element.widget as EditableText).controller
          .buildTextSpan(context: element, withComposing: false)
          .toPlainText(),
  ];

  Finder part(int index) => find.byType(EditableText).at(index);

  Future<void> type(WidgetTester tester, int index, String text) async {
    await tester.showKeyboard(part(index));
    tester.testTextInput.enterText(text);
    await tester.pump();
  }

  Future<void> blur(WidgetTester tester) async {
    Focus.of(tester.element(find.text('Next'))).requestFocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  int focusedPart(WidgetTester tester) {
    final focus = FocusManager.instance.primaryFocus;
    final fields = find.byType(EditableText).evaluate().toList();
    for (var i = 0; i < fields.length; i++) {
      if ((fields[i].widget as EditableText).focusNode == focus) return i;
    }
    return -1;
  }

  group('DateField', () {
    testWidgets('builds in every layout at twice the text size', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Center(child: DateField(initialValue: DateTime(2026, 11, 25))),
        ),
      );
    });

    testWidgets('shows the date in the order the locale writes it, a day '
        'and a month with two digits', (tester) async {
      await pumpFinesse(tester, field(initialValue: DateTime(2026, 3, 5)));
      expect(shown(tester), ['05', '03', '2026']);
      expect(find.text('Day'), findsOneWidget);
      // Day, month, year from left to right.
      expect(
        tester.getCenter(find.text('Day')).dx,
        lessThan(tester.getCenter(find.text('Month')).dx),
      );

      await pumpFinesse(tester, const SizedBox());
      await pumpFinesse(
        tester,
        field(
          initialValue: DateTime(2026, 3, 5),
          locale: const Locale('en', 'US'),
        ),
      );
      expect(shown(tester), ['03', '05', '2026']);
      expect(
        tester.getCenter(find.text('Month')).dx,
        lessThan(tester.getCenter(find.text('Day')).dx),
      );
    });

    testWidgets('right to left, the digits keep their order and what is '
        'beside them moves to the other ends', (tester) async {
      await pumpFinesse(
        tester,
        inLocale(
          const Locale('en', 'GB'),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: DateField(
                initialValue: DateTime(2026, 3, 5),
                leading: const Text('From'),
              ),
            ),
          ),
        ),
      );
      double x(Finder finder) => tester.getCenter(finder).dx;
      expect(x(find.text('Day')), lessThan(x(find.text('Month'))));
      expect(x(find.text('Year')), greaterThan(x(find.byType(IconButton))));
      expect(x(find.text('From')), greaterThan(x(find.text('Year'))));
    });

    testWidgets('each field is a text field in looks: as tall as one, with '
        'digits of one width', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DateField(showLabels: false),
              SizedBox(width: 200, child: TextField()),
            ],
          ),
        ),
      );
      final heights = {
        for (final element in find.byType(TextField).evaluate())
          element.size!.height,
      };
      expect(heights, hasLength(1));
      final style = tester.widget<EditableText>(part(0)).style;
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
      // A year's field is wider than a day's.
      expect(
        tester.getSize(find.byType(TextField).at(2)).width,
        greaterThan(tester.getSize(find.byType(TextField).at(0)).width),
      );
    });

    testWidgets('typing fills a field and moves on, and the date is '
        'reported once all three spell one', (tester) async {
      await pumpFinesse(tester, field());
      await type(tester, 0, '2');
      expect(focusedPart(tester), 0);
      await type(tester, 0, '25');
      expect(focusedPart(tester), 1);
      await type(tester, 1, '1');
      expect(focusedPart(tester), 1);
      await type(tester, 1, '11');
      expect(focusedPart(tester), 2);
      expect(changes, isEmpty);
      await type(tester, 2, '202');
      expect(changes, isEmpty);
      await type(tester, 2, '2026');
      expect(changes, [DateTime(2026, 11, 25)]);
      expect(shown(tester), ['25', '11', '2026']);
    });

    testWidgets('a digit that no other can follow fills its field alone', (
      tester,
    ) async {
      await pumpFinesse(tester, field());
      await type(tester, 0, '7');
      expect(focusedPart(tester), 1);
      await type(tester, 1, '4');
      expect(focusedPart(tester), 2);
      expect(shown(tester).take(2), ['07', '04']);
    });

    testWidgets('emptying a field of a complete date reports null', (
      tester,
    ) async {
      await pumpFinesse(tester, field(initialValue: DateTime(2026, 11, 25)));
      await type(tester, 1, '');
      expect(changes, [null]);
    });

    testWidgets('the up and down arrows step the focused field and wrap; '
        'left and right move between fields', (tester) async {
      await pumpFinesse(tester, field(initialValue: DateTime(2026, 12, 31)));
      await tester.showKeyboard(part(0));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      // The 31st of December steps to the 1st.
      expect(shown(tester), ['01', '12', '2026']);
      expect(changes.last, DateTime(2026, 12));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedPart(tester), 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(shown(tester), ['01', '01', '2026']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(shown(tester), ['01', '11', '2026']);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(changes.last, DateTime(2027, 11));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(focusedPart(tester), 0);
    });

    testWidgets('an arrow in an empty field starts from today', (tester) async {
      await pumpFinesse(tester, field());
      await tester.showKeyboard(part(2));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(shown(tester).last, '${DateTime.now().year}');
    });

    testWidgets('when the focus leaves, a day the month does not have '
        'becomes its last, and a short year gets its century', (tester) async {
      await pumpFinesse(tester, field());
      await type(tester, 0, '31');
      await type(tester, 1, '02');
      await type(tester, 2, '24');
      expect(changes, isEmpty);
      await blur(tester);
      expect(shown(tester), ['29', '02', '2024']);
      expect(changes, [DateTime(2024, 2, 29)]);
    });

    testWidgets('a date outside min and max is moved inside when the focus '
        'leaves', (tester) async {
      await pumpFinesse(
        tester,
        field(
          initialValue: DateTime(2026, 6, 15),
          min: DateTime(2026, 6, 10),
          max: DateTime(2026, 6, 20),
        ),
      );
      await type(tester, 0, '28');
      expect(changes.last, DateTime(2026, 6, 28));
      await blur(tester);
      expect(shown(tester), ['20', '06', '2026']);
      expect(changes.last, DateTime(2026, 6, 20));
    });

    testWidgets('a new value from outside is written into the fields, and '
        'null empties them', (tester) async {
      DateTime? value = DateTime(2026, 1, 2);
      late StateSetter rebuild;
      await pumpFinesse(
        tester,
        inLocale(
          const Locale('en', 'GB'),
          Center(
            child: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return DateField(value: value, onChanged: changes.add);
              },
            ),
          ),
        ),
      );
      expect(shown(tester), ['02', '01', '2026']);
      rebuild(() => value = DateTime(2030, 12, 24));
      await tester.pump();
      expect(shown(tester), ['24', '12', '2030']);
      rebuild(() => value = null);
      await tester.pump();
      expect(shown(tester), ['', '', '']);
      expect(changes, isEmpty);
    });

    testWidgets('the calendar button opens a calendar on the date, and a '
        'day picked there is written into the fields', (tester) async {
      await tester.runAsync(() => initializeDateFormatting('en_GB'));
      await pumpFinesse(tester, field(initialValue: DateTime(2026, 11, 25)));
      await tester.tap(find.byType(IconButton));
      for (var i = 0; i < 14; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.byType(Calendar), findsOneWidget);
      expect(find.text('November 2026'), findsOneWidget);
      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();
      expect(changes, [DateTime(2026, 11, 12)]);
      expect(shown(tester), ['12', '11', '2026']);
    });

    testWidgets('without the calendar button it is three fields', (
      tester,
    ) async {
      await pumpFinesse(tester, field(showCalendarButton: false));
      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('disabled, nothing can be typed, stepped or picked', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        field(initialValue: DateTime(2026, 11, 25), enabled: false),
      );
      for (final widget in tester.widgetList<TextField>(
        find.byType(TextField),
      )) {
        expect(widget.enabled, isFalse);
      }
      await tester.tap(find.byType(IconButton), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(Calendar), findsNothing);
      expect(changes, isEmpty);
    });

    testWidgets('every field has a name, shown or not, and the button says '
        'what it opens', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, field(showLabels: false));
      expect(find.text('Day'), findsNothing);
      // Each field is one node, named, that takes text.
      for (final name in ['Day', 'Month', 'Year']) {
        final node = find.bySemanticsLabel(RegExp('^$name'));
        expect(node, findsOneWidget);
        expect(
          tester
              .getSemantics(node)
              .getSemanticsData()
              .flagsCollection
              .isTextField,
          isTrue,
        );
      }
      expect(find.bySemanticsLabel('Select date'), findsOneWidget);
      // The placeholders spell the order out.
      expect(find.text('DD'), findsOneWidget);
      expect(find.text('YYYY'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('at rest it schedules nothing', (tester) async {
      await pumpFinesse(tester, field(initialValue: DateTime(2026, 11, 25)));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });

  group('DateFormField', () {
    testWidgets('its value is the date, null until the fields spell one; '
        'validation focuses the first field and a reset restores it', (
      tester,
    ) async {
      final form = GlobalKey<FinesseFormState>();
      await pumpFinesse(
        tester,
        inLocale(
          const Locale('en', 'GB'),
          Center(
            child: FinesseForm(
              key: form,
              child: DateFormField(
                id: 'born',
                label: const Text('Date of birth'),
                validator: (date) => date == null ? 'Enter a date' : null,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Date of birth'), findsOneWidget);
      // The form field is labelled; the parts are named for assistive
      // technology only.
      expect(find.text('Day'), findsNothing);

      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter a date'), findsOneWidget);
      expect(focusedPart(tester), 0);

      await type(tester, 0, '02');
      await type(tester, 1, '04');
      await type(tester, 2, '1990');
      form.currentState!.save();
      expect(form.currentState!.value['born'], DateTime(1990, 4, 2));
      expect(form.currentState!.validate(), isTrue);

      form.currentState!.reset();
      await tester.pump();
      expect(shown(tester), ['', '', '']);
      form.currentState!.save();
      expect(form.currentState!.value['born'], isNull);
    });
  });
}
