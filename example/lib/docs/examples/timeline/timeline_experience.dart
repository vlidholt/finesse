import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Work experience. The marker in the gutter is any widget, here a company
/// logo; the line runs from under each marker to the next.
class TimelineExperienceExample extends StatelessWidget {
  const TimelineExperienceExample({super.key});

  static const _roles = [
    (
      'assets/images/logo_halcyon.png',
      'Senior product designer',
      'Halcyon',
      '2022 to present',
    ),
    (
      'assets/images/logo_birchline.png',
      'Product designer',
      'Birchline',
      '2019 to 2022',
    ),
    (
      'assets/images/logo_lumen_labs.png',
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
