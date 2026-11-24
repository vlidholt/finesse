import 'package:example/strand/data.dart';
import 'package:example/strand/data/home_data.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/strand_actions.dart';
import 'package:example/strand/widgets/strand_pieces.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The thread under a desktop post: comments with their replies, the
/// "View more replies" link and the field for a new comment.
class HomePostComments extends StatefulWidget {
  const HomePostComments(this.post, {this.fieldFocusNode, super.key});

  final FeedPost post;

  /// The comment field's focus node, so the post's "Comment" action can
  /// move focus to it.
  final FocusNode? fieldFocusNode;

  @override
  State<HomePostComments> createState() => _HomePostCommentsState();
}

class _HomePostCommentsState extends State<HomePostComments> {
  /// The comments whose hidden replies are showing.
  final _expanded = <String>{};

  /// The comments and replies the signed-in user has liked.
  final _liked = <String>{};

  /// What is typed in the comment field.
  final _draft = TextEditingController();

  /// The field's focus node when the post did not hand one in.
  final _ownFocus = FocusNode();

  FocusNode get _fieldFocus => widget.fieldFocusNode ?? _ownFocus;

  @override
  void dispose() {
    _draft.dispose();
    _ownFocus.dispose();
    super.dispose();
  }

  /// Puts [text] at the end of the draft and the cursor after it.
  void _append(String text) {
    final next = '${_draft.text}$text';
    _draft.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    _fieldFocus.requestFocus();
  }

  void _post() {
    final text = _draft.text.trim();
    if (text.isEmpty) return;
    _draft.clear();
    showStrandToast(context, 'Comment posted', description: text);
  }

  void _toggle(Set<String> set, String id) {
    setState(() {
      if (!set.remove(id)) set.add(id);
    });
  }

  /// The portrait beside a comment and beside the comment field; a reply's
  /// is a step smaller.
  static const _avatarSize = 32.0;
  static const _replyAvatarSize = 28.0;

