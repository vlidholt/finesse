import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// `UnaPadding` takes theme spacing steps, not logical pixels.
class LayoutPaddingExample extends StatelessWidget {
  const LayoutPaddingExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return ColoredBox(
      color: theme.colorScheme.muted,
      child: UnaPadding.symmetric(
        horizontal: 6,
        vertical: 4,
        child: Card(
          child: Text(
            'Inset by ${spacing(6)} x ${spacing(4)}',
            style: theme.textTheme.small,
          ),
        ),
      ),
    );
  }
}
