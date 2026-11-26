import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class IconButtonTooltipExample extends StatelessWidget {
  const IconButtonTooltipExample({super.key});

  @override
  Widget build(BuildContext context) {
    // The tooltip names the button: on hover, on focus, on a long press,
    // and to a screen reader.
    return UnaRow(
      gap: GapSize.xs,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.ghost(
          tooltip: 'Reply',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.arrowBendUpLeft),
        ),
        IconButton.ghost(
          tooltip: 'Archive',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.archive),
        ),
        IconButton.ghost(
          tooltip: 'Move to trash',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.trash),
        ),
      ],
    );
  }
}
