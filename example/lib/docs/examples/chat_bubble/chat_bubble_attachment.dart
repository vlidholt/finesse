import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A bubble is a container: any widget works as its child. An attachment
/// swaps the fill for the card colour and adds a border.
class ChatBubbleAttachmentExample extends StatelessWidget {
  const ChatBubbleAttachmentExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          const ChatBubble(
            showTail: false,
            child: Text('Here is the map from the workshop.'),
          ),
          ChatBubble(
            color: theme.colorScheme.card,
            foregroundColor: theme.colorScheme.foreground,
            border: Border.all(color: theme.colorScheme.border),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                const IconTile(icon: PhosphorIcon(PhosphorIconsRegular.image)),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'onboarding-map.jpg',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.small,
                      ),
                      Text('840 KB', style: theme.textTheme.muted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
