import 'package:finesse/finesse.dart';
import 'package:finesse/material.dart';
import 'package:flutter/material.dart' hide IconButton, TextField, ThemeData;
import 'package:flutter_test/flutter_test.dart';

/// The reference gives fields, select triggers and every button variant the
/// same border-box height per style (`h-9`/`h-8`/`h-7`/`h-10`), which is what
/// lets them sit level on a single row. These renders lock that in: the
/// border — and the no-secondary-border variant's focus reserve — must be
/// counted *inside* the height, not added around it.
void main() {
  testWidgets('controls share the style height on a row', (tester) async {
    for (final disableSecondaryBorder in [false, true]) {
      for (final style in StyleTokens.all) {
        final theme = ThemeData(
          brightness: Brightness.light,
          colorScheme: const SlateColorScheme.light(),
          style: style,
          disableSecondaryBorder: disableSecondaryBorder,
        );
        await tester.pumpWidget(
          FinesseApp(
            builder: (context, child) => FinesseMaterial(child: child!),
            theme: theme,
            home: Scaffold(
              // A Wrap rather than a Row: the roster is wider than the test
              // surface, and an overflowing Row throws in tests. The heights
              // are asserted per widget, not from the row geometry.
              body: Center(
                child: Wrap(
                  children: [
                    const SizedBox(
                      width: 140,
                      child: TextField(placeholder: Text('Email')),
                    ),
                    SizedBox(
                      width: 140,
                      child: Select<String>(
                        placeholder: const Text('Pick'),
                        options: const [
                          SelectOption(value: 'a', child: Text('A')),
                        ],
                        selectedOptionBuilder: (context, value) => Text(value),
                      ),
                    ),
                    Button(onPressed: () {}, child: const Text('Go')),
                    Button.outline(
                      onPressed: () {},
                      child: const Text('Go'),
                    ),
                    Button.secondary(
                      onPressed: () {},
                      child: const Text('Go'),
                    ),
                    Button.ghost(onPressed: () {}, child: const Text('Go')),
                    Toggle(
                      value: false,
                      onChanged: (_) {},
                      child: const Text('Tg'),
                    ),
                    Toggle.outline(
                      value: false,
                      onChanged: (_) {},
                      child: const Text('Tg'),
                    ),
                    const DatePicker(),
                    const OtpField(
                      maxLength: 2,
                      children: [
                        OtpFieldGroup(
                          children: [OtpFieldSlot(), OtpFieldSlot()],
                        ),
                      ],
                    ),
                    const TimePicker(),
                    const Menubar(
                      items: [
                        MenubarItem(
                          items: [ContextMenuItem(child: Text('New'))],
                          child: Text('File'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        // Let the implicit theme animation from the previous iteration's
        // theme finish before measuring.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        final label =
            '${style.name} '
            '(disableSecondaryBorder: $disableSecondaryBorder)';
        final expected = style.inputHeight;
        // `.first` — the time picker contributes Inputs of its own.
        expect(
          tester.getSize(find.byType(TextField).first).height,
          expected,
          reason: 'input height in $label',
        );
        expect(
          tester.getSize(find.byType(Select<String>)).height,
          expected,
          reason: 'select trigger height in $label',
        );
        // The date picker trigger is itself a Button, so it is covered by
        // the loop.
        final buttons = find.byType(Button, skipOffstage: false);
        for (var i = 0; i < 5; i++) {
          expect(
            tester.getSize(buttons.at(i)).height,
            style.buttonHeight,
            reason: 'button #$i height in $label',
          );
        }
        final toggles = find.byType(Toggle);
        for (var i = 0; i < 2; i++) {
          expect(
            tester.getSize(toggles.at(i)).height,
            style.buttonHeight,
            reason: 'toggle #$i height in $label',
          );
        }
        expect(
          tester.getSize(find.byType(OtpFieldSlot).first),
          Size.square(style.inputHeight),
          reason: 'OTP slot size in $label',
        );
        expect(
          tester
              .getSize(
                find
                    .descendant(
                      of: find.byType(TimePicker),
                      matching: find.byType(TextField),
                    )
                    .first,
              )
              .height,
          expected,
          reason: 'time picker field height in $label',
        );
        expect(
          tester.getSize(find.byType(Menubar)).height,
          style.menubarHeight,
          reason: 'menubar strip height in $label',
        );
      }
    }
  });

  testWidgets('calendar geometry follows the style tokens', (tester) async {
    for (final disableSecondaryBorder in [false, true]) {
      for (final style in StyleTokens.all) {
        final theme = ThemeData(
          brightness: Brightness.light,
          colorScheme: const SlateColorScheme.light(),
          style: style,
          disableSecondaryBorder: disableSecondaryBorder,
        );
        await tester.pumpWidget(
          FinesseApp(
            builder: (context, child) => FinesseMaterial(child: child!),
            theme: theme,
            home: Scaffold(
              body: Center(
                child: Calendar(
                  selected: DateTime(2024, 5, 15),
                  captionLayout: CalendarCaptionLayout.dropdown,
                  // Single-glyph captions: the test font (Ahem) renders every
                  // glyph a full em wide, so a real month name wraps to two
                  // lines inside the trigger and inflates its height.
                  dropdownFormatMonth: (date) => 'M',
                  dropdownFormatYear: (date) => 'Y',
                  // Ditto for the day numbers: two Ahem digits are wider than
                  // mira's 24px cell, though half that wide in a real font.
                  // Every day state resolves its own style, so all four are
                  // pinned.
                  dayButtonTextStyle: const TextStyle(fontSize: 8),
                  selectedDayButtonTextStyle: const TextStyle(fontSize: 8),
                  insideRangeDayButtonTextStyle: const TextStyle(fontSize: 8),
                  dayButtonOutsideMonthTextStyle: const TextStyle(fontSize: 8),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        final label =
            '${style.name} '
            '(disableSecondaryBorder: $disableSecondaryBorder)';
        // A mid-month day cell: `size-(--cell-size)`.
        expect(
          tester.getSize(
            find.widgetWithText(Button, '15', skipOffstage: false).first,
          ),
          Size.square(style.calendarCellSize),
          reason: 'day cell size in $label',
        );
        // The navigation chevrons share the cell size.
        expect(
          tester.getSize(find.byType(IconButton).first),
          Size.square(style.calendarCellSize),
          reason: 'navigation button size in $label',
        );
        // The month/year dropdown triggers take the caption height
        // (`.cn-calendar-caption-label`), not the field height.
        expect(
          tester.getSize(find.byType(Select<int>).first).height,
          style.calendarCaptionHeight,
          reason: 'caption dropdown trigger height in $label',
        );
      }
    }
  });
}
