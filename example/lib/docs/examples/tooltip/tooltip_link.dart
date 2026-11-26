import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class TooltipLinkExample extends StatelessWidget {
  const TooltipLinkExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      builder: (context) => const Text('Click to read the documentation'),
      child: Button.link(
        onPressed: () {},
        child: const Text('Learn more'),
      ),
    );
  }
}
