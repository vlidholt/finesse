import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/data_table/data_table_payments.dart';

final dataTableDoc = ComponentDoc(
  slug: 'data_table',
  title: 'Data Table',
  description:
      '`DataTable` is the data features on top of the grid: give it rows '
      'and columns and a `DataTableController` sorts, filters, selects and '
      'pages them. To lay out cells of your own with none of that, use '
      '`FinesseTable`, the grid it is built on.',
  examples: [
    ComponentExample(
      id: 'data_table_payments',
      title: 'Payments',
      description: 'Tap a column header to sort. A third tap clears the sort.',
      minPreviewHeight: 420,
      builder: (_) => const DataTablePaymentsExample(),
    ),
  ],
);
