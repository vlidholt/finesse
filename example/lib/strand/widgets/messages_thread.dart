import 'dart:math' as math;

import 'package:example/strand/data.dart';
import 'package:example/strand/data/messages_data.dart';
import 'package:example/strand/widgets/messages_common.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The measurements of a thread that the designs change between the desktop
/// pane and the full-screen conversation.
@immutable
class ThreadMetrics {
  const ThreadMetrics({
    required this.padding,
    required this.gap,
    required this.maxBubbleWidth,
    required this.imageSize,
    required this.attachmentWidth,
    required this.alignToEnd,
  });

  /// The conversation pane of the desktop card: the theme's widest gap at
  /// the sides and the card's padding under the header.
  factory ThreadMetrics.pane(ThemeData theme) {
    final side = theme.layoutTheme.gap(GapSize.xl);
    return ThreadMetrics(
      padding: EdgeInsets.fromLTRB(side, messagesPaneInset(theme), side, 0),
      // Between the theme's `sm` and `md` gaps.
      gap: 10,
      maxBubbleWidth: 420,
      imageSize: const Size(280, 190),
      attachmentWidth: 320,
      alignToEnd: false,
    );
  }

  /// The conversation as a page of its own: tighter all round.
  factory ThreadMetrics.page(ThemeData theme) {
    final layout = theme.layoutTheme;
    final inset = layout.gap(GapSize.md);
    return ThreadMetrics(
      padding: EdgeInsets.fromLTRB(inset, inset, inset, 0),
      gap: layout.gap(GapSize.sm),
      maxBubbleWidth: 268,
      imageSize: const Size(260, 170),
      attachmentWidth: 300,
      alignToEnd: true,
    );
  }

  /// The inset of the messages, without the room kept for the composer.
  final EdgeInsets padding;

  /// The space between two messages.
  final double gap;

  /// The widest a line of message text runs. An incoming row — avatar, gap
  /// and bubble — is capped at this; an outgoing bubble is this plus its own
  /// padding, as the designs' CSS has it.
  final double maxBubbleWidth;

  /// The size of a picture message.
  final Size imageSize;

  /// The width of an attachment card.
  final double attachmentWidth;

  /// Whether a thread shorter than the viewport sits against the composer
  /// rather than under the header.
  final bool alignToEnd;
}

/// The messages of one conversation: the day divider, bubbles, attachments
/// and pictures, the read receipt and the typing indicator.
///
/// The list is anchored to its end, as a chat is: it opens on the newest
/// message, and [controller] is at offset zero when that message is in view.
class MessagesThread extends StatefulWidget {
  const MessagesThread({
    required this.conversation,
    required this.messages,
    required this.metrics,
    this.controller,
    this.insets = EdgeInsets.zero,
    super.key,
  });

  final Conversation conversation;

  /// The thread; `conversation.messages` and anything sent since.
  final List<ChatMessage> messages;

  final ThreadMetrics metrics;

  final ScrollController? controller;

  /// Space to keep clear around the messages on top of the metrics' own
  /// padding: the header and the composer the thread scrolls under.
  final EdgeInsets insets;

  @override
  State<MessagesThread> createState() => _MessagesThreadState();
}

class _MessagesThreadState extends State<MessagesThread> {
  // The avatar beside the last incoming bubble of a run, and the gutter the
  // other bubbles keep free for it.
  static const _avatarSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final layout = Theme.of(context).layoutTheme;
    final metrics = widget.metrics;
    final conversation = widget.conversation;
    final messages = widget.messages;
    final padding = metrics.padding + widget.insets;

