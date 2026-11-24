import 'dart:math' as math;

import 'package:example/strand/data/messages_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/widgets/messages_controller.dart';
import 'package:example/strand/widgets/messages_conversation.dart';
import 'package:example/strand/widgets/messages_conversation_list.dart';
import 'package:example/strand/widgets/messages_details_pane.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The Messages destination of the Strand shell.
///
/// On a desktop it is one tall card split by hairlines into three panes: the
/// conversation list, the open conversation, and the details of whoever it
/// is with. The card sheds panes as the window narrows — the details first,
/// then the conversation, which the list then pushes as a full-screen page.
///
/// On a phone the destination is the list alone, on the page itself, and a
/// row opens the conversation as a page with its own header and composer.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  /// The widths of the outer panes; the conversation takes what is left.
  static const listWidth = 360.0;
  static const detailsWidth = 340.0;

  /// The card's width under which the details pane is dropped, and the one
  /// under which the conversation is.
  static const detailsBreakpoint = 1100.0;
  static const conversationBreakpoint = 760.0;

  /// The least the card is tall, in a window too short for it; the page
  /// scrolls instead.
  static const minHeight = 520.0;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _controller = MessagesController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openAsPage(Conversation conversation) {
    _controller.select(conversation);
    context.pushFullScreen<void>(
      (context) => MessagesConversationPage(
        controller: _controller,
        conversationId: conversation.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => FormFactorBuilder(
        mobile: _buildList,
        desktop: _buildCard,
      ),
    );
  }

  /// A phone: the list is the page.
  Widget _buildList(BuildContext context) {
    final theme = Theme.of(context);
    final layout = theme.layoutTheme;
    final margins = (layout.pagePadding ?? const EdgeInsets.all(16)).resolve(
      Directionality.of(context),
    );
    return PageContainer(
      scrollable: true,
      // The list brings its own insets: the header's are the page margins,
      // the rows' are tighter, as in the card.
      padding: EdgeInsets.zero,
      child: MessagesConversationList(
        controller: _controller,
        onOpen: _openAsPage,
        scrollable: false,
        showSelection: false,
        surfaceColor: theme.colorScheme.background,
        headerPadding: margins.copyWith(bottom: layout.gap(GapSize.md)),
      ),
    );
  }

  /// A desktop: the card, as tall as the window allows.
  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    final layout = theme.layoutTheme;
    final margins = (layout.pagePadding ?? const EdgeInsets.all(24)).resolve(
      Directionality.of(context),
    );
    final bars = MediaQuery.paddingOf(context);

    return LayoutBuilder(
      builder: (context, viewport) {
        final available = viewport.hasBoundedHeight
            ? viewport.maxHeight - bars.vertical - margins.vertical
            : MessagesScreen.minHeight;
        return PageContainer(
          // Only scrolls in a window shorter than the card's least height.
          scrollable: true,
          child: SizedBox(
            height: math.max(available, MessagesScreen.minHeight),
            child: LayoutBuilder(
              builder: (context, card) => _buildPanes(context, card.maxWidth),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPanes(BuildContext context, double width) {
    final theme = Theme.of(context);
    final layout = theme.layoutTheme;
    final showConversation = width >= MessagesScreen.conversationBreakpoint;
    final canShowDetails = width >= MessagesScreen.detailsBreakpoint;

    final list = MessagesConversationList(
      controller: _controller,
      onOpen: showConversation ? _controller.select : _openAsPage,
      showSelection: showConversation,
      // 18 above the title is the design's; the rest is on the gap scale.
      headerPadding: EdgeInsets.fromLTRB(
        layout.gap(GapSize.lg),
        18,
        layout.gap(GapSize.lg),
        layout.gap(GapSize.md),
      ),
    );

    return Card(
      padding: EdgeInsets.zero,
      // Rounder than the theme's cards: the design gives this one 22, which
      // falls between two steps of the radius scale.
      radius: const BorderRadius.all(Radius.circular(22)),
      child: SizedBox.expand(
        child: !showConversation
            ? list
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: MessagesScreen.listWidth, child: list),
                  const Divider.vertical(),
                  Expanded(
                    child: MessagesConversationPane(
                      controller: _controller,
                      onToggleDetails: canShowDetails
                          ? _controller.toggleDetails
                          : null,
                    ),
                  ),
                  if (canShowDetails && _controller.detailsVisible) ...[
                    const Divider.vertical(),
                    SizedBox(
                      width: MessagesScreen.detailsWidth,
                      child: MessagesDetailsPane(controller: _controller),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
