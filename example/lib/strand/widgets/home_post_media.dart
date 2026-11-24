import 'package:example/strand/data/home_data.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/strand_actions.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// What a post carries under its text: photographs, a link preview or an
/// event. Null-returning for a text-only post.
class HomePostMedia extends StatelessWidget {
  const HomePostMedia(this.post, {required this.compact, super.key});

  final FeedPost post;

  /// Whether this is the phone's card: one photograph at a time, shorter.
  final bool compact;

  /// Whether [post] has anything for this widget to show.
  static bool has(FeedPost post) =>
      post.images.isNotEmpty || post.link != null || post.event != null;

  /// The corner radius of every kind of media, between the theme's `lg`
  /// and `xl`.
  static const radius = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context) {
    if (post.event case final event?) {
      return _EventMedia(event, compact: compact);
    }
    if (post.link case final link?) {
      return _LinkPreview(link, compact: compact);
    }
    if (post.images.isEmpty) return const SizedBox.shrink();
    return compact ? _ImagePager(post.images) : _ImageGrid(post.images);
  }
}

/// The desktop card's photographs, side by side under one rounded clip.
class _ImageGrid extends StatelessWidget {
  const _ImageGrid(this.images);

  final List<FeedImage> images;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: HomePostMedia.radius,
      child: Row(
        spacing: homeTightGap,
        children: [
          for (final image in images)
            Expanded(
              child: Image.asset(
                image.asset,
                height: 280,
                fit: BoxFit.cover,
                semanticLabel: image.alt,
              ),
            ),
        ],
      ),
    );
  }
}

/// The phone card's photographs: one at a time, with a "1 / 2" counter.
/// Tapping the photograph moves to the next one.
class _ImagePager extends StatefulWidget {
  const _ImagePager(this.images);

  final List<FeedImage> images;

  @override
  State<_ImagePager> createState() => _ImagePagerState();
}

