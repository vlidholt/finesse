import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class NumberFieldStepperExample extends StatefulWidget {
  const NumberFieldStepperExample({super.key});

  @override
  State<NumberFieldStepperExample> createState() =>
      _NumberFieldStepperExampleState();
}

class _NumberFieldStepperExampleState extends State<NumberFieldStepperExample> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Quantity', style: theme.textTheme.small),
        const Gap.md(),
        // A compact pill with no typing. Hold a button to keep stepping;
        // it stops at the bounds.
        NumberField.stepper(
          value: quantity,
          min: 1,
          max: 9,
          semanticLabel: 'Quantity',
          onChanged: (value) {
            setState(() => quantity = value?.toInt() ?? 1);
          },
        ),
      ],
    );
  }
}
