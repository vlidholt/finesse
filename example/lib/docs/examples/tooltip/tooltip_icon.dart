import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
