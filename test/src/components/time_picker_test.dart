import 'package:finesse/finesse.dart';
import 'package:finesse/src/components/picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// A time picker that holds its own value, as most parents do.
class _Host extends StatefulWidget {
  const _Host({
    this.initial,
    this.presentation = PickerPresentation.auto,
    this.allowClear = false,
    this.minuteInterval = 1,
    this.use24HourFormat = true,
    this.controller,
    this.triggerBuilder,
    super.key,
  });

  final TimeOfDay? initial;
  final PickerPresentation presentation;
  final bool allowClear;
  final int minuteInterval;
  final bool use24HourFormat;
  final PopoverController? controller;
  final PickerTriggerBuilder<TimeOfDay?>? triggerBuilder;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late TimeOfDay? value = widget.initial;
  final changes = <TimeOfDay?>[];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TimePicker(
        value: value,
        presentation: widget.presentation,
        allowClear: widget.allowClear,
        minuteInterval: widget.minuteInterval,
        use24HourFormat: widget.use24HourFormat,
        controller: widget.controller,
        triggerBuilder: widget.triggerBuilder,
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

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(PickerTrigger).first);
    for (var i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> rest(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Finder wheelOf(String label) => find.byWidgetPredicate(
    (w) => w is WheelPicker && w.semanticLabel == label,
  );

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

  group('TimePickerTheme', () {
    test('is a field', () {
      expect(ThemeData().timePickerTheme.buttonVariant, isNull);
      expect(ThemeData().timePickerTheme.sheetWheelItems, 5);
    });
  });

  group('formatTimeOfDay', () {
    testWidgets('writes both clocks', (tester) async {
      await pumpFinesse(tester, const SizedBox());
      final context = tester.element(find.byType(SizedBox).last);
      const time = TimeOfDay(hour: 14, minute: 5, second: 9);
      expect(formatTimeOfDay(context, time, use24HourFormat: true), '14:05');
      expect(formatTimeOfDay(context, time, use24HourFormat: false), '2:05 PM');
      expect(
        formatTimeOfDay(
          context,
          time,
          use24HourFormat: true,
          showSeconds: true,
        ),
        '14:05:09',
      );
      expect(
        formatTimeOfDay(
          context,
          const TimeOfDay(hour: 0, minute: 30),
          use24HourFormat: false,
        ),
        '12:30 AM',
      );
    });
  });

  group('TimePicker', () {
    testWidgets('shows the placeholder, then the time', (tester) async {
      await pumpFinesse(tester, const _Host());
      expect(find.text('Select time'), findsOneWidget);
      await pumpFinesse(
        tester,
        const _Host(
          key: ValueKey(1),
          initial: TimeOfDay(hour: 7, minute: 45),
        ),
      );
      expect(find.text('07:45'), findsOneWidget);
      await pumpFinesse(
        tester,
        const _Host(
          key: ValueKey(2),
          initial: TimeOfDay(hour: 19, minute: 45),
          use24HourFormat: false,
        ),
      );
      expect(find.text('7:45 PM'), findsOneWidget);
    });

    testWidgets('is as tall as a text field on each form factor', (
      tester,
    ) async {
      for (final formFactor in FormFactor.values) {
        await pumpFinesse(tester, const _Host(), formFactor: formFactor);
        final theme = themeOf(tester, find.byType(TimePicker));
        expect(
          tester.getSize(find.byType(PickerTrigger)).height,
          theme.style.inputHeight,
        );
      }
    });

    testWidgets('on a desktop it opens a time field in a popover', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(initial: TimeOfDay(hour: 7, minute: 45)),
      );
      await open(tester);
      expect(find.byType(TimeField), findsOneWidget);
      expect(find.byType(Sheet), findsNothing);
      expect(find.byType(WheelPicker<int>), findsNothing);
      // The hours have the focus: typing replaces them, and each change is
      // taken at once.
      tester.testTextInput.enterText('16');
      await tester.pump();
      expect(host(tester).value, const TimeOfDay(hour: 16, minute: 45));
      expect(find.text('16:45'), findsOneWidget);
      // Escape closes it and the button has the focus again.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await rest(tester);
      expect(find.byType(TimeField), findsNothing);
    });

    testWidgets('on a phone it opens wheels in a sheet', (tester) async {
      await pumpFinesse(
        tester,
        const _Host(initial: TimeOfDay(hour: 7, minute: 45)),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      expect(find.byType(Sheet), findsOneWidget);
      expect(find.byType(TimeWheelPicker), findsOneWidget);
      expect(find.byType(TimeField), findsNothing);
      expect(
        find.descendant(
          of: find.byType(Sheet),
          matching: find.text('Select time'),
        ),
        findsOneWidget,
      );
      // The sheet is at the bottom and as wide as the screen.
      final sheet = tester.getRect(find.byType(Sheet));
      expect(sheet.width, 390);
      expect(sheet.bottom, 844);
      // Its buttons are touch targets.
      final done = find.widgetWithText(Button, 'Done');
      expect(tester.getSize(done).height, greaterThanOrEqualTo(44));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the wheels turn a draft that Done reports', (tester) async {
      await pumpFinesse(
        tester,
        const _Host(initial: TimeOfDay(hour: 7, minute: 45)),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      await turn(tester, 'Hours', 2);
      await turn(tester, 'Minutes', -3);
      expect(host(tester).changes, isEmpty);
      await tester.tap(find.widgetWithText(Button, 'Done'));
      await rest(tester);
      expect(host(tester).changes, [const TimeOfDay(hour: 9, minute: 42)]);
      expect(find.byType(Sheet), findsNothing);
      expect(find.text('09:42'), findsOneWidget);
    });

    testWidgets('Cancel and a tap outside leave the time as it was', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(initial: TimeOfDay(hour: 7, minute: 45)),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      await turn(tester, 'Hours', 1);
      await tester.tap(find.widgetWithText(Button, 'Cancel'));
      await rest(tester);
      expect(find.byType(Sheet), findsNothing);
      expect(host(tester).changes, isEmpty);

      await open(tester);
      await turn(tester, 'Hours', 1);
      await tester.tapAt(const Offset(195, 60));
      await rest(tester);
      expect(find.byType(Sheet), findsNothing);
      expect(host(tester).changes, isEmpty);
      // It opens again afterwards, on the time it holds.
      await open(tester);
      expect(
        tester.widget<TimeWheelPicker>(find.byType(TimeWheelPicker)).value,
        const TimeOfDay(hour: 7, minute: 45),
      );
    });

    testWidgets('Clear reports null, when there is something to clear', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(
          initial: TimeOfDay(hour: 7, minute: 45),
          allowClear: true,
        ),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      await tester.tap(find.widgetWithText(Button, 'Clear'));
      await rest(tester);
      expect(host(tester).changes, [null]);
      expect(find.text('Select time'), findsOneWidget);
      await open(tester);
      expect(find.widgetWithText(Button, 'Clear'), findsNothing);
    });

    testWidgets('with no time the wheels start on a row of the interval', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(minuteInterval: 15),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      final draft = tester
          .widget<TimeWheelPicker>(find.byType(TimeWheelPicker))
          .value;
      expect(draft.minute % 15, 0);
      expect(draft.second, 0);
      await tester.tap(find.widgetWithText(Button, 'Done'));
      await rest(tester);
      expect(host(tester).changes, [draft]);
    });

    testWidgets('presentation forces a sheet on a desktop and a popover on a '
        'phone', (tester) async {
      await pumpFinesse(
        tester,
        const _Host(presentation: PickerPresentation.sheet),
      );
      await open(tester);
      expect(find.byType(Sheet), findsOneWidget);
      await tester.tap(find.widgetWithText(Button, 'Cancel'));
      await rest(tester);

      await pumpFinesse(
        tester,
        const _Host(presentation: PickerPresentation.popover),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      expect(find.byType(Sheet), findsNothing);
      expect(find.byType(TimeField), findsOneWidget);
    });

    testWidgets('a controller opens and closes either presentation', (
      tester,
    ) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      for (final formFactor in FormFactor.values) {
        await pumpFinesse(
          tester,
          _Host(controller: controller),
          formFactor: formFactor,
        );
        controller.open();
        await rest(tester);
        final content = formFactor == FormFactor.mobile
            ? find.byType(TimeWheelPicker)
            : find.byType(TimeField);
        expect(content, findsOneWidget, reason: formFactor.name);
        controller.close();
        await rest(tester);
        expect(content, findsNothing, reason: formFactor.name);
        expect(controller.isOpen, isFalse);
      }
    });

    testWidgets('a sheet left open closes when the picker goes away', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host(), formFactor: FormFactor.mobile);
      await open(tester);
      expect(find.byType(Sheet), findsOneWidget);
      await pumpFinesse(
        tester,
        const SizedBox(),
        formFactor: FormFactor.mobile,
      );
      await rest(tester);
      expect(find.byType(Sheet), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('triggerBuilder replaces the button', (tester) async {
      await pumpFinesse(
        tester,
        _Host(
          initial: const TimeOfDay(hour: 7, minute: 45),
          triggerBuilder: (context, value, toggle) => Chip(
            label: Text('at ${value!.hour}'),
            onPressed: toggle,
          ),
        ),
      );
      expect(find.byType(Button), findsNothing);
      await tester.tap(find.text('at 7'));
      await rest(tester);
      expect(find.byType(TimeField), findsOneWidget);
    });

    testWidgets('a null onChanged disables it', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: TimePicker(value: null, onChanged: null)),
      );
      await tester.tap(find.byType(PickerTrigger), warnIfMissed: false);
      await rest(tester);
      expect(find.byType(TimeField), findsNothing);
    });

    testWidgets('builds in every layout, open and closed', (tester) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => const _Host(
          initial: TimeOfDay(hour: 7, minute: 45),
          use24HourFormat: false,
          allowClear: true,
        ),
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

    testWidgets('the sheet survives a doubled text scale', (tester) async {
      await pumpFinesse(
        tester,
        const MediaQuery(
          data: MediaQueryData(
            size: Size(390, 844),
            textScaler: TextScaler.linear(2),
          ),
          child: _Host(
            initial: TimeOfDay(hour: 7, minute: 45),
            use24HourFormat: false,
            allowClear: true,
            presentation: PickerPresentation.sheet,
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('TimeWheelPicker', () {
    Widget wheels({
      required ValueChanged<TimeOfDay> onChanged,
      TimeOfDay value = const TimeOfDay(hour: 10, minute: 30),
      bool twentyFour = true,
      bool showSeconds = false,
      int minuteInterval = 1,
      TimeOfDay? min,
      TimeOfDay? max,
    }) {
      var time = value;
      return StatefulBuilder(
        builder: (context, setState) => Center(
          child: TimeWheelPicker(
            value: time,
            use24HourFormat: twentyFour,
            showSeconds: showSeconds,
            minuteInterval: minuteInterval,
            min: min,
            max: max,
            onChanged: (v) {
              setState(() => time = v);
              onChanged(v);
            },
          ),
        ),
      );
    }

    testWidgets('has a wheel per unit under one lens', (tester) async {
      await pumpFinesse(tester, wheels(onChanged: (_) {}));
      expect(find.byType(WheelPicker<int>), findsNWidgets(2));
      expect(find.byType(WheelPicker<DayPeriod>), findsNothing);
      expect(find.byType(Glass), findsOneWidget);

      await pumpFinesse(
        tester,
        wheels(onChanged: (_) {}, twentyFour: false, showSeconds: true),
      );
      expect(find.byType(WheelPicker<int>), findsNWidgets(3));
      expect(find.byType(WheelPicker<DayPeriod>), findsOneWidget);
      expect(find.byType(Glass), findsOneWidget);
    });

    testWidgets('each wheel changes its part of the time', (tester) async {
      final reported = <TimeOfDay>[];
      await pumpFinesse(
        tester,
        wheels(onChanged: reported.add, twentyFour: false, minuteInterval: 5),
      );
      await turn(tester, 'Minutes', 2);
      expect(reported.last, const TimeOfDay(hour: 10, minute: 40));
      await turn(tester, 'Hours', -1);
      expect(reported.last, const TimeOfDay(hour: 9, minute: 40));
      await turn(tester, 'Period', 1);
      expect(reported.last, const TimeOfDay(hour: 21, minute: 40));
    });

    testWidgets('the hours go round', (tester) async {
      final reported = <TimeOfDay>[];
      await pumpFinesse(
        tester,
        wheels(
          onChanged: reported.add,
          value: const TimeOfDay(hour: 23, minute: 0),
        ),
      );
      await turn(tester, 'Hours', 2);
      expect(reported.last, const TimeOfDay(hour: 1, minute: 0));
    });

    testWidgets('a time outside the bounds cannot be rested on', (
      tester,
    ) async {
      final reported = <TimeOfDay>[];
      await pumpFinesse(
        tester,
        wheels(
          onChanged: reported.add,
          value: const TimeOfDay(hour: 16, minute: 10),
          min: const TimeOfDay(hour: 9, minute: 30),
          max: const TimeOfDay(hour: 17, minute: 15),
        ),
      );
      // Past the last hour: the wheel comes back to 17.
      await turn(tester, 'Hours', 3);
      expect(reported.last, const TimeOfDay(hour: 17, minute: 10));
      // In the last hour the minutes stop at the bound.
      await turn(tester, 'Minutes', 20);
      expect(reported.last, const TimeOfDay(hour: 17, minute: 15));
    });

    testWidgets('the clock reads left to right in RTL, period first', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        wheels(onChanged: (_) {}, twentyFour: false),
        textDirection: TextDirection.rtl,
      );
      final hours = tester.getCenter(wheelOf('Hours')).dx;
      final minutes = tester.getCenter(wheelOf('Minutes')).dx;
      final period = tester.getCenter(wheelOf('Period')).dx;
      expect(hours, lessThan(minutes));
      expect(period, lessThan(hours));
    });

    testWidgets('builds in every layout', (tester) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => wheels(onChanged: (_) {}, twentyFour: false, showSeconds: true),
      );
    });
  });

  group('TimePickerFormField', () {
    testWidgets('validates and saves what the sheet reports', (tester) async {
      final formKey = GlobalKey<FinesseFormState>();
      await pumpFinesse(
        tester,
        Center(
          child: FinesseForm(
            key: formKey,
            child: TimePickerFormField(
              id: 'start',
              use24HourFormat: true,
              validator: (v) => v == null ? 'Pick a time' : null,
            ),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Pick a time'), findsOneWidget);
      await open(tester);
      final draft = tester
          .widget<TimeWheelPicker>(find.byType(TimeWheelPicker))
          .value;
      await tester.tap(find.widgetWithText(Button, 'Done'));
      await rest(tester);
      expect(formKey.currentState!.saveAndValidate(), isTrue);
      expect(formKey.currentState!.value['start'], draft);
    });
  });
}
