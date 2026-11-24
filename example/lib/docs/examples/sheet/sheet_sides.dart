import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SheetSidesExample extends StatelessWidget {
  const SheetSidesExample({super.key});

  void _open(BuildContext context, SheetSide side) {
    showSheet<void>(
      context: context,
      side: side,
      builder: (context) => Sheet(
        title: const Text('Edit Profile'),
        description: const Text(
          "Make changes to your profile here. Click save when you're done.",
        ),
        actions: [
          Button(
            child: const Text('Save changes'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: TextField(placeholder: Text('Name')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final side in SheetSide.values)
          Button.outline(
            onPressed: () => _open(context, side),
            child: Text(side.name),
          ),
      ],
    );
  }
}
