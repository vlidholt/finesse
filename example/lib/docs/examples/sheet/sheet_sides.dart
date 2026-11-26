import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A sheet comes from any edge. `start` and `end` follow the text direction;
/// the other four are physical. A sheet from the top or bottom is as tall as
/// its content, one from a side as tall as the page.
class SheetSidesExample extends StatelessWidget {
  const SheetSidesExample({super.key});

  void _open(BuildContext context, SheetSide side) {
    showSheet<void>(
      context: context,
      side: side,
      builder: (context) => Sheet(
        title: const Text('Edit profile'),
        description: const Text(
          "Make changes to your profile here. Save when you're done.",
        ),
        actions: [
          Button.outline(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save changes'),
          ),
        ],
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
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
