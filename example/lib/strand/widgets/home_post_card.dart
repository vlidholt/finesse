import 'package:example/strand/data/home_data.dart';
import 'package:example/strand/widgets/home_feed_scope.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/home_post_comments.dart';
import 'package:example/strand/widgets/home_post_media.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/strand_actions.dart';
import 'package:example/strand/widgets/strand_pieces.dart';
import 'package:example/strand/widgets/strand_previews.dart';
import 'package:example/strand/widgets/verified_badge.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A post in the home feed.
///
/// The desktop card is the full post: header with "Follow", text, media, the
/// reaction summary, four labelled actions and the comment thread. The
/// phone's card is the compact one from the mobile design: shorter text, one
/// photograph, and an icon-only action row that carries the counts.
class HomePostCard extends StatefulWidget {
  const HomePostCard(this.post, {super.key});

  final FeedPost post;

  @override
  State<HomePostCard> createState() => _HomePostCardState();
}

class _HomePostCardState extends State<HomePostCard> {
  final _commentFocus = FocusNode(debugLabel: 'Add a comment');

  @override
  void dispose() {
    _commentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;
    final compact = theme.formFactor == FormFactor.mobile;
    final layout = theme.layoutTheme;
    // 14 on a desktop, 12 on a phone: between the card's blocks.
    final blockGap = compact ? layout.gap(GapSize.md) : homeLooseGap;
    final body = Text(
      compact ? post.compactBody : post.body,
      // The feed's reading size, 15/24: roomier than the theme's body text
      // on either form factor.
      style: theme.textTheme.p.copyWith(
        fontSize: 15,
        height: 24 / 15,
        color: theme.colorScheme.foreground,
      ),
    );

    if (compact) {
      final padding = (theme.cardTheme.padding ?? const EdgeInsets.all(16))
          .resolve(
            Directionality.of(context),
          );
      return Card(
        // The action row's 44-point targets reach 6 into the bottom inset.
        padding: padding.copyWith(bottom: padding.bottom - homeTightGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _PostHeader(post, compact: true),
            Gap.raw(blockGap),
            body,
            if (HomePostMedia.has(post)) ...[
              Gap.raw(blockGap),
              HomePostMedia(post, compact: true),
            ],
            Gap.raw(blockGap),
            _ReactionSummary(post, compact: true),
            const Gap.xs(),
            _CompactActions(post),
          ],
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PostHeader(post, compact: false),
          Gap.raw(blockGap),
          body,
          if (HomePostMedia.has(post)) ...[
            Gap.raw(blockGap),
            HomePostMedia(post, compact: false),
          ],
          Padding(
            padding: EdgeInsets.only(
              top: layout.gap(GapSize.md),
              bottom: homeSnugGap,
            ),
            child: _ReactionSummary(post, compact: false),
          ),
          const Divider.horizontal(),
          const Gap.raw(homeTightGap),
          _Actions(
            post,
            onComment: post.thread.isEmpty
                ? () => showCommentDialog(context, post.author)
                : _commentFocus.requestFocus,
          ),
          if (post.thread.isNotEmpty) ...[
            const Gap.md(),
            HomePostComments(post, fieldFocusNode: _commentFocus),
          ],
        ],
      ),
    );
  }
}

/// Portrait, name, age and headline, then "Follow" and the overflow menu.
class _PostHeader extends StatelessWidget {
  const _PostHeader(this.post, {required this.compact});

  final FeedPost post;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final model = HomeFeedScope.of(context);
    final author = post.author;
    final following = model.isFollowing(author);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonAvatar(author, size: compact ? 40 : homeAvatarSize),
        const Gap.md(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: HomeTextLink(
                      author.name,
                      onPressed: () => showPersonPreview(context, author),
                      style: theme.textTheme.large.copyWith(
                        color: scheme.foreground,
                      ),
                    ),
                  ),
                  if (author.verified) ...[
                    const Gap.raw(homeTightGap),
                    const VerifiedBadge(),
                  ],
                  const Gap.raw(homeTightGap),
                  Text('· ${post.age}', style: theme.textTheme.muted),
                ],
              ),
              Text(
                author.headline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.muted,
              ),
            ],
          ),
        ),
        // The phone's card has no room for "Follow"; it lives in the menu.
        if (!compact && post.followable) ...[
          const Gap.xs(),
          _FollowChip(
            following: following,
            onPressed: () => model.toggleFollow(author),
          ),
        ],
        const Gap.xs(),
        _PostMenu(post),
      ],
    );
  }
}

