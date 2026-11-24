import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SkeletonCardExample extends StatelessWidget {
  const SkeletonCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Skeleton.circle(size: 48),
        SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(width: 250, height: 16),
            SizedBox(height: 8),
            Skeleton(width: 200, height: 16),
          ],
        ),
      ],
    );
  }
}
