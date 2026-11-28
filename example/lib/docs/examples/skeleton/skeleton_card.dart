import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
            Skeleton(width: 220, height: 16),
            SizedBox(height: 8),
            Skeleton(width: 160, height: 16),
          ],
        ),
      ],
    );
  }
}
