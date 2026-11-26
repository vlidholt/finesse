import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Every child is forced to `size` and clipped to a circle, so anything
/// works: initials, reaction icons, a "+5" for the rest. `overlap` sets how
/// far each one slides under the one before it.
class AvatarGroupMixedExample extends StatelessWidget {
  const AvatarGroupMixedExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget reaction(IconData icon, Color color) {
      return Container(
        width: 40,
        height: 40,
        color: color,
        alignment: Alignment.center,
        child: PhosphorIcon(icon, size: 24, color: const Color(0xFFFFFFFF)),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        AvatarGroup(
          size: 22,
          // On the page rather than on a card.
          ringColor: scheme.background,
          children: [
            reaction(PhosphorIconsFill.thumbsUp, scheme.tint),
            reaction(PhosphorIconsFill.heart, scheme.destructive),
            reaction(PhosphorIconsFill.lightbulb, scheme.warning),
          ],
        ),
        AvatarGroup(
          size: 40,
          overlap: 8,
          ringColor: scheme.background,
          children: [
            const Avatar('', fallback: Text('NH')),
            const Avatar('', fallback: Text('OR')),
            const Avatar('', fallback: Text('MT')),
            Container(
              width: 40,
              height: 40,
              color: scheme.muted,
              alignment: Alignment.center,
              child: Text('+5', style: theme.textTheme.small),
            ),
          ],
        ),
      ],
    );
  }
}
