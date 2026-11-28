import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A list loading: rows the shape of list tiles, avatar and all.
class SkeletonListExample extends StatelessWidget {
  const SkeletonListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonListTile(),
          SkeletonListTile(trailing: Skeleton.button(width: 64)),
          SkeletonListTile(subtitleLines: 2),
          SkeletonListTile(leading: Skeleton(width: 40, height: 40)),
        ],
      ),
    );
  }
}
