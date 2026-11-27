import 'package:example/common/app_shell.dart';
import 'package:example/common/app_state.dart';
import 'package:example/common/una_logo.dart';
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

  /// The window's top bar: the one the logo is in.
  final topBar = find
      .ancestor(of: find.byType(UnaLogo), matching: find.byType(AppBar))
      .first;

  ComponentsScreenState docs(WidgetTester tester) =>
      tester.state<ComponentsScreenState>(find.byType(ComponentsScreen));

  AppSection section(WidgetTester tester) =>
      appSectionProvider.of(appContext(tester)).value;

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

  group('the top bar', () {
    testWidgets('spans the window, with the logo at its start and the '
        'settings at its end, the editor open or not', (tester) async {
      await pumpApp(tester, size: wide);

      Rect logo() => tester.getRect(find.byType(UnaLogo).first);
      Rect brush() =>
          tester.getRect(find.byIcon(PhosphorIconsRegular.paintBrush).first);

      void expectAcrossTheWindow() {
        expect(tester.getRect(topBar).left, 0);
        expect(tester.getSize(topBar).width, wide.width);
        // At the bar's own margins, not held to the page's measure.
        expect(logo().left, lessThanOrEqualTo(32));
        expect(brush().right, greaterThanOrEqualTo(wide.width - 32));
      }

      expectAcrossTheWindow();
      final closed = (logo(), brush());

      await toggleEditor(tester);
      expect(find.byType(ThemeCustomizerPanel), findsOneWidget);
      expectAcrossTheWindow();
      expect((logo(), brush()), closed);
      // The panel is under the bar, not beside it.
      expect(
        tester.getTopLeft(find.byType(ThemeCustomizerPanel)).dy,
        greaterThan(tester.getBottomLeft(topBar).dy),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('has three destinations; Introduction and Components open '
        'their pages, and the one selected follows the page shown', (
      tester,
    ) async {
      await pumpApp(tester);
      Finder inBar(String label) =>
          find.descendant(of: topBar, matching: find.text(label));
      for (final label in ['Showcase', 'Introduction', 'Components']) {
        expect(inBar(label), findsOneWidget, reason: label);
      }
      expect(
        find.descendant(
          of: topBar,
          matching: find.byIcon(PhosphorIconsRegular.balloon),
        ),
        findsOneWidget,
      );
      expect(section(tester), AppSection.introduction);
      expect(docs(tester).selectedSlug, 'introduction');

      // Components: the overview, with the sidebar scrolled down to it.
      final sidebarScroll = find
          .ancestor(
            of: inSidebar(find.text('Getting started')),
            matching: find.byType(Scrollable),
          )
          .first;
      expect(tester.state<ScrollableState>(sidebarScroll).position.pixels, 0);
      await tester.tap(inBar('Components'));
      await settle(tester);
      expect(section(tester), AppSection.components);
      expect(docs(tester).selectedSlug, 'overview');
      expect(
        tester.state<ScrollableState>(sidebarScroll).position.pixels,
        greaterThan(0),
      );

      // A guide opened from the sidebar selects Introduction, a component
      // Components.
      await openPage(tester, 'Theming');
      expect(section(tester), AppSection.introduction);
      await openPage(tester, 'Badge');
      expect(section(tester), AppSection.components);

      // Away to the showcase and back: the page is kept.
      await tester.tap(inBar('Showcase'));
      await settle(tester);
      expect(find.byType(ComponentsScreen), findsNothing);
      await tester.tap(inBar('Components'));
      await settle(tester);
      expect(docs(tester).selectedSlug, 'badge');

      // Introduction from a component page: the introduction.
      await tester.tap(inBar('Introduction'));
      await settle(tester);
      expect(section(tester), AppSection.introduction);
      expect(docs(tester).selectedSlug, 'introduction');
      expect(tester.takeException(), isNull);
    });

    testWidgets('the showcase\'s way to the reference opens the components', (
      tester,
    ) async {
      await pumpApp(tester, startOn: AppSection.showcase);
      appSectionProvider.of(appContext(tester)).value = AppSection.components;
      await settle(tester);
      expect(docs(tester).selectedSlug, 'overview');
      expect(tester.takeException(), isNull);
    });

    testWidgets('on a phone the three are in the bottom bar', (tester) async {
      await pumpApp(tester, size: mobileSize);
      final bar = find.byType(BottomNavigationBar);
      expect(bar, findsOneWidget);
      // Icons only, as a phone's bar is by default.
      Finder inBar(IconData icon) =>
          find.descendant(of: bar, matching: find.byIcon(icon));
      expect(inBar(PhosphorIconsRegular.balloon), findsOneWidget);
      expect(inBar(PhosphorIconsFill.bookOpen), findsOneWidget);
      expect(inBar(PhosphorIconsRegular.squaresFour), findsOneWidget);
      await tester.tap(inBar(PhosphorIconsRegular.squaresFour));
      await settle(tester);
      expect(section(tester), AppSection.components);
      expect(docs(tester).selectedSlug, 'overview');
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
      const margin = 12.0;
      expect(ThemeCustomizerPanel.dockMargin, margin);
      expect(tester.getSize(panel).width, ThemeCustomizerPanel.width);
      expect(
        tester.getSize(find.byType(ComponentsSection)).width,
        wide.width - ThemeCustomizerPanel.width - 2 * margin,
      );
      // A box under the top bar, clear of the window's edges.
      final box = tester.getRect(panel);
      expect(box.right, wide.width - margin);
      expect(box.bottom, wide.height - margin);
      expect(box.top, tester.getBottomLeft(topBar).dy + margin);
      // Docked, it needs no close button of its own.
      expect(find.byIcon(PhosphorIconsRegular.x), findsNothing);

      await toggleEditor(tester);
      expect(panel, findsNothing);
      expect(tester.getSize(find.byType(ComponentsSection)).width, wide.width);

      await toggleEditor(tester);
      expect(panel, findsOneWidget);
      expect(find.text('Focus Ring'), findsOneWidget);
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
      expect(
        tester.getTopLeft(find.byType(ThemeCustomizerPanel)).dx,
        ThemeCustomizerPanel.dockMargin,
      );
      expect(
        tester.getTopLeft(find.byType(ComponentsSection)).dx,
        AppShell.dockedPanelWidth,
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
