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
            padding: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
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
