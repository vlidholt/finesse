import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class ButtonGroupTextExample extends StatefulWidget {
  const ButtonGroupTextExample({super.key});

  @override
  State<ButtonGroupTextExample> createState() => _ButtonGroupTextExampleState();
}

class _ButtonGroupTextExampleState extends State<ButtonGroupTextExample> {
  var _guests = 2;

  @override
  Widget build(BuildContext context) {
    return ButtonGroup(
      semanticLabel: 'Guests',
      children: [
        IconButton.outline(
          tooltip: 'One fewer',
          enabled: _guests > 1,
          onPressed: () => setState(() => _guests--),
          icon: const PhosphorIcon(PhosphorIconsRegular.minus),
        ),
        // A label that sits in the group like a button.
        ButtonGroupText(
          child: Text('$_guests ${_guests == 1 ? 'guest' : 'guests'}'),
        ),
        IconButton.outline(
          tooltip: 'One more',
          onPressed: () => setState(() => _guests++),
          icon: const PhosphorIcon(PhosphorIconsRegular.plus),
        ),
      ],
    );
  }
}
