import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class NumberFieldFormExample extends StatefulWidget {
  const NumberFieldFormExample({super.key});

  @override
  State<NumberFieldFormExample> createState() => _NumberFieldFormExampleState();
}

class _NumberFieldFormExampleState extends State<NumberFieldFormExample> {
  final formKey = GlobalKey<FinesseFormState>();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: FinesseForm(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumberFormField(
              id: 'age',
              label: const Text('Age'),
              description: const Text('You must be 18 or older.'),
              placeholder: const Text('Years'),
              min: 0,
              max: 120,
              validator: (value) {
                if (value == null) return 'Enter your age';
                return value < 18 ? 'You must be 18 or older' : null;
              },
            ),
            const Gap.md(),
            Button(
              onPressed: () => formKey.currentState!.validate(),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
