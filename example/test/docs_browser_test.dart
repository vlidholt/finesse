import 'package:example/docs/registry.dart';
import 'package:example/screens/components_screen.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  setUpAll(setUpFonts);

  /// The component library, which is where the docs browser lives.
  Future<void> pumpDocs(WidgetTester tester) async {
    await pumpApp(tester, size: const Size(1400, 900));
  }

  ComponentsScreenState docs(WidgetTester tester) =>
      tester.state<ComponentsScreenState>(find.byType(ComponentsScreen));

  /// The offset of the docs sidebar's content area — the one scrollable
  /// under the sidebar with anywhere to go (the search field nests its own,
  /// extentless one).
  double sidebarOffset(WidgetTester tester) {
    final scrollable = find.descendant(
      of: find.byType(Sidebar),
      matching: find.byType(Scrollable),
    );
    return tester
        .stateList<ScrollableState>(scrollable)
        .firstWhere((s) => s.position.maxScrollExtent > 0)
        .position
        .pixels;
  }

  testWidgets('opens on the written pages; open() reveals a section', (
    tester,
  ) async {
    await pumpDocs(tester);

    // Lands on the Introduction page, sidebar at the top.
    expect(find.text('Getting started'), findsWidgets);
    expect(
      find.textContaining('finesse is a Flutter implementation'),
      findsOneWidget,
    );
    final state = docs(tester);
    expect(state.selectedSlug, 'introduction');
    expect(sidebarOffset(tester), 0);

    // Opening the component reference scrolls the sidebar down to the
    // Components section.
    final components = docGroups.firstWhere((g) => g.title == 'Components');
    state.open(components.items.first.slug);
    // Three pumps: the reveal is scheduled post-frame, its animation ticks
    // from the following frame, and completes on the one after.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(state.selectedSlug, 'overview');
    expect(sidebarOffset(tester), greaterThan(0));

    // Back to the first page: Introduction again, scrolled back up.
    state.open(docGroups.first.items.first.slug);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(state.selectedSlug, 'introduction');
    expect(sidebarOffset(tester), 0);
  });

  testWidgets('the breadcrumb names the section of the open page', (
    tester,
  ) async {
    await pumpDocs(tester);

    // Breadcrumb: "Getting started / Introduction".
    final state = docs(tester);
    expect(state.selectedGroup.title, 'Getting started');

    // Selecting a page in another group moves the breadcrumb with it.
    await tester.tap(find.text('Typography'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(state.selectedGroup.title, 'Foundations');
    expect(find.text('Foundations'), findsWidgets);
  });
}
