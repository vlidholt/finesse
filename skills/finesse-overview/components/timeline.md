# Timeline

A vertical sequence of entries joined by a line: work experience, an activity log, the steps of an order.

## Default

Each `TimelineEntry` pairs a `marker` in the gutter with a `child` beside it. The line stops at the last entry.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Work experience. The marker in the gutter is any widget, here a company
/// logo; the line runs from under each marker to the next.
class TimelineExperienceExample extends StatelessWidget {
  const TimelineExperienceExample({super.key});

  static const _roles = [
    (
      'assets/strand/logo_halcyon.png',
      'Senior product designer',
      'Halcyon',
      '2022 to present',
    ),
    (
      'assets/strand/logo_birchline.png',
      'Product designer',
      'Birchline',
      '2019 to 2022',
    ),
    (
      'assets/strand/logo_lumen_labs.png',
      'Design intern',
      'Lumen Labs',
      '2018 to 2019',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Timeline(
        entries: [
          for (final (logo, role, company, years) in _roles)
            TimelineEntry(
              marker: ClipRRect(
                borderRadius: theme.radii.lg,
                child: Image.asset(logo, width: 42, height: 42),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role, style: theme.textTheme.large),
                  Text(company, style: theme.textTheme.small),
                  Text(years, style: theme.textTheme.muted),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
```

## Compact, with icon markers

`gap` is the space between a marker and its content, `spacing` the space between entries, and `lineColor` the colour of the line.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
```

