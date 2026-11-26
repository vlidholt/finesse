import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class ButtonSizesExample extends StatelessWidget {
  const ButtonSizesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Button.outline(
          size: ButtonSize.sm,
          onPressed: () {},
          child: const Text('Small'),
        ),
        Button.outline(
          onPressed: () {},
          child: const Text('Regular'),
        ),
        Button.outline(
          size: ButtonSize.lg,
          onPressed: () {},
          child: const Text('Large'),
        ),
      ],
    );
  }
}
