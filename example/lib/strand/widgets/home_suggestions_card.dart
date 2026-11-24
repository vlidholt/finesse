import 'package:example/strand/data/home_data.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The right rail's "Add to your network" card.
class HomeSuggestionsCard extends StatefulWidget {
  const HomeSuggestionsCard({this.onDismissed, super.key});

  /// Called when the card's close button is pressed.
  final VoidCallback? onDismissed;

  @override
  State<HomeSuggestionsCard> createState() => _HomeSuggestionsCardState();
}

class _HomeSuggestionsCardState extends State<HomeSuggestionsCard> {
  /// The names of the people an invitation has been sent to.
  final _invited = <String>{};

  void _toggle(String name) {
    setState(() {
      if (!_invited.remove(name)) _invited.add(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HomeSectionCard(
      title: 'Add to your network',
      trailing: IconButton.ghost(
        // A 28-point close button: smaller than the theme's smallest, so
        // the heading row stays the height of the other rail cards'.
        width: 28,
        height: 28,
        iconSize: 16,
        icon: const Icon(PhosphorIconsRegular.x),
        semanticLabel: 'Dismiss',
        onPressed: widget.onDismissed,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          FinesseColumn(
            // 16 between people; this card is desktop-only, where the
            // theme's `lg` gap is that.
            gap: GapSize.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final suggestion in HomeData.suggestions)
                _SuggestionRow(
                  suggestion,
                  invited: _invited.contains(suggestion.person.name),
                  onPressed: () => _toggle(suggestion.person.name),
                ),
            ],
          ),
          const Gap.lg(),
          Button.secondary(
            width: double.infinity,
            gap: homeTightGap,
            textStyle: theme.textTheme.small,
            trailing: const Icon(PhosphorIconsRegular.caretRight, size: 14),
            onPressed: () {},
            child: const Flexible(
              child: Text(
                'Show all suggestions',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow(
    this.suggestion, {
    required this.invited,
    required this.onPressed,
  });

  final Suggestion suggestion;
  final bool invited;
  final VoidCallback onPressed;

  /// The diameter of a mutual connection's portrait.
  static const _mutualSize = 18.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final person = suggestion.person;
    return FinesseRow(
      gap: GapSize.md,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonAvatar(person, size: homeAvatarSize),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                person.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.p.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.foreground,
                ),
              ),
              Text(
                person.headline,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.muted,
              ),
              const Gap.raw(homeTightGap),
              // Scales down rather than overflowing if the column is ever
              // narrower than the stack of portraits.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: AvatarGroup(
                        size: _mutualSize,
                        overlap: 6,
                        children: [
                          for (final avatar in suggestion.mutuals)
                            Image.asset(
                              avatar,
                              width: _mutualSize,
                              height: _mutualSize,
                              fit: BoxFit.cover,
                            ),
                        ],
                      ),
                    ),
                    const Gap.raw(homeTightGap),
                    Text(
                      '${suggestion.mutualCount} mutual',
                      maxLines: 1,
                      softWrap: false,
                      style: homeFinePrint(theme),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Button.outline(
          size: ButtonSize.sm,
          decoration: theme.buttonDecoration(radius: theme.radii.full),
          textStyle: theme.textTheme.small,
          leading: Icon(
            invited
                ? PhosphorIconsRegular.clock
                : PhosphorIconsRegular.userPlus,
          ),
          onPressed: onPressed,
          child: Text(invited ? 'Pending' : 'Connect'),
        ),
      ],
    );
  }
}
