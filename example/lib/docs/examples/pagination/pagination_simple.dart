import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class PaginationSimpleExample extends StatefulWidget {
  const PaginationSimpleExample({super.key});

  @override
  State<PaginationSimpleExample> createState() =>
      _PaginationSimpleExampleState();
}

class _PaginationSimpleExampleState extends State<PaginationSimpleExample> {
  int page = 2;

  @override
  Widget build(BuildContext context) {
    return Pagination(
      page: page,
      pageCount: 5,
      showEdges: false,
      onPageChanged: (value) => setState(() => page = value),
    );
  }
}
