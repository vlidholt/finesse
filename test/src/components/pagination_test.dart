import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => FinesseApp(
    builder: (context, child) => FinesseMaterial(child: child!),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('inactive page buttons match the selected button size', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const Pagination(
          page: 2,
          pageCount: 5,
          showEdges: false,
          onPageChanged: _noop,
        ),
      ),
    );

    final selected = tester.getSize(find.text('2'));
    for (final label in ['1', '3', '4', '5']) {
      expect(tester.getSize(find.text(label)), selected);
    }
  });

  testWidgets('changing the selected page does not move edge labels', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const _PaginationHarness()));

    final previousBefore = tester.getTopLeft(find.text('Previous'));
    final nextBefore = tester.getTopLeft(find.text('Next'));

    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Previous')), previousBefore);
    expect(tester.getTopLeft(find.text('Next')), nextBefore);
  });

  group('Pagination.buildPageWindow', () {
    test('returns every page when they all fit', () {
      expect(
        Pagination.buildPageWindow(page: 1, pageCount: 5),
        [1, 2, 3, 4, 5],
      );
    });

    test('inserts an ellipsis for a skipped run', () {
      expect(
        Pagination.buildPageWindow(page: 1, pageCount: 20),
        [1, 2, null, 20],
      );
    });

    test('windows around the current page', () {
      expect(
        Pagination.buildPageWindow(page: 10, pageCount: 20),
        [1, null, 9, 10, 11, null, 20],
      );
    });

    test('renders the page itself rather than hiding a single one', () {
      // A gap of exactly one page would make the ellipsis longer than the
      // number it replaces.
      expect(
        Pagination.buildPageWindow(page: 4, pageCount: 7),
        [1, 2, 3, 4, 5, 6, 7],
      );
    });

    test('handles the degenerate cases', () {
      expect(Pagination.buildPageWindow(page: 1, pageCount: 0), isEmpty);
      expect(Pagination.buildPageWindow(page: 1, pageCount: 1), [1]);
      // An out-of-range page is clamped rather than throwing.
      expect(
        Pagination.buildPageWindow(page: 99, pageCount: 3),
        [1, 2, 3],
      );
    });
  });

  group('Pagination', () {
    Widget wrap(Widget child) => FinesseApp(home: Center(child: child));

    testWidgets('navigates with the previous/next buttons', (tester) async {
      final visited = <int>[];
      await tester.pumpWidget(
        wrap(
          Pagination(
            page: 5,
            pageCount: 20,
            onPageChanged: visited.add,
          ),
        ),
      );

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(visited, [6]);

      await tester.tap(find.text('Previous'));
      await tester.pumpAndSettle();
      expect(visited, [6, 4]);
    });

    testWidgets('does not go before the first page', (tester) async {
      final visited = <int>[];
      await tester.pumpWidget(
        wrap(
          Pagination(page: 1, pageCount: 5, onPageChanged: visited.add),
        ),
      );

      await tester.tap(find.text('Previous'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(visited, isEmpty);
    });

    testWidgets('jumps to a tapped page number', (tester) async {
      final visited = <int>[];
      await tester.pumpWidget(
        wrap(
          Pagination(page: 1, pageCount: 5, onPageChanged: visited.add),
        ),
      );

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      expect(visited, [3]);
    });
  });
}

void _noop(int _) {}

class _PaginationHarness extends StatefulWidget {
  const _PaginationHarness();

  @override
  State<_PaginationHarness> createState() => _PaginationHarnessState();
}

class _PaginationHarnessState extends State<_PaginationHarness> {
  int page = 2;

  @override
  Widget build(BuildContext context) {
    return Pagination(
      page: page,
      pageCount: 5,
      onPageChanged: (value) => setState(() => page = value),
    );
  }
}
