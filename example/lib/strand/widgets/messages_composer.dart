import 'package:example/strand/widgets/strand_actions.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The bar a message is written in: add and photo buttons, the field, and
/// the round send button, on a glass surface that floats over the thread.
///
/// Enter and the send button both call [onSend] with the field's text; the
/// field is cleared, and keeps the focus, when [onSend] returns true.
class MessagesComposer extends StatefulWidget {
  const MessagesComposer({
    required this.onSend,
    required this.borderRadius,
    super.key,
  });

  /// Called with what was typed. Returns whether it was sent.
  final bool Function(String text) onSend;

  /// The corners of the glass bar.
  final BorderRadius borderRadius;

  /// The bar's height: the send button, the padding around it and the
  /// hairline. The thread reserves this much, and a margin, under its last
  /// message.
  static double heightOf(BuildContext context) =>
      _sendSize + 2 * Theme.of(context).layoutTheme.gap(GapSize.sm) + 2;

  // The designs keep the composer's controls the same size on a desktop and
  // on a phone — 40-point buttons and field, a 44-point send button — so
  // these do not follow the theme's control heights.
  static const _controlSize = 40.0;
  static const _sendSize = 44.0;

  @override
  State<MessagesComposer> createState() => _MessagesComposerState();
}

class _MessagesComposerState extends State<MessagesComposer> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    if (widget.onSend(_text.text)) _text.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final layout = theme.layoutTheme;
    // What is typed is set like the message it will become.
    final messageStyle = theme.chatBubbleTheme.textStyle ?? theme.textTheme.p;

    Widget tool(IconData icon, String label) => IconButton.ghost(
      width: MessagesComposer._controlSize,
      height: MessagesComposer._controlSize,
      iconSize: 22,
      icon: Icon(icon),
      semanticLabel: label,
      onPressed: () => showNothingToAttach(context),
    );

    return Glass(
      borderRadius: widget.borderRadius,
      padding: EdgeInsets.all(layout.gap(GapSize.sm)),
      shadows: theme.cardTheme.shadows ?? const [],
      child: Row(
        spacing: layout.gap(GapSize.xs),
        children: [
          tool(PhosphorIconsRegular.plusCircle, 'Add'),
          tool(PhosphorIconsRegular.image, 'Add photo'),
          Expanded(
            child: Semantics(
              label: 'Message',
              child: TextField(
                controller: _text,
                focusNode: _focus,
                style: messageStyle.copyWith(color: colors.foreground),
                placeholderStyle: messageStyle.copyWith(
                  color: colors.mutedForeground,
                ),
                placeholder: const Text(
                  'Write a message…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                textInputAction: TextInputAction.send,
                textCapitalization: TextCapitalization.sentences,
                // Not `onSubmitted`: the default editing-complete handler
                // drops the focus first, and a chat keeps the keyboard up.
                onEditingComplete: _send,
                constraints: const BoxConstraints(
                  minHeight: MessagesComposer._controlSize,
                ),
                // A borderless pill in the field's own fill. The design
                // shows no focus outline here; the caret is the indication.
                decoration: FinesseDecoration(
                  border: FinesseBorder.all(
                    width: 0,
                    color: const Color(0x00000000),
                    radius: theme.radii.full,
                  ),
                  disableSecondaryBorder: true,
                ),
                trailing: Icon(
                  PhosphorIconsRegular.smiley,
                  size: 20,
                  color: colors.mutedForeground,
                ),
              ),
            ),
          ),
          IconButton(
            width: MessagesComposer._sendSize,
            height: MessagesComposer._sendSize,
            iconSize: 20,
            // The design's `--accent`: the tint, not the primary button's
            // fill, which stays dark teal in the dark theme.
            backgroundColor: colors.tint,
            hoverBackgroundColor: colors.tint.withValues(alpha: .9),
            foregroundColor: colors.tintForeground,
            hoverForegroundColor: colors.tintForeground,
            icon: const Icon(PhosphorIconsRegular.paperPlaneTilt),
            semanticLabel: 'Send',
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}
