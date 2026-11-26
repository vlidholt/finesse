import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:una/material.dart';
import 'package:una/src/app.dart';
import 'package:una/src/components/table.dart';

const invoices = [
  (
    invoice: 'INV001',
    paymentStatus: 'Paid',
    totalAmount: r'$250.00',
    paymentMethod: 'Credit Card',
  ),
  (
    invoice: 'INV002',
    paymentStatus: 'Pending',
    totalAmount: r'$150.00',
    paymentMethod: 'PayPal',
  ),
  (
    invoice: 'INV003',
    paymentStatus: 'Unpaid',
    totalAmount: r'$350.00',
    paymentMethod: 'Bank Transfer',
  ),
  (
    invoice: 'INV004',
    paymentStatus: 'Paid',
    totalAmount: r'$450.00',
    paymentMethod: 'Credit Card',
  ),
  (
    invoice: 'INV005',
    paymentStatus: 'Paid',
    totalAmount: r'$550.00',
    paymentMethod: 'PayPal',
  ),
  (
    invoice: 'INV006',
    paymentStatus: 'Pending',
    totalAmount: r'$200.00',
    paymentMethod: 'Bank Transfer',
  ),
  (
    invoice: 'INV007',
    paymentStatus: 'Unpaid',
    totalAmount: r'$300.00',
    paymentMethod: 'Credit Card',
  ),
];
void main() {
  // Helper method to create a test widget wrapped in UnaApp and Scaffold
  Widget createTestWidget(Widget child) {
    return UnaApp(
      builder: (context, child) => UnaMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('UnaTable', () {
    testWidgets('UnaTable matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          UnaTable.list(
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
                child: Text(r'$2500.00'),
              ),
            ],
            columnSpanExtent: (index) {
              if (index == 2) return const FixedTableSpanExtent(130);
              if (index == 3) {
                return const MaxTableSpanExtent(
                  FixedTableSpanExtent(120),
                  RemainingTableSpanExtent(),
                );
              }
              // uses the default value
              return null;
            },
            children: invoices.map(
              (invoice) => [
                UnaTableCell(
                  child: Text(
                    invoice.invoice,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                UnaTableCell(child: Text(invoice.paymentStatus)),
                UnaTableCell(child: Text(invoice.paymentMethod)),
                UnaTableCell(
                  alignment: Alignment.centerRight,
                  child: Text(
                    invoice.totalAmount,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(UnaTable),
        matchesGoldenFile('goldens/table.png'),
      );
    });
  });
}
