# Data Table

`DataTable` is the data features on top of the grid: give it rows and columns and a `DataTableController` sorts, filters, selects and pages them — or, made with `DataTableController.remote`, asks a server for one page at a time. To lay out cells of your own with none of that, use `FinesseTable`, the grid it is built on.

## Payments

Tap a column header to sort. A third tap clears the sort.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class Payment {
  const Payment(this.id, this.status, this.email, this.amount);

  final String id;
  final String status;
  final String email;
  final double amount;
}

const _payments = [
  Payment('m5gr84i9', 'success', 'ken99@example.com', 316),
  Payment('3u1reuv4', 'success', 'abe45@example.com', 242),
  Payment('derv1ws0', 'processing', 'monserrat44@example.com', 837),
  Payment('5kma53ae', 'success', 'silas22@example.com', 874),
  Payment('bhqecj4p', 'failed', 'carmella@example.com', 721),
  Payment('a1b2c3d4', 'processing', 'jason@example.com', 128),
  Payment('e5f6g7h8', 'failed', 'nina@example.com', 455),
];

class DataTablePaymentsExample extends StatefulWidget {
  const DataTablePaymentsExample({super.key});

  @override
  State<DataTablePaymentsExample> createState() =>
      _DataTablePaymentsExampleState();
}

class _DataTablePaymentsExampleState extends State<DataTablePaymentsExample> {
  final controller = DataTableController<Payment>(
    rows: _payments,
    pageSize: 5,
  );

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = controller.filteredRows.length;
    final rowHeight = theme.tableTheme.cellHeight ?? 48;
    final visibleRowCount = controller.visibleRows.length;
    // TableView does not shrink-wrap, so height tracks the pinned header
    // plus the rows on the current page.
    final tableHeight = visibleRowCount == 0
        ? rowHeight * 3
        : rowHeight * (visibleRowCount + 1);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              style: CardTheme(
                padding: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
              ),
              child: DataTable<Payment>(
                controller: controller,
                selectable: true,
                keyOf: (payment) => payment.id,
                height: tableHeight,
                showPagination: false,
                showSelectionCount: false,
                columns: [
                  DataTableColumn(
                    id: 'status',
                    header: 'Status',
                    extent: const FixedTableSpanExtent(140),
                    compare: (a, b) => a.status.compareTo(b.status),
                    cellBuilder: (context, payment) => Badge(
                      variant: switch (payment.status) {
                        'success' => BadgeVariant.primary,
                        'failed' => BadgeVariant.destructive,
                        _ => BadgeVariant.secondary,
                      },
                      child: Text(payment.status),
                    ),
                  ),
                  DataTableColumn(
                    id: 'email',
                    header: 'Email',
                    compare: (a, b) => a.email.compareTo(b.email),
                    cellBuilder: (context, payment) =>
                        Text(payment.email, overflow: TextOverflow.ellipsis),
                  ),
                  DataTableColumn(
                    id: 'amount',
                    header: 'Amount',
                    extent: const FixedTableSpanExtent(120),
                    alignment: Alignment.centerRight,
                    compare: (a, b) => a.amount.compareTo(b.amount),
                    cellBuilder: (context, payment) =>
                        Text('\$${payment.amount.toStringAsFixed(2)}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Expanded, so on a narrow screen the count truncates
                // rather than pushing the pager out.
                Expanded(
                  child: Text(
                    '${controller.selectedKeys.length} of $total row(s) '
                    'selected.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.muted,
                  ),
                ),
                PaginationCompact(
                  page: controller.page,
                  pageCount: controller.pageCount,
                  onPageChanged: (page) => controller.page = page,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## Rows from a server

`DataTableController.remote` holds one page and asks a source for each: `onPageRequested` gets the page, the sort and the `query`, and answers with a `DataTablePage` of rows and the total. Skeleton rows stand in while a page loads, and an answer overtaken by a newer request is dropped. Columns sort with `sortable: true`; nothing is sorted or filtered here.

```dart
import 'dart:async';

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class Shipment {
  const Shipment(this.id, this.city, this.weight);

  final int id;
  final String city;
  final int weight;
}

/// Stands in for a server: 137 shipments it sorts, searches and pages
/// itself, answering after a delay.
class _FakeServer {
  static const _cities = [
    'Lisbon',
    'Osaka',
    'Nairobi',
    'Lima',
    'Tallinn',
    'Hanoi',
    'Quito',
  ];

  final _all = [
    for (var i = 1; i <= 137; i++)
      Shipment(1000 + i, _cities[i % _cities.length], 4 + (i * 53) % 96),
  ];

  Timer? _timer;

  Future<DataTablePage<Shipment>> fetch(DataTablePageRequest request) {
    // A timer the example can cancel, not a `Future.delayed` that would
    // outlive it.
    _timer?.cancel();
    final answer = Completer<DataTablePage<Shipment>>();
    _timer = Timer(const Duration(milliseconds: 700), () {
      var rows = _all.toList();
      final search = (request.query as String?)?.toLowerCase() ?? '';
      if (search.isNotEmpty) {
        rows = [
          for (final shipment in rows)
            if (shipment.city.toLowerCase().contains(search)) shipment,
        ];
      }
      final sign = request.sortDirection == SortDirection.ascending ? 1 : -1;
      switch (request.sortColumnId) {
        case 'city':
          rows.sort((a, b) => sign * a.city.compareTo(b.city));
        case 'weight':
          rows.sort((a, b) => sign * a.weight.compareTo(b.weight));
      }
      answer.complete(
        DataTablePage(
          rows: rows.skip(request.offset).take(request.pageSize).toList(),
          // The total comes back with every page: it is what gives the
          // pager its last page.
          rowCount: rows.length,
        ),
      );
    });
    return answer.future;
  }

  void dispose() => _timer?.cancel();
}

/// The table holds one page. Sorting, searching and paging are requests to
/// the source; skeleton rows stand in while one is on its way.
class DataTableRemoteExample extends StatefulWidget {
  const DataTableRemoteExample({super.key});

  @override
  State<DataTableRemoteExample> createState() => _DataTableRemoteExampleState();
}

class _DataTableRemoteExampleState extends State<DataTableRemoteExample> {
  final _server = _FakeServer();

  late final _controller = DataTableController<Shipment>.remote(
    pageSize: 6,
    onPageRequested: _server.fetch,
  );

  @override
  void dispose() {
    _server.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rowHeight = theme.tableTheme.cellHeight ?? 48;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: FinesseColumn(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        gap: GapSize.md,
        children: [
          SearchField(
            placeholder: const Text('Search by city'),
            // Handed to the source with every request; back to page one.
            onChanged: (text) => _controller.query = text,
            onCleared: () => _controller.query = '',
          ),
          Card(
            style: CardTheme(
              padding: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
            ),
            child: DataTable<Shipment>(
              controller: _controller,
              // The header and six rows: the same while a page loads.
              height: rowHeight * 7,
              showPagination: false,
              columns: [
                DataTableColumn(
                  id: 'id',
                  header: 'Shipment',
                  extent: const FixedTableSpanExtent(120),
                  cellBuilder: (context, shipment) => Text('#${shipment.id}'),
                ),
                DataTableColumn(
                  id: 'city',
                  header: 'Destination',
                  // No comparator: the source does the sorting.
                  sortable: true,
                  cellBuilder: (context, shipment) => Text(shipment.city),
                ),
                DataTableColumn(
                  id: 'weight',
                  header: 'Weight',
                  sortable: true,
                  extent: const FixedTableSpanExtent(120),
                  alignment: Alignment.centerRight,
                  cellBuilder: (context, shipment) =>
                      Text('${shipment.weight} kg'),
                ),
              ],
            ),
          ),
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => Row(
              children: [
                Expanded(
                  child: Text(
                    _controller.rowCount == null
                        ? 'Counting…'
                        : '${_controller.rowCount} shipments',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.muted,
                  ),
                ),
                PaginationCompact(
                  page: _controller.page,
                  pageCount: _controller.pageCount,
                  onPageChanged: (page) => _controller.page = page,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```
