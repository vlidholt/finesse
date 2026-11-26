import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Without a child the badge is laid out on its own: an unread count at the
/// end of a row, or a short label in place of a number.
class IndicatorBadgeStandaloneExample extends StatelessWidget {
  const IndicatorBadgeStandaloneExample({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Card(
        style: CardTheme(padding: const EdgeInsets.all(8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const PhosphorIcon(PhosphorIconsRegular.tray),
              title: const Text('Inbox'),
              trailing: const IndicatorBadge(count: 24),
              onTap: () {},
            ),
            ListTile(
              leading: const PhosphorIcon(PhosphorIconsRegular.userPlus),
              title: const Text('Invitations'),
              trailing: IndicatorBadge(
                count: 2,
                color: scheme.tint,
                foregroundColor: scheme.tintForeground,
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const PhosphorIcon(PhosphorIconsRegular.calendarBlank),
              title: const Text('Events'),
              trailing: IndicatorBadge(
                label: const Text('New'),
                color: scheme.success,
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