  Widget _comment(FeedComment comment, {required double avatarSize}) {
    return _Comment(
      comment,
      avatarSize: avatarSize,
      liked: _liked.contains(comment.id),
      onLike: () => _toggle(_liked, comment.id),
      // Start the comment with who it answers.
      onReply: () => _append('@${comment.author.name} '),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      // 14 between the thread's rows: looser than a group's 12, tighter
      // than the gap between cards.
      spacing: homeLooseGap,
      children: [
        for (final comment in widget.post.thread) ...[
          _comment(comment, avatarSize: _avatarSize),
          for (final reply in [
            ...comment.replies,
            if (_expanded.contains(comment.id)) ...comment.hiddenReplies,
          ])
            _Reply(
              // The rule is centred under the comment's portrait.
              ruleCentre: _avatarSize / 2,
              child: _comment(reply, avatarSize: _replyAvatarSize),
            ),
          if (comment.hiddenReplies.isNotEmpty)
            Padding(
              // Under the comment's text column: its portrait and gap.
              padding: const EdgeInsetsDirectional.only(
                start: _avatarSize + homeSnugGap,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: HomeTextLink(
                  _expanded.contains(comment.id)
                      ? 'Hide replies'
                      : 'View ${comment.hiddenReplies.length} more replies',
                  onPressed: () => _toggle(_expanded, comment.id),
                  style: theme.textTheme.small.copyWith(
                    color: scheme.mutedForeground,
                  ),
                ),
              ),
            ),
        ],
        Row(
          children: [
            const PersonAvatar(People.me, size: _avatarSize),
            const Gap.raw(homeSnugGap),
            Expanded(
              child: Semantics(
                label: 'Add a comment',
                child: TextField(
                  controller: _draft,
                  focusNode: _fieldFocus,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _post(),
                  placeholder: const Text('Add a comment…'),
                  // The reshaping a pill button takes suits a field too.
                  decoration: theme.buttonDecoration(radius: theme.radii.full),
                  // The designs size the field's inside at 40 and draw the
                  // hairline around that.
                  constraints: const BoxConstraints(minHeight: 42),
                  // The text starts 16 in — the design's 14 and the 2 a
                  // browser pads an input with; the round trailing buttons
                  // sit closer to the pill's end than a field's usual 12.
                  padding: EdgeInsetsDirectional.only(
                    start: theme.layoutTheme.gap(GapSize.lg),
                    end: homeTightGap,
                  ),
                  gap: theme.layoutTheme.gap(GapSize.xs),
                  trailing: FinesseRow(
                    gap: GapSize.xs,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.ghost(
                        size: ButtonSize.sm,
                        iconSize: 18,
                        icon: const Icon(PhosphorIconsRegular.smiley),
                        semanticLabel: 'Add emoji',
                        onPressed: () => _append('👏'),
                      ),
                      IconButton.ghost(
                        size: ButtonSize.sm,
                        iconSize: 18,
                        icon: const Icon(PhosphorIconsRegular.image),
                        semanticLabel: 'Add photo',
                        onPressed: () => showNothingToAttach(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A reply: indented under its comment, with a rule down its start edge.
class _Reply extends StatelessWidget {
  const _Reply({required this.ruleCentre, required this.child});

  /// How far in from the start edge the rule's centre line runs.
  final double ruleCentre;
  final Widget child;

  static const _ruleWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        PositionedDirectional(
          start: ruleCentre - _ruleWidth / 2,
          top: 0,
          bottom: 0,
          width: _ruleWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.borderStrong,
              borderRadius: const BorderRadius.all(
                Radius.circular(_ruleWidth),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: ruleCentre + _ruleWidth / 2 + homeSnugGap,
          ),
          child: child,
        ),
      ],
    );
  }
}

/// One comment: portrait, a bubble with the author and the text, and the
/// age / like / reply line under it.
class _Comment extends StatelessWidget {
  const _Comment(
    this.comment, {
    required this.avatarSize,
    required this.liked,
    required this.onLike,
    required this.onReply,
  });

  final FeedComment comment;
  final double avatarSize;
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final author = comment.author;
    final meta = theme.style.caption
        .apply(theme.textTheme.small)
        .copyWith(color: scheme.mutedForeground);
    final likes = comment.likes + (liked ? 1 : 0);
    // The bubble's three round corners; the fourth is the tail.
    final corner = theme.radii.xl.topLeft;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonAvatar(author, size: avatarSize),
        const Gap.raw(homeSnugGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // The package's ChatBubble is a message: capped at part of
              // the width, with its tail at the bottom. A comment fills the
              // column and points up at its author, so only the bubble's
              // colour is shared.
              Container(
                padding:
                    theme.chatBubbleTheme.padding ??
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.chatBubbleTheme.incomingColor ?? scheme.accent,
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: const Radius.circular(4),
                    topEnd: corner,
                    bottomStart: corner,
                    bottomEnd: corner,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: author.name,
                        children: [
                          TextSpan(
                            text: ' · ${author.headline}',
                            // A copy of the theme's style, so the lighter
                            // weight gets the font's regular face.
                            style: theme.textTheme.small.copyWith(
                              fontWeight: FontWeight.w400,
                              color: scheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.small.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.foreground,
                      ),
                    ),
                    const Gap.raw(homeHairGap),
                    Text(
                      comment.text,
                      style: theme.textTheme.p.copyWith(
                        color: scheme.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: theme.layoutTheme.gap(GapSize.xs),
                  top: homeTightGap,
                  right: theme.layoutTheme.gap(GapSize.xs),
                ),
                child: Row(
                  spacing: homeLooseGap,
                  children: [
                    Text(comment.age, style: meta),
                    HomeTextLink(
                      '${liked ? 'Liked' : 'Like'} · $likes',
                      onPressed: onLike,
                      style: liked ? meta.copyWith(color: scheme.tint) : meta,
                    ),
                    HomeTextLink('Reply', onPressed: onReply, style: meta),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
