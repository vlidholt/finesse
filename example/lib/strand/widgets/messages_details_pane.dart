import 'package:example/strand/data/messages_data.dart';
import 'package:example/strand/widgets/messages_common.dart';
import 'package:example/strand/widgets/messages_controller.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

// One notch under the theme's `md` gap, where the designs tighten it: between
// a row's tile and its text, and between the avatar stack and its title.
const _tightGap = 10.0;

/// The last pane of the desktop card: who the conversation is with, the
/// people both sides know, and what has been shared.
class MessagesDetailsPane extends StatelessWidget {
  const MessagesDetailsPane({required this.controller, super.key});

  final MessagesController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final layout = theme.layoutTheme;
    final conversation = controller.selected;
    final muted = controller.isMuted(conversation);
    final location = conversation.person?.location;
    final mutedText = theme.textTheme.muted;
    final inset = messagesPaneInset(theme);

    Widget section(String title, Widget child, {double? titleGap}) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.messagesLabel.copyWith(fontWeight: FontWeight.w600),
        ),
        Gap.raw(titleGap ?? layout.gap(GapSize.md)),
        child,
      ],
    );

    return SingleChildScrollView(
      // The card's padding at the sides and a little more above and below;
      // the sections are as far apart as a card's.
      padding: EdgeInsets.symmetric(
        horizontal: inset,
        vertical: layout.gap(GapSize.xl),
      ),
      child: Column(
        spacing: theme.cardTheme.sectionGap ?? inset,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              ConversationAvatar(conversation, size: 88, showOnline: false),
              const Gap.md(),
              Text(
                conversation.name,
                textAlign: TextAlign.center,
                // 600 17/24: between the theme's h4 (16) and h3 (20).
                style: theme.textTheme.h4.copyWith(
                  fontSize: 17,
                  height: 24 / 17,
                  letterSpacing: 0,
                  color: colors.foreground,
                ),
              ),
              const Gap.xs(),
              Text(
                conversation.headline,
                textAlign: TextAlign.center,
                style: mutedText,
              ),
              if (location != null) ...[
                const Gap.xs(),
                Text(location, textAlign: TextAlign.center, style: mutedText),
              ],
              const Gap.lg(),
              FinesseRow(
                gap: GapSize.sm,
                children: [
                  Expanded(
                    child: Button.outline(
                      onPressed: () {},
                      child: Text(
                        conversation.isGroup ? 'View group' : 'View profile',
                      ),
                    ),
                  ),
                  IconButton.secondary(
                    // A rounded square beside the button rather than the
                    // theme's round icon button.
                    decoration: theme.buttonDecoration(radius: theme.radius),
                    iconSize: 18,
                    icon: Icon(
                      muted
                          ? PhosphorIconsRegular.bellSlash
                          : PhosphorIconsRegular.bell,
                    ),
                    semanticLabel: muted
                        ? 'Unmute notifications'
                        : 'Mute notifications',
                    onPressed: () => controller.toggleMuted(conversation),
                  ),
                ],
              ),
            ],
          ),
          const Divider.horizontal(),
          if (conversation.mutuals.isNotEmpty)
            section(
              conversation.isGroup ? 'Members' : 'Mutual connections',
              titleGap: _tightGap,
              FinesseRow(
                gap: GapSize.sm,
                children: [
                  AvatarGroup(
                    size: 26,
                    overlap: 6,
                    children: [
                      for (final avatar in conversation.mutuals)
                        Avatar(avatar, fit: BoxFit.cover),
                    ],
                  ),
                  if (conversation.mutualsLabel case final label?)
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: mutedText,
                      ),
                    ),
                ],
              ),
            ),
          if (conversation.sharedFiles.isNotEmpty)
            section(
              'Shared files',
              FinesseColumn(
                gap: GapSize.md,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final file in conversation.sharedFiles)
                    _SharedFileRow(file),
                ],
              ),
            ),
          if (conversation.sharedGroups.isNotEmpty)
            section(
              'Shared groups',
              FinesseColumn(
                gap: GapSize.md,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final group in conversation.sharedGroups)
                    ListTile(
                      padding: EdgeInsets.zero,
                      gap: _tightGap,
                      leading: GroupLogo(group, size: 32),
                      title: Text(group.name),
                      titleStyle: theme.messagesLabel,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A shared file: its type on a soft tile, its name, its size and age.
class _SharedFileRow extends StatelessWidget {
  const _SharedFileRow(this.file);

  final SharedFile file;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      padding: EdgeInsets.zero,
      gap: _tightGap,
      leading: IconTile(
        size: 36,
        iconSize: 20,
        borderRadius: theme.radius,
        icon: Icon(file.icon),
      ),
      title: Text(file.name),
      titleStyle: theme.messagesLabel,
      subtitle: Text(file.listCaption),
      subtitleStyle: theme.messagesCaption,
    );
  }
}
