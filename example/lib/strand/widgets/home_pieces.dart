import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Small pieces several home-feed cards share.

// The steps the home designs use between the stops of the theme's gap
// scale (4 / 8 / 12 / 16 / 24). They hold on both form factors.

/// 2: between a name and the line under it.
const homeHairGap = 2.0;

/// 6: between a label and the glyph, mark or count beside it.
const homeTightGap = 6.0;

/// 10: between a small portrait or logo and its text, and the side inset of
/// a compact control.
const homeSnugGap = 10.0;

/// 14: between the rows and blocks of a card.
const homeLooseGap = 14.0;

/// 18: the inset of the side-rail cards, between the theme's 16 and 20.
const homeRailInset = 18.0;

/// 44: the portrait that leads a post, the composer and a suggestion.
const homeAvatarSize = 44.0;

/// The feed's fine print — 12/16 in the muted colour: counts under a name,
/// the footer links. Lighter than the theme's caption role, which is medium.
TextStyle homeFinePrint(ThemeData theme) =>
    theme.textTheme.muted.copyWith(fontSize: 12, height: 16 / 12);

/// The designs' `--coral`: the unseen-story ring and the "love" reaction.
/// It has no theme token.
Color coralOf(ThemeData theme) => theme.brightness == Brightness.dark
    ? const Color(0xFFD24B38)
    : const Color(0xFFC8432F);

/// A line of text that acts as a link: it underlines on hover and takes a
/// focus ring, but has no box of its own.
class HomeTextLink extends StatelessWidget {
  const HomeTextLink(
    this.text, {
    required this.style,
    required this.onPressed,
    this.maxLines = 1,
    super.key,
  });

  final String text;
  final TextStyle style;
  final VoidCallback onPressed;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Pressable(
      onPressed: onPressed,
      builder: (context, states) => FocusRing(
        visible: states.contains(WidgetState.focused),
        borderRadius: theme.radii.sm,
        child: Text(
          text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(
            decoration: states.contains(WidgetState.hovered)
                ? TextDecoration.underline
                : null,
            decorationColor: style.color,
          ),
        ),
      ),
    );
  }
}

/// A side-rail card with a heading row: "Your groups", "Add to your
/// network", "Trending in design".
///
/// The heading is the card's own `title`, in the card's title style. The
/// link, button or icon that ends the row rides in the same slot rather
/// than in `Card.action`, which pins its widget to the top of the header:
/// the designs centre it on the heading, whichever of the two is taller.
class HomeSectionCard extends StatelessWidget {
  const HomeSectionCard({
    required this.title,
    required this.child,
    this.trailing,
    super.key,
  });

  final String title;

  /// The link, button or icon at the end of the heading row.
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(homeRailInset),
      sectionGap: homeLooseGap,
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      action: trailing,
      child: child,
    );
  }
}
