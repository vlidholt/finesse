import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonIconExample extends StatelessWidget {
  const ButtonIconExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Button(
          onPressed: () {},
          leading: const Icon(PhosphorIconsRegular.envelopeSimple),
          child: const Text('Login with Email'),
        ),
        Button.outline(
          onPressed: () {},
          trailing: const Icon(PhosphorIconsRegular.caretRight),
          child: const Text('Next'),
        ),
      ],
    );
  }
}