    final children = <Widget>[_DayDivider(conversation.day)];
    for (final (index, message) in messages.indexed) {
      final next = index + 1 < messages.length ? messages[index + 1] : null;
      // The receipt hangs closer to its message than the next message
      // would; a reaction pill overhangs its bubble and needs more room.
      children
        ..add(SizedBox(height: metrics.gap))
        ..add(
          _MessageRow(
            message: message,
            sender: message.sender ?? conversation.person,
            metrics: metrics,
            avatarSize: _avatarSize,
            showAvatar:
                next == null || next.outgoing || next.sender != message.sender,
          ),
        );
      if (message.receipt case final receipt?) {
        children
          ..add(SizedBox(height: metrics.gap - layout.gap(GapSize.xs)))
          ..add(_Receipt(receipt));
      }
      if (message.reactions > 0) {
        children.add(const SizedBox(height: _Reacted.margin));
      }
    }
    final typist = conversation.person;
    if (conversation.typing && typist != null) {
      children
        ..add(SizedBox(height: metrics.gap))
        ..add(_TypingRow(person: typist, avatarSize: _avatarSize));
    }

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        controller: widget.controller,
        reverse: true,
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.max(0, constraints.maxHeight - padding.vertical),
          ),
          child: Column(
            mainAxisAlignment: metrics.alignToEnd
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// "Today", between two hairlines.
class _DayDivider extends StatelessWidget {
  const _DayDivider(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: theme.layoutTheme.gap(GapSize.xs),
      ),
      child: FinesseRow(
        gap: GapSize.md,
        children: [
          const Expanded(child: Divider.horizontal()),
          Text(
            label,
            style: theme.messagesCaption.copyWith(
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const Expanded(child: Divider.horizontal()),
        ],
      ),
    );
  }
}

/// One message on its side of the thread: an outgoing one against the end
/// edge, an incoming one after the avatar gutter.
class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.message,
    required this.sender,
    required this.metrics,
    required this.avatarSize,
    required this.showAvatar,
  });

  final ChatMessage message;

  /// Who sent an incoming message.
  final Person? sender;

  final ThreadMetrics metrics;
  final double avatarSize;

  /// Whether this is the last incoming message of a run, which carries the
  /// sender's portrait.
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final direction = message.outgoing
        ? ChatBubbleDirection.outgoing
        : ChatBubbleDirection.incoming;
    final bubblePadding =
        (theme.chatBubbleTheme.padding ??
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10))
            .resolve(Directionality.of(context));
    final gutter = theme.layoutTheme.gap(GapSize.sm);

    // Each kind of content caps its own width, the way the designs measure
    // it: the whole box for a card or a picture; for a bubble, the text of
    // an outgoing one and the row — avatar, gutter and bubble — of an
    // incoming one.
    final Widget content;
    if (message.file case final file?) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: metrics.attachmentWidth),
        child: _Attachment(file),
      );
    } else if (message.image case final image?) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: metrics.imageSize.width + 2 * _Picture.borderWidth,
        ),
        child: _Picture(image, size: metrics.imageSize),
      );
    } else {
      content = ChatBubble(
        direction: direction,
        maxWidth: message.outgoing
            ? metrics.maxBubbleWidth + bubblePadding.horizontal
            : metrics.maxBubbleWidth - avatarSize - gutter,
        child: message.reactions > 0
            ? _Reacted(
                count: message.reactions,
                bubblePadding: bubblePadding,
                child: Text(message.text!),
              )
            : Text(message.text!),
      );
    }

    if (message.outgoing) {
      return Padding(
        // An outgoing message stays out of the avatar gutter.
        padding: EdgeInsetsDirectional.only(start: avatarSize),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: content,
        ),
      );
    }

    final person = sender;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showAvatar && person != null)
          ExcludeSemantics(child: PersonAvatar(person, size: avatarSize))
        else
          SizedBox(width: avatarSize),
        SizedBox(width: gutter),
        Flexible(child: content),
      ],
    );
  }
}

/// A message with the reaction pill hanging off its bottom end corner.
///
/// The pill is positioned from inside the bubble — a `ChatBubble` has no
/// slot for one and aligns itself, so its outline cannot be reached from
/// outside — and is pushed out past the bubble's padding.
class _Reacted extends StatelessWidget {
  const _Reacted({
    required this.count,
    required this.bubblePadding,
    required this.child,
  });

