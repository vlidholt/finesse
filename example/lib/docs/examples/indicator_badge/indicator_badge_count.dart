import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Counts on icons. Above `maxCount` the badge reads `99+`; with no count at
/// all it is a dot.
class IndicatorBadgeCountExample extends StatelessWidget {
  const IndicatorBadgeCountExample({super.key});

  @override
  Widget build(BuildContext context) {
    // The ring is what separates the badge from the icon under it. It
    // defaults to the card colour; these icons sit on the page instead.
    final ring = Theme.of(context).colorScheme.background;

    return IconTheme.merge(
      data: const IconThemeData(size: 28),
      child: Wrap(
        spacing: 36,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        children: [
          IndicatorBadge(
            count: 3,
            ringColor: ring,
            semanticLabel: '3 unread messages',
            child: const PhosphorIcon(PhosphorIconsRegular.chatCircleDots),
          ),
          IndicatorBadge(
            count: 128,
            ringColor: ring,
            child: const PhosphorIcon(PhosphorIconsRegular.bell),
          ),
          IndicatorBadge(
            count: 12,
            maxCount: 9,
            ringColor: ring,
            child: const PhosphorIcon(PhosphorIconsRegular.envelopeSimple),
          ),
          IndicatorBadge(
            ringColor: ring,
            child: const PhosphorIcon(PhosphorIconsRegular.usersThree),
          ),
          // A count of zero hides the badge unless `showZero` is set.
          IndicatorBadge(
            count: 0,
            ringColor: ring,
            child: const PhosphorIcon(PhosphorIconsRegular.briefcase),
          ),
        ],
      ),
    );
  }
}
