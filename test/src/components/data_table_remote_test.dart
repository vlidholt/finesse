import 'dart:async';

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

class _Order {
  const _Order(this.id, this.customer, this.total);

  final int id;
  final String customer;
  final int total;
}

/// 23 orders that live "on a server": pages are handed out when the test
/// says so.
class _Source {
  final all = [
    for (var i = 1; i <= 23; i++) _Order(i, 'Customer $i', (i * 37) % 100),
  ];

  final requests = <DataTablePageRequest>[];
  final _pending = <Completer<DataTablePage<_Order>>>[];

  /// Set to answer each page with the total.
  bool reportTotal = false;

  Future<DataTablePage<_Order>> fetch(DataTablePageRequest request) {
    requests.add(request);
    final completer = Completer<DataTablePage<_Order>>();
    _pending.add(completer);
    return completer.future;
  }

  DataTablePage<_Order> rowsFor(DataTablePageRequest request) {
    var rows = all.toList();
    final query = request.query as String?;
    if (query != null) {
      rows = rows.where((order) => order.customer.endsWith(query)).toList();
    }
    if (request.sortColumnId == 'total') {
      rows.sort((a, b) => a.total.compareTo(b.total));
      if (request.sortDirection == SortDirection.descending) {
        rows = rows.reversed.toList();
      }
    }
    return DataTablePage(
      rows: rows.skip(request.offset).take(request.pageSize).toList(),
      rowCount: reportTotal ? rows.length : null,
    );
  }

  int get pendingCount => _pending.where((c) => !c.isCompleted).length;

  /// Answers the request at [index] among those made so far.
  void answer([int? index]) {
    final i = index ?? requests.length - 1;
    _pending[i].complete(rowsFor(requests[i]));
  }

  void fail([int? index]) {
    final i = index ?? requests.length - 1;
    _pending[i].completeError(StateError('offline'));
  }
}

