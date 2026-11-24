import 'package:example/strand/data/messages_data.dart';
import 'package:example/strand/widgets/messages_common.dart';
import 'package:example/strand/widgets/messages_controller.dart';
import 'package:example/strand/widgets/strand_metrics.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Opens "New message": the people and groups the user can write to, with
/// a field to narrow them down. Choosing one calls [onOpen] with their
/// conversation, exactly as tapping their row in the list would.
Future<void> showNewMessageDialog(
  BuildContext context,
  MessagesController controller,
  ValueChanged<Conversation> onOpen,
) async {
  final conversation = await showDialog<Conversation>(
    context: context,
    builder: (context) => _NewMessageDialog(controller.conversations),
  );
  if (conversation != null) onOpen(conversation);
}

class _NewMessageDialog extends StatefulWidget {
  const _NewMessageDialog(this.conversations);

  final List<Conversation> conversations;

  @override
  State<_NewMessageDialog> createState() => _NewMessageDialogState();
}

class _NewMessageDialogState extends State<_NewMessageDialog> {
  final _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needle = _query.text.trim().toLowerCase();
    final matches = [
      for (final conversation in widget.conversations)
        if (!conversation.request &&
            conversation.name.toLowerCase().contains(needle))
          conversation,
    ];

    return Dialog(
      title: const Text('New message'),
      // A picker with no actions of its own: the x is its way out, next to
      // Escape and a tap outside. Dialogs have none unless they ask.
      closeIconData: PhosphorIconsRegular.x,
      constraints: const BoxConstraints(maxWidth: 440),
      scrollable: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            label: 'To',
            child: TextField(
              controller: _query,
              autofocus: true,
              placeholder: const Text('Type a name'),
              leading: PhosphorIcon(
                PhosphorIconsRegular.magnifyingGlass,
                size: theme.glyph,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ),
          const Gap.sm(),
          if (matches.isEmpty)
            Padding(
              padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.lg)),
              child: Text(
                'No one in your conversations is called “${_query.text}”.',
                textAlign: TextAlign.center,
                style: theme.textTheme.muted,
              ),
            )
          else
            for (final conversation in matches)
              ListTile(
                onTap: () => Navigator.of(context).pop(conversation),
                leading: ConversationAvatar(conversation),
                titleStyle: theme.messagesName,
                title: Text(conversation.name),
                subtitle: Text(conversation.headline),
              ),
        ],
      ),
    );
  }
}
