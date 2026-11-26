import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/table/table_invoices.dart';

final tableDoc = ComponentDoc(
  slug: 'table',
  title: 'Table',
  description:
      '`UnaTable` is the grid itself: header, body and footer rows of '
      'cells you build, laid out lazily in both directions, with sizes per '
      'row and column. It knows nothing about your data. For sorting, '
      'selection, filtering and paging over a list of rows, use '
      '`DataTable`, which is built on it.',
  examples: [
    ComponentExample(
      id: 'table_invoices',
      title: 'Invoices',
      minPreviewHeight: 420,
      builder: (_) => const TableInvoicesExample(),
    ),
  ],
);
