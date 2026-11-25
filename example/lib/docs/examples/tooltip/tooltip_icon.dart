import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TooltipIconExample extends StatelessWidget {
  const TooltipIconExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      builder: (context) => const Text('Additional information'),
      child: IconButton.ghost(
        icon: const PhosphorIcon(PhosphorIconsRegular.info),
        onPressed: () {},
      ),
    );
  }
}
