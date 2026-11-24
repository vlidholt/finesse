import 'package:example/strand/data/messages_data.dart';
import 'package:example/strand/widgets/messages_common.dart';
import 'package:example/strand/widgets/messages_controller.dart';
import 'package:example/strand/widgets/search_field.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The first pane of Messages: the title, search, the filter chips and one
/// row per conversation.
///
/// In the desktop card it fills the pane and scrolls its own rows. On a
/// phone it is the whole Messages destination and the page scrolls it, so
/// [scrollable] is false and the rows are laid out in full.
class MessagesConversationList extends StatelessWidget {
  const MessagesConversationList({
    required this.controller,
    required this.onOpen,
    required this.headerPadding,
    this.scrollable = true,
    this.showSelection = true,
    this.surfaceColor,
    super.key,
  });

  final MessagesController controller;

  /// Called with the conversation whose row was tapped.
  final ValueChanged<Conversation> onOpen;

  /// The inset of the title, the search field and the chips.
  final EdgeInsetsGeometry headerPadding;

  /// Whether the rows scroll inside the pane.
  final bool scrollable;

  /// Whether the open conversation's row is highlighted. Off where the
  /// conversation is not on screen beside the list.
  final bool showSelection;

  /// The colour behind the list, when it is not a card.
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rowInset = theme.layoutTheme.gap(GapSize.sm);
    final conversations = controller.visible;

    Widget row(Conversation conversation) => _ConversationTile(
      key: ValueKey(conversation.id),
      conversation: conversation,
      preview: controller.previewOf(conversation),
      time: controller.timeOf(conversation),
      unread: controller.unreadOf(conversation),
      selected: showSelection && conversation.id == controller.selected.id,
      surfaceColor: surfaceColor,
      onTap: () => onOpen(conversation),
    );

    final header = Padding(
      padding: headerPadding,
      child: _ListHeader(controller: controller),
    );

    if (conversations.isEmpty) {
      const empty = Empty(
        icon: Icon(PhosphorIconsRegular.chatCircleDots),
        title: Text('No conversations'),
        description: Text('Nothing matches this filter.'),
      );
      return Column(
        mainAxisSize: scrollable ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          if (scrollable)
            const Expanded(child: SingleChildScrollView(child: empty))
          else
            empty,
        ],
      );
    }

    // The designs leave 2 between rows, which is under the gap scale.
    const rowGap = 2.0;
    final rowsPadding = EdgeInsets.fromLTRB(rowInset, 0, rowInset, rowInset);

    return Column(
      mainAxisSize: scrollable ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        if (scrollable)
          Expanded(
            child: ListView.separated(
              padding: rowsPadding,
              itemCount: conversations.length,
              separatorBuilder: (_, _) => const SizedBox(height: rowGap),
              itemBuilder: (context, index) => row(conversations[index]),
            ),
          )
        else
          Padding(
            padding: rowsPadding,
            child: Column(
              spacing: rowGap,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final c in conversations) row(c)],
            ),
          ),
      ],
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.controller});

  final MessagesController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Widget action(IconData icon, String label) => IconButton.secondary(
      icon: Icon(icon),
      semanticLabel: label,
      onPressed: () {},
    );

    return FinesseColumn(
      gap: GapSize.md,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Messages',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // 700 22/28: between the theme's h3 (20) and h1 (30).
                style: theme.textTheme.h3.copyWith(
                  fontSize: 22,
                  height: 28 / 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.44,
                  color: colors.foreground,
                ),
              ),
            ),
            action(PhosphorIconsRegular.slidersHorizontal, 'Filter'),
            const Gap.xs(),
            action(PhosphorIconsRegular.pencilSimple, 'New message'),
          ],
        ),
        SearchField(
          placeholder: 'Search messages',
          showShortcut: false,
          maxWidth: double.infinity,
          controller: controller.search,
        ),
        // The chips do not wrap: the ones that do not fit scroll into view.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: messagesTightGap,
            children: [
              for (final filter in MessageFilter.values)
                Chip(
                  label: Text(
                    filter == MessageFilter.requests
                        ? '${filter.label} · ${controller.requestCount}'
                        : filter.label,
                  ),
                  selected: controller.filter == filter,
                  onSelected: (_) => controller.filter = filter,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One conversation: avatar, name and time on the first line, the last
/// message and the unread count on the second.
class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.preview,
    required this.time,
    required this.unread,
    required this.selected,
    required this.onTap,
    this.surfaceColor,
    super.key,
  });

  final Conversation conversation;
  final String preview;
  final String time;
  final int unread;
  final bool selected;
  final VoidCallback onTap;
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isUnread = unread > 0;

    return ListTile(
      selected: selected,
      onTap: onTap,
      leading: ConversationAvatar(
        conversation,
        size: 48,
        surfaceColor: surfaceColor,
      ),
      titleStyle: theme.messagesName,
      // The time shares the name's line and the count the preview's, so the
      // preview runs the full width under the time when nothing is unread.
      title: Row(
        children: [
          Expanded(child: Text(conversation.name)),
          const Gap.sm(),
          Text(
            time,
            style: theme.messagesCaption.copyWith(
              height: 20 / 12,
              fontWeight: isUnread ? FontWeight.w600 : null,
              color: isUnread ? colors.accentForeground : null,
            ),
          ),
        ],
      ),
      subtitleStyle: isUnread ? theme.messagesLabel : null,
      subtitle: Row(
        children: [
          Expanded(child: Text(preview)),
          if (isUnread) ...[
            const Gap.sm(),
            IndicatorBadge(
              count: unread,
              size: 20,
              ringWidth: 0,
              semanticLabel: '$unread unread',
            ),
          ],
        ],
      ),
    );
  }
}
