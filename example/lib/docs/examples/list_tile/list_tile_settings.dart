import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Settings rows: an icon tile in front, a control or a chevron behind, and
/// a subtitle that is allowed to wrap to two lines.
class ListTileSettingsExample extends StatefulWidget {
  const ListTileSettingsExample({super.key});

  @override
  State<ListTileSettingsExample> createState() =>
      _ListTileSettingsExampleState();
}

class _ListTileSettingsExampleState extends State<ListTileSettingsExample> {
  bool digest = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const IconTile(
                icon: Icon(PhosphorIconsRegular.envelopeSimple),
              ),
              title: const Text('Weekly digest'),
              subtitle: const Text(
                'A summary of what your network posted, every Monday '
                'morning.',
              ),
              subtitleMaxLines: 2,
              trailing: Switch(
                value: digest,
                onChanged: (value) => setState(() => digest = value),
              ),
            ),
            ListTile(
              leading: const IconTile(
                icon: Icon(PhosphorIconsRegular.lockSimple),
              ),
              title: const Text('Privacy'),
              subtitle: const Text('Who can see your profile and activity'),
              trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const IconTile(
                icon: Icon(PhosphorIconsRegular.translate),
              ),
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
