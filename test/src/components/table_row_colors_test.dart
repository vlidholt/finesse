import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../frame_sampler.dart';

/// A hovered row is a barely-there wash; a selected one is one clear step
/// past it.
///
/// The hover used to be `muted.withValues(alpha: .5)`, which *replaces* the
/// alpha: fine for shadcn's opaque muted grey, but teal's `muted` is a 4%
/// wash of the foreground, and at 50% it painted the row almost as dark as
/// its text. The pixel tests below read the row off the screen so that
/// cannot come back unseen.
void main() {
  group('TableTheme row colours', () {
    test('una: a faint hover, an accent-tinted selection', () {
      final light = ThemeData();
      final dark = ThemeData(brightness: Brightness.dark);

      // Light: 3–5% of the foreground.
      final hover = light.tableTheme.rowHoverColor!;
      expect(hover.a, inInclusiveRange(.03, .05));
      expect(
        hover.withValues(alpha: 1),
        light.colorScheme.foreground.withValues(alpha: 1),
      );
      // Dark: 5–7% of a near-white.
      final hoverDark = dark.tableTheme.rowHoverColor!;
      expect(hoverDark.a, inInclusiveRange(.05, .07));
      expect(
        hoverDark.withValues(alpha: 1).computeLuminance(),
        greaterThan(.8),
      );

      for (final theme in [light, dark]) {
        final table = theme.tableTheme;
        final card = theme.colorScheme.card.withValues(alpha: 1);
        double step(Color wash) =>
            (over(wash, card).computeLuminance() - card.computeLuminance())
                .abs();
        final selected = table.rowSelectedColor!;
        // The scheme's tint, not a grey…
        expect(
          selected.withValues(alpha: 1),
          theme.colorScheme.tint.withValues(alpha: 1),
        );
        // …clearly past the hover, and still a wash: no more than three
        // times its step.
        final hoverStep = step(table.rowHoverColor!);
        expect(step(selected), greaterThan(hoverStep * 1.3));
        expect(step(selected), lessThan(hoverStep * 3.2));
        // The footer sits between nothing and a hovered row.
        expect(step(table.footerColor!), lessThan(hoverStep));
        expect(step(table.footerHoverColor!), greaterThan(hoverStep));
      }
    });

    test('the shadcn styles keep muted/50 and muted', () {
      for (final style in [
        StyleTokens.nova,
        StyleTokens.maia,
        StyleTokens.lyra,
      ]) {
        for (final scheme in const <ColorScheme>[
          NeutralColorScheme.light(),
          NeutralColorScheme.dark(),
        ]) {
          final theme = ThemeData(style: style, colorScheme: scheme);
          final muted = scheme.muted;
          // `hover:bg-muted/50`.
          expect(
            theme.tableTheme.rowHoverColor,
            muted.withValues(alpha: muted.a * .5),
          );
          // `data-[state=selected]:bg-muted`.
          expect(theme.tableTheme.rowSelectedColor, muted);
          // The footer's `bg-muted/50`, and the row hover on top of it.
          expect(
            theme.tableTheme.footerColor,
            muted.withValues(alpha: muted.a * .5),
          );
          expect(theme.tableTheme.footerHoverColor, muted);
        }
      }
    });
  });

  group('on screen', () {
    Future<FrameSampler> pump(
      WidgetTester tester,
      ThemeData theme,
      Widget child,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(600, 400);
      addTearDown(tester.view.reset);
      final sampler = FrameSampler();
      await tester.pumpWidget(
        sampler.wrap(
          UnaApp(
            theme: theme,
            darkTheme: theme,
            home: Builder(
              builder: (context) => ColoredBox(
                // Opaque, so the expected pixel is one blend away.
                color: Theme.of(context).colorScheme.card.withValues(alpha: 1),
                child: child,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      return sampler;
    }

    void expectPixel(Color seen, Color expected, String reason) {
      final a = rgbOf(seen);
      final b = rgbOf(expected);
      for (var c = 0; c < 3; c++) {
        expect(a[c], closeTo(b[c], 2), reason: '$reason: $seen vs $expected');
      }
    }

    for (final (name, theme) in [
      ('una light', ThemeData()),
      ('una dark', ThemeData(brightness: Brightness.dark)),
      (
        'nova light',
        ThemeData(
          style: StyleTokens.nova,
          colorScheme: const NeutralColorScheme.light(),
        ),
      ),
      (
        'nova dark',
        ThemeData(
          style: StyleTokens.nova,
          colorScheme: const NeutralColorScheme.dark(),
        ),
      ),
    ]) {
      testWidgets('$name: a hovered and a selected table row', (tester) async {
        final sampler = await pump(
          tester,
          theme,
          UnaTable.list(
            header: const [
              UnaTableCell.header(child: Text('A')),
              UnaTableCell.header(child: Text('B')),
            ],
            footer: const [
              UnaTableCell.footer(child: Text('T')),
              UnaTableCell.footer(child: Text('9')),
            ],
            // Row 2 (the second body row) is selected.
            rowSelected: (row) => row == 2,
            columnSpanExtent: (_) => const FixedTableSpanExtent(250),
            children: const [
              [
                UnaTableCell(child: Text('a')),
                UnaTableCell(child: Text('1')),
              ],
              [
                UnaTableCell(child: Text('b')),
                UnaTableCell(child: Text('2')),
              ],
              [
                UnaTableCell(child: Text('c')),
                UnaTableCell(child: Text('3')),
              ],
            ],
          ),
        );
        final table = theme.tableTheme;
        final surface = theme.colorScheme.card.withValues(alpha: 1);
        // A point at the far end of each row, clear of the cell text.
        Offset rowPoint(String text) =>
            Offset(480, tester.getCenter(find.text(text)).dy);

        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        // At rest: nothing on a plain row, the selection on its own.
        expectPixel(
          await sampler.pixel(tester, rowPoint('a')),
          surface,
          '$name rest',
        );
        expectPixel(
          await sampler.pixel(tester, rowPoint('b')),
          over(table.rowSelectedColor!, surface),
          '$name selected',
        );
        expectPixel(
          await sampler.pixel(tester, rowPoint('T')),
          over(table.footerColor!, surface),
          '$name footer',
        );

        await gesture.moveTo(rowPoint('a'));
        await tester.pump();
        await tester.pump();
        final hovered = await sampler.pixel(tester, rowPoint('a'));
        expectPixel(
          hovered,
          over(table.rowHoverColor!, surface),
          '$name hover',
        );
        // Barely there: within 6% of the surface on every channel, in any
        // theme.
        for (var c = 0; c < 3; c++) {
          expect(
            (rgbOf(hovered)[c] - rgbOf(surface)[c]).abs(),
            lessThanOrEqualTo(15),
            reason: '$name hover is too strong: $hovered',
          );
        }

        // A selected row stays selected under the pointer.
        await gesture.moveTo(rowPoint('b'));
        await tester.pump();
        await tester.pump();
        expectPixel(
          await sampler.pixel(tester, rowPoint('b')),
          over(table.rowSelectedColor!, surface),
          '$name selected, hovered',
        );

        await gesture.moveTo(rowPoint('T'));
        await tester.pump();
        await tester.pump();
        expectPixel(
          await sampler.pixel(tester, rowPoint('T')),
          over(table.footerHoverColor!, surface),
          '$name footer, hovered',
        );
      });
    }

    testWidgets('a DataTable fills the rows it has selected', (tester) async {
      final theme = ThemeData();
      final controller = DataTableController<String>(
        rows: const ['Ada', 'Brook', 'Cleo'],
      );
      addTearDown(controller.dispose);
      final sampler = await pump(
        tester,
        theme,
        SizedBox(
          height: 300,
          child: DataTable<String>(
            controller: controller,
            selectable: true,
            keyOf: (row) => row,
            columns: [
              DataTableColumn(
                id: 'name',
                header: 'Name',
                cellBuilder: (context, row) => Text(row),
              ),
            ],
          ),
        ),
      );
      final surface = theme.colorScheme.card.withValues(alpha: 1);
      // Just before the row's text, inside its cell's padding.
      Offset rowPoint(String text) =>
          tester.getTopLeft(find.text(text)) + const Offset(-6, -4);

      expectPixel(
        await sampler.pixel(tester, rowPoint('Brook')),
        surface,
        'unselected',
      );
      controller.setSelected('Brook', selected: true);
      await tester.pump();
      await tester.pump();
      expectPixel(
        await sampler.pixel(tester, rowPoint('Brook')),
        over(theme.tableTheme.rowSelectedColor!, surface),
        'selected',
      );
      expectPixel(
        await sampler.pixel(tester, rowPoint('Ada')),
        surface,
        'its neighbour',
      );
    });
  });
}
