import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class BreadcrumbEllipsisExample extends StatelessWidget {
  const BreadcrumbEllipsisExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Breadcrumb(
      children: [
        BreadcrumbLink(
          onPressed: () {},
          child: const Text('Home'),
        ),
        // Collapses the middle of a deep hierarchy.
        const BreadcrumbEllipsis(),
        BreadcrumbLink(
          onPressed: () {},
          child: const Text('Components'),
        ),
        const Text('Breadcrumb'),
      ],
    );
  }
}
