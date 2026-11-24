import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  /// The chip's own box: fill, outline and radius.
  BoxDecoration boxOf(WidgetTester tester, [Finder? chip]) {
    final fill = tester.widget<AnimatedFill>(
      find.descendant(
        of: chip ?? find.byType(Chip),
        matching: find.byType(AnimatedFill),
      ),
    );
    return BoxDecoration(
      color: fill.color,
      borderRadius: fill.borderRadius,
      border: fill.borderColor == null
          ? null
          : Border.all(color: fill.borderColor!, width: fill.borderWidth),
    );
  }

  Color labelColorOf(WidgetTester tester, String label) =>
      DefaultTextStyle.of(tester.element(find.text(label))).style.color!;

  group('ChipTheme', () {
    test('follows the form factor and the scheme', () {
      final desktop = ThemeData();
      final mobile = ThemeData(formFactor: FormFactor.mobile);
      final s = desktop.colorScheme;

      expect(desktop.chipTheme.height, 32);
      expect(mobile.chipTheme.height, 36);
      expect(
        desktop.chipTheme.padding,
        const EdgeInsets.symmetric(horizontal: 12),
      );
      expect(desktop.chipTheme.gap, 6);
      expect(desktop.chipTheme.iconSize, 16);
      expect(desktop.chipTheme.radius, desktop.radii.full);
      expect(desktop.chipTheme.borderWidth, 1);
      // A 13px medium label on a single line.
      expect(desktop.chipTheme.textStyle!.fontSize, 13);
      expect(desktop.chipTheme.textStyle!.fontWeight, FontWeight.w500);
      expect(desktop.chipTheme.textStyle!.height, 1);
      // Card colour at the strong glass opacity.
      expect(desktop.chipTheme.backgroundColor, s.card.withValues(alpha: .9));
      expect(desktop.chipTheme.hoverBackgroundColor, s.muted);
      expect(desktop.chipTheme.foregroundColor, s.foregroundSubtle);
      expect(desktop.chipTheme.borderColor, s.border);
      expect(desktop.chipTheme.selectedBackgroundColor, s.accent);
      expect(desktop.chipTheme.selectedForegroundColor, s.accentForeground);
      expect(desktop.chipTheme.selectedBorderColor, s.accentBorder);
    });

    test('scales with the spacing unit', () {
      final theme = ThemeData(spacing: const Spacing(step: 5));
      expect(theme.chipTheme.height, 40);
      expect(theme.chipTheme.iconSize, 20);
      expect(
        theme.chipTheme.padding,
        const EdgeInsets.symmetric(horizontal: 15),
      );
    });
  });

  group('Chip layout', () {
    testWidgets('renders in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => Center(
          child: Wrap(
            spacing: 8,
            children: [
              Chip(label: const Text('One'), onPressed: () {}),
              Chip(
                label: const Text('Two'),
                leading: const Icon(PhosphorIconsRegular.globe),
                trailing: const Icon(PhosphorIconsRegular.x),
                selected: true,
                onSelected: (_) {},
              ),
              const Chip(label: Text('Tag'), variant: ChipVariant.soft),
              const Chip(label: Text('Add'), variant: ChipVariant.dashed),
            ],
          ),
        ),
        check: (layout) async {
          final theme = themeOf(tester, find.byType(Wrap));
          final expected = layout.formFactor == FormFactor.mobile ? 36.0 : 32.0;
          expect(theme.chipTheme.height, expected);
          // The two chips that can be tapped follow the form factor; the
          // two tags keep the desktop height.
          for (final label in ['One', 'Two']) {
            expect(
              tester.getSize(find.widgetWithText(Chip, label)).height,
              expected,
              reason: label,
            );
          }
          for (final label in ['Tag', 'Add']) {
            expect(
              tester.getSize(find.widgetWithText(Chip, label)).height,
              32,
              reason: label,
            );
          }
        },
      );
    });

    testWidgets('a tappable chip is 32 on a desktop and 36 on a phone; a '
        'static one is 32 on both', (tester) async {
      for (final formFactor in FormFactor.values) {
        await pumpFinesse(
          tester,
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Chip(key: Key('static'), label: Text('Tag')),
                const Chip(
                  key: Key('static-selected'),
                  label: Text('Tag'),
                  selected: true,
                ),
                Chip(
                  key: const Key('toggle'),
                  label: const Text('Tag'),
                  onSelected: (_) {},
                ),
                Chip(
                  key: const Key('action'),
                  label: const Text('Tag'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          formFactor: formFactor,
        );
        final touch = formFactor == FormFactor.mobile ? 36.0 : 32.0;
        double heightOf(String key) =>
            tester.getSize(find.byKey(Key(key))).height;
        expect(heightOf('static'), 32, reason: formFactor.name);
        expect(heightOf('static-selected'), 32, reason: formFactor.name);
        expect(heightOf('toggle'), touch, reason: formFactor.name);
        expect(heightOf('action'), touch, reason: formFactor.name);
      }
    });

    testWidgets("a static chip's height still follows the spacing unit", (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(child: Chip(label: Text('Tag'))),
        theme: ThemeData(spacing: const Spacing(step: 5)),
        formFactor: FormFactor.mobile,
      );
      // The desktop 32 at a 5px step, not the phone's 36 at one.
      expect(tester.getSize(find.byType(Chip)).height, 40);
    });

    testWidgets('the height is applied outside the animated box, so a change '
        'of form factor does not animate it', (tester) async {
      // A plain `Theme`, so the only animation that could move the height
      // is the chip's own.
      Widget chip(FormFactor formFactor) => FinesseApp(
        formFactor: FormFactor.desktop,
        home: Theme(
          data: ThemeData(formFactor: formFactor),
          child: Center(
            child: Chip(label: const Text('Remote'), onPressed: () {}),
          ),
        ),
      );
      await tester.pumpWidget(chip(FormFactor.desktop));
      await settle(tester);
      expect(tester.getSize(find.byType(Chip)).height, 32);

      await tester.pumpWidget(chip(FormFactor.mobile));
      // On the very frame the theme changes, and at every point of the
      // 120 ms colour animation.
      expect(tester.getSize(find.byType(Chip)).height, 36);
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.getSize(find.byType(Chip)).height, 36, reason: '$i');
      }

      await tester.pumpWidget(chip(FormFactor.desktop));
      expect(tester.getSize(find.byType(Chip)).height, 32);
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.getSize(find.byType(Chip)).height, 32);

      // The animated box itself carries no size at all.
      expect(
        find.ancestor(
          of: find.byType(AnimatedFill),
          matching: find.byWidgetPredicate(
            (w) => w is SizedBox && w.height == 32 && w.width == null,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('hugs its label: padding, hairline and nothing else', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(child: Chip(label: Text('Remote'))),
      );
      final label = tester.getSize(find.text('Remote'));
      final chip = tester.getSize(find.byType(Chip));
      // 12 of padding and a 1px outline on each side.
      expect(chip.width, label.width + 24 + 2);
      expect(chip.height, 32);
    });

    testWidgets('centres its content vertically', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: Chip(
            label: Text('Remote'),
            leading: Icon(PhosphorIconsRegular.globe),
          ),
        ),
      );
      final chip = tester.getRect(find.byType(Chip));
      expect(
        tester.getRect(find.text('Remote')).center.dy,
        closeTo(chip.center.dy, .5),
      );
      expect(
        tester.getRect(find.byType(Icon)).center.dy,
        closeTo(chip.center.dy, .5),
      );
    });

    testWidgets('lays out leading, label and trailing with the theme gap, in '
        'reading order', (tester) async {
      for (final direction in TextDirection.values) {
        await pumpFinesse(
          tester,
          const Center(
            child: Chip(
              label: Text('Go'),
              leading: Icon(PhosphorIconsRegular.globe, key: Key('lead')),
              trailing: Icon(PhosphorIconsRegular.x, key: Key('trail')),
            ),
          ),
          textDirection: direction,
        );
        final lead = tester.getRect(find.byKey(const Key('lead')));
        final label = tester.getRect(find.text('Go'));
        final trail = tester.getRect(find.byKey(const Key('trail')));
        final chip = tester.getRect(find.byType(Chip));

        // Icons take the theme's 16.
        expect(lead.size, const Size.square(16));
        expect(trail.size, const Size.square(16));
        if (direction == TextDirection.ltr) {
          expect(lead.left, chip.left + 13);
          expect(label.left - lead.right, 6);
          expect(trail.left - label.right, 6);
          expect(trail.right, chip.right - 13);
        } else {
          expect(lead.right, chip.right - 13);
          expect(lead.left - label.right, 6);
          expect(label.left - trail.right, 6);
          expect(trail.left, chip.left + 13);
        }
      }
    });

    testWidgets('truncates a label that does not fit instead of overflowing', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(
          child: SizedBox(
            width: 120,
            child: Chip(
              label: const Text('A very long label that cannot fit'),
              leading: const Icon(PhosphorIconsRegular.globe),
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Chip)).width, 120);
      final text = tester.widget<RichText>(
        find.descendant(
          of: find.text('A very long label that cannot fit'),
          matching: find.byType(RichText),
        ),
      );
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });

    testWidgets('height and padding can be set per chip', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: Chip(
            label: SizedBox(width: 30, height: 10),
            height: 24,
            padding: EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      );
      expect(tester.getSize(find.byType(Chip)), const Size(40, 24));
    });

    testWidgets('is a pill by default and follows the theme radius', (
      tester,
    ) async {
      await pumpFinesse(tester, const Center(child: Chip(label: Text('Hi'))));
      expect(
        boxOf(tester).borderRadius,
        themeOf(tester, find.byType(Chip)).radii.full,
      );

      const radius = BorderRadius.all(Radius.circular(4));
      await pumpFinesse(
        tester,
        const Center(child: Chip(label: Text('Hi'))),
        theme: ThemeData(chipTheme: const ChipTheme(radius: radius)),
      );
      expect(boxOf(tester).borderRadius, radius);
    });
  });

  group('Chip interaction', () {
    testWidgets('toggles through onSelected', (tester) async {
      var selected = false;
      final calls = <bool>[];
      await pumpFinesse(
        tester,
        Center(
          child: StatefulBuilder(
            builder: (context, setState) => Chip(
              label: const Text('Remote'),
              selected: selected,
              onSelected: (value) {
                calls.add(value);
                setState(() => selected = value);
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Chip));
      await settle(tester);
      expect(calls, [true]);
      expect(tester.widget<Chip>(find.byType(Chip)).selected, isTrue);

      await tester.tap(find.byType(Chip));
      await settle(tester);
      expect(calls, [true, false]);
      expect(tester.widget<Chip>(find.byType(Chip)).selected, isFalse);
    });

    testWidgets('onSelected is handed the opposite of selected, and does not '
        'flip the chip by itself', (tester) async {
      final calls = <bool>[];
      await pumpFinesse(
        tester,
        Center(
          child: Chip(
            label: const Text('Remote'),
            selected: true,
            onSelected: calls.add,
          ),
        ),
      );
      await tester.tap(find.byType(Chip));
      await tester.tap(find.byType(Chip));
      await settle(tester);
      // Controlled: without a rebuild it keeps reporting the same thing.
      expect(calls, [false, false]);
    });

    testWidgets('onPressed makes it a button', (tester) async {
      var presses = 0;
      await pumpFinesse(
        tester,
        Center(
          child: Chip(label: const Text('Clear'), onPressed: () => presses++),
        ),
      );
      await tester.tap(find.byType(Chip));
      expect(presses, 1);
    });

    testWidgets('onSelected wins when both are given', (tester) async {
      var presses = 0;
      final calls = <bool>[];
      await pumpFinesse(
        tester,
        Center(
          child: Chip(
            label: const Text('Both'),
            onPressed: () => presses++,
            onSelected: calls.add,
          ),
        ),
      );
      await tester.tap(find.byType(Chip));
      expect(calls, [true]);
      expect(presses, 0);
    });

    testWidgets('Enter and Space toggle the focused chip', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      final calls = <bool>[];
      await pumpFinesse(
        tester,
        Center(
          child: Chip(
            label: const Text('Remote'),
            focusNode: node,
            onSelected: calls.add,
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      expect(node.hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(calls, [true, true]);
    });

    testWidgets('a chip with neither callback does nothing and takes no '
        'focus', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpFinesse(
        tester,
        Center(
          child: Chip(label: const Text('Tag'), focusNode: node),
        ),
      );
      await tester.tap(find.byType(Chip));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(node.hasFocus, isFalse);
      expect(tester.takeException(), isNull);
    });
  });

  group('Chip colours', () {
    testWidgets('unselected: glass fill, subtle text, hairline', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        await pumpFinesse(
          tester,
          Center(
            child: Chip(label: const Text('Remote'), onPressed: () {}),
          ),
          theme: ThemeData(brightness: brightness),
        );
        final s = themeOf(tester, find.byType(Chip)).colorScheme;
        final box = boxOf(tester);

        expect(box.color, s.card.withValues(alpha: .9), reason: '$brightness');
        expect((box.border! as Border).top.color, s.border);
        expect((box.border! as Border).top.width, 1);
        expect(labelColorOf(tester, 'Remote'), s.foregroundSubtle);
      }
    });

    testWidgets('selected: the accent fill, text and outline', (tester) async {
      for (final brightness in Brightness.values) {
        await pumpFinesse(
          tester,
          Center(
            child: Chip(
              label: const Text('Remote'),
              leading: const Icon(PhosphorIconsRegular.globe),
              selected: true,
              onSelected: (_) {},
            ),
          ),
          theme: ThemeData(brightness: brightness),
        );
        final s = themeOf(tester, find.byType(Chip)).colorScheme;
        final box = boxOf(tester);

        expect(box.color, s.accent, reason: '$brightness');
        expect((box.border! as Border).top.color, s.accentBorder);
        expect(labelColorOf(tester, 'Remote'), s.accentForeground);
        // The icon follows the label.
        expect(
          IconTheme.of(tester.element(find.byType(Icon))).color,
          s.accentForeground,
        );
      }
    });

    testWidgets('selecting changes every resolved colour', (tester) async {
      Future<(Color?, Color, Color)> resolve({required bool selected}) async {
        await pumpFinesse(
          tester,
          Center(
            child: Chip(
              label: const Text('Remote'),
              selected: selected,
              onSelected: (_) {},
            ),
          ),
        );
        final box = boxOf(tester);
        return (
          box.color,
          (box.border! as Border).top.color,
          labelColorOf(tester, 'Remote'),
        );
      }

      final off = await resolve(selected: false);
      final on = await resolve(selected: true);
      expect(on.$1, isNot(off.$1));
      expect(on.$2, isNot(off.$2));
      expect(on.$3, isNot(off.$3));
    });

    testWidgets('per-chip colours apply to the unselected chip only', (
      tester,
    ) async {
      const fill = Color(0xff102030);
      const text = Color(0xff405060);
      const line = Color(0xff708090);

      Future<void> pump({required bool selected}) => pumpFinesse(
        tester,
        Center(
          child: Chip(
            label: const Text('Go'),
            selected: selected,
            backgroundColor: fill,
            foregroundColor: text,
            borderColor: line,
          ),
        ),
      );

      await pump(selected: false);
      expect(boxOf(tester).color, fill);
      expect((boxOf(tester).border! as Border).top.color, line);
      expect(labelColorOf(tester, 'Go'), text);

      await pump(selected: true);
      final s = themeOf(tester, find.byType(Chip)).colorScheme;
      expect(boxOf(tester).color, s.accent);
      expect((boxOf(tester).border! as Border).top.color, s.accentBorder);
      expect(labelColorOf(tester, 'Go'), s.accentForeground);
    });

    testWidgets('hover fills an enabled chip with the muted colour', (
      tester,
    ) async {
      useTraditionalHighlights();
      await pumpFinesse(
        tester,
        Center(
          child: Chip(label: const Text('Remote'), onPressed: () {}),
        ),
      );
      final s = themeOf(tester, find.byType(Chip)).colorScheme;
      expect(boxOf(tester).color, s.card.withValues(alpha: .9));

      final gesture = await hoverAt(
        tester,
        tester.getCenter(find.byType(Chip)),
      );
      await settle(tester);
      expect(boxOf(tester).color, s.muted);

      await gesture.moveTo(Offset.zero);
      await settle(tester);
      expect(boxOf(tester).color, s.card.withValues(alpha: .9));
    });

    testWidgets('a static chip does not react to the pointer', (tester) async {
      useTraditionalHighlights();
      await pumpFinesse(tester, const Center(child: Chip(label: Text('Tag'))));
      final before = boxOf(tester).color;

      await hoverAt(tester, tester.getCenter(find.byType(Chip)));
      await settle(tester);
      expect(boxOf(tester).color, before);
    });

    testWidgets('the soft variant is a muted fill', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: Chip(label: Text('Figma'), variant: ChipVariant.soft),
        ),
      );
      final s = themeOf(tester, find.byType(Chip)).colorScheme;
      expect(boxOf(tester).color, s.muted);
      expect(labelColorOf(tester, 'Figma'), s.foregroundSubtle);
    });

    testWidgets('the soft variant keeps a hairline round its muted fill', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        await pumpFinesse(
          tester,
          const Center(
            child: Chip(label: Text('Figma'), variant: ChipVariant.soft),
          ),
          theme: ThemeData(brightness: brightness),
        );
        final theme = themeOf(tester, find.byType(Chip));
        final border = boxOf(tester).border! as Border;
        expect(border.isUniform, isTrue, reason: '$brightness');
        expect(border.top.style, BorderStyle.solid, reason: '$brightness');
        expect(border.top.width, theme.chipTheme.borderWidth);
        expect(border.top.width, 1);
        expect(border.top.color, theme.colorScheme.border);
        // A solid hairline, not the dashed painter.
        expect(
          find.descendant(
            of: find.byType(Chip),
            matching: find.byWidgetPredicate(
              (w) => w is CustomPaint && w.foregroundPainter != null,
            ),
          ),
          findsNothing,
        );
      }
    });

    testWidgets("the soft variant's borderColor can be overridden", (
      tester,
    ) async {
      const outline = Color(0xff336699);
      await pumpFinesse(
        tester,
        const Center(
          child: Chip(
            label: Text('Figma'),
            variant: ChipVariant.soft,
            borderColor: outline,
          ),
        ),
      );
      expect((boxOf(tester).border! as Border).top.color, outline);
    });

    testWidgets('the dashed variant has no fill and a dashed strong outline', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: Chip(label: Text('Add'), variant: ChipVariant.dashed),
        ),
      );
      final s = themeOf(tester, find.byType(Chip)).colorScheme;
      final box = boxOf(tester);
      expect(box.color!.a, 0);
      // The solid border is replaced by a painter…
      expect(box.border, isNull);
      final painter = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(Chip),
          matching: find.byWidgetPredicate(
            (w) => w is CustomPaint && w.foregroundPainter != null,
          ),
        ),
      );
      expect(painter.foregroundPainter, isNotNull);
      // …which takes no space: the chip is the same size as a solid one.
      final dashed = tester.getSize(find.byType(Chip));

      await pumpFinesse(tester, const Center(child: Chip(label: Text('Add'))));
      expect(tester.getSize(find.byType(Chip)).height, dashed.height);
      expect(s.borderStrong, isNot(s.border));
    });

    testWidgets('the dashed outline is drawn in borderStrong, inside the '
        'chip, with gaps', (tester) async {
      final boundary = GlobalKey();
      await pumpFinesse(
        tester,
        Center(
          child: RepaintBoundary(
            key: boundary,
            child: const ColoredBox(
              color: Color(0xffffffff),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Chip(
                  label: SizedBox(width: 80, height: 10),
                  variant: ChipVariant.dashed,
                  // Opaque, so the sampled pixels are exactly this.
                  borderColor: Color(0xff000000),
                ),
              ),
            ),
          ),
        ),
      );

      late final ui.Image image;
      await tester.runAsync(() async {
        image =
            await (boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage();
      });
      final data = (await tester.runAsync(() => image.toByteData()))!;
      bool dark(int x, int y) => data.getUint8((y * image.width + x) * 4) < 128;

      // Along the chip's top edge (y = 8, the first row inside it), over the
      // straight middle section.
      final row = [for (var x = 40; x < 90; x++) dark(x, 8)];
      expect(row, contains(true), reason: 'dashes');
      expect(row, contains(false), reason: 'gaps');
      // 3 on, 3 off, give or take the stretch that closes the loop.
      var runs = 0;
      for (var i = 1; i < row.length; i++) {
        if (row[i] != row[i - 1]) runs++;
      }
      expect(runs, greaterThan(10));
      // Nothing is painted outside the chip's box.
      for (var x = 40; x < 90; x++) {
        expect(dark(x, 7), isFalse);
      }
    });

    testWidgets('a selected dashed chip is solid like any other', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: Chip(
            label: Text('Add'),
            variant: ChipVariant.dashed,
            selected: true,
          ),
        ),
      );
      final s = themeOf(tester, find.byType(Chip)).colorScheme;
      expect(boxOf(tester).color, s.accent);
      expect((boxOf(tester).border! as Border).top.color, s.accentBorder);
    });

    testWidgets('keyboard focus draws the ring', (tester) async {
      useTraditionalHighlights();
      await pumpFinesse(
        tester,
        Center(
          child: Chip(label: const Text('Remote'), onPressed: () {}),
        ),
      );
      expect(tester.widget<FocusRing>(find.byType(FocusRing)).visible, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final ring = tester.widget<FocusRing>(find.byType(FocusRing));
      expect(ring.visible, isTrue);
      expect(ring.borderRadius, boxOf(tester).borderRadius);
    });
  });

  group('Chip semantics', () {
    testWidgets('a toggle chip is a button that says when it is selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Center(
          child: Chip(
            label: const Text('Remote'),
            selected: true,
            onSelected: (_) {},
          ),
        ),
      );
      final data = tester.getSemantics(find.byType(Chip)).getSemanticsData();
      expect(data.label, 'Remote');
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isEnabled, ui.Tristate.isTrue);
      expect(data.flagsCollection.isSelected, ui.Tristate.isTrue);
      expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('an unselected toggle chip says it is not selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Center(
          child: Chip(label: const Text('Remote'), onSelected: (_) {}),
        ),
      );
      final data = tester.getSemantics(find.byType(Chip)).getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isSelected, ui.Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('an action chip announces a selected state only when it is '
        'selected', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Center(
          child: Chip(label: const Text('Clear'), onPressed: () {}),
        ),
      );
      expect(
        tester
            .getSemantics(find.byType(Chip))
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        ui.Tristate.none,
      );

      await pumpFinesse(
        tester,
        Center(
          child: Chip(
            label: const Text('Clear'),
            selected: true,
            onPressed: () {},
          ),
        ),
      );
      final data = tester.getSemantics(find.byType(Chip)).getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isSelected, ui.Tristate.isTrue);
      handle.dispose();
    });

    testWidgets('a selected static chip is announced as selected, and still '
        'not as a button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        const Center(child: Chip(label: Text('Figma'), selected: true)),
      );
      final data = tester.getSemantics(find.text('Figma')).getSemanticsData();
      expect(data.label, 'Figma');
      expect(data.flagsCollection.isSelected, ui.Tristate.isTrue);
      expect(data.flagsCollection.isButton, isFalse);
      expect(data.hasAction(ui.SemanticsAction.tap), isFalse);
      expect(find.byType(Pressable), findsNothing);
      handle.dispose();
    });

    testWidgets('an action chip is an enabled button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Center(
          child: Chip(label: const Text('Clear'), onPressed: () {}),
        ),
      );
      expect(
        tester.getSemantics(find.byType(Chip)),
        matchesSemantics(
          label: 'Clear',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('a static chip is plain text, not a disabled button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        const Center(child: Chip(label: Text('Figma'))),
      );

      final data = tester.getSemantics(find.text('Figma')).getSemanticsData();
      expect(data.label, 'Figma');
      expect(data.flagsCollection.isButton, isFalse);
      expect(data.flagsCollection.isEnabled, ui.Tristate.none);
      expect(data.flagsCollection.isSelected, ui.Tristate.none);
      expect(data.hasAction(ui.SemanticsAction.tap), isFalse);
      handle.dispose();
    });

    testWidgets('semanticLabel names the chip', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Center(
          child: Chip(
            label: const Icon(PhosphorIconsRegular.globe),
            semanticLabel: 'Remote only',
            onPressed: () {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Remote only'), findsOneWidget);
      handle.dispose();
    });
  });
}
