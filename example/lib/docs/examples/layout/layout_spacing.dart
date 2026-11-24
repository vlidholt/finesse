import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// `FinesseRow` and `FinesseColumn` accept a `spacing` argument in theme steps.
class LayoutSpacingExample extends StatelessWidget {
  const LayoutSpacingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FinesseColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Card(
          child: FinesseRow(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              for (final label in ['One', 'Two', 'Three'])
                Badge.secondary(child: Text(label)),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Card(
            child: FinesseColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              spacing: 3,
              children: [
                const TextField(placeholder: Text('Email')),
                const TextField(placeholder: Text('Password')),
                Button(onPressed: () {}, child: const Text('Sign in')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
