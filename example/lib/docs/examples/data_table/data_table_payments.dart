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
