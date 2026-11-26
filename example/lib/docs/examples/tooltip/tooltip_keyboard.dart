import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class TooltipKeyboardExample extends StatelessWidget {
  const TooltipKeyboardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      builder: (context) => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Save Changes'),
          SizedBox(width: 6),
          Kbd('S'),
        ],
      ),
      child: IconButton.outline(
        icon: const PhosphorIcon(PhosphorIconsRegular.floppyDisk),
        onPressed: () {},
      ),
    );
  }
}
