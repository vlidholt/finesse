import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/src/components/picker.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

class _Host extends StatefulWidget {
  const _Host({
    this.initial,
    this.presentation = PickerPresentation.auto,
    this.mode = DatePickerMode.calendar,
    this.closeOnSelection,
    this.allowDeselection,
    this.min,
    this.max,
    super.key,
  });

  final DateTime? initial;
  final PickerPresentation presentation;
  final DatePickerMode mode;
  final bool? closeOnSelection;
  final bool? allowDeselection;
  final DateTime? min;
  final DateTime? max;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late DateTime? value = widget.initial;
  final changes = <DateTime?>[];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DatePicker(
        value: value,
        presentation: widget.presentation,
        mode: widget.mode,
        closeOnSelection: widget.closeOnSelection,
        allowDeselection: widget.allowDeselection,
        min: widget.min,
        max: widget.max,
        // One glyph a cell: the test font is an em wide per glyph.
        calendarTheme: const CalendarTheme(
          dayButtonTextStyle: TextStyle(fontSize: 8),
          selectedDayButtonTextStyle: TextStyle(fontSize: 8),
          dayButtonOutsideMonthTextStyle: TextStyle(fontSize: 8),
        ),
        onChanged: (v) {
          changes.add(v);
          setState(() => value = v);
        },
      ),
    );
  }
}

class _RangeHost extends StatefulWidget {
  const _RangeHost({this.initial});

  final DateTimeRange? initial;

  @override
  State<_RangeHost> createState() => _RangeHostState();
}

class _RangeHostState extends State<_RangeHost> {
  late DateTimeRange? value = widget.initial;
  final changes = <DateTimeRange?>[];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DateRangePicker(
        value: value,
        calendarTheme: const CalendarTheme(
          dayButtonTextStyle: TextStyle(fontSize: 8),
          selectedDayButtonTextStyle: TextStyle(fontSize: 8),
          insideRangeDayButtonTextStyle: TextStyle(fontSize: 8),
          dayButtonOutsideMonthTextStyle: TextStyle(fontSize: 8),
        ),
        onChanged: (v) {
          changes.add(v);
          setState(() => value = v);
        },
      ),
    );
  }
}

