import 'dart:math' as math;

import 'package:example/strand/data/messages_data.dart';
import 'package:example/strand/widgets/messages_common.dart';
import 'package:example/strand/widgets/messages_composer.dart';
import 'package:example/strand/widgets/messages_controller.dart';
import 'package:example/strand/widgets/messages_thread.dart';
import 'package:example/strand/widgets/strand_actions.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The middle pane of the desktop card: who the conversation is with, the
/// thread, and the composer floating over its end.
class MessagesConversationPane extends StatelessWidget {
  const MessagesConversationPane({
    required this.controller,
    this.onToggleDetails,
    super.key,
  });

  final MessagesController controller;

  /// Called by the header's info button; null hides the button, where the
  /// details pane cannot be shown.
  final VoidCallback? onToggleDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conversation = controller.selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PaneHeader(
          conversation: conversation,
          onToggleDetails: onToggleDetails,
        ),
        Expanded(
          child: MessagesConversationView(
            // A new thread starts at its newest message, with an empty
            // composer.
            key: ValueKey(conversation.id),
            controller: controller,
            conversation: conversation,
            metrics: ThreadMetrics.pane(theme),
            composerInset: EdgeInsets.all(theme.layoutTheme.gap(GapSize.lg)),
            composerRadius: theme.radii.xl,
          ),
        ),
      ],
    );
  }
}

/// The pane's header: avatar, name, presence and headline, and the call,
/// video and details buttons.
class _PaneHeader extends StatelessWidget {
  const _PaneHeader({required this.conversation, this.onToggleDetails});

  final Conversation conversation;
  final VoidCallback? onToggleDetails;

  // Taller than the theme's app bar, for the two lines beside a 44-point
  // avatar.
  static const _height = 72.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Widget action(IconData icon, String label, VoidCallback onPressed) =>
        IconButton.ghost(
          size: ButtonSize.lg,
          icon: Icon(icon),
          semanticLabel: label,
          onPressed: onPressed,
        );

