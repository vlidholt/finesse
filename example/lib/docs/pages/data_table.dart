import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/data_table/data_table_payments.dart';
import 'package:example/docs/examples/data_table/data_table_remote.dart';

final dataTableDoc = ComponentDoc(
  slug: 'data_table',
  title: 'Data Table',
  description:
      '`DataTable` is the data features on top of the grid: give it rows '
      'and columns and a `DataTableController` sorts, filters, selects and '
      'pages them — or, made with `DataTableController.remote`, asks a '
      'server for one page at a time. To lay out cells of your own with none of that, use '
      '`UnaTable`, the grid it is built on.',
  examples: [
    ComponentExample(
      id: 'data_table_payments',
      title: 'Payments',
      description: 'Tap a column header to sort. A third tap clears the sort.',
      minPreviewHeight: 420,
      builder: (_) => const DataTablePaymentsExample(),
    ),
    ComponentExample(
      id: 'data_table_remote',
      title: 'Rows from a server',
      description:
          '`DataTableController.remote` holds one page and asks a source '
          'for each: `onPageRequested` gets the page, the sort and the '
          '`query`, and answers with a `DataTablePage` of rows and the '
          'total. Skeleton rows stand in while a page loads, and an answer '
          'overtaken by a newer request is dropped. Columns sort with '
          '`sortable: true`; nothing is sorted or filtered here.',
      minPreviewHeight: 520,
      builder: (_) => const DataTableRemoteExample(),
    ),
  ],
);
