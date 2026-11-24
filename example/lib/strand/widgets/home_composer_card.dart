import 'package:example/strand/data.dart';
import 'package:example/strand/data/home_data.dart';
import 'package:example/strand/widgets/compose_dialog.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The desktop feed's "Start a post" card: the signed-in user's portrait, a
/// pill that opens the composer, and four attachment shortcuts.
class HomeComposerCard extends StatelessWidget {
  const HomeComposerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    void compose() => showComposeDialog(context);

    return Card(
      padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.lg)),
      child: FinesseColumn(
        gap: GapSize.md,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          FinesseRow(
            gap: GapSize.md,
            children: [
              const PersonAvatar(People.me, size: homeAvatarSize),
              Expanded(
                // A button dressed as a field: tapping it opens the
                // composer rather than taking text here.
                child: Button.outline(
                  height: 46,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: theme.buttonDecoration(
                    radius: theme.radii.full,
                  ),
                  backgroundColor: scheme.muted,
                  hoverBackgroundColor: scheme.secondary,
                  foregroundColor: scheme.mutedForeground,
                  hoverForegroundColor: scheme.mutedForeground,
                  mainAxisAlignment: MainAxisAlignment.start,
                  cursor: SystemMouseCursors.text,
                  pressedOffset: Offset.zero,
                  // The size of the theme's `large`, at the weight of
                  // running text: a placeholder, not a label.
                  textStyle: theme.textTheme.large.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                  onPressed: compose,
                  child: Flexible(
                    child: Text(
                      'Start a post, ${People.me.firstName}…',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final action in HomeData.composerActions)
                Flexible(
                  child: Button.ghost(
                    // Two points taller than the theme's button, with a
                    // larger glyph: these read as tools, not as actions.
                    height: 38,
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.layoutTheme.gap(GapSize.md),
                    ),
                    iconSize: 22,
                    foregroundColor: scheme.foregroundSubtle,
                    leading: Icon(action.icon),
                    onPressed: compose,
                    child: Flexible(
                      child: Text(
                        action.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
