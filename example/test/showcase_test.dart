import 'package:example/common/app_state.dart';
import 'package:example/common/theme_editor/customizer_panel.dart';
import 'package:example/screens/components_screen.dart';
import 'package:example/showcase/showcase_layout.dart';
import 'package:example/showcase/showcase_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import 'support.dart';

/// The showcase is what the app opens on; the top bar switches to the
/// reference; on a desktop the editor opens beside it by itself.
void main() {
  setUpAll(setUpFonts);

  Finder visible<T>() => find.byType(T);

  testWidgets('the app opens on the showcase, and the bar switches to the '
      'reference and back, keeping each', (tester) async {
    await pumpApp(tester, startOn: AppSection.showcase);
    expect(visible<ShowcaseScreen>(), findsOneWidget);
    expect(visible<ComponentsScreen>(), findsNothing);

    await tester.tap(find.text('Components').first);
    await settle(tester);
    expect(visible<ComponentsScreen>(), findsOneWidget);
    expect(visible<ShowcaseScreen>(), findsNothing);
    // Still built, off stage: its state is kept.
    expect(
      find.byType(ShowcaseScreen, skipOffstage: false),
      findsOneWidget,
    );

    await tester.tap(find.text('Showcase').first);
    await settle(tester);
    expect(visible<ShowcaseScreen>(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('on a desktop the editor opens by itself; on a phone it does '
      'not', (tester) async {
    await pumpApp(tester, startOn: AppSection.showcase, openEditor: true);
    expect(find.byType(ThemeCustomizerPanel), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpApp(
      tester,
      size: mobileSize,
      startOn: AppSection.showcase,
      openEditor: true,
    );
    expect(find.byType(ThemeCustomizerPanel), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets("the header's buttons open the editor and the reference", (
    tester,
  ) async {
    await pumpApp(tester, startOn: AppSection.showcase);
    await tester.tap(find.text('Customize the theme'));
    await settle(tester);
    expect(find.byType(ThemeCustomizerPanel), findsOneWidget);

    await tester.tap(find.text('Browse components'));
    await settle(tester);
    expect(
      appSectionProvider.of(appContext(tester)).value,
      AppSection.components,
    );
    expect(tester.takeException(), isNull);
  });

  for (final (width, columns) in [(1440.0, 3), (900.0, 2), (390.0, 1)]) {
    testWidgets('at $columns columns every card sits on the grid', (
      tester,
    ) async {
      await pumpApp(
        tester,
        size: Size(width, 900),
        startOn: AppSection.showcase,
      );
      final masonries = find.byType(ShowcaseMasonry, skipOffstage: false);
      expect(masonries, findsNWidgets(2));
      final grid = tester.widget<ShowcaseMasonry>(masonries.first).columns;
      expect(grid.count, columns);
      final origin = tester.getTopLeft(masonries.first).dx;
      final starts = [
        for (var c = 0; c < grid.count; c++) origin + grid.start(c),
      ];
      final ends = [for (final start in starts) start + grid.column];

      // Every card of both masonries starts and ends on a column.
      for (final masonry in masonries.evaluate()) {
        final render = masonry.renderObject! as RenderBox;
        render.visitChildren((child) {
          final box = child as RenderBox;
          final left = box.localToGlobal(Offset.zero).dx;
          expect(starts.any((s) => (s - left).abs() < .01), isTrue);
          expect(
            ends.any((e) => (e - (left + box.size.width)).abs() < .01),
            isTrue,
          );
        });
      }

      // The revenue (found by its description: a stat tile is called
      // Revenue too) is two columns and a gutter wide on a desktop, the top
      // pages the third column; below that the revenue is the whole grid.
      Rect cardOf(String text) => tester.getRect(
        find
            .ancestor(
              of: find.textContaining(text, skipOffstage: false),
              matching: find.byType(Card, skipOffstage: false),
            )
            .first,
      );
      final revenue = cardOf('53% up on last year');
      expect(revenue.left, moreOrLessEquals(starts.first, epsilon: .01));
      expect(
        revenue.right,
        moreOrLessEquals(ends[columns >= 3 ? 1 : columns - 1], epsilon: .01),
      );
      if (columns >= 3) {
        final pages = cardOf('Views this month');
        expect(pages.left, moreOrLessEquals(starts[2], epsilon: .01));
        expect(pages.right, moreOrLessEquals(ends[2], epsilon: .01));
        expect(pages.height, moreOrLessEquals(revenue.height, epsilon: .01));
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final (name, size) in [
    ('desktop', desktopSize),
    ('phone', mobileSize),
  ]) {
    testWidgets('builds every card on a $name, light and dark', (
      tester,
    ) async {
      await pumpApp(tester, size: size, startOn: AppSection.showcase);
      // Scroll the whole page through, so every card is laid out.
      final scrollable = find
          .descendant(
            of: find.byType(ShowcaseScreen),
            matching: find.byType(Scrollable),
          )
          .first;
      for (var i = 0; i < 12; i++) {
        await tester.drag(scrollable, const Offset(0, -600));
        await settle(tester);
      }
      themeModeProvider.of(appContext(tester)).value = ThemeMode.dark;
      await settle(tester);
      expect(find.text('Quick actions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
