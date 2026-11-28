import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A table loading: the table's row height and padding, bars of different
/// lengths so it does not read as loaded and empty.
class SkeletonTableExample extends StatelessWidget {
  const SkeletonTableExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var row = 0; row < 5; row++)
            SkeletonTableRow(columns: 4, flex: const [3, 2, 2, 1], row: row),
        ],
      ),
    );
  }
}
