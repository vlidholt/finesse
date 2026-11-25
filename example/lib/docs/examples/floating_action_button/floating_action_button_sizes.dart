import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Small, regular and large. Each is larger on a phone, where the button is
/// a touch target first.
class FloatingActionButtonSizesExample extends StatelessWidget {
  const FloatingActionButtonSizesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FinesseRow(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.lg,
      children: [
        for (final size in FloatingActionButtonSize.values)
          FloatingActionButton(
            icon: const PhosphorIcon(PhosphorIconsRegular.plus),
            semanticLabel: 'Add',
            size: size,
            onPressed: () {},
          ),
      ],
    );
  }
}