    return Container(
      // 72 and the hairline under it, which a `Container` counts in.
      height: _height + 1,
      padding: EdgeInsets.symmetric(horizontal: messagesPaneInset(theme)),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          ConversationAvatar(conversation, size: 44),
          const Gap.md(),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.large.copyWith(
                    color: colors.foreground,
                  ),
                ),
                Row(
                  children: [
                    if (conversation.online) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: theme.messagesCoral,
                        ),
                      ),
                      const Gap.raw(messagesTightGap),
                    ],
                    Flexible(
                      child: Text(
                        conversation.online
                            ? 'Active now · ${conversation.headline}'
                            : conversation.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap.sm(),
          FinesseRow(
            gap: GapSize.xs,
            mainAxisSize: MainAxisSize.min,
            children: [
              action(
                PhosphorIconsRegular.phone,
                'Call',
                () => startCall(context, conversation.name),
              ),
              action(
                PhosphorIconsRegular.videoCamera,
                'Video call',
                () => startCall(context, conversation.name, video: true),
              ),
              if (onToggleDetails case final toggle?)
                action(
                  PhosphorIconsRegular.info,
                  'Conversation details',
                  toggle,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A thread with the composer pinned over its end.
///
/// The messages scroll under the composer — and under whatever [MediaQuery]
/// says covers the top of the view, which on the full-screen page is its
/// glass app bar. The software keyboard pushes both the composer and the
/// end of the thread up.
class MessagesConversationView extends StatefulWidget {
  const MessagesConversationView({
    required this.controller,
    required this.conversation,
    required this.metrics,
    required this.composerInset,
    required this.composerRadius,
    super.key,
  });

  final MessagesController controller;
  final Conversation conversation;
  final ThreadMetrics metrics;

  /// How far the composer floats from the view's sides and bottom.
  final EdgeInsets composerInset;

  final BorderRadius composerRadius;

  @override
  State<MessagesConversationView> createState() =>
      _MessagesConversationViewState();
}

class _MessagesConversationViewState extends State<MessagesConversationView> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool _send(String text) {
    if (!widget.controller.send(widget.conversation, text)) return false;
    // The thread is anchored to its end, so the newest message is offset 0.
    if (_scroll.hasClients && _scroll.offset > 0) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // The home indicator's inset gives way to the keyboard's when it is up.
    final bottom = math.max(media.viewInsets.bottom, media.padding.bottom);
    final composerInset = widget.composerInset;
    // The designs keep 96 under the last message: the composer, its 16 from
    // the bottom, and a little air between the two.
    final reserve =
        composerInset.bottom + MessagesComposer.heightOf(context) + 18;

    return Stack(
      fit: StackFit.expand,
      children: [
        MessagesThread(
          conversation: widget.conversation,
          messages: widget.controller.messagesOf(widget.conversation),
          metrics: widget.metrics,
          controller: _scroll,
          insets: EdgeInsets.only(
            top: media.padding.top,
            bottom: bottom + reserve,
          ),
        ),
        Positioned(
          left: composerInset.left + media.padding.left,
          right: composerInset.right + media.padding.right,
          bottom: composerInset.bottom + bottom,
          child: MessagesComposer(
            onSend: _send,
            borderRadius: widget.composerRadius,
          ),
        ),
      ],
    );
  }
}

/// A conversation as a page of its own: what a phone — or a window too
/// narrow for two panes — pushes when a row of the list is tapped.
///
/// It has its own glass app bar (back, avatar, name, presence, call and
/// video) and no bottom navigation; the composer sits in a glass bar at the
/// bottom.
class MessagesConversationPage extends StatelessWidget {
  const MessagesConversationPage({
    required this.controller,
    required this.conversationId,
    super.key,
  });

  final MessagesController controller;
  final String conversationId;

  // The designs' header is 68 tall — taller than the theme's phone app bar,
  // to fit the two lines beside a 40-point avatar. The hairline under it is
  // the `AppBar`'s own business.
  static const _barHeight = 68.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final layout = theme.layoutTheme;
    final conversation = controller.byId(conversationId);

    return Scaffold(
      appBar: AppBar(
        height: _barHeight,
        // 8 at the sides, so the 44-point buttons' glyphs — not their boxes
        // — line up with the page margin, and 4 between everything.
        padding: EdgeInsets.symmetric(horizontal: layout.gap(GapSize.sm)),
        gap: 2 * layout.gap(GapSize.xs),
        actionsGap: layout.gap(GapSize.xs),
        leading: FinesseRow(
          gap: GapSize.xs,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.ghost(
              icon: const Icon(PhosphorIconsRegular.caretLeft),
              iconSize: 24,
              semanticLabel: 'Back',
              onPressed: () => Navigator.of(context).pop(),
            ),
            ConversationAvatar(
              conversation,
              size: 40,
              // The bar is the surface here, not a card.
              surfaceColor: colors.bar,
            ),
          ],
        ),
        title: Padding(
          // 10 between the avatar and the name: the bar's 4 and these 6.
          padding: const EdgeInsetsDirectional.only(start: messagesTightGap),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(conversation.name),
              Text(
                conversation.online ? 'Active now' : conversation.headline,
                style: theme.messagesCaption.copyWith(
                  color: conversation.online ? colors.tint : null,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton.ghost(
            icon: const Icon(PhosphorIconsRegular.phone),
            semanticLabel: 'Call',
            onPressed: () => startCall(context, conversation.name),
          ),
          IconButton.ghost(
            icon: const Icon(PhosphorIconsRegular.videoCamera),
            semanticLabel: 'Video call',
            onPressed: () => startCall(context, conversation.name, video: true),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => MessagesConversationView(
          controller: controller,
          conversation: conversation,
          metrics: ThreadMetrics.page(theme),
          // 10 from the sides — under the gap scale — and 16 from the
          // bottom, in a bar as round as the phone's cards.
          composerInset: const EdgeInsets.fromLTRB(10, 0, 10, 16),
          composerRadius: theme.radii.xl4,
        ),
      ),
    );
  }
}
