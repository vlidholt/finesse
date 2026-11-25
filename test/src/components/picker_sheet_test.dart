import 'package:finesse/finesse.dart';
import 'package:finesse/src/components/picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// The pickers' sheets on the sheet they are shown in: as tall as what they
/// hold, with a handle to drag them away by, their buttons in the sheet's
/// actions, and wheels that turn under a finger without the sheet moving.
void main() {
  Future<void> rest(WidgetTester tester, [int frames = 20]) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> open(WidgetTester tester, [Finder? trigger]) async {
    await tester.tap(trigger ?? find.byType(PickerTrigger).first);
    await rest(tester);
  }

  // With one detent the handle is something to drag, not a button to
  // resize with: it has no name to find it by.
  Finder handle() => find.byWidgetPredicate(
    (widget) => '${widget.runtimeType}' == '_SheetHandle',
  );

  final pickers = <String, Widget>{
    'TimePicker': TimePicker(
      value: const TimeOfDay(hour: 9, minute: 30),
      onChanged: (_) {},
    ),
    'DatePicker': DatePicker(
      value: DateTime(2026, 11, 25),
      onChanged: (_) {},
    ),
    'DatePicker, wheels': DatePicker(
      value: DateTime(2026, 11, 25),
      mode: DatePickerMode.wheel,
      onChanged: (_) {},
    ),
    'DateRangePicker': DateRangePicker(value: null, onChanged: (_) {}),
    'ColorPickerButton': ColorPickerButton(
      value: const Color(0xFF0E7490),
      onChanged: (_) {},
    ),
  };

  for (final MapEntry(key: name, value: picker) in pickers.entries) {
    testWidgets('$name on a phone: a sheet as tall as its content, with a '
        'drag handle and its buttons in the actions', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Center(child: picker),
        formFactor: FormFactor.mobile,
      );
      await open(
        tester,
        picker is ColorPickerButton ? find.byType(ColorPickerButton) : null,
      );
      expect(tester.takeException(), isNull);
      final sheet = tester.widget<Sheet>(find.byType(Sheet));
      // One detent, the content's: the default.
      expect(sheet.detents, isNull);
      expect(sheet.showDragHandle, isNull);
      expect(handle(), findsOneWidget);
      // The handle is at the sheet's top edge: well below the screen's.
      expect(tester.getRect(handle()).top, greaterThan(120));

      // Cancel and Done are the sheet's actions: one row, side by side. A
      // calendar that closes on a tap has nothing for Done to do.
      expect(sheet.actions, hasLength(1));
      final cancel = tester.getRect(find.widgetWithText(Button, 'Cancel'));
      expect(cancel.bottom, lessThanOrEqualTo(844));
      final doneButton = find.widgetWithText(Button, 'Done');
      if (name == 'DatePicker') {
        expect(doneButton, findsNothing);
      } else {
        final done = tester.getRect(doneButton);
        expect(done.top, cancel.top);
        expect(done.left, greaterThanOrEqualTo(cancel.right));
        expect(done.width, moreOrLessEquals(cancel.width, epsilon: 1));
      }
      semantics.dispose();
    });
  }

  testWidgets('with Clear in the row, it keeps its own width beside the '
      'other two', (tester) async {
    await pumpFinesse(
      tester,
      Center(
        child: TimePicker(
          value: const TimeOfDay(hour: 9, minute: 30),
          allowClear: true,
          onChanged: (_) {},
        ),
      ),
      formFactor: FormFactor.mobile,
    );
    await open(tester);
    expect(tester.takeException(), isNull);
    final clear = tester.getRect(find.widgetWithText(Button, 'Clear'));
    final cancel = tester.getRect(find.widgetWithText(Button, 'Cancel'));
    final done = tester.getRect(find.widgetWithText(Button, 'Done'));
    expect(clear.width, lessThan(cancel.width));
    expect(clear.right, lessThanOrEqualTo(cancel.left));
    expect(cancel.right, lessThanOrEqualTo(done.left));
    expect(done.right, lessThanOrEqualTo(390));
  });

  testWidgets('a tall picker scrolls under its buttons, which stay put', (
    tester,
  ) async {
    // A short phone, held sideways: the calendar does not fit.
    await pumpFinesse(
      tester,
      Center(
        child: DatePicker(
          value: DateTime(2026, 11, 25),
          closeOnSelection: false,
          onChanged: (_) {},
        ),
      ),
      formFactor: FormFactor.mobile,
      surfaceSize: const Size(390, 420),
    );
    await open(tester);
    expect(tester.takeException(), isNull);
    final sheet = tester.getRect(find.byType(Sheet));
    expect(sheet.top, greaterThanOrEqualTo(0));
    final done = tester.getRect(find.widgetWithText(Button, 'Done'));
    expect(done.bottom, lessThanOrEqualTo(420));
    expect(done.top, greaterThan(sheet.top));
  });

  group('a wheel in a sheet', () {
    Future<void> pumpTime(WidgetTester tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: TimePicker(
            // The first hour: the hour wheel is at its top edge.
            value: const TimeOfDay(hour: 0, minute: 30),
            onChanged: (_) {},
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
    }

    for (final (direction, dy) in [('down', 120.0), ('up', -120.0)]) {
      testWidgets('dragged $direction by a finger, the wheel turns and the '
          'sheet stays where it is', (tester) async {
        await pumpTime(tester);
        final before = tester.getRect(find.byType(Sheet));
        final wheel = find.byType(WheelPicker<int>).first;
        final gesture = await tester.startGesture(tester.getCenter(wheel));
        for (var i = 0; i < 12; i++) {
          await gesture.moveBy(Offset(0, dy / 12));
          await tester.pump(const Duration(milliseconds: 16));
          expect(
            tester.getRect(find.byType(Sheet)).top,
            moreOrLessEquals(before.top, epsilon: .5),
            reason: 'frame $i',
          );
        }
        final position = tester
            .state<ScrollableState>(
              find.descendant(of: wheel, matching: find.byType(Scrollable)),
            )
            .position;
        // It moved, or pulled against its edge: the drag was the wheel's.
        expect(
          position.pixels != 0 ||
              position.activity is DragScrollActivity ||
              position.userScrollDirection != ScrollDirection.idle,
          isTrue,
        );
        await gesture.up();
        await rest(tester);
        expect(find.byType(Sheet), findsOneWidget);
        expect(
          tester.getRect(find.byType(Sheet)).top,
          moreOrLessEquals(before.top, epsilon: .5),
        );
      });
    }

    testWidgets('the handle still drags the sheet away', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpTime(tester);
      await tester.drag(handle(), const Offset(0, 500));
      await rest(tester, 30);
      expect(find.byType(Sheet), findsNothing);
      semantics.dispose();
    });
  });

  group('Sheet.actions on a phone', () {
    Future<void> show(WidgetTester tester, List<Widget> actions) async {
      await pumpFinesse(
        tester,
        Builder(
          builder: (context) => Center(
            child: Button(
              onPressed: () => showSheet<void>(
                context: context,
                builder: (context) => Sheet(
                  title: const Text('Filters'),
                  actions: actions,
                  child: const SizedBox(height: 80),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      await open(tester, find.text('Open'));
    }

    testWidgets('a row of buttons lays out its own: a compact one beside '
        'two that share the rest', (tester) async {
      await show(tester, [
        Row(
          spacing: 8,
          children: [
            Button.ghost(onPressed: () {}, child: const Text('Reset')),
            Expanded(
              child: Button.outline(
                onPressed: () {},
                expands: true,
                child: const Text('Cancel'),
              ),
            ),
            Expanded(
              child: Button(
                onPressed: () {},
                expands: true,
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ]);
      expect(tester.takeException(), isNull);
      final reset = tester.getRect(find.widgetWithText(Button, 'Reset'));
      final cancel = tester.getRect(find.widgetWithText(Button, 'Cancel'));
      final apply = tester.getRect(find.widgetWithText(Button, 'Apply'));
      expect(reset.width, lessThan(120));
      expect(cancel.width, moreOrLessEquals(apply.width, epsilon: 1));
      expect(reset.top, cancel.top);
      expect(apply.right, lessThanOrEqualTo(390));
    });

    testWidgets('buttons given one by one are stacked, each as wide as the '
        'sheet, and a long label is cut short', (tester) async {
      await show(tester, [
        Button(onPressed: () {}, child: const Text('Apply')),
        Button.outline(
          onPressed: () {},
          child: Text('Cancel and ${'go back ' * 12}'),
        ),
      ]);
      expect(tester.takeException(), isNull);
      final apply = tester.getRect(find.widgetWithText(Button, 'Apply'));
      final cancel = tester.getRect(
        find.byWidgetPredicate(
          (w) => w is Button && w.variant == ButtonVariant.outline,
        ),
      );
      expect(apply.width, cancel.width);
      expect(apply.width, greaterThan(300));
      // The first one at the bottom.
      expect(apply.top, greaterThan(cancel.bottom));
    });
  });
}