  final int count;
  final EdgeInsets bubblePadding;
  final Widget child;

  // The pill's geometry in the designs: how tall it is, its padding and how
  // far it hangs past the bubble's side, how far below the bubble's bottom,
  // and the room the thread adds under a message that carries one.
  static const _height = 22.0;
  static const _inset = 6.0;
  static const _drop = 12.0;
  static const margin = 10.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          end: -(bubblePadding.right + _inset),
          bottom: -(bubblePadding.bottom + _drop),
          child: Semantics(
            label: '$count ${count == 1 ? 'reaction' : 'reactions'}',
            excludeSemantics: true,
            child: Container(
              height: _height,
              padding: const EdgeInsets.symmetric(horizontal: _inset),
              decoration: ShapeDecoration(
                color: colors.card,
                shape: StadiumBorder(side: BorderSide(color: colors.border)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  // The designs' coral, in both themes.
                  const Icon(
                    PhosphorIconsFill.heart,
                    size: 12,
                    color: Color(0xFFC8432F),
                  ),
                  Text(
                    '$count',
                    style: theme.messagesCaption.copyWith(
                      fontSize: 11,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: colors.foregroundSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A shared document: a file-type tile, the name, the size, and an arrow.
class _Attachment extends StatelessWidget {
  const _Attachment(this.file);

  final SharedFile file;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = theme.radii.xl;
    return Glass(
      level: GlassLevel.strong,
      borderRadius: radius,
      child: ListTile(
        onTap: () {},
        padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.md)),
        borderRadius: radius,
        leading: IconTile(
          size: 44,
          iconSize: 26,
          borderRadius: theme.radius,
          icon: Icon(file.icon),
        ),
        title: Text(file.name),
        titleStyle: theme.messagesName,
        subtitle: Text(file.attachmentCaption),
        trailing: Icon(
          PhosphorIconsRegular.arrowUpRight,
          size: 18,
          color: theme.colorScheme.mutedForeground,
        ),
      ),
    );
  }
}

/// A picture message.
class _Picture extends StatelessWidget {
  const _Picture(this.image, {required this.size});

  final MessageImage image;

  /// The size of the photograph; the hairline goes around it.
  final Size size;

  static const borderWidth = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(theme.chatBubbleTheme.radius ?? 18);
    final outer = Size(
      size.width + 2 * borderWidth,
      size.height + 2 * borderWidth,
    );
    return AspectRatio(
      aspectRatio: outer.aspectRatio,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: theme.colorScheme.muted,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: theme.colorScheme.border,
            width: borderWidth,
          ),
        ),
        child: Image.asset(
          image.asset,
          fit: BoxFit.cover,
          semanticLabel: image.label,
        ),
      ),
    );
  }
}

/// "Seen 10:14", under the outgoing message it belongs to.
class _Receipt extends StatelessWidget {
  const _Receipt(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: FinesseRow(
        gap: GapSize.xs,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsRegular.check,
            size: 14,
            color: theme.colorScheme.tint,
          ),
          Text(
            label,
            style: theme.messagesCaption.copyWith(
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// The other person's portrait beside three pulsing dots.
class _TypingRow extends StatelessWidget {
  const _TypingRow({required this.person, required this.avatarSize});

  final Person person;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // The indicator says who is typing.
        ExcludeSemantics(child: PersonAvatar(person, size: avatarSize)),
        const Gap.sm(),
        Flexible(
          child: ChatBubble(
            // Rounder than a text bubble's padding, so the dots sit in a
            // pill. The designs keep both values on a phone, so neither
            // follows the gap scale.
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: TypingIndicator(
              dotSize: 7,
              semanticLabel: '${person.firstName} is typing',
            ),
          ),
        ),
      ],
    );
  }
}
