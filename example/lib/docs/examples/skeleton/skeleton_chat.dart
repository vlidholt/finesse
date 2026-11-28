import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A conversation loading: bubbles on both sides, tails and all.
class SkeletonChatExample extends StatelessWidget {
  const SkeletonChatExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          SkeletonChatBubble(),
          SkeletonChatBubble(lines: 1, widthFactor: .45),
          SkeletonChatBubble(
            direction: ChatBubbleDirection.outgoing,
            lines: 3,
          ),
          SkeletonChatBubble(
            direction: ChatBubbleDirection.outgoing,
            lines: 1,
            widthFactor: .3,
          ),
        ],
      ),
    );
  }
}
