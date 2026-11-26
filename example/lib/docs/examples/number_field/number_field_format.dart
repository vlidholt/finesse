import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class NumberFieldFormatExample extends StatefulWidget {
  const NumberFieldFormatExample({super.key});

  @override
  State<NumberFieldFormatExample> createState() =>
      _NumberFieldFormatExampleState();
}

class _NumberFieldFormatExampleState extends State<NumberFieldFormatExample> {
  // A format writes the number and reads it back from what was typed.
  final currency = NumberFormat.simpleCurrency(locale: 'en_US');

  num? price = 1249.5;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: NumberField(
        value: price,
        min: 0,
        step: .5,
        decimalDigits: 2,
        format: currency,
        semanticLabel: 'Price',
        onChanged: (value) => setState(() => price = value),
      ),
    );
  }
}
