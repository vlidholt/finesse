import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A heading and a paragraph, each as tall as the text it stands in for.
class SkeletonTextExample extends StatelessWidget {
  const SkeletonTextExample({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          SkeletonText(lines: 1, style: text.h3, lastLineWidthFactor: .5),
          SkeletonText(lines: 4, style: text.p),
        ],
      ),
    );
  }
}