/// "+ Follow", an outlined pill; "✓ Following" once pressed.
class _FollowChip extends StatelessWidget {
  const _FollowChip({required this.following, required this.onPressed});

  final bool following;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      selected: following,
      onSelected: (_) => onPressed(),
      // Tighter than a filter chip — 10 at the sides, a 14-point glyph —
      // and outlined in the strong border on the bare card.
      padding: const EdgeInsets.symmetric(horizontal: homeSnugGap),
      backgroundColor: const Color(0x00000000),
      borderColor: scheme.borderStrong,
      foregroundColor: scheme.foreground,
      leading: Icon(
        following ? PhosphorIconsRegular.check : PhosphorIconsRegular.plus,
        size: 14,
      ),
      label: Text(following ? 'Following' : 'Follow'),
    );
  }
}

/// The "More options" button and its menu.
class _PostMenu extends StatelessWidget {
  const _PostMenu(this.post);

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final model = HomeFeedScope.of(context);
    final author = post.author;
    return DropdownMenu(
      itemsBuilder: (_) => [
        ContextMenuItem(
          leading: const Icon(PhosphorIconsRegular.bookmarkSimple),
          onPressed: () => showStrandToast(
            context,
            'Post saved',
            description: 'Find it under Saved items in your menu.',
          ),
          child: const Text('Save post'),
        ),
        ContextMenuItem(
          leading: const Icon(PhosphorIconsRegular.link),
          onPressed: () => copyLink(context, 'strand.app/posts/${post.id}'),
          child: const Text('Copy link'),
        ),
        if (post.followable)
          ContextMenuItem(
            leading: Icon(
              model.isFollowing(author)
                  ? PhosphorIconsRegular.userMinus
                  : PhosphorIconsRegular.userPlus,
            ),
            onPressed: () => model.toggleFollow(author),
            child: Text(
              '${model.isFollowing(author) ? 'Unfollow' : 'Follow'} '
              '${author.firstName}',
            ),
          ),
        ContextMenuItem(
          leading: const Icon(PhosphorIconsRegular.eyeSlash),
          onPressed: () => showStrandToast(
            context,
            'Thanks, noted',
            description: 'You will see fewer posts like this one.',
          ),
          child: const Text('Not interested'),
        ),
      ],
      builder: (context, controller, _) => IconButton.ghost(
        size: ButtonSize.sm,
        icon: const Icon(PhosphorIconsRegular.dotsThree),
        semanticLabel: 'More options',
        onPressed: controller.toggle,
      ),
    );
  }
}

/// The overlapping reaction discs and "Sara Lindqvist and 214 others";
/// on a desktop, the comment and repost counts at the end of the row.
class _ReactionSummary extends StatelessWidget {
  const _ReactionSummary(this.post, {required this.compact});

  final FeedPost post;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = HomeFeedScope.of(context);
    final others = formatCount(model.otherReactions(post));
    final name = compact ? post.reactedBy.firstName : post.reactedBy.name;
    final size = compact ? 18.0 : 20.0;

