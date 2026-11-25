import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// `ChipGroup` holds the set of chosen chips. Here any number may be
/// chosen and each one shows a check; the arrow keys move between chips.
class ChipGroupExample extends StatefulWidget {
  const ChipGroupExample({super.key});

  @override
  State<ChipGroupExample> createState() => _ChipGroupExampleState();
}

class _ChipGroupExampleState extends State<ChipGroupExample> {
  static const _toppings = [
    'Mozzarella',
    'Basil',
    'Mushrooms',
    'Olives',
    'Artichoke',
    'Anchovies',
    'Chili',
  ];

  Set<String> chosen = {'Mozzarella', 'Basil'};

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: ChipGroup<String>.multiple(
        semanticLabel: 'Toppings',
        values: chosen,
        onValuesChanged: (values) => setState(() => chosen = values),
        showCheckmark: true,
        alignment: WrapAlignment.center,
        items: [
          for (final topping in _toppings)
            ChipGroupItem(
              value: topping,
              label: Text(topping),
              enabled: topping != 'Anchovies',
            ),
        ],
      ),
    );
  }
}
