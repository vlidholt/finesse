import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/src/components/picker.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// One glyph a cell: the test font is an em wide per glyph.
const _smallDays = CalendarTheme(
  dayButtonTextStyle: TextStyle(fontSize: 8),
  selectedDayButtonTextStyle: TextStyle(fontSize: 8),
  dayButtonOutsideMonthTextStyle: TextStyle(fontSize: 8),
  insideRangeDayButtonTextStyle: TextStyle(fontSize: 8),
);

/// How many weeks [month] spans, with weeks starting on Monday.
int _weeksOf(DateTime month) {
  final first = DateTime(month.year, month.month);
  final days = DateTime(month.year, month.month + 1, 0).day;
  return ((first.weekday - 1) + days + 6) ~/ 7;
}

/// The first month from 2100 on that spans [weeks] weeks: far from today,
/// so the calendar shows no "today", and the same whenever the test runs.
DateTime _monthOfWeeks(int weeks) {
  var month = DateTime(2100);
  while (_weeksOf(month) != weeks) {
    month = DateTime(month.year, month.month + 1);
  }
  return month;
}

/// A page as the docs show one: in a navigator under a scaffold's bar, so
/// an overlay on it sits where the `MediaQuery` is padded by the bar, and in
/// a scroll view with a `PageStorageKey`, which keeps its offset where every
/// unkeyed scrollable below it would find it.
class _Page extends StatelessWidget {
  const _Page({required this.controller, required this.child});

