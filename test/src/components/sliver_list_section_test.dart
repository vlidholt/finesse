import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/src/components/list_section.dart'
    show debugListSectionDivider;
import 'package:una/una.dart';

import '../../decoration_finders.dart';
import '../../una_harness.dart';

void main() {
  late int built;

  setUp(() => built = 0);

  Widget page({
    int count = 300,
    ListSectionVariant variant = ListSectionVariant.card,
    bool dividers = true,
    Widget? header = const Text('Packages'),
    Widget? footer = const Text('Read from the registry.'),
    VoidCallback? onTap,
    bool children = false,
  }) {
    Widget row(BuildContext context, int index) {
      built++;
      return ListTile(
        key: ValueKey('row $index'),
        leading: index.isEven ? const SizedBox(width: 28, height: 28) : null,
        title: Text('Package $index'),
        onTap: onTap,
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 360,
        height: 500,
        child: Builder(
          builder: (context) => CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
              if (children)
                SliverListSection(
                  header: header,
                  footer: footer,
                  variant: variant,
                  dividers: dividers,
                  children: [for (var i = 0; i < count; i++) row(context, i)],
                )
              else
                SliverListSection.builder(
                  header: header,
                  headerTrailing: const Text('See all'),
                  footer: footer,
                  variant: variant,
                  dividers: dividers,
                  itemCount: count,
                  itemBuilder: row,
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  // The section's own wrapper of a row carries the row's key too.
  Finder rowAt(int index) => find.byWidgetPredicate(
    (widget) => widget is ListTile && widget.key == ValueKey('row $index'),
  );

  ListSectionScope scopeOf(WidgetTester tester, int index) =>
      ListSectionScope.maybeOf(tester.element(find.text('Package $index')))!;

  ScrollPosition position(WidgetTester tester) =>
      tester.state<ScrollableState>(find.byType(Scrollable).first).position;

  group('SliverListSection', () {
    testWidgets('builds in every layout at twice the text size', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: page(),
        ),
      );
    });

    testWidgets('builds only the rows near the viewport, and more as it '
        'scrolls', (tester) async {
      await pumpUna(tester, page());
      expect(built, lessThan(40));
      expect(rowAt(0), findsOneWidget);
      expect(rowAt(120), findsNothing);
      position(tester).jumpTo(5000);
      await tester.pump();
      expect(rowAt(0), findsNothing);
      expect(find.byType(ListTile), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rows are told where they are: first, middle, last', (
      tester,
    ) async {
      await pumpUna(tester, page(count: 4));
      expect(scopeOf(tester, 0).position, ListSectionPosition.first);
      expect(scopeOf(tester, 1).position, ListSectionPosition.middle);
      expect(scopeOf(tester, 3).position, ListSectionPosition.last);
      expect(scopeOf(tester, 0).variant, ListSectionVariant.card);

      await pumpUna(tester, page(count: 1));
      expect(scopeOf(tester, 0).position, ListSectionPosition.only);
    });

    testWidgets('it looks as a ListSection does: the same card, the same '
        'rows in the same places', (tester) async {
      const tiles = [
        ListTile(key: ValueKey('row 0'), title: Text('Package 0')),
        ListTile(key: ValueKey('row 1'), title: Text('Package 1')),
        ListTile(key: ValueKey('row 2'), title: Text('Package 2')),
      ];
      await pumpUna(
        tester,
        const Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 360,
            child: ListSection(
              header: Text('Packages'),
              footer: Text('Read from the registry.'),
              children: tiles,
            ),
          ),
        ),
      );
      final boxRows = [
        for (var i = 0; i < 3; i++) tester.getRect(rowAt(i)),
      ];
      final boxHeader = tester.getRect(find.text('Packages'));
      final boxFooter = tester.getRect(find.text('Read from the registry.'));
      final cardDecoration = tester
          .widget<Container>(
            find.descendant(
              of: find.byType(Card),
              matching: find.byType(Container),
            ),
          )
          .decoration;
      final card = boxDecorationOf(
        tester
            .widget<Container>(
              find.descendant(
                of: find.byType(Card),
                matching: find.byType(Container),
              ),
            )
            .decoration,
      )!;

      await pumpUna(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 360,
            height: 500,
            child: CustomScrollView(
              slivers: [
                SliverListSection(
                  header: const Text('Packages'),
                  footer: const Text('Read from the registry.'),
                  children: tiles,
                ),
              ],
            ),
          ),
        ),
      );
      for (var i = 0; i < 3; i++) {
        expect(tester.getRect(rowAt(i)), boxRows[i], reason: 'row $i');
      }
      expect(tester.getRect(find.text('Packages')), boxHeader);
      expect(tester.getRect(find.text('Read from the registry.')), boxFooter);

      final decorated = tester.widget<DecoratedSliver>(
        find.byType(DecoratedSliver),
      );
      final own = boxDecorationOf(decorated.decoration)!;
      expect(shadowsOf(decorated.decoration), shadowsOf(cardDecoration));
      expect(own.color, card.color);
      expect(own.borderRadius, card.borderRadius);
      expect(own.border, card.border);
    });

    testWidgets('no row is clipped or composited on its own, and the card is '
        'one decoration', (tester) async {
      await pumpUna(tester, page());
      final viewport = find.byType(Viewport);
      for (final type in [ClipRRect, ClipRect, ClipPath, Opacity, Backdrop]) {
        expect(
          find.descendant(of: viewport, matching: find.byType(type)),
          findsNothing,
          reason: '$type',
        );
      }
      expect(find.byType(DecoratedSliver), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('the plain variant has no card', (tester) async {
      await pumpUna(tester, page(variant: ListSectionVariant.plain));
      expect(find.byType(DecoratedSliver), findsNothing);
      expect(tester.getRect(rowAt(0)).left, tester.getRect(rowAt(1)).left);
      expect(tester.getSize(rowAt(0)).width, 360);
      expect(scopeOf(tester, 0).rowBorderRadius, BorderRadius.zero);
    });

    testWidgets('an empty section draws no card', (tester) async {
      await pumpUna(tester, page(count: 0));
      expect(find.byType(DecoratedSliver), findsNothing);
      expect(find.text('Packages'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets("every row but the last has a hairline, from its row's text", (
      tester,
    ) async {
      await pumpUna(tester, page(count: 4));
      ({bool divider, double indent}) dividerOf(int index) =>
          debugListSectionDivider(tester.renderObject(rowAt(index)))!;
      expect(dividerOf(0).divider, isTrue);
      expect(dividerOf(2).divider, isTrue);
      expect(dividerOf(3).divider, isFalse);
      // Row 0 leads with a 28-point box; row 1 does not.
      final text0 = tester.getRect(find.text('Package 0')).left;
      final text1 = tester.getRect(find.text('Package 1')).left;
      final row = tester.getRect(rowAt(0)).left;
      expect(dividerOf(0).indent, closeTo(text0 - row, .5));
      expect(dividerOf(1).indent, closeTo(text1 - row, .5));
      expect(text0, greaterThan(text1));

      await pumpUna(tester, page(count: 4, dividers: false));
      expect(dividerOf(0).divider, isFalse);
    });

    testWidgets('the header scrolls away with the rows and the footer comes '
        'after the last', (tester) async {
      await pumpUna(tester, page(count: 30));
      expect(find.text('Packages'), findsOneWidget);
      expect(find.text('Read from the registry.'), findsNothing);
      position(tester).jumpTo(position(tester).maxScrollExtent);
      await tester.pump();
      expect(find.text('Packages'), findsNothing);
      final footer = tester.getRect(find.text('Read from the registry.'));
      expect(footer.top, greaterThan(tester.getRect(rowAt(29)).bottom));
    });

    testWidgets('a tap reaches the row, and the keyboard walks the rows', (
      tester,
    ) async {
      var taps = 0;
      await pumpUna(tester, page(count: 5, onTap: () => taps++));
      await tester.tap(find.text('Package 2'));
      await tester.pump();
      expect(taps, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 2);
    });

    testWidgets('at rest it schedules nothing, and scrolling builds no row '
        'twice', (tester) async {
      await pumpUna(tester, page());
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      final before = built;
      position(tester).jumpTo(1);
      await tester.pump();
      position(tester).jumpTo(2);
      await tester.pump();
      expect(built, before);
    });

    testWidgets('the rows are a list, each an item with its index', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, page(count: 5, onTap: () {}));
      expect(tester.takeException(), isNull);
      expect(
        tester.getSemantics(find.text('Packages')),
        matchesSemantics(label: 'Packages', isHeader: true),
      );
      SemanticsNode? list;
      void find_(SemanticsNode node) {
        if (node.role == SemanticsRole.list) list = node;
        node.visitChildren((child) {
          find_(child);
          return true;
        });
      }

      find_(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
      expect(list, isNotNull);
      final indices = <int?>[];
      list!.visitChildren((child) {
        if (child.role == SemanticsRole.listItem) {
          indices.add(child.indexInParent);
        }
        return true;
      });
      expect(indices, [0, 1, 2, 3, 4]);
      handle.dispose();
    });

    testWidgets('a row may have a GlobalKey, and keeps its state when the '
        'rows are reordered', (tester) async {
      final keys = [for (var i = 0; i < 3; i++) GlobalKey(debugLabel: '$i')];
      var order = [0, 1, 2];
      late StateSetter rebuild;
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return CustomScrollView(
              slivers: [
                SliverListSection.builder(
                  itemCount: order.length,
                  findChildIndexCallback: (key) {
                    final index = order.indexWhere((i) => keys[i] == key);
                    return index < 0 ? null : index;
                  },
                  itemBuilder: (context, index) => ListTile(
                    key: keys[order[index]],
                    title: Text('Row ${order[index]}'),
                  ),
                ),
              ],
            );
          },
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Row 0'), findsOneWidget);
      final element = keys[0].currentContext;
      rebuild(() => order = [2, 1, 0]);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(keys[0].currentContext, same(element));
      expect(
        tester.getTopLeft(find.text('Row 0')).dy,
        greaterThan(tester.getTopLeft(find.text('Row 2')).dy),
      );
    });
  });
}
