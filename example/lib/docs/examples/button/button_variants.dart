import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonVariantsExample extends StatelessWidget {
  const ButtonVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Button(
          onPressed: () {},
          child: const Text('Primary'),
        ),
        Button.secondary(
          onPressed: () {},
          child: const Text('Secondary'),
        ),
        Button.destructive(
          onPressed: () {},
          child: const Text('Destructive'),
        ),
        Button.outline(
          onPressed: () {},
          child: const Text('Outline'),
        ),
        Button.ghost(
          onPressed: () {},
          child: const Text('Ghost'),
        ),
        Button.link(
          onPressed: () {},
          child: const Text('Link'),
        ),
      ],
    );
  }
}
