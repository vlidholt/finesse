import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A short exchange. Only the last bubble of each run keeps its tail, and a
/// bubble never grows past a fraction of the width, so long messages wrap.
class ChatBubbleConversationExample extends StatelessWidget {
  const ChatBubbleConversationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChatBubble(
            showTail: false,
            child: Text('Morning! Did the research summary come through?'),
          ),
          SizedBox(height: 4),
          ChatBubble(child: Text('I sent it late last night.')),
          SizedBox(height: 12),
          ChatBubble(
            direction: ChatBubbleDirection.outgoing,
            showTail: false,
            child: Text('It did, thank you.'),
          ),
          SizedBox(height: 4),
          ChatBubble(
            direction: ChatBubbleDirection.outgoing,
            child: Text(
              'The part about onboarding drop-off is exactly what we '
              'needed for Thursday. Can I quote it in the deck?',
            ),
          ),
        ],
      ),
    );
  }
}
