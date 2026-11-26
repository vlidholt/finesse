import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The steps of an application, with small icon tiles as markers. `gap`,
/// `spacing` and `lineColor` tune the gutter; the step still to come is
/// drawn muted.
class TimelineActivityExample extends StatelessWidget {
  const TimelineActivityExample({super.key});

  static const _steps = [
    (PhosphorIconsRegular.paperPlaneTilt, 'Application sent', 'Mon 09:12'),
    (PhosphorIconsRegular.eye, 'Viewed by the hiring team', 'Tue 14:30'),
    (PhosphorIconsRegular.chatCircleDots, 'Interview scheduled', 'Thu 10:00'),
    (PhosphorIconsRegular.handshake, 'Offer', 'Pending'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Timeline(
        gap: 12,
        spacing: 16,
        lineColor: scheme.border,
        entries: [
          for (final (index, (icon, title, time)) in _steps.indexed)
            TimelineEntry(
              marker: IconTile(
                size: 28,
                iconSize: 16,
                borderRadius: theme.radii.full,
                backgroundColor: index == _steps.length - 1
                    ? scheme.muted
                    : null,
                foregroundColor: index == _steps.length - 1
                    ? scheme.mutedForeground
                    : null,
                icon: PhosphorIcon(icon),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.small),
                  Text(time, style: theme.textTheme.muted),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
