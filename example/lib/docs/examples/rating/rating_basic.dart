import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A rating that can be given. Tap a star, drag across them, hover with a
/// mouse to preview, or focus it and use the arrow keys.
class RatingBasicExample extends StatefulWidget {
  const RatingBasicExample({super.key});

  @override
  State<RatingBasicExample> createState() => _RatingBasicExampleState();
}

class _RatingBasicExampleState extends State<RatingBasicExample> {
  static const _words = ['Not rated', 'Poor', 'Fair', 'Good', 'Great', 'Loved'];

  double stars = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FinesseColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.sm,
      children: [
        Rating(
          semanticLabel: 'Your rating',
          value: stars,
          onChanged: (value) => setState(() => stars = value),
        ),
        Text(_words[stars.round()], style: theme.textTheme.muted),
      ],
    );
  }
}
