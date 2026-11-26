import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class TooltipLongContentExample extends StatelessWidget {
  const TooltipLongContentExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      // Long content wraps at the tooltip's max width.
      builder: (context) => const Text(
        'To learn more about how this works, check out the docs. If you '
        'have any questions, please reach out to us.',
      ),
      child: Button.outline(
        onPressed: () {},
        child: const Text('Show Tooltip'),
      ),
    );
  }
}
