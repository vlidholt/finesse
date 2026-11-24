import 'package:example/strand/data.dart';
import 'package:example/strand/data/network_data.dart';
import 'package:example/strand/data/notifications_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/session.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/network_links.dart';
import 'package:example/strand/widgets/notifications_controller.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/settings_controller.dart';
import 'package:example/strand/widgets/settings_links.dart';
import 'package:example/strand/widgets/strand_pieces.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The notifications of the selected tab: a heading and a card of rows per
/// period — Today, This week, Earlier — or a note when the tab is empty.
class NotificationsList extends StatelessWidget {
  const NotificationsList({required this.controller, super.key});

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = controller.groups;
    final inset = theme.layoutTheme.gap(GapSize.sm);

    if (groups.isEmpty) {
      final filter = controller.filter;
      return Card(
        child: Empty(
          icon: const Icon(PhosphorIconsRegular.bellSimpleSlash),
          title: const Text('Nothing here'),
          description: Text(
            filter == NotificationFilter.all
                ? 'You have cleared every notification. New ones will '
                      'show up here.'
                : 'No notifications under ${filter.label} right now.',
          ),
          actions: [
            if (filter != NotificationFilter.all)
              Button.outline(
                onPressed: () => controller.filter = NotificationFilter.all,
                child: const Text('Show all notifications'),
              ),
          ],
        ),
      );
    }

