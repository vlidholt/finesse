import 'package:example/strand/data/network_data.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/network_controller.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/strand_pieces.dart';
import 'package:example/strand/widgets/strand_previews.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// "People you may know": a heading and a grid of person cards.
///
/// The number of columns comes from the width the grid is given, so it is
/// four across beside both rails, three beside one, and two on a phone.
class NetworkSuggestions extends StatefulWidget {
  const NetworkSuggestions({required this.controller, super.key});

  final NetworkController controller;

  @override
  State<NetworkSuggestions> createState() => _NetworkSuggestionsState();
}

class _NetworkSuggestionsState extends State<NetworkSuggestions> {
  /// Whether "Show more people" has been pressed.
  bool _expanded = false;

  NetworkController get controller => widget.controller;

  /// The least a card is wide: its portrait, a name and a "Connect" pill.
  static const _minCardWidth = 168.0;
  static const _maxColumns = 4;

  /// How many rows are shown before "Show more people".
  static const _collapsedRows = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = controller.suggestions;
    final gap = theme.layoutTheme.gap(GapSize.md);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StrandSectionHeading(
          'People you may know',
          trailing: Text('Based on your profile', style: theme.textTheme.muted),
        ),
        const Gap.md(),
        if (suggestions.isEmpty)
          const Card(
            child: Empty(
              icon: Icon(PhosphorIconsRegular.usersThree),
              title: Text('No more suggestions'),
              description: Text(
                'You have been through everyone we had in mind. More will '
                'turn up as your network grows.',
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  ((constraints.maxWidth + gap) / (_minCardWidth + gap))
                      .floor()
                      .clamp(1, _maxColumns);
              // Whole rows only until the rest is asked for, so the grid
              // never ends on a ragged row by default.
              final collapsed = columns * _collapsedRows;
              final shown = _expanded || suggestions.length <= collapsed
                  ? suggestions.length
                  : collapsed;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: gap,
                children: [
                  for (var i = 0; i < shown; i += columns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: gap,
                      children: [
                        for (var j = i; j < i + columns; j++)
                          Expanded(
                            child: j < shown
                                ? _PersonCard(
                                    suggestions[j],
                                    key: ValueKey(suggestions[j].person.name),
                                    controller: controller,
                                  )
                                : const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  if (shown < suggestions.length)
                    Button.secondary(
                      gap: homeTightGap,
                      textStyle: theme.textTheme.small,
                      trailing: const Icon(
                        PhosphorIconsRegular.caretDown,
                        size: 14,
                      ),
                      onPressed: () => setState(() => _expanded = true),
                      child: Text(
                        switch (suggestions.length - shown) {
                          1 => 'Show 1 more person',
                          final more => 'Show $more more people',
                        },
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

/// One suggestion: portrait, name, headline, why they are suggested, the
/// people in common and "Connect".
class _PersonCard extends StatelessWidget {
  const _PersonCard(this.suggestion, {required this.controller, super.key});

  final NetworkSuggestion suggestion;
  final NetworkController controller;

  static const _avatarSize = 64.0;

  /// The dismiss button, smaller than the theme's smallest so that it sits
  /// in the card's corner without crowding the portrait.
  static const _dismissSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final person = suggestion.person;
    final pending = controller.isRequested(person);
    void open() => showPersonPreview(context, person);

    return Card(
      radius: theme.radii.xl,
      // 16 on a desktop and a phone alike, as the job cards are.
      padding: const EdgeInsets.all(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Pressable(
                  onPressed: open,
                  semanticLabel: 'Preview ${person.name}',
                  builder: (context, states) => FocusRing(
                    visible: states.contains(WidgetState.focused),
                    borderRadius: theme.radii.full,
                    child: PersonAvatar(
                      person,
                      size: _avatarSize,
                      showOnline: person.online,
                    ),
                  ),
                ),
              ),
              const Gap.raw(homeSnugGap),
              Center(child: PersonName(person, onPressed: open)),
              const Gap.raw(homeHairGap),
              Text(
                // The trailing line break keeps a one-line headline two
                // lines tall, so every card in a row is the same height.
                '${person.headline}\n',
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.muted,
              ),
              const Gap.raw(homeSnugGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    suggestion.reasonIcon,
                    size: 14,
                    color: scheme.mutedForeground,
                  ),
                  const Gap.xs(),
                  Flexible(
                    child: Text(
                      suggestion.reason,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: homeFinePrint(theme),
                    ),
                  ),
                ],
              ),
              const Gap.raw(homeTightGap),
              MutualsLine(
                people: suggestion.mutuals,
                label: '${suggestion.mutualCount} mutual',
                alignment: MainAxisAlignment.center,
              ),
              const Gap.md(),
              StrandPillButton.connect(
                pending: pending,
                expand: true,
                onPressed: () => controller.toggleRequest(person),
              ),
            ],
          ),
          PositionedDirectional(
            // Hung 6 into the card's padding, like a job card's bookmark.
            top: -6,
            end: -6,
            child: IconButton.ghost(
              width: _dismissSize,
              height: _dismissSize,
              iconSize: 16,
              icon: const Icon(PhosphorIconsRegular.x),
              foregroundColor: scheme.mutedForeground,
              semanticLabel: 'Dismiss ${person.name}',
              onPressed: () => controller.dismiss(suggestion),
            ),
          ),
        ],
      ),
    );
  }
}
