import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// `UnaRow` and `UnaColumn` accept a `spacing` argument in theme steps.
class LayoutSpacingExample extends StatelessWidget {
  const LayoutSpacingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return UnaColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Card(
          child: UnaRow(
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
            child: UnaColumn(
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