    return FinesseColumn(
      gap: GapSize.lg,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (period, notifications) in groups)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StrandSectionHeading(
                period.label,
                trailing: switch (notifications
                    .where(controller.isUnread)
                    .length) {
                  0 => null,
                  final unread => Text(
                    '$unread new',
                    style: theme.textTheme.muted,
                  ),
                },
              ),
              const Gap.md(),
              Card(
                // The rows bring their own inset, as a conversation's do.
                padding: EdgeInsets.all(inset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  // The Messages list's 2 between rows.
                  spacing: 2,
                  children: [
                    for (final notification in notifications)
                      _NotificationRow(
                        notification,
                        key: ValueKey(notification.id),
                        controller: controller,
                      ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// One notification: who or what it is from, the sentence, what was
/// written, a button where one makes sense, its age and its menu.
class _NotificationRow extends StatelessWidget {
  const _NotificationRow(
    this.notification, {
    required this.controller,
    super.key,
  });

  final StrandNotification notification;
  final NotificationsController controller;

  static const _markSize = 48.0;

  /// Follows the row to wherever it is about.
  void _open(BuildContext context) {
    controller.markRead(notification);
    if (notification.kind == NotificationKind.event) {
      openNetworkSection(context, NetworkSection.events);
    } else if (notification.target == StrandDestination.network) {
      openNetworkSection(context, NetworkSection.grow);
    } else {
      context.goTo(notification.target);
    }
  }

  void _act(BuildContext context, NotificationAction action) {
    final person = notification.people.firstOrNull;
    switch (action) {
      case NotificationAction.reply:
      case NotificationAction.viewJob:
      case NotificationAction.message:
        _open(context);
      case NotificationAction.accept:
        final invitation = NotificationsData.invitationOf(notification);
        if (invitation != null) context.strand.network.accept(invitation);
        controller.answer(notification);
        showStrandToast(
          context,
          'You and ${person?.firstName} are now connected',
        );
      case NotificationAction.wish:
        controller.answer(notification);
        showStrandToast(
          context,
          'Birthday wishes sent to ${person?.firstName}',
        );
      case NotificationAction.congratulate:
        controller.answer(notification);
        showStrandToast(
          context,
          'Congratulations sent to ${person?.firstName}',
        );
    }
  }

  void _remove(BuildContext context, String message) {
    final unread = controller.isUnread(notification);
    controller.remove(notification);
    showStrandToast(
      context,
      message,
      actionLabel: 'Undo',
      onAction: () => controller.restore(notification, unread: unread),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final layout = theme.layoutTheme;
    final unread = controller.isUnread(notification);
    final action = notification.action;
    // An invitation accepted on the Network screen is answered here too.
    final answered =
        controller.isAnswered(notification) ||
        (action == NotificationAction.accept &&
            notification.people.isNotEmpty &&
            context.strand.network.isConnected(notification.people.first));

    // The accent, thinned: a dozen unread rows are a tint, not a block.
    final wash = Color.alphaBlend(
      scheme.accent.withValues(
        alpha: theme.brightness == Brightness.dark ? .4 : .6,
      ),
      scheme.card,
    );

    final body = theme.textTheme.p.copyWith(
      color: unread ? scheme.foreground : scheme.foregroundSubtle,
    );

    return Pressable(
      onPressed: () => _open(context),
      builder: (context, states) {
        final hovered =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed);
        return FocusRing(
          visible: states.contains(WidgetState.focused),
          borderRadius: theme.radii.lg,
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 120),
            padding: EdgeInsets.all(layout.gap(GapSize.md)),
            decoration: BoxDecoration(
              // Unread rows carry the accent wash a selected card does.
              color: unread
                  ? wash
                  : hovered
                  ? scheme.muted
                  : scheme.muted.withValues(alpha: 0),
              borderRadius: theme.radii.lg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Mark(notification, surface: unread ? wash : null),
                const Gap.md(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(children: _spans(notification.text, body)),
                        style: body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (notification.excerpt case final excerpt?) ...[
                        const Gap.raw(homeHairGap),
                        Text(
                          excerpt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.muted,
                        ),
                      ],
                      if (notification.quote case final quote?) ...[
                        const Gap.sm(),
                        _Quote(quote, onCard: !unread),
                      ],
                      if (action != null) ...[
                        const Gap.raw(homeSnugGap),
                        StrandPillButton(
                          label: action.label,
                          icon: action.icon,
                          done: answered && action.done != null,
                          doneLabel: action.done,
                          doneIcon: PhosphorIconsRegular.check,
                          primary: action == NotificationAction.accept,
                          onPressed: answered && action.done != null
                              ? null
                              : () => _act(context, action),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap.sm(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (unread) ...[
                          Semantics(
                            label: 'Unread',
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: scheme.tint,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const Gap.raw(homeTightGap),
                        ],
                        Text(
                          notification.age,
                          // The conversation list's timestamp: 12/20, and
                          // semibold in the tint while unread.
                          style: homeFinePrint(theme).copyWith(
                            height: 20 / 12,
                            fontWeight: unread ? FontWeight.w600 : null,
                            color: unread ? scheme.tint : null,
                          ),
                        ),
                      ],
                    ),
                    _RowMenu(
                      unread: unread,
                      onToggleRead: () => controller.toggleRead(notification),
                      onMute: () => _remove(
                        context,
                        'You will see fewer notifications like this',
                      ),
                      onRemove: () => _remove(context, 'Notification removed'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Splits `*bold* text` into spans; the bold ones are semibold in the
  /// foreground colour.
  static List<TextSpan> _spans(String text, TextStyle base) {
    final strong = base.copyWith(fontWeight: FontWeight.w600);
    final parts = text.split('*');
    return [
      for (final (index, part) in parts.indexed)
        if (part.isNotEmpty)
          TextSpan(text: part, style: index.isOdd ? strong : null),
    ];
  }
}

/// What leads a row: a portrait, a logo or a glyph, with the kind's mark
/// pinned to its corner when it is a picture.
class _Mark extends StatelessWidget {
  const _Mark(this.notification, {this.surface});

  final StrandNotification notification;

  /// The colour behind the row, when it is not a card: the mark's ring.
  final Color? surface;

  static const _size = _NotificationRow._markSize;
  static const _badgeSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final kind = notification.kind;

    final Widget picture;
    if (notification.people.firstOrNull case final Person person?) {
      picture = PersonAvatar(person, size: _size);
    } else if (notification.company case final company?) {
      picture = StrandMark(
        asset: company.logo,
        label: company.name,
        size: _size,
      );
    } else if (notification.group case final group?) {
      picture = StrandMark(asset: group.logo, label: group.name, size: _size);
    } else {
      // No one to show: the kind's glyph is the picture.
      return IconTile(
        icon: Icon(kind.icon),
        size: _size,
        iconSize: 24,
        borderRadius: theme.radii.full,
        backgroundColor: surface == null ? null : scheme.card,
      );
    }

    final (Color fill, Color ink) = switch (kind) {
      NotificationKind.reaction => (coralOf(theme), const Color(0xFFFFFFFF)),
      NotificationKind.celebration => (
        scheme.warning,
        const Color(0xFFFFFFFF),
      ),
      NotificationKind.job || NotificationKind.application => (
        scheme.success,
        const Color(0xFFFFFFFF),
      ),
      _ => (scheme.primary, scheme.primaryForeground),
    };

    return SizedBox.square(
      dimension: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          picture,
          PositionedDirectional(
            end: -3,
            bottom: -3,
            child: Container(
              width: _badgeSize,
              height: _badgeSize,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: Border.all(
                  color: surface ?? scheme.card,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: Icon(kind.icon, size: 11, color: ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// What someone wrote, set apart from the sentence about it.
class _Quote extends StatelessWidget {
  const _Quote(this.text, {required this.onCard});

  final String text;

  /// Whether the row behind is the card itself rather than the unread wash.
  final bool onCard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.layoutTheme.gap(GapSize.md),
        vertical: theme.layoutTheme.gap(GapSize.sm),
      ),
      decoration: BoxDecoration(
        // A comment's bubble on the card; the card's own colour on the
        // wash, where the bubble's grey would disappear.
        color: onCard ? scheme.muted : scheme.card,
        borderRadius: theme.radii.lg,
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.muted.copyWith(
          height: 19 / 13,
          color: scheme.foregroundSubtle,
        ),
      ),
    );
  }
}

/// The "More options" button of a row.
class _RowMenu extends StatelessWidget {
  const _RowMenu({
    required this.unread,
    required this.onToggleRead,
    required this.onMute,
    required this.onRemove,
  });

  final bool unread;
  final VoidCallback onToggleRead;
  final VoidCallback onMute;
  final VoidCallback onRemove;

  static const _anchor = AnchorAuto(
    offset: Offset(0, 4),
    targetAnchor: AlignmentDirectional.bottomEnd,
    followerAnchor: AlignmentDirectional.bottomStart,
    fallback: AnchorAuto(
      offset: Offset(0, -4),
      targetAnchor: AlignmentDirectional.topEnd,
      followerAnchor: AlignmentDirectional.topStart,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      anchor: _anchor,
      itemsBuilder: (_) => [
        ContextMenuItem(
          leading: Icon(
            unread
                ? PhosphorIconsRegular.envelopeSimpleOpen
                : PhosphorIconsRegular.envelopeSimple,
          ),
          onPressed: onToggleRead,
          child: Text(unread ? 'Mark as read' : 'Mark as unread'),
        ),
        ContextMenuItem(
          leading: const Icon(PhosphorIconsRegular.bellSimpleSlash),
          onPressed: onMute,
          child: const Text('Show fewer like this'),
        ),
        ContextMenuItem(
          leading: const Icon(PhosphorIconsRegular.gearSix),
          onPressed: () => openSettings(context, SettingsSection.notifications),
          child: const Text('Notification settings'),
        ),
        const Divider.horizontal(margin: EdgeInsets.symmetric(vertical: 4)),
        ContextMenuItem(
          destructive: true,
          leading: const Icon(PhosphorIconsRegular.trash),
          onPressed: onRemove,
          child: const Text('Remove'),
        ),
      ],
      builder: (context, menu, _) => IconButton.ghost(
        size: ButtonSize.sm,
        icon: const Icon(PhosphorIconsRegular.dotsThree),
        semanticLabel: 'More options',
        onPressed: menu.toggle,
      ),
    );
  }
}