void main() {
  List<DataTableColumn<_Order>> columns() => [
    DataTableColumn(
      id: 'customer',
      header: 'Customer',
      cellBuilder: (context, order) => Text(order.customer),
    ),
    DataTableColumn(
      id: 'total',
      header: 'Total',
      sortable: true,
      extent: const FixedTableSpanExtent(120),
      cellBuilder: (context, order) => Text('\$${order.total}'),
    ),
  ];

  Future<void> pumpTable(
    WidgetTester tester,
    DataTableController<_Order> controller, {
    bool selectable = false,
    Widget Function(BuildContext, Object, VoidCallback)? errorBuilder,
  }) => pumpFinesse(
    tester,
    Center(
      child: SizedBox(
        width: 600,
        height: 420,
        child: DataTable<_Order>(
          controller: controller,
          columns: columns(),
          selectable: selectable,
          keyOf: (order) => order.id,
          errorBuilder: errorBuilder,
        ),
      ),
    ),
  );

  // A skeleton never settles: pump frames.
  Future<void> frames(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('DataTableController.remote', () {
    test('asks for the first page when a listener attaches', () async {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        rowCount: 23,
        onPageRequested: source.fetch,
      );
      addTearDown(controller.dispose);
      expect(controller.isRemote, isTrue);
      // Nothing is shown, and nothing was asked, before somebody looks.
      expect(controller.isLoading, isTrue);
      expect(source.requests, isEmpty);
      expect(controller.pageCount, 3);

      var notified = 0;
      controller.addListener(() => notified++);
      expect(source.requests, [
        const DataTablePageRequest(page: 1, pageSize: 10),
      ]);
      expect(source.requests.single.offset, 0);
      // Attaching is not a change.
      expect(notified, 0);

      source.answer();
      await Future<void>.delayed(Duration.zero);
      expect(notified, 1);
      expect(controller.isLoading, isFalse);
      expect(controller.visibleRows.map((o) => o.id), [
        for (var i = 1; i <= 10; i++) i,
      ]);
      expect(controller.totalRowCount, 23);
    });

    test('a page, a sort and a query are each a request, not local work', () {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        rowCount: 23,
        onPageRequested: source.fetch,
      )..addListener(() {});
      addTearDown(controller.dispose);
      source.requests.clear();

      controller.page = 3;
      expect(source.requests.last.page, 3);
      expect(source.requests.last.offset, 20);
      expect(controller.isLoading, isTrue);
      expect(controller.visibleRows, isEmpty);

      // Past the end is clamped, and the same page is not asked twice.
      controller.page = 9;
      expect(source.requests.length, 1);

      // Sorting goes back to the first page.
      controller.sortBy('total');
      expect(
        source.requests.last,
        const DataTablePageRequest(
          page: 1,
          pageSize: 10,
          sortColumnId: 'total',
        ),
      );
      controller.sortBy('total');
      expect(source.requests.last.sortDirection, SortDirection.descending);
      controller.sortBy('total');
      expect(source.requests.last.sortColumnId, isNull);

      controller.page = 2;
      controller.query = '3';
      expect(source.requests.last.query, '3');
      expect(source.requests.last.page, 1);
      // The same query again asks for nothing.
      final count = source.requests.length;
      controller.query = '3';
      expect(source.requests.length, count);
    });

    test('an answer overtaken by a newer request is dropped', () async {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        rowCount: 23,
        onPageRequested: source.fetch,
      )..addListener(() {});
      addTearDown(controller.dispose);
      controller
        ..page = 2
        ..page = 3;
      expect(source.requests.map((r) => r.page), [1, 2, 3]);

      // The newest arrives first, the stale ones after it.
      source.answer(2);
      await Future<void>.delayed(Duration.zero);
      expect(controller.isLoading, isFalse);
      expect(controller.visibleRows.map((o) => o.id), [21, 22, 23]);
      source
        ..answer(0)
        ..fail(1);
      await Future<void>.delayed(Duration.zero);
      expect(controller.visibleRows.map((o) => o.id), [21, 22, 23]);
      expect(controller.error, isNull);
    });

    test('a failure is held as the error, and reload asks again', () async {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        rowCount: 23,
        onPageRequested: source.fetch,
      )..addListener(() {});
      addTearDown(controller.dispose);
      source.fail();
      await Future<void>.delayed(Duration.zero);
      expect(controller.isLoading, isFalse);
      expect(controller.error, isStateError);
      expect(controller.visibleRows, isEmpty);

      controller.reload();
      expect(controller.error, isNull);
      expect(controller.isLoading, isTrue);
      expect(source.requests.length, 2);
      source.answer();
      await Future<void>.delayed(Duration.zero);
      expect(controller.visibleRows.length, 10);
    });

    test('a source that throws at once is a failure too', () async {
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        onPageRequested: (request) => throw StateError('no network'),
      )..addListener(() {});
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);
      expect(controller.error, isStateError);
      expect(controller.isLoading, isFalse);
    });

    test('with no row count, there is a next page while pages come back '
        'full', () async {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        onPageRequested: source.fetch,
      )..addListener(() {});
      addTearDown(controller.dispose);
      expect(controller.rowCount, isNull);
      expect(controller.pageCount, 1);
      source.answer();
      await Future<void>.delayed(Duration.zero);
      expect(controller.pageCount, 2);

      controller.page = 2;
      source.answer();
      await Future<void>.delayed(Duration.zero);
      expect(controller.pageCount, 3);
      controller.page = 3;
      source.answer();
      await Future<void>.delayed(Duration.zero);
      // Three rows: the last page.
      expect(controller.pageCount, 3);
      expect(controller.totalRowCount, 23);
    });

    test('the source can set the row count with each page', () async {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        onPageRequested: source.fetch,
      )..addListener(() {});
      addTearDown(controller.dispose);
      source
        ..reportTotal = true
        ..answer();
      await Future<void>.delayed(Duration.zero);
      expect(controller.rowCount, 23);
      expect(controller.pageCount, 3);

      // A query that leaves three rows: one page.
      controller.query = '3';
      source.answer();
      await Future<void>.delayed(Duration.zero);
      expect(controller.rowCount, 3);
      expect(controller.pageCount, 1);
      expect(controller.visibleRows.map((o) => o.id), [3, 13, 23]);
    });

    test('an overtaken answer does not change the row count either', () async {
      final source = _Source()..reportTotal = true;
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        onPageRequested: source.fetch,
      )..addListener(() {});
      addTearDown(controller.dispose);
      // Three rows match '3'; the unfiltered first page answers late.
      controller.query = '3';
      source.answer(1);
      await Future<void>.delayed(Duration.zero);
      expect(controller.rowCount, 3);
      source.answer(0);
      await Future<void>.delayed(Duration.zero);
      expect(controller.rowCount, 3);
      expect(controller.visibleRows.map((o) => o.id), [3, 13, 23]);
    });

    test(
      'an answer whose total ends before its page goes to the last page',
      () async {
        final source = _Source()..reportTotal = true;
        final controller = DataTableController<_Order>.remote(
          pageSize: 10,
          rowCount: 50,
          onPageRequested: source.fetch,
        )..addListener(() {});
        addTearDown(controller.dispose);
        controller.page = 4;
        // The source has 23 rows now: page 4 is empty, and the last is 3.
        source.answer();
        await Future<void>.delayed(Duration.zero);
        expect(controller.rowCount, 23);
        expect(controller.page, 3);
        expect(source.requests.last.page, 3);
        expect(controller.isLoading, isTrue);
        source.answer();
        await Future<void>.delayed(Duration.zero);
        expect(controller.visibleRows.map((o) => o.id), [21, 22, 23]);
      },
    );

    test('a row count that puts the page past the end goes to the last', () {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        rowCount: 50,
        onPageRequested: source.fetch,
      )..addListener(() {});
      addTearDown(controller.dispose);
      controller.page = 5;
      controller.rowCount = 12;
      expect(controller.page, 2);
      expect(source.requests.last.page, 2);
    });

    test('nothing is reported after dispose', () async {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        onPageRequested: source.fetch,
      )..addListener(() {});
      controller.dispose();
      source.answer();
      await Future<void>.delayed(Duration.zero);
      // Reaching here without "used after being disposed" is the test.
    });

    test('rows and filter belong to a controller that holds its rows', () {
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        onPageRequested: (request) async => const DataTablePage(rows: []),
      );
      addTearDown(controller.dispose);
      expect(() => controller.rows = const [], throwsAssertionError);
      expect(() => controller.filter = (_) => true, throwsAssertionError);
      final local = DataTableController<_Order>();
      addTearDown(local.dispose);
      expect(local.isRemote, isFalse);
      expect(local.isLoading, isFalse);
      expect(() => local.query = 'x', throwsAssertionError);
      // Harmless.
      local.reload();
    });
  });

  group('DataTable with a remote controller', () {
    testWidgets('shows skeleton rows while a page loads, then the rows', (
      tester,
    ) async {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        rowCount: 23,
        onPageRequested: source.fetch,
      );
      addTearDown(controller.dispose);
      await pumpTable(tester, controller);
      expect(source.requests.length, 1);
      // A full page of placeholders, two cells a row; the header is real.
      expect(find.byType(Skeleton), findsNWidgets(20));
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Customer 1'), findsNothing);
      expect(find.byType(Empty), findsNothing);

      source.answer();
      await frames(tester);
      expect(find.byType(Skeleton), findsNothing);
      expect(find.text('Customer 1'), findsOneWidget);
      expect(find.text('Customer 10'), findsOneWidget);
      expect(find.text('Customer 11'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the last page loads with as many placeholders as it has '
        'rows', (tester) async {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        rowCount: 23,
        onPageRequested: source.fetch,
      );
      addTearDown(controller.dispose);
      await pumpTable(tester, controller);
      source.answer();
      await frames(tester);

      controller.page = 3;
      await frames(tester);
      expect(find.byType(Skeleton), findsNWidgets(6));
      source.answer();
      await frames(tester);
      expect(find.text('Customer 21'), findsOneWidget);
      expect(find.text('Customer 23'), findsOneWidget);
    });

    testWidgets('the pager and a sortable header ask the source', (
      tester,
    ) async {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        rowCount: 23,
        onPageRequested: source.fetch,
      );
      addTearDown(controller.dispose);
      await pumpTable(tester, controller);
      source.answer();
      await frames(tester);

      await tester.tap(find.bySemanticsLabel('Next'));
      await frames(tester);
      expect(source.requests.last.page, 2);
      expect(find.byType(Skeleton), findsWidgets);
      source.answer();
      await frames(tester);
      expect(find.text('Customer 11'), findsOneWidget);

      // A column with `sortable: true` and no comparator.
      await tester.tap(find.text('Total'));
      await frames(tester);
      expect(source.requests.last.sortColumnId, 'total');
      expect(source.requests.last.page, 1);
      source.answer();
      await frames(tester);
      // In the source's order: the smallest total first.
      final sorted = source.all.toList()
        ..sort((a, b) => a.total.compareTo(b.total));
      expect(find.text(sorted.first.customer), findsOneWidget);

      // A column without it does nothing.
      final before = source.requests.length;
      await tester.tap(find.text('Customer'));
      await frames(tester);
      expect(source.requests.length, before);
    });

    testWidgets('a failure shows a message and a retry', (tester) async {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        rowCount: 23,
        onPageRequested: source.fetch,
      );
      addTearDown(controller.dispose);
      await pumpTable(tester, controller);
      source.fail();
      await frames(tester);
      expect(find.byType(Skeleton), findsNothing);
      expect(find.text('These rows could not be loaded.'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await frames(tester);
      expect(source.requests.length, 2);
      expect(find.byType(Skeleton), findsWidgets);
      source.answer();
      await frames(tester);
      expect(find.text('Customer 1'), findsOneWidget);
    });

    testWidgets('errorBuilder replaces the message', (tester) async {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        onPageRequested: source.fetch,
      );
      addTearDown(controller.dispose);
      await pumpTable(
        tester,
        controller,
        errorBuilder: (context, error, retry) => Center(
          child: Button(onPressed: retry, child: Text('Failed: $error')),
        ),
      );
      source.fail();
      await frames(tester);
      expect(find.textContaining('Failed: Bad state: offline'), findsOneWidget);
      await tester.tap(find.textContaining('Failed'));
      await frames(tester);
      expect(source.requests.length, 2);
    });

    testWidgets('no rows at all is the empty state, not a skeleton', (
      tester,
    ) async {
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        onPageRequested: (request) async => const DataTablePage(rows: []),
      );
      addTearDown(controller.dispose);
      await pumpTable(tester, controller);
      await frames(tester);
      expect(find.byType(Skeleton), findsNothing);
      expect(find.byType(Empty), findsOneWidget);
    });

    testWidgets('selection is by key and survives a change of page', (
      tester,
    ) async {
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        rowCount: 23,
        onPageRequested: source.fetch,
      );
      addTearDown(controller.dispose);
      await pumpTable(tester, controller, selectable: true);
      // Nothing to select yet: the checkbox column is placeholders.
      expect(find.byType(Checkbox), findsOneWidget);
      expect(
        tester.widget<Checkbox>(find.byType(Checkbox)).enabled,
        isFalse,
      );
      source.answer();
      await frames(tester);

      controller.setSelected(2, selected: true);
      await frames(tester);
      expect(find.text('1 of 23 row(s) selected.'), findsOneWidget);

      controller.page = 2;
      source.answer();
      await frames(tester);
      expect(controller.isSelected(2), isTrue);
      expect(find.text('1 of 23 row(s) selected.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a source that answers at once, and sets the row count while '
        'the table is being built, is fine', (tester) async {
      late final DataTableController<_Order> controller;
      final source = _Source();
      controller = DataTableController<_Order>.remote(
        pageSize: 10,
        onPageRequested: (request) {
          // Synchronously, inside the build that attaches the table.
          controller.rowCount = 23;
          return Future.value(source.rowsFor(request));
        },
      );
      addTearDown(controller.dispose);
      await pumpTable(tester, controller);
      await frames(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('Customer 1'), findsOneWidget);
      expect(controller.pageCount, 3);
    });

    testWidgets('loading is announced once', (tester) async {
      final handle = tester.ensureSemantics();
      final source = _Source();
      final controller = DataTableController<_Order>.remote(
        pageSize: 10,
        onPageRequested: source.fetch,
      );
      addTearDown(controller.dispose);
      await pumpTable(tester, controller);
      expect(find.bySemanticsLabel('Loading rows'), findsOneWidget);
      source.answer();
      await frames(tester);
      expect(find.bySemanticsLabel('Loading rows'), findsNothing);
      handle.dispose();
    });
  });
}