void main() {
  _HostState host(WidgetTester tester) => tester.state(find.byType(_Host));
  _RangeHostState rangeHost(WidgetTester tester) =>
      tester.state(find.byType(_RangeHost));

  Future<void> rest(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(PickerTrigger).first);
    await rest(tester);
  }

  /// The button of day [day] of the month shown.
  Finder dayOf(int day) => find.descendant(
    of: find.byType(Calendar),
    matching: find.widgetWithText(Button, '$day'),
  );

  final may = DateTime(2024, 5, 15);

  group('DatePickerTheme', () {
    test('a field that closes on a choice', () {
      final picker = ThemeData().datePickerTheme;
      expect(picker.buttonVariant, isNull);
      expect(picker.width, 276);
      expect(picker.closeOnSelection, isTrue);
      expect(picker.allowDeselection, isTrue);
    });
  });

  group('the trigger', () {
    Widget form({ButtonVariant? variant, DateTime? value}) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(controller: TextEditingController(text: 'Typed')),
        DatePicker(
          value: value,
          onChanged: (_) {},
          variant: variant,
          expands: true,
        ),
      ],
    );

    for (final (name, style) in [
      ('una', StyleTokens.una),
      ('nova', StyleTokens.nova),
      ('maia', StyleTokens.maia),
      ('lyra', StyleTokens.lyra),
    ]) {
      testWidgets('$name: is a field among fields, a value as a field '
          'value and a placeholder as a field placeholder', (tester) async {
        for (final formFactor in FormFactor.values) {
          final theme = ThemeData(style: style);
          await pumpUna(
            tester,
            Center(
              child: SizedBox(width: 320, child: form(value: may)),
            ),
            theme: theme,
            formFactor: formFactor,
          );
          final resolved = themeOf(tester, find.byType(DatePicker));
          final field = tester.getSize(find.byType(TextField));
          final trigger = tester.getSize(find.byType(PickerTrigger));
          expect(trigger.height, field.height, reason: '$formFactor');
          expect(trigger.height, resolved.style.inputHeight);
          expect(trigger.width, field.width);
          expect(find.byType(Button), findsNothing);
          final typed = tester
              .widget<EditableText>(find.byType(EditableText))
              .style;
          final value = tester
              .renderObject<RenderParagraph>(find.text('May 15th, 2024'))
              .text
              .style!;
          expect(value.fontSize, typed.fontSize);
          expect(value.color, resolved.colorScheme.foreground);

          await tester.pumpWidget(const SizedBox.shrink());
          await pumpUna(
            tester,
            Center(child: SizedBox(width: 320, child: form())),
            theme: theme,
            formFactor: formFactor,
          );
          final placeholder = tester
              .renderObject<RenderParagraph>(find.text('Select date'))
              .text
              .style!;
          expect(placeholder.fontSize, typed.fontSize);
          expect(placeholder.color, resolved.colorScheme.mutedForeground);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        }
      });
    }

    testWidgets('a variant makes it that button', (tester) async {
      await pumpUna(
        tester,
        Center(child: form(variant: ButtonVariant.outline)),
      );
      final button = tester.widget<Button>(
        find.descendant(
          of: find.byType(PickerTrigger),
          matching: find.byType(Button),
        ),
      );
      expect(button.variant, ButtonVariant.outline);
      await open(tester);
      expect(find.byType(Calendar), findsOneWidget);
    });

    testWidgets('the field is one button node, named by what it shows, '
        'and opens from the keyboard', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, Center(child: form(value: may)));
      final node = find.bySemanticsLabel(RegExp('May 15th, 2024'));
      expect(node, findsOneWidget);
      final data = tester.getSemantics(node).getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      handle.dispose();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await rest(tester);
      expect(find.byType(Calendar), findsOneWidget);
    });

    testWidgets('disabled, it does not open', (tester) async {
      await pumpUna(
        tester,
        const Center(child: DatePicker(value: null, onChanged: null)),
      );
      await tester.tap(find.byType(PickerTrigger), warnIfMissed: false);
      await rest(tester);
      expect(find.byType(Calendar), findsNothing);
    });
  });

  group('DatePicker', () {
    testWidgets('shows the placeholder, then the date', (tester) async {
      await pumpUna(tester, const _Host());
      expect(find.text('Select date'), findsOneWidget);
      await pumpUna(tester, _Host(key: const ValueKey(1), initial: may));
      expect(find.text('May 15th, 2024'), findsOneWidget);
    });

    testWidgets('on a desktop a tap on a day reports it and closes the '
        'popover', (tester) async {
      await pumpUna(tester, _Host(initial: may));
      await open(tester);
      expect(find.byType(Calendar), findsOneWidget);
      expect(find.byType(Sheet), findsNothing);
      await tester.tap(dayOf(20).first);
      await rest(tester);
      expect(host(tester).changes, [DateTime(2024, 5, 20)]);
      expect(find.byType(Calendar), findsNothing);
      expect(find.text('May 20th, 2024'), findsOneWidget);
    });

    testWidgets('closeOnSelection false keeps the popover open', (
      tester,
    ) async {
      await pumpUna(tester, _Host(initial: may, closeOnSelection: false));
      await open(tester);
      await tester.tap(dayOf(20).first);
      await rest(tester);
      expect(host(tester).value, DateTime(2024, 5, 20));
      expect(find.byType(Calendar), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await rest(tester);
      expect(find.byType(Calendar), findsNothing);
    });

    testWidgets('tapping the selected day clears it, unless told not to', (
      tester,
    ) async {
      await pumpUna(tester, _Host(initial: may));
      await open(tester);
      await tester.tap(dayOf(15).first);
      await rest(tester);
      expect(host(tester).changes, [null]);

      await pumpUna(
        tester,
        _Host(key: const ValueKey(2), initial: may, allowDeselection: false),
      );
      await open(tester);
      await tester.tap(dayOf(15).first);
      await rest(tester);
      expect(host(tester).value, may);
    });

    testWidgets('days outside the bounds cannot be chosen', (tester) async {
      await pumpUna(
        tester,
        _Host(
          initial: may,
          min: DateTime(2024, 5, 10),
          max: DateTime(2024, 5, 20),
        ),
      );
      await open(tester);
      expect(tester.widget<Button>(dayOf(9).first).enabled, isFalse);
      expect(tester.widget<Button>(dayOf(10).first).enabled, isTrue);
      expect(tester.widget<Button>(dayOf(20).first).enabled, isTrue);
      expect(tester.widget<Button>(dayOf(21).first).enabled, isFalse);
      // Nor can the calendar leave their months.
      for (final button in tester.widgetList<IconButton>(
        find.descendant(
          of: find.byType(Calendar),
          matching: find.byType(IconButton),
        ),
      )) {
        expect(button.enabled, isFalse);
      }
    });

    testWidgets('on a phone the calendar fills a sheet and a tap chooses', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _Host(initial: may),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      expect(find.byType(Sheet), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Sheet),
          matching: find.text('Select date'),
        ),
        findsOneWidget,
      );
      // Seven cells across the sheet's content: larger than the theme's,
      // and touch targets.
      final theme = themeOf(tester, find.byType(Calendar));
      final cell = tester.getSize(dayOf(20).first);
      expect(cell.width, cell.height);
      expect(cell.width, greaterThan(theme.calendarTheme.dayButtonSize!));
      expect(cell.width, greaterThanOrEqualTo(44));
      expect(tester.getSize(find.byType(Calendar)).width, cell.width * 7);
      // A tap is the choice: there is no Done.
      expect(find.widgetWithText(Button, 'Done'), findsNothing);
      await tester.tap(dayOf(20).first);
      await rest(tester);
      expect(host(tester).changes, [DateTime(2024, 5, 20)]);
      expect(find.byType(Sheet), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the sheet has Cancel and Clear', (tester) async {
      await pumpUna(
        tester,
        _Host(initial: may),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      await tester.tap(find.widgetWithText(Button, 'Cancel'));
      await rest(tester);
      expect(find.byType(Sheet), findsNothing);
      expect(host(tester).changes, isEmpty);
      await open(tester);
      await tester.tap(find.widgetWithText(Button, 'Clear'));
      await rest(tester);
      expect(host(tester).changes, [null]);
      // Nothing to clear now.
      await open(tester);
      expect(find.widgetWithText(Button, 'Clear'), findsNothing);
    });

    testWidgets('closeOnSelection false makes the sheet a draft with Done', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _Host(initial: may, closeOnSelection: false),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      await tester.tap(dayOf(20).first);
      await rest(tester);
      expect(host(tester).changes, isEmpty);
      expect(find.byType(Sheet), findsOneWidget);
      await tester.tap(find.widgetWithText(Button, 'Done'));
      await rest(tester);
      expect(host(tester).changes, [DateTime(2024, 5, 20)]);
    });

    testWidgets('wheel mode: a sheet of wheels that Done reports', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _Host(initial: may, mode: DatePickerMode.wheel),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      expect(find.byType(DateWheelPicker), findsOneWidget);
      expect(find.byType(Calendar), findsNothing);
      final wheel = find.byWidgetPredicate(
        (w) => w is WheelPicker && w.semanticLabel == 'Day',
      );
      final extent = themeOf(tester, wheel).wheelPickerTheme.itemExtent!;
      final gesture = await tester.startGesture(tester.getCenter(wheel));
      await gesture.moveBy(const Offset(0, -20));
      for (var i = 0; i < 12; i++) {
        await gesture.moveBy(Offset(0, -extent * 3 / 12));
        await tester.pump(const Duration(milliseconds: 8));
      }
      await gesture.up();
      await rest(tester);
      expect(host(tester).changes, isEmpty);
      await tester.tap(find.widgetWithText(Button, 'Done'));
      await rest(tester);
      expect(host(tester).changes, [DateTime(2024, 5, 18)]);
    });

    testWidgets('wheel mode in a popover takes the date as the wheels turn', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _Host(initial: may, mode: DatePickerMode.wheel),
      );
      await open(tester);
      expect(find.byType(DateWheelPicker), findsOneWidget);
      expect(find.byType(Sheet), findsNothing);
      final wheel = find.byWidgetPredicate(
        (w) => w is WheelPicker && w.semanticLabel == 'Day',
      );
      await tester.tap(wheel, kind: PointerDeviceKind.mouse);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await rest(tester);
      expect(host(tester).value, DateTime(2024, 5, 16));
    });

    testWidgets('presentation forces either one', (tester) async {
      await pumpUna(
        tester,
        _Host(initial: may, presentation: PickerPresentation.sheet),
      );
      await open(tester);
      expect(find.byType(Sheet), findsOneWidget);
      // On a wide screen the sheet's content is held to a readable width.
      expect(
        tester.getSize(find.byType(Calendar)).width,
        lessThanOrEqualTo(420),
      );
      await tester.tap(find.widgetWithText(Button, 'Cancel'));
      await rest(tester);

      await pumpUna(
        tester,
        _Host(
          key: const ValueKey(2),
          initial: may,
          presentation: PickerPresentation.popover,
        ),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      expect(find.byType(Sheet), findsNothing);
      expect(find.byType(Calendar), findsOneWidget);
    });

    testWidgets('builds in every layout, open and closed', (tester) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => _Host(initial: may),
        check: (layout) async {
          await open(tester);
          expect(tester.takeException(), isNull);
          if (layout.formFactor == FormFactor.mobile) {
            await tester.tap(find.widgetWithText(Button, 'Cancel'));
          } else {
            await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          }
          await rest(tester);
        },
      );
    });

    testWidgets('matches goldens', (tester) async {
      await pumpUna(
        tester,
        Center(child: DatePicker(value: null, onChanged: (_) {})),
      );
      await expectLater(
        find.byType(DatePicker),
        matchesGoldenFile('goldens/date_picker.png'),
      );
    });
  });

  group('DateRangePicker', () {
    testWidgets('shows the placeholder, then the range', (tester) async {
      await pumpUna(tester, const _RangeHost());
      expect(find.text('Select dates'), findsOneWidget);
      await pumpUna(
        tester,
        KeyedSubtree(
          key: const ValueKey(1),
          child: _RangeHost(
            initial: DateTimeRange(
              start: DateTime(2024, 5, 10),
              end: DateTime(2024, 5, 16),
            ),
          ),
        ),
      );
      expect(find.text('May 10, 2024 - May 16, 2024'), findsOneWidget);
    });

    testWidgets('in a popover each tap is reported and the second closes it', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _RangeHost(initial: DateTimeRange(start: may)),
      );
      await open(tester);
      await tester.tap(dayOf(22).first);
      await rest(tester);
      expect(
        rangeHost(tester).changes.single,
        DateTimeRange(start: may, end: DateTime(2024, 5, 22)),
      );
      expect(find.byType(Calendar), findsNothing);
    });

    testWidgets('in a sheet the range is a draft that Done reports', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _RangeHost(initial: DateTimeRange(start: may)),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      expect(find.byType(Sheet), findsOneWidget);
      await tester.tap(dayOf(22).first);
      await rest(tester);
      expect(rangeHost(tester).changes, isEmpty);
      expect(find.byType(Sheet), findsOneWidget);
      await tester.tap(find.widgetWithText(Button, 'Done'));
      await rest(tester);
      expect(
        rangeHost(tester).changes.single,
        DateTimeRange(start: may, end: DateTime(2024, 5, 22)),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('form fields', () {
    testWidgets('DatePickerFormField validates and saves', (tester) async {
      final formKey = GlobalKey<UnaFormState>();
      await pumpUna(
        tester,
        Center(
          child: UnaForm(
            key: formKey,
            child: DatePickerFormField(
              id: 'due',
              validator: (v) => v == null ? 'Pick a date' : null,
              calendarTheme: const CalendarTheme(
                dayButtonTextStyle: TextStyle(fontSize: 8),
                dayButtonOutsideMonthTextStyle: TextStyle(fontSize: 8),
              ),
            ),
          ),
        ),
      );
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Pick a date'), findsOneWidget);
      // The failed validation put the focus on the button.
      final focus = FocusManager.instance.primaryFocus!;
      expect(focus.context, isNotNull);
      await open(tester);
      await tester.tap(dayOf(12).first);
      await rest(tester);
      expect(formKey.currentState!.saveAndValidate(), isTrue);
      expect((formKey.currentState!.value['due'] as DateTime).day, 12);
    });

    testWidgets('DateRangePickerFormField holds a range', (tester) async {
      final formKey = GlobalKey<UnaFormState>();
      await pumpUna(
        tester,
        Center(
          child: UnaForm(
            key: formKey,
            child: DateRangePickerFormField(
              id: 'stay',
              initialValue: DateTimeRange(
                start: DateTime(2024, 5, 10),
                end: DateTime(2024, 5, 16),
              ),
            ),
          ),
        ),
      );
      expect(find.text('May 10, 2024 - May 16, 2024'), findsOneWidget);
      expect(formKey.currentState!.saveAndValidate(), isTrue);
      expect(
        formKey.currentState!.value['stay'],
        DateTimeRange(
          start: DateTime(2024, 5, 10),
          end: DateTime(2024, 5, 16),
        ),
      );
    });
  });
}
