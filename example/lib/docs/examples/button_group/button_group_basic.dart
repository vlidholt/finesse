import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class ButtonGroupBasicExample extends StatelessWidget {
  const ButtonGroupBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ButtonGroup(
      semanticLabel: 'Message actions',
      children: [
        Button.outline(onPressed: () {}, child: const Text('Archive')),
        Button.outline(onPressed: () {}, child: const Text('Report')),
        Button.outline(onPressed: () {}, child: const Text('Snooze')),
        IconButton.outline(
          tooltip: 'More',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.dotsThree),
        ),
      ],
    );
  }
}
