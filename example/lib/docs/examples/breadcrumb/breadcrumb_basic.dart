import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
