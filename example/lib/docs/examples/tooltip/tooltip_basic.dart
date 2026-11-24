import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TooltipBasicExample extends StatelessWidget {
  const TooltipBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      builder: (context) => const Text('Add to library'),
      child: Button.outline(
        onPressed: () {},
        child: const Text('Show Tooltip'),
      ),
    );
  }
}
