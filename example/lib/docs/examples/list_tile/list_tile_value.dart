import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// What a row can say beyond its title: its current value, a chevron for a
/// row that leads somewhere, a destructive action, and a row switched off.
class ListTileValueExample extends StatelessWidget {
  const ListTileValueExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        style: CardTheme(padding: const EdgeInsets.all(8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const PhosphorIcon(PhosphorIconsRegular.translate),
              title: const Text('Language'),
              value: const Text('English'),
              showChevron: true,
              onTap: () {},
            ),
            ListTile(
              leading: const PhosphorIcon(PhosphorIconsRegular.cloud),
              title: const Text('Storage'),
              value: const Text('12.4 GB of 50 GB'),
              showChevron: true,
              onTap: () {},
              onLongPress: () {},
            ),
            ListTile(
              leading: const PhosphorIcon(PhosphorIconsRegular.usersThree),
              title: const Text('Team workspace'),
              value: const Text('Upgrade to unlock'),
              showChevron: true,
              enabled: false,
              onTap: () {},
            ),
            ListTile(
              leading: const PhosphorIcon(PhosphorIconsRegular.trash),
              title: const Text('Delete account'),
              destructive: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
