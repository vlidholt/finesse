import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class PaginationBasicExample extends StatefulWidget {
  const PaginationBasicExample({super.key});

  @override
  State<PaginationBasicExample> createState() => _PaginationBasicExampleState();
}

class _PaginationBasicExampleState extends State<PaginationBasicExample> {
  int page = 5;

  @override
  Widget build(BuildContext context) {
    // The full run is wider than a phone, where controls are 44 points
    // across; there it scrolls. `PaginationCompact` is the form made for
    // narrow screens.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Pagination(
        page: page,
        pageCount: 20,
        onPageChanged: (value) => setState(() => page = value),
      ),
    );
  }
}
