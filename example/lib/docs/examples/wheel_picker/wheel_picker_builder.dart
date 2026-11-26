import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A long list is built a row at a time: three centuries of years cost no
/// more than the rows in view.
class WheelPickerBuilderExample extends StatefulWidget {
  const WheelPickerBuilderExample({super.key});

  @override
  State<WheelPickerBuilderExample> createState() =>
      _WheelPickerBuilderExampleState();
}

class _WheelPickerBuilderExampleState extends State<WheelPickerBuilderExample> {
  static const _first = 1800;

  int year = 1969;

  @override
  Widget build(BuildContext context) {
    return UnaRow(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.lg,
      children: [
        WheelPicker<int>.builder(
          semanticLabel: 'Year',
          itemCount: 301,
          itemBuilder: (index) => WheelPickerItem(
            value: _first + index,
            label: '${_first + index}',
          ),
          indexOf: (year) => year - _first,
          value: year,
          onChanged: (value) => setState(() => year = value),
        ),
        Button.outline(
          onPressed: () => setState(() => year = DateTime.now().year),
          child: const Text('This year'),
        ),
      ],
    );
  }
}
