import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Cards loading: one with a picture and actions, one with text only.
class SkeletonCardsExample extends StatelessWidget {
  const SkeletonCardsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        SkeletonCard(width: 280, actions: 2),
        SkeletonCard(width: 280, mediaAspectRatio: null, lines: 4),
      ],
    );
  }
}
