import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class NumberFieldBasicExample extends StatefulWidget {
  const NumberFieldBasicExample({super.key});

  @override
  State<NumberFieldBasicExample> createState() =>
      _NumberFieldBasicExampleState();
}

class _NumberFieldBasicExampleState extends State<NumberFieldBasicExample> {
  num? guests = 2;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      // Type a number, or step it: the buttons, the arrow keys, Page Up and
      // Page Down for ten at a time, Home and End for the bounds. On a
      // phone the buttons are a minus and a plus at the two ends.
      child: NumberField(
        value: guests,
        min: 1,
        max: 12,
        semanticLabel: 'Guests',
        onChanged: (value) => setState(() => guests = value),
      ),
    );
  }
}
