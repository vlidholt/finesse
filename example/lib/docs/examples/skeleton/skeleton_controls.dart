import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Avatars, chips and buttons, each the size its component would be.
class SkeletonControlsExample extends StatelessWidget {
  const SkeletonControlsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Skeleton.avatar(),
            Skeleton.avatar(),
            Skeleton.avatar(),
            Skeleton.avatar(size: 48),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            Skeleton.chip(),
            Skeleton.chip(width: 96),
            Skeleton.chip(width: 56),
            Skeleton.chip(width: 80),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            Skeleton.button(size: ButtonSize.sm),
            Skeleton.button(),
            Skeleton.button(size: ButtonSize.lg, width: 120),
          ],
        ),
      ],
    );
  }
}
