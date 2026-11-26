import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

const _invoices = [
  (
    invoice: 'INV001',
    status: 'Paid',
    method: 'Credit Card',
    amount: r'$250.00',
  ),
  (invoice: 'INV002', status: 'Pending', method: 'PayPal', amount: r'$150.00'),
  (
    invoice: 'INV003',
    status: 'Unpaid',
    method: 'Bank Transfer',
    amount: r'$350.00',
  ),
  (
    invoice: 'INV004',
    status: 'Paid',
    method: 'Credit Card',
    amount: r'$450.00',
  ),
  (invoice: 'INV005', status: 'Paid', method: 'PayPal', amount: r'$550.00'),
];

class TableInvoicesExample extends StatelessWidget {
  const TableInvoicesExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rowHeight = theme.tableTheme.cellHeight ?? 48;
    // Header row + one row per invoice + footer row, so the card hugs the
    // table exactly instead of leaving space below the last row.
    final tableHeight = rowHeight * (_invoices.length + 2);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          style: CardTheme(
            padding: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
          ),
          child: SizedBox(
            height: tableHeight,
            child: UnaTable.list(
              // The Amount column absorbs any leftover width so the table
              // spans the full card instead of leaving a gap on the right.
              columnSpanExtent: (index) => switch (index) {
                0 => const FixedTableSpanExtent(140),
                1 => const FixedTableSpanExtent(110),
                2 => const FixedTableSpanExtent(140),
                _ => const MaxTableSpanExtent(
                  FixedTableSpanExtent(120),
                  RemainingTableSpanExtent(),
                ),
              },
              header: const [
                UnaTableCell.header(child: Text('Invoice')),
                UnaTableCell.header(child: Text('Status')),
                UnaTableCell.header(child: Text('Method')),
                UnaTableCell.header(
                  alignment: Alignment.centerRight,
                  child: Text('Amount'),
                ),
              ],
              footer: const [
                UnaTableCell.footer(child: Text('Total')),
                UnaTableCell.footer(child: Text('')),
                UnaTableCell.footer(child: Text('')),
                UnaTableCell.footer(
                  alignment: Alignment.centerRight,
                  child: Text(r'$1750.00'),
                ),
              ],
              children: [
                for (final invoice in _invoices)
                  [
                    UnaTableCell(child: Text(invoice.invoice)),
                    UnaTableCell(child: Text(invoice.status)),
                    UnaTableCell(child: Text(invoice.method)),
                    UnaTableCell(
                      alignment: Alignment.centerRight,
                      child: Text(invoice.amount),
                    ),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
