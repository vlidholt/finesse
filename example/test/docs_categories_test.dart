// The component reference by category: the sidebar folds the component
// pages by kind and the overview shows them by kind, both from
// `componentCategories`. `componentDocs` stays the flat, alphabetical list
// the skills generator reads, so the two have to agree: a page added to one
// and not the other would vanish from the sidebar, or from the skills.
import 'package:example/docs/docs.dart';
import 'package:example/docs/registry.dart';
import 'package:example/screens/components_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import 'support.dart';

void main() {
  group('componentCategories', () {
    test('names every component page exactly once', () {
      final placed = <String, List<String>>{};
      for (final category in componentCategories) {
        for (final doc in category.items) {
          (placed[doc.slug] ??= []).add(category.title);
        }
      }

      final missing = [
        for (final doc in componentDocs)
          if (!placed.containsKey(doc.slug)) doc.slug,
      ];
      expect(
        missing,
        isEmpty,
        reason:
            'Every page of `componentDocs` belongs in a category of '
            '`componentCategories` (lib/docs/registry.dart), or the '
            'sidebar does not list it.',
      );

      final twice = {
        for (final entry in placed.entries)
          if (entry.value.length > 1) entry.key: entry.value,
      };
      expect(twice, isEmpty, reason: 'A page is in one category only.');

      final components = {for (final doc in componentDocs) doc.slug};
      expect(
        placed.keys.where((slug) => !components.contains(slug)),
        isEmpty,
        reason:
            'A categorised page has to be in `componentDocs` too, which '
            'is what the skills generator reads.',
      );
    });

    test('has unique titles, says what each is for, and lists its pages '
        'alphabetically', () {
      final titles = <String>{};
      for (final category in componentCategories) {
        expect(titles.add(category.title), isTrue, reason: category.title);
        expect(category.description, isNotEmpty);
        expect(category.items, isNotEmpty, reason: category.title);
        final names = [
          for (final doc in category.items) doc.title.toLowerCase(),
        ];
        expect(names, [...names]..sort(), reason: category.title);
      }
    });

    test('are the Components section of the sidebar, after the overview', () {
      final components = docGroups.singleWhere(
        (group) => group.title == 'Components',
      );
      expect(components.items, [overviewDoc]);
      expect(components.categories, componentCategories);
      expect(components.pages.length, componentDocs.length + 1);
    });
  });

  group('the sidebar', () {
    setUpAll(setUpFonts);

    Finder inSidebar(Finder finder) =>
        find.descendant(of: find.byType(Sidebar), matching: finder);

    ComponentsScreenState docs(WidgetTester tester) =>
        tester.state<ComponentsScreenState>(find.byType(ComponentsScreen));

    DocCategory categoryOf(String slug) => componentCategories.firstWhere(
      (category) => category.items.any((doc) => doc.slug == slug),
    );

    testWidgets('shows the categories folded, and folds one open and shut', (
      tester,
    ) async {
      await pumpApp(tester, size: const Size(1400, 900));
      final actions = componentCategories.first;

      for (final category in componentCategories) {
        expect(inSidebar(find.text(category.title)), findsOneWidget);
      }
      // On the introduction no category is open: none of their pages is
      // built.
      expect(inSidebar(find.text(actions.items.first.title)), findsNothing);

      await tester.ensureVisible(inSidebar(find.text(actions.title)));
      await settle(tester);
      await tester.tap(inSidebar(find.text(actions.title)));
      await settle(tester);
      for (final doc in actions.items) {
        expect(inSidebar(find.text(doc.title)), findsOneWidget);
      }

      await tester.tap(inSidebar(find.text(actions.title)));
      await settle(tester);
      expect(inSidebar(find.text(actions.items.first.title)), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('opening a page folds its category open and names it in '
        'the breadcrumb', (tester) async {
      await pumpApp(tester, size: const Size(1400, 900));
      final state = docs(tester);
      final category = categoryOf('tooltip');

      state.open('tooltip');
      await settle(tester, frames: 20);

      expect(state.selectedSlug, 'tooltip');
      expect(state.selectedCategory, category);
      expect(state.openCategories, contains(category.title));
      expect(inSidebar(find.text('Tooltip')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Breadcrumb),
          matching: find.text(category.title),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a search finds pages in folded categories, and a '
        "category's title finds all of its pages", (tester) async {
      await pumpApp(tester, size: const Size(1400, 900));

      await tester.enterText(inSidebar(find.byType(TextField)), 'picker');
      await settle(tester);
      expect(inSidebar(find.text('Date Picker')), findsOneWidget);
      expect(inSidebar(find.text('Color Picker')), findsOneWidget);
      // A category with no match is not listed at all.
      expect(inSidebar(find.text('Chat')), findsNothing);

      await tester.enterText(inSidebar(find.byType(TextField)), 'chat');
      await settle(tester);
      for (final doc in categoryOf('chat_list').items) {
        expect(inSidebar(find.text(doc.title)), findsOneWidget);
      }

      // Cleared, the categories fold shut again.
      await tester.enterText(inSidebar(find.byType(TextField)), '');
      await settle(tester);
      expect(inSidebar(find.text('Streaming Text')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a card on the overview opens its page', (tester) async {
      await pumpApp(tester, size: const Size(1400, 900));
      final state = docs(tester);
      state.open('overview');
      await settle(tester, frames: 20);

      final card = find.ancestor(
        of: find.text('Kbd'),
        matching: find.byType(Card),
      );
      await tester.ensureVisible(card.first);
      await settle(tester);
      await tester.tap(card.first);
      await settle(tester, frames: 20);

      expect(state.selectedSlug, 'kbd');
      expect(state.openCategories, contains(categoryOf('kbd').title));
      expect(tester.takeException(), isNull);
    });

    testWidgets("on a phone the sheet's categories fold open, its search "
        'filters, and a page put the sheet away', (tester) async {
      await pumpApp(tester, size: const Size(390, 844));
      final state = docs(tester);
      final chat = categoryOf('chat_list');

      // The overview, on a phone: a row per page instead of a card.
      state.open('overview');
      await settle(tester, frames: 20);
      expect(find.text('Chat List'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('Chat List'),
          matching: find.byType(ListTile),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byType(SidebarTrigger));
      await settle(tester, frames: 20);
      // The sheet keeps the sidebar it was opened with; its content has to
      // follow the screen's state all the same.
      await tester.ensureVisible(inSidebar(find.text(chat.title)));
      await settle(tester);
      await tester.tap(inSidebar(find.text(chat.title)));
      await settle(tester);
      expect(inSidebar(find.text('Streaming Text')), findsOneWidget);

      await tester.enterText(inSidebar(find.byType(TextField)), 'tooltip');
      await settle(tester);
      expect(inSidebar(find.text('Streaming Text')), findsNothing);
      expect(inSidebar(find.text('Tooltip')), findsOneWidget);

      await tester.tap(inSidebar(find.text('Tooltip')));
      await settle(tester, frames: 20);
      expect(state.selectedSlug, 'tooltip');
      expect(find.byType(Sidebar), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
