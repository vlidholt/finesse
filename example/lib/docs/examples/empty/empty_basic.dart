import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class EmptyBasicExample extends StatelessWidget {
  const EmptyBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      width: 400,
      height: 320,
      columnMainAxisSize: MainAxisSize.max,
      child: Empty(
        icon: const PhosphorIcon(PhosphorIconsRegular.tray),
        title: const Text('No messages'),
        description: const Text('Messages you receive will show up here.'),
        actions: [
          Button.outline(
            onPressed: () {},
            child: const Text('Refresh'),
          ),
          Button(
            onPressed: () {},
            child: const Text('Compose'),
          ),
        ],
      ),
    );
  }
}