class _ImagePagerState extends State<_ImagePager> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = widget.images;
    final image = images[_index % images.length];
    return ClipRRect(
      borderRadius: HomePostMedia.radius,
      // Its own layer, so the counter's backdrop blur samples the
      // photograph alone.
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        children: [
          GestureDetector(
            onTap: images.length < 2
                ? null
                : () => setState(() => _index = (_index + 1) % images.length),
            child: Image.asset(
              image.asset,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              semanticLabel: image.alt,
            ),
          ),
          if (images.length > 1)
            PositionedDirectional(
              top: homeSnugGap,
              end: homeSnugGap,
              child: Glass(
                color: _scrim,
                border: const Border.fromBorderSide(BorderSide.none),
                borderRadius: theme.radii.full,
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: homeSnugGap),
                alignment: Alignment.center,
                child: Text(
                  '${_index + 1} / ${images.length}',
                  style: theme.textTheme.small.copyWith(
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: _onPhoto,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The article a post links to: thumbnail, source line, title.
class _LinkPreview extends StatelessWidget {
  const _LinkPreview(this.link, {required this.compact});

  final FeedLink link;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final layout = theme.layoutTheme;
    final overline = theme.style.overline;
    return Pressable(
      onPressed: () => showArticlePreview(
        context,
        image: link.image,
        source: link.source,
        title: link.title,
      ),
      builder: (context, states) => FocusRing(
        visible: states.contains(WidgetState.focused),
        borderRadius: HomePostMedia.radius,
        child: Container(
          // A 120-point thumbnail inside the hairline.
          height: 122,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: states.contains(WidgetState.hovered)
                ? scheme.secondary
                : scheme.muted,
            borderRadius: HomePostMedia.radius,
            border: Border.all(color: scheme.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                link.image,
                // The design gives the desktop thumbnail 168; the phone
                // card is too narrow for that and the title together.
                width: compact ? 104 : 168,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    // 16 on a desktop and 12 on a phone, as the theme's
                    // `lg` gap is.
                    horizontal: layout.gap(GapSize.lg),
                    vertical: compact ? layout.gap(GapSize.md) : homeLooseGap,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overline.applyCase(link.source),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: overline
                            .apply(theme.textTheme.small)
                            .copyWith(color: scheme.mutedForeground),
                      ),
                      const Gap.xs(),
                      Flexible(
                        child: Text(
                          link.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.large.copyWith(
                            height: 21 / 15,
                            color: scheme.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A post's event: the photograph with the event's date, name and an
/// "Interested" toggle on a glass strip along its bottom edge.
///
/// Everything on the strip sits on a photograph, so its colours are the
/// design's literals and do not follow the theme.
class _EventMedia extends StatefulWidget {
  const _EventMedia(this.event, {required this.compact});

  final FeedEvent event;
  final bool compact;

  @override
  State<_EventMedia> createState() => _EventMediaState();
}

class _EventMediaState extends State<_EventMedia> {
  bool _interested = false;

  void _toggle() => setState(() => _interested = !_interested);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inset = theme.layoutTheme.gap(GapSize.md);
    final event = widget.event;
    final compact = widget.compact;
    final star = Icon(
      _interested ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
    );

    return ClipRRect(
      borderRadius: HomePostMedia.radius,
      // Its own layer, so the strip's backdrop blur samples the photograph
      // alone and not the card around it.
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        children: [
          Image.asset(
            event.image.asset,
            height: compact ? 220 : 320,
            width: double.infinity,
            fit: BoxFit.cover,
            semanticLabel: event.image.alt,
          ),
          Positioned(
            left: inset,
            right: inset,
            bottom: inset,
            child: Glass(
              color: _scrim,
              border: Border.all(color: const Color(0x2EFFFFFF)),
              borderRadius: HomePostMedia.radius,
              padding: EdgeInsets.symmetric(
                horizontal: homeLooseGap,
                vertical: inset,
              ),
              child: FinesseRow(
                gap: GapSize.md,
                children: [
                  _DateTile(month: event.month, day: event.day),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.large.copyWith(
                            color: _onPhoto,
                          ),
                        ),
                        Text(
                          event.detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.muted.copyWith(
                            color: _onPhoto.withValues(alpha: .86),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (compact)
                    // No room for the label beside the event's name.
                    IconButton(
                      size: ButtonSize.sm,
                      iconSize: 16,
                      backgroundColor: _onPhoto,
                      hoverBackgroundColor: _onPhotoHover,
                      foregroundColor: _ink,
                      hoverForegroundColor: _ink,
                      icon: star,
                      semanticLabel: 'Interested',
                      onPressed: _toggle,
                    )
                  else
                    Button(
                      gap: homeTightGap,
                      iconSize: 16,
                      backgroundColor: _onPhoto,
                      hoverBackgroundColor: _onPhotoHover,
                      foregroundColor: _ink,
                      hoverForegroundColor: _ink,
                      textStyle: theme.textTheme.small.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      leading: star,
                      onPressed: _toggle,
                      child: const Text('Interested'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The calendar-page tile: month over day on near-opaque white.
class _DateTile extends StatelessWidget {
  const _DateTile({required this.month, required this.day});

  final String month;
  final String day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.small.copyWith(fontWeight: FontWeight.w700);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xEBFFFFFF),
        borderRadius: theme.radii.md,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            month,
            style: base.copyWith(
              fontSize: 10,
              height: 1,
              letterSpacing: .6,
              color: const Color(0xFF176B83),
            ),
          ),
          Text(
            day,
            style: base.copyWith(fontSize: 18, height: 20 / 18, color: _ink),
          ),
        ],
      ),
    );
  }
}

/// `rgba(9, 9, 11, .36)`: the scrim under text on a photograph.
const _scrim = Color(0x5C09090B);
const _onPhoto = Color(0xFFFFFFFF);
const _onPhotoHover = Color(0xE6FFFFFF);
const _ink = Color(0xFF09090B);
