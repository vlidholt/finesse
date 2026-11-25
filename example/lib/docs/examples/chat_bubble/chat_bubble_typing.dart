import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// `TypingIndicator` in an incoming bubble, beside the sender's avatar.
class ChatBubbleTypingExample extends StatelessWidget {
  const ChatBubbleTypingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          ChatBubble(
            direction: ChatBubbleDirection.outgoing,
            child: Text('Can I quote it in the deck?'),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 8,
            children: [
              Avatar(
                'assets/images/avatar_omar_rahimi.jpg',
                size: Size.square(28),
                fallback: Text('O'),
              ),
              // The bubble sizes itself against the width it is given.
              Expanded(
                child: ChatBubble(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: TypingIndicator(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
