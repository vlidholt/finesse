import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class BreadcrumbBasicExample extends StatelessWidget {
  const BreadcrumbBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Breadcrumb(
      children: [
        BreadcrumbLink(
          onPressed: () {},
          child: const Text('Home'),
        ),
        BreadcrumbLink(
          onPressed: () {},
          child: const Text('Components'),
        ),
        const Text('Breadcrumb'),
      ],
    );
  }
}
