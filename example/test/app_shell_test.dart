import 'package:example/common/app_shell.dart';
import 'package:example/common/theme_editor/customizer_panel.dart';
import 'package:example/docs/registry.dart';
import 'package:example/screens/components_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import 'support.dart';

void main() {
  setUpAll(setUpFonts);

  const wide = Size(1400, 1200);

  Finder inSidebar(Finder finder) =>
      find.descendant(of: find.byType(Sidebar), matching: finder);

  /// Opens the docs page called [name] from the sidebar, folding its
  /// component category open first if it is shut. The list grows with the
  /// library, so the entry is scrolled into view first: a page added above
  /// it must not push it out of reach.
  Future<void> openPage(WidgetTester tester, String name) async {
    final entry = inSidebar(find.text(name));
    if (entry.evaluate().isEmpty) {
      final category = componentCategories.firstWhere(
        (c) => c.items.any((doc) => doc.title == name),
      );
      final fold = inSidebar(find.text(category.title));
      await tester.ensureVisible(fold);
      await settle(tester);
      await tester.tap(fold);
      await settle(tester);
    }
    await tester.ensureVisible(entry);
    await settle(tester);
    await tester.tap(entry);
    await settle(tester);
  }

  /// The paint-brush button in the component library's bar.
  Future<void> toggleEditor(WidgetTester tester) async {
    await tester.tap(find.byIcon(PhosphorIconsRegular.paintBrush).first);
    await settle(tester);
  }

  testWidgets('the app opens on the component library, with the editor '
      'closed', (tester) async {
    await pumpApp(tester, size: wide);

    expect(find.byType(ComponentsScreen), findsOneWidget);
    expect(find.byType(ThemeCustomizerPanel), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('the component library', () {
    testWidgets('opens the docs browser under its own bar', (tester) async {
      await pumpApp(tester, size: wide);

      expect(find.byType(ComponentsSection), findsOneWidget);
      expect(find.byType(Sidebar), findsOneWidget);
      expect(find.text('Components'), findsWidgets);
      expect(
        find.textContaining('una is a Flutter implementation'),
        findsOneWidget,
      );
      // The first route: nothing to go back to.
      expect(find.byIcon(PhosphorIconsRegular.arrowLeft), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecting a component in the sidebar opens its doc page', (
      tester,
    ) async {
      await pumpApp(tester, size: wide);

      await openPage(tester, 'Button');

      // The page's description: rich text, since it names widgets in code.
      expect(
        find.textContaining(
          'A label that does something when pressed.',
          findRichText: true,
        ),
        findsWidgets,
      );
    });

    testWidgets('the search box filters the sidebar', (tester) async {
      await pumpApp(tester, size: wide);

      await tester.enterText(inSidebar(find.byType(TextField)), 'badge');
      await settle(tester);

      expect(inSidebar(find.text('Badge')), findsOneWidget);
      expect(inSidebar(find.text('Accordion')), findsNothing);
    });

    testWidgets('its bar switches light and dark, and text direction', (
      tester,
    ) async {
      await pumpApp(tester, size: wide);

      await tester.tap(find.byIcon(PhosphorIconsRegular.sun));
      await settle(tester);
      expect(Theme.of(appContext(tester)).brightness, Brightness.dark);

      await tester.tap(find.byIcon(PhosphorIconsRegular.textAlignLeft));
      await settle(tester);
      expect(
        Directionality.of(tester.element(find.byType(ComponentsScreen))),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a phone', (tester) async {
      await pumpApp(tester, size: mobileSize);

      expect(find.byType(ComponentsScreen), findsOneWidget);
      expect(find.byIcon(PhosphorIconsRegular.paintBrush), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('the theme editor', () {
    testWidgets('docks beside the page, and closes again', (tester) async {
      await pumpApp(tester, size: wide);

      expect(find.byType(ThemeCustomizerPanel), findsNothing);
      await toggleEditor(tester);

      final panel = find.byType(ThemeCustomizerPanel);
      expect(panel, findsOneWidget);
      // Docked, not covering: the page is still there beside it, narrower.
      expect(tester.getSize(panel).width, ThemeCustomizerPanel.width);
      expect(
        tester.getSize(find.byType(ComponentsSection)).width,
        wide.width - ThemeCustomizerPanel.width,
      );
      expect(
        tester.getTopLeft(panel).dx,
        wide.width - ThemeCustomizerPanel.width,
      );
      // Docked, it needs no close button of its own.
      expect(find.byIcon(PhosphorIconsRegular.x), findsNothing);

      await toggleEditor(tester);
      expect(panel, findsNothing);
      expect(tester.getSize(find.byType(ComponentsSection)).width, wide.width);

      await toggleEditor(tester);
      expect(panel, findsOneWidget);
      expect(find.text('Style'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('docking it beside a medium window lays the page out for '
        'the room it is left with, and keeps the open page', (tester) async {
      await pumpApp(tester, size: const Size(1000, 900));
      await openPage(tester, 'Badge');
      ThemeData theme() =>
          Theme.of(tester.element(find.byType(ComponentsScreen)));
      expect(theme().formFactor, FormFactor.desktop);

      editorOpenSignal(tester).value = true;
      await settle(tester, frames: 20);
      // 1000 less the panel is below the phone breakpoint.
      expect(theme().formFactor, FormFactor.mobile);
      expect(
        tester
            .state<ComponentsScreenState>(find.byType(ComponentsScreen))
            .selectedSlug,
        'badge',
      );

      editorOpenSignal(tester).value = false;
      await settle(tester, frames: 20);
      expect(theme().formFactor, FormFactor.desktop);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the panel is built once for its slide, not on every frame '
        'of it', (tester) async {
      await pumpApp(tester);
      editorOpenSignal(tester).value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      final seen = <Widget>{};
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        seen.add(tester.widget(find.byType(ThemeCustomizerPanel)));
      }
      await settle(tester, frames: 20);
      expect(
        seen.length,
        1,
        reason: 'a new ThemeCustomizerPanel on ${seen.length} of 8 frames',
      );

      // And out again.
      editorOpenSignal(tester).value = false;
      await tester.pump();
      seen.clear();
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        seen.addAll(
          tester.widgetList(find.byType(ThemeCustomizerPanel)),
        );
      }
      expect(seen.length, lessThanOrEqualTo(1));
      await settle(tester, frames: 20);
      expect(find.byType(ThemeCustomizerPanel), findsNothing);
    });

    testWidgets('docks on the start side of nothing: it follows direction', (
      tester,
    ) async {
      await pumpApp(tester, size: wide);
      await toggleEditor(tester);
      await tester.tap(find.byIcon(PhosphorIconsRegular.textAlignLeft));
      await settle(tester);

      // In RTL the panel is at the left edge and the page beside it.
      expect(tester.getTopLeft(find.byType(ThemeCustomizerPanel)).dx, 0);
      expect(
        tester.getTopLeft(find.byType(ComponentsSection)).dx,
        ThemeCustomizerPanel.width,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('opening it keeps the page you were on', (tester) async {
      // Building the page conditionally around the panel used to drop the
      // docs browser's State, which sent you back to the first component
      // every time the editor was opened.
      await pumpApp(tester, size: wide);
      await openPage(tester, 'Badge');
      await toggleEditor(tester);

      expect(find.byType(ThemeCustomizerPanel), findsOneWidget);
      expect(
        find.textContaining(
          'A small pill that states something',
          findRichText: true,
        ),
        findsWidgets,
      );
    });

    testWidgets('stays closed on a narrow viewport until it is opened', (
      tester,
    ) async {
      await pumpApp(tester, size: const Size(600, 1000));

      expect(find.byType(ThemeCustomizerPanel), findsNothing);
    });

    testWidgets('fills a narrow viewport, and closes itself', (tester) async {
      const narrow = Size(600, 1000);
      await pumpApp(tester, size: narrow);
      await toggleEditor(tester);

      final panel = find.byType(ThemeCustomizerPanel);
      expect(panel, findsOneWidget);
      expect(tester.getSize(panel), narrow);
      // The page stays in the tree underneath — covered, not discarded, so
      // closing the panel brings back the page you were on.
      expect(find.byType(ComponentsScreen), findsOneWidget);
      expect(tester.getSize(find.byType(ComponentsSection)), narrow);

      // Every other toggle is underneath it, so it carries its own.
      await tester.tap(find.byIcon(PhosphorIconsRegular.x));
      await settle(tester);
      expect(panel, findsNothing);
      expect(find.byType(ComponentsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
