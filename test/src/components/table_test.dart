import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/table.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

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
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('FinesseTable', () {
    testWidgets('FinesseTable matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          FinesseTable.list(
            header: const [
              FinesseTableCell.header(child: Text('Invoice')),
              FinesseTableCell.header(child: Text('Status')),
              FinesseTableCell.header(child: Text('Method')),
              FinesseTableCell.header(
                alignment: Alignment.centerRight,
                child: Text('Amount'),
              ),
            ],
            footer: const [
              FinesseTableCell.footer(child: Text('Total')),
              FinesseTableCell.footer(child: Text('')),
              FinesseTableCell.footer(child: Text('')),
              FinesseTableCell.footer(
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
                FinesseTableCell(
                  child: Text(
                    invoice.invoice,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                FinesseTableCell(child: Text(invoice.paymentStatus)),
                FinesseTableCell(child: Text(invoice.paymentMethod)),
                FinesseTableCell(
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
        find.byType(FinesseTable),
        matchesGoldenFile('goldens/table.png'),
      );
    });
  });
}
