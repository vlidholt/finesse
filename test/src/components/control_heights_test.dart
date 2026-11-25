import 'package:finesse/finesse.dart' hide Scaffold;
import 'package:finesse/material.dart';
import 'package:flutter/material.dart'
    hide
        Checkbox,
        Chip,
        IconButton,
        Switch,
        Tab,
        TabBar,
        TextField,
        Theme,
        ThemeData;
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// The reference gives fields, select triggers and every button variant the
/// same border-box height per style (`h-9`/`h-8`/`h-7`/`h-10`), which is what
/// lets them sit level on a single row. These renders lock that in: the
/// border — and the no-secondary-border variant's focus reserve — must be
/// counted *inside* the height, not added around it.
///
/// Every shipped style is walked in both form factors — a style's mobile
/// metrics are a second full set, whether it states them (finesse) or has
/// them derived (the shadcn styles) — and in both variants.
void main() {
  /// Every (variant, style, form factor) combination, with the metrics that
  /// combination resolves to.
  Iterable<
    ({
      bool disableSecondaryBorder,
      StyleTokens style,
      FormFactor formFactor,
      StyleTokens metrics,
      String label,
    })
  >
  combinations() sync* {
    for (final disableSecondaryBorder in [false, true]) {
      for (final style in StyleTokens.all) {
        for (final formFactor in FormFactor.values) {
          yield (
            disableSecondaryBorder: disableSecondaryBorder,
            style: style,
            formFactor: formFactor,
            metrics: style.forFormFactor(formFactor),
            label:
                '${style.name} ${formFactor.name} '
                '(disableSecondaryBorder: $disableSecondaryBorder)',
          );
        }
      }
    }
  }

  testWidgets('controls share the style height on a row', (tester) async {
    for (final combination in combinations()) {
      {
        final style = combination.metrics;
        final disableSecondaryBorder = combination.disableSecondaryBorder;
        final theme = ThemeData(
          brightness: Brightness.light,
          colorScheme: const NeutralColorScheme.light(),
          style: combination.style,
          formFactor: combination.formFactor,
          disableSecondaryBorder: disableSecondaryBorder,
        );
        expect(theme.style, style, reason: combination.label);
        await tester.pumpWidget(
          FinesseApp(
            builder: (context, child) => FinesseMaterial(child: child!),
            theme: theme,
            // Pinned: left alone, the app would pick the form factor from
            // the 800px test window and undo the theme's.
            formFactor: combination.formFactor,
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
                        onChanged: (_) {},
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
                    DatePicker(value: null, onChanged: (_) {}),
                    const OtpField(
                      maxLength: 2,
                      children: [
                        OtpFieldGroup(
                          children: [OtpFieldSlot(), OtpFieldSlot()],
                        ),
                      ],
                    ),
                    const TimeField(),
                    const Menubar(
                      items: [
                        MenubarItem(
                          items: [MenuItem(child: Text('New'))],
                          child: Text('File'),
                        ),
                      ],
                    ),
                    Chip(label: const Text('Ch'), onPressed: () {}),
                    IconButton(
                      icon: const Icon(PhosphorIconsRegular.plus),
                      onPressed: () {},
                    ),
                    IconButton.outline(
                      icon: const Icon(PhosphorIconsRegular.plus),
                      onPressed: () {},
                    ),
                    const SizedBox(
                      width: 160,
                      child: Tabs<String>(
                        value: 'a',
                        tabs: [
                          Tab(value: 'a', child: Text('A')),
                          Tab(value: 'b', child: Text('B')),
                        ],
                      ),
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
        // A chip eases to a new height by itself, and only starts once the
        // theme has settled on one.
        await tester.pump(const Duration(milliseconds: 250));
        expect(tester.takeException(), isNull, reason: combination.label);

        final label = combination.label;
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
        // The date picker's trigger is a field, as tall as one.
        expect(
          tester.getSize(find.byType(DatePicker)).height,
          expected,
          reason: 'date picker trigger height in $label',
        );
        final buttons = find.byType(Button, skipOffstage: false);
        for (var i = 0; i < 4; i++) {
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
                      of: find.byType(TimeField),
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
        expect(
          tester.getSize(find.byType(Chip)).height,
          style.chipHeight,
          reason: 'chip height in $label',
        );
        // Icon buttons are square, outlined or not.
        final iconButtons = find.byType(IconButton);
        for (var i = 0; i < 2; i++) {
          expect(
            tester.getSize(iconButtons.at(i)),
            Size.square(style.iconButtonSize),
            reason: 'icon button #$i size in $label',
          );
        }
        // A tab is `tabHeight` tall where the style pins one, and the
        // historical 32 where it does not.
        final tabs = find.descendant(
          of: find.byType(Tabs<String>),
          matching: find.byType(MovingIndicatorTarget),
        );
        for (var i = 0; i < 2; i++) {
          expect(
            tester.getSize(tabs.at(i)).height,
            style.tabHeight ?? 32,
            reason: 'tab #$i height in $label',
          );
        }
      }
    }
  });

  testWidgets('finesse: 36/40/32 on a desktop, 44/46/36 on a phone, in both '
      'variants', (tester) async {
    // The literal numbers, so a change to the style tokens cannot move the
    // expectation along with the render.
    const expected = {
      FormFactor.desktop: (
        button: 36.0,
        input: 40.0,
        chip: 32.0,
        staticChip: 32.0,
        iconButton: 36.0,
        tab: 32.0,
        menubar: 40.0,
        checkbox: 18.0,
        switchSize: Size(36, 20),
      ),
      FormFactor.mobile: (
        button: 44.0,
        input: 46.0,
        chip: 36.0,
        // A tag is not a touch target: it keeps the desktop height.
        staticChip: 32.0,
        iconButton: 44.0,
        tab: 36.0,
        menubar: 44.0,
        checkbox: 20.0,
        switchSize: Size(58, 26),
      ),
    };

    for (final disableSecondaryBorder in [false, true]) {
      for (final brightness in Brightness.values) {
        for (final formFactor in FormFactor.values) {
          await tester.pumpWidget(
            FinesseApp(
              // The default theme: finesse on teal.
              theme: ThemeData(
                brightness: brightness,
                disableSecondaryBorder: disableSecondaryBorder,
              ),
              formFactor: formFactor,
              home: Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const SizedBox(
                      width: 140,
                      child: TextField(placeholder: Text('Email')),
                    ),
                    SizedBox(
                      width: 140,
                      child: Select<String>(
                        onChanged: (_) {},
                        placeholder: const Text('Pick'),
                        options: const [
                          SelectOption(value: 'a', child: Text('A')),
                        ],
                        selectedOptionBuilder: (context, value) => Text(value),
                      ),
                    ),
                    Button(onPressed: () {}, child: const Text('Go')),
                    Button.outline(onPressed: () {}, child: const Text('Go')),
                    Button.secondary(
                      onPressed: () {},
                      child: const Text('Go'),
                    ),
                    Button.ghost(onPressed: () {}, child: const Text('Go')),
                    Button.destructive(
                      onPressed: () {},
                      child: const Text('Go'),
                    ),
                    Chip(label: const Text('Ch'), onPressed: () {}),
                    Chip(
                      label: const Text('Ch'),
                      selected: true,
                      onSelected: (_) {},
                    ),
                    Chip(
                      label: const Text('Ch'),
                      variant: ChipVariant.dashed,
                      onPressed: () {},
                    ),
                    const Chip(label: Text('Tag')),
                    const Chip(
                      label: Text('Tag'),
                      variant: ChipVariant.soft,
                    ),
                    IconButton(
                      icon: const Icon(PhosphorIconsRegular.plus),
                      onPressed: () {},
                    ),
                    IconButton.outline(
                      icon: const Icon(PhosphorIconsRegular.plus),
                      onPressed: () {},
                    ),
                    const SizedBox(
                      width: 160,
                      child: Tabs<String>(
                        value: 'a',
                        tabs: [
                          Tab(value: 'a', child: Text('A')),
                          Tab(value: 'b', child: Text('B')),
                        ],
                      ),
                    ),
                    const Menubar(
                      items: [
                        MenubarItem(
                          items: [MenuItem(child: Text('New'))],
                          child: Text('File'),
                        ),
                      ],
                    ),
                    Checkbox(value: false, onChanged: (_) {}),
                    Switch(value: false, onChanged: (_) {}),
                  ],
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 250));
          await tester.pump(const Duration(milliseconds: 250));
          expect(tester.takeException(), isNull);

          final want = expected[formFactor]!;
          final label =
              '$formFactor $brightness '
              '(disableSecondaryBorder: $disableSecondaryBorder)';
          final theme = Theme.of(tester.element(find.byType(Wrap)));
          expect(theme.formFactor, formFactor, reason: label);

          expect(
            tester.getSize(find.byType(TextField)).height,
            want.input,
            reason: 'input in $label',
          );
          expect(
            tester.getSize(find.byType(Select<String>)).height,
            want.input,
            reason: 'select in $label',
          );
          final buttons = find.widgetWithText(Button, 'Go');
          expect(buttons, findsNWidgets(5));
          for (var i = 0; i < 5; i++) {
            expect(
              tester.getSize(buttons.at(i)).height,
              want.button,
              reason: 'button #$i in $label',
            );
          }
          final chips = find.widgetWithText(Chip, 'Ch');
          expect(chips, findsNWidgets(3));
          for (var i = 0; i < 3; i++) {
            expect(
              tester.getSize(chips.at(i)).height,
              want.chip,
              reason: 'chip #$i in $label',
            );
          }
          final tags = find.widgetWithText(Chip, 'Tag');
          expect(tags, findsNWidgets(2));
          for (var i = 0; i < 2; i++) {
            expect(
              tester.getSize(tags.at(i)).height,
              want.staticChip,
              reason: 'static chip #$i in $label',
            );
          }
          final iconButtons = find.byType(IconButton);
          for (var i = 0; i < 2; i++) {
            expect(
              tester.getSize(iconButtons.at(i)),
              Size.square(want.iconButton),
              reason: 'icon button #$i in $label',
            );
          }
          final tabs = find.descendant(
            of: find.byType(Tabs<String>),
            matching: find.byType(MovingIndicatorTarget),
          );
          for (var i = 0; i < 2; i++) {
            expect(
              tester.getSize(tabs.at(i)).height,
              want.tab,
              reason: 'tab #$i in $label',
            );
          }
          expect(
            tester.getSize(find.byType(Menubar)).height,
            want.menubar,
            reason: 'menubar in $label',
          );
          expect(theme.checkboxTheme.size, want.checkbox, reason: label);
          expect(
            Size(theme.switchTheme.width!, theme.switchTheme.height!),
            want.switchSize,
            reason: label,
          );
        }
      }
    }
  });

  testWidgets('a fixed-height control grows with the text scale instead of '
      'clipping its label, and by no more than the label needs', (
    tester,
  ) async {
    // A style height is the height at the platform's text size. Scaled up,
    // the label's line grows and the control used to stay put: the label
    // was laid out in the room that was left and cut off at the bottom
    // (a tab at 1.45x, a small button at 1.6x). The height is now a floor.
    for (final combination in combinations()) {
      final theme = ThemeData(
        brightness: Brightness.light,
        colorScheme: const NeutralColorScheme.light(),
        style: combination.style,
        formFactor: combination.formFactor,
        disableSecondaryBorder: combination.disableSecondaryBorder,
      );
      final unscaled = <String, double>{};
      // 1 first: it is what the others are measured against. Below 1 the
      // text shrinks and the control does not.
      for (final scale in const [1.0, .85, 1.3, 1.45, 2.0, 3.0]) {
        final controls = <String, Widget>{
          'button': Button(onPressed: () {}, child: const Text('Label')),
          'small button': Button(
            size: ButtonSize.sm,
            onPressed: () {},
            child: const Text('Label'),
          ),
          'large button': Button(
            size: ButtonSize.lg,
            onPressed: () {},
            child: const Text('Label'),
          ),
          'outline button': Button.outline(
            onPressed: () {},
            child: const Text('Label'),
          ),
          'toggle': Toggle(
            value: false,
            onChanged: (_) {},
            child: const Text('Label'),
          ),
          'outline toggle': Toggle.outline(
            value: true,
            onChanged: (_) {},
            child: const Text('Label'),
          ),
          'chip': Chip(label: const Text('Label'), onPressed: () {}),
          'tab strip': const Tabs<String>(
            value: 'a',
            tabs: [
              Tab(value: 'a', child: Text('Label')),
              Tab(value: 'b', child: Text('Other')),
            ],
          ),
          'underline tabs': TabBar<int>(
            tabs: const [
              Tab(value: 0, child: Text('Label')),
              Tab(value: 1, child: Text('Other')),
            ],
            value: 0,
            expandTabs: false,
            onChanged: (_) {},
          ),
          'icon button': IconButton(
            icon: const Icon(PhosphorIconsRegular.plus),
            onPressed: () {},
          ),
        };
        await tester.pumpWidget(
          FinesseApp(
            theme: theme,
            formFactor: combination.formFactor,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: child!,
            ),
            home: SingleChildScrollView(
              child: FinesseColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final MapEntry(:key, :value) in controls.entries)
                    KeyedSubtree(key: ValueKey(key), child: value),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        for (final name in controls.keys) {
          final reason = '$name at ${scale}x in ${combination.label}';
          final control = find.byKey(ValueKey(name));
          final box = tester.getRect(control);
          if (scale == 1) unscaled[name] = box.height;
          final floor = unscaled[name]!;
          expect(
            box.height,
            greaterThanOrEqualTo(floor),
            reason: '$reason is never shorter than at 1x',
          );
          expect(
            box.height,
            lessThanOrEqualTo(floor * (scale < 1 ? 1 : scale) + .01),
            reason: '$reason grows no faster than its text',
          );

          final text = find.descendant(
            of: control,
            matching: find.text('Label'),
          );
          if (text.evaluate().isEmpty) {
            // Nothing in it scales, so nothing about it changes.
            expect(box.height, floor, reason: reason);
            continue;
          }
          final paragraph = tester.renderObject<RenderParagraph>(
            find.descendant(of: text, matching: find.byType(RichText)),
          );
          // The line's own height at this scale: what it is given must be
          // all of it.
          final line = paragraph.getMaxIntrinsicHeight(double.infinity);
          expect(
            paragraph.size.height,
            greaterThanOrEqualTo(line - .01),
            reason: '$reason: the label is squeezed into less than its line',
          );
          final label = tester.getRect(text);
          expect(
            label.top >= box.top - .01 && label.bottom <= box.bottom + .01,
            isTrue,
            reason: '$reason: the label $label leaves the control $box',
          );
          // Room it already had is used before it grows: a control whose
          // label still fits has not changed.
          if (line <= paragraph.size.height + .01 && scale == 1.3) {
            expect(
              box.height,
              lessThanOrEqualTo(floor + (line - line / scale) + .01),
              reason: '$reason grew by more than its line did',
            );
          }
        }
        expect(
          tester.takeException(),
          isNull,
          reason: '${scale}x in ${combination.label}',
        );
      }
    }
  });

  testWidgets('calendar geometry follows the style tokens', (tester) async {
    for (final combination in combinations()) {
      {
        final style = combination.metrics;
        final theme = ThemeData(
          brightness: Brightness.light,
          colorScheme: const NeutralColorScheme.light(),
          style: combination.style,
          formFactor: combination.formFactor,
          disableSecondaryBorder: combination.disableSecondaryBorder,
        );
        await tester.pumpWidget(
          FinesseApp(
            builder: (context, child) => FinesseMaterial(child: child!),
            theme: theme,
            formFactor: combination.formFactor,
            home: Scaffold(
              body: Center(
                child: Calendar(
                  value: DateTime(2024, 5, 15),
                  captionLayout: CalendarCaptionLayout.dropdown,
                  calendarTheme: CalendarTheme(
                    // Single-glyph captions: the test font (Ahem) renders
                    // every glyph a full em wide, so a real month name wraps
                    // to two lines inside the trigger and inflates its
                    // height.
                    dropdownFormatMonth: (date) => 'M',
                    dropdownFormatYear: (date) => 'Y',
                    // Ditto for the day numbers: two Ahem digits are wider
                    // than mira's 24px cell, though half that wide in a real
                    // font. Every day state resolves its own style, so all
                    // four are pinned.
                    dayButtonTextStyle: const TextStyle(fontSize: 8),
                    selectedDayButtonTextStyle: const TextStyle(fontSize: 8),
                    insideRangeDayButtonTextStyle: const TextStyle(
                      fontSize: 8,
                    ),
                    dayButtonOutsideMonthTextStyle: const TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        final label = combination.label;
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

  testWidgets('calendar cells follow the text scale, and keep their size at '
      '1x', (tester) async {
    // Room for six weeks of 80-point cells.
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Two Ahem digits at 12 are 24 wide: inside the smallest style's
    // 28-point cell at 1x, so whether they still fit when scaled is down to
    // the cell alone.
    const day = TextStyle(fontSize: 12);
    for (final combination in combinations()) {
      final style = combination.metrics;
      final theme = ThemeData(
        brightness: Brightness.light,
        colorScheme: const NeutralColorScheme.light(),
        style: combination.style,
        formFactor: combination.formFactor,
        disableSecondaryBorder: combination.disableSecondaryBorder,
      );
      for (final scale in const [1.0, .85, 1.3, 2.0]) {
        await tester.pumpWidget(
          FinesseApp(
            theme: theme,
            formFactor: combination.formFactor,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: child!,
            ),
            home: Center(
              child: Calendar(
                value: DateTime(2024, 5, 15),
                calendarTheme: const CalendarTheme(
                  dayButtonTextStyle: day,
                  selectedDayButtonTextStyle: day,
                  insideRangeDayButtonTextStyle: day,
                  dayButtonOutsideMonthTextStyle: day,
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        final reason = '${scale}x in ${combination.label}';
        final cell = find.widgetWithText(Button, '28').first;
        // Exactly the style's cell at 1x and below; in proportion above.
        final side = style.calendarCellSize * (scale < 1 ? 1 : scale);
        expect(
          tester.getSize(cell),
          Size.square(side),
          reason: 'day cell at $reason',
        );
        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(of: cell, matching: find.byType(RichText)),
        );
        // On one line, inside its cell.
        expect(
          paragraph.size.height,
          lessThanOrEqualTo(
            paragraph.getMinIntrinsicHeight(double.infinity) + .01,
          ),
          reason: 'a two-digit day wraps at $reason',
        );
        final cellRect = tester.getRect(cell);
        final textRect = tester.getRect(
          find.descendant(of: cell, matching: find.byType(RichText)),
        );
        expect(
          textRect.left >= cellRect.left - .01 &&
              textRect.right <= cellRect.right + .01,
          isTrue,
          reason: 'a two-digit day leaves its cell at $reason',
        );
        expect(tester.takeException(), isNull, reason: reason);
      }
    }
  });
}