    return Row(
      children: [
        ExcludeSemantics(
          child: AvatarGroup(
            size: size,
            overlap: 5,
            children: [
              for (final reaction in post.reactions)
                SizedBox.square(
                  dimension: size,
                  child: ColoredBox(
                    color: reaction.background,
                    child: Icon(
                      reaction.icon,
                      size: compact ? 10 : 12,
                      color: reaction.foreground,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Gap.sm(),
        Expanded(
          child: Text(
            '$name and $others others',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.muted,
          ),
        ),
        if (!compact) ...[
          const Gap.md(),
          Text(
            [
              '${formatCount(post.comments)} comments',
              if (post.reposts > 0) '${formatCount(post.reposts)} reposts',
            ].join(' · '),
            style: theme.textTheme.muted,
          ),
        ],
      ],
    );
  }
}

/// The desktop card's four labelled actions, sharing the width.
class _Actions extends StatelessWidget {
  const _Actions(this.post, {required this.onComment});

  final FeedPost post;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final model = HomeFeedScope.of(context);
    final liked = model.isLiked(post);

    Widget action({
      required IconData icon,
      required String label,
      required VoidCallback onPressed,
      Color? color,
    }) {
      return Expanded(
        child: Button.ghost(
          // 40: a full-width action sits between the theme's 36-point
          // button and its 44-point large one.
          height: 40,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: theme.layoutTheme.gap(GapSize.xs),
          ),
          iconSize: 20,
          foregroundColor: color ?? scheme.foregroundSubtle,
          hoverForegroundColor: color ?? scheme.foreground,
          leading: Icon(icon),
          onPressed: onPressed,
          child: Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      );
    }

    return FinesseRow(
      gap: GapSize.xs,
      children: [
        action(
          icon: liked ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
          label: 'Like',
          color: liked ? scheme.tint : null,
          onPressed: () => model.toggleLike(post),
        ),
        action(
          icon: PhosphorIconsRegular.chatCircle,
          label: 'Comment',
          onPressed: onComment,
        ),
        action(
          icon: PhosphorIconsRegular.repeat,
          label: 'Repost',
          onPressed: () => repostWithToast(context, post.author),
        ),
        action(
          icon: PhosphorIconsRegular.paperPlaneTilt,
          label: 'Send',
          onPressed: () => showSendDialog(context, what: 'this post'),
        ),
      ],
    );
  }
}

/// The phone card's action row: like, comment and repost with their
/// counts, then send.
class _CompactActions extends StatelessWidget {
  const _CompactActions(this.post);

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final model = HomeFeedScope.of(context);
    final liked = model.isLiked(post);
    final pill = theme.buttonDecoration(radius: theme.radii.full);

    Widget action({
      required IconData icon,
      required String label,
      required int count,
      required VoidCallback onPressed,
      Color? color,
    }) {
      return Semantics(
        label: label,
        child: Button.ghost(
          // Hugs its count: 10 at the sides and 6 from glyph to number,
          // so four of them fit a phone with room to spare.
          padding: const EdgeInsets.symmetric(horizontal: homeSnugGap),
          gap: homeTightGap,
          iconSize: theme.buttonSizesTheme.icon?.iconSize,
          decoration: pill,
          textStyle: theme.textTheme.small,
          foregroundColor: color ?? scheme.foregroundSubtle,
          hoverForegroundColor: color ?? scheme.foreground,
          leading: Icon(icon),
          onPressed: onPressed,
          child: Text(formatCount(count)),
        ),
      );
    }

    // The row's glyphs line up with the card's content, so the buttons
    // start their side padding outside it.
    return Transform.translate(
      offset: Offset(
        Directionality.of(context) == TextDirection.rtl
            ? homeSnugGap
            : -homeSnugGap,
        0,
      ),
      child: Row(
        spacing: homeHairGap,
        children: [
          action(
            icon: liked ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
            label: 'Like',
            count: model.reactionCount(post),
            color: liked ? scheme.tint : null,
            onPressed: () => model.toggleLike(post),
          ),
          action(
            icon: PhosphorIconsRegular.chatCircle,
            label: 'Comment',
            count: post.comments,
            onPressed: () => showCommentDialog(context, post.author),
          ),
          if (post.reposts > 0)
            action(
              icon: PhosphorIconsRegular.repeat,
              label: 'Repost',
              count: post.reposts,
              onPressed: () => repostWithToast(context, post.author),
            )
          else
            IconButton.ghost(
              icon: const Icon(PhosphorIconsRegular.repeat),
              foregroundColor: scheme.foregroundSubtle,
              semanticLabel: 'Repost',
              onPressed: () => repostWithToast(context, post.author),
            ),
          IconButton.ghost(
            icon: const Icon(PhosphorIconsRegular.paperPlaneTilt),
            foregroundColor: scheme.foregroundSubtle,
            semanticLabel: 'Send',
            onPressed: () => showSendDialog(context, what: 'this post'),
          ),
        ],
      ),
    );
  }
}
