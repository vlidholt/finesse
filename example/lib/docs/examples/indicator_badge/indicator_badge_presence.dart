import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Presence dots on avatars. `alignment` picks the corner; an `overhang` of
/// zero keeps the dot inside the avatar's bounds, on the edge of the circle.
class IndicatorBadgePresenceExample extends StatelessWidget {
  const IndicatorBadgePresenceExample({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget person(String photo, String initial, {required Color color}) {
      return IndicatorBadge(
        alignment: AlignmentDirectional.bottomEnd,
        overhang: 0,
        size: 12,
        color: color,
        ringColor: scheme.background,
        child: Avatar(
          photo,
          size: const Size.square(48),
          fallback: Text(initial),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        person(
          'assets/images/avatar_mei_tanaka.jpg',
          'M',
          color: scheme.success,
        ),
        person(
          'assets/images/avatar_julian_reyes.jpg',
          'J',
          color: scheme.warning,
        ),
        person(
          'assets/images/avatar_freya_holm.jpg',
          'F',
          color: scheme.mutedForeground,
        ),
      ],
    );
  }
}