  final ScrollController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBar(title: Text('Page')),
      body: Navigator(
        onGenerateRoute: (settings) => UnaPageRoute<void>(
          settings: settings,
          builder: (context) => MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: SingleChildScrollView(
              key: const PageStorageKey('page'),
              controller: controller,
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  const SizedBox(height: 700),
                  Center(child: child),
                  const SizedBox(height: 1400),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The day cells of the calendar on screen.
Finder _days() => find.descendant(
  of: find.byWidgetPredicate((w) => '${w.runtimeType}' == '_DayGrid'),
  matching: find.byType(Button),
);

/// Where everything in the calendar is: its box, its caption, its weekday
/// names and every day, in global coordinates.
List<Rect> _layoutOf(WidgetTester tester) {
  final calendar = find.byType(Calendar);
  Iterable<Rect> rectsOf(Finder finder) => finder
      .evaluate()
      .map((e) => e.renderObject! as RenderBox)
      .map((box) => box.localToGlobal(Offset.zero) & box.size);
  return [
    ...rectsOf(calendar),
    ...rectsOf(find.descendant(of: calendar, matching: find.byType(Text))),
    ...rectsOf(find.descendant(of: calendar, matching: find.byType(Button))),
  ];
}

/// Whether the popover is on screen: the portal lays it out once unseen, to
/// measure it, before it shows it.
bool _shown(WidgetTester tester) {
  final calendar = find.byType(Calendar);
  if (calendar.evaluate().isEmpty) return false;
  final visibility = find.ancestor(
    of: calendar,
    matching: find.byType(Visibility),
  );
  return visibility.evaluate().every(
    (e) => (e.widget as Visibility).visible,
  );
}

/// The rects of [layout] relative to its first, the calendar's own box: a
/// sheet slides the whole calendar in, and nothing may move inside it.
List<Rect> _relative(List<Rect> layout) => [
  for (final rect in layout) rect.shift(-layout.first.topLeft),
];

/// Fails unless [actual] and [expected] are the same rects, give or take
/// the rounding of a sliding sheet's offset.
void _expectSameLayout(List<Rect> actual, List<Rect> expected, String reason) {
  expect(actual.length, expected.length, reason: reason);
  for (final (i, rect) in actual.indexed) {
    final other = expected[i];
    final drift = [
      rect.left - other.left,
      rect.top - other.top,
      rect.right - other.right,
      rect.bottom - other.bottom,
    ].map((d) => d.abs()).reduce((a, b) => a > b ? a : b);
    expect(drift, lessThan(.01), reason: '$reason: rect $i, $rect vs $other');
  }
}

void main() {
  final cases = [
    for (final weeks in [4, 5, 6]) ...[
      (weeks: weeks, withValue: true),
      (weeks: weeks, withValue: false),
    ],
  ];

  for (final formFactor in FormFactor.values) {
    for (final c in cases) {
      testWidgets(
        'a ${formFactor.name} date picker opens a ${c.weeks}-week month '
        '${c.withValue ? 'with' : 'without'} a value with nothing moving in '
        'it, on a scrolled page',
        (tester) async {
          final month = _monthOfWeeks(c.weeks);
          final controller = ScrollController();
          addTearDown(controller.dispose);
          var value = c.withValue ? DateTime(month.year, month.month, 9) : null;
          await pumpUna(
            tester,
            _Page(
              controller: controller,
              child: StatefulBuilder(
                builder: (context, setState) => DatePicker(
                  value: value,
                  // Without a value the picker opens on the first day it
                  // allows: the month under test.
                  min: DateTime(month.year, month.month),
                  calendarTheme: _smallDays,
                  onChanged: (v) => setState(() => value = v),
                ),
              ),
            ),
            formFactor: formFactor,
          );
          // Scrolled, so the page's `PageStorage` holds an offset.
          controller.jumpTo(500);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          await tester.tap(find.byType(PickerTrigger));
          final frames = <List<Rect>>[];
          for (var i = 0; i < 60; i++) {
            await tester.pump(const Duration(milliseconds: 16));
            if (_shown(tester)) frames.add(_layoutOf(tester));
          }
          expect(frames, isNotEmpty, reason: 'the calendar never showed');

          final sheet = formFactor == FormFactor.mobile;
          final first = sheet ? _relative(frames.first) : frames.first;
          for (final (i, frame) in frames.indexed) {
            _expectSameLayout(
              sheet ? _relative(frame) : frame,
              first,
              'frame $i of the open ${sheet ? 'sheet' : 'popover'}: '
              'something in the calendar moved or was resized',
            );
          }

          // The weeks follow the weekday names directly: no row of the
          // page's padding between them, none under the last week.
          final theme = Theme.of(tester.element(find.byType(Calendar)));
          final calendarTheme = theme.calendarTheme;
          final weekdayBottom = tester.getRect(find.text('Mo')).bottom;
          final days = _days();
          final firstDay = tester.getRect(days.first);
          final lastDay = tester.getRect(days.last);
          final cell = firstDay.height;
          final bottomPadding = calendarTheme.weekdaysPadding!.vertical;
          expect(firstDay.top, moreOrLessEquals(weekdayBottom + bottomPadding));
          // Six weeks, always.
          expect(
            lastDay.bottom - firstDay.top,
            moreOrLessEquals(
              6 * cell + 5 * (sheet ? 0 : calendarTheme.gridMainAxisSpacing!),
            ),
          );
          expect(
            lastDay.bottom,
            moreOrLessEquals(tester.getRect(find.byType(Calendar)).bottom),
          );

          // The page kept its offset: the calendar wrote none over it.
          expect(controller.offset, 500);
        },
      );
    }
  }

  testWidgets('a calendar on a scrolled page under a bar shows its weeks '
      'straight under the weekday names', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final show = ValueNotifier(false);
    addTearDown(show.dispose);
    final month = _monthOfWeeks(5);
    await pumpUna(
      tester,
      _Page(
        controller: controller,
        child: ValueListenableBuilder(
          valueListenable: show,
          builder: (context, show, _) => show
              ? Calendar(initialMonth: month, calendarTheme: _smallDays)
              : const SizedBox(height: 300),
        ),
      ),
    );
    controller.jumpTo(500);
    await tester.pump();
    // Built only now, on a scrolled page.
    show.value = true;
    await tester.pump();
    final before = _layoutOf(tester);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      _expectSameLayout(_layoutOf(tester), before, 'frame $i');
    }

    final theme = Theme.of(tester.element(find.byType(Calendar)));
    final weekdayBottom = tester.getRect(find.text('Mo')).bottom;
    final days = _days();
    expect(
      tester.getRect(days.first).top,
      moreOrLessEquals(
        weekdayBottom + theme.calendarTheme.weekdaysPadding!.vertical,
      ),
    );
    expect(controller.offset, 500);
  });
}
