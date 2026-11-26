import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Settings folded under their headings in one section. Each heading shows
/// a summary of what is under it, and the rows keep their state while they
/// are folded away.
class ExpansionTileSettingsExample extends StatefulWidget {
  const ExpansionTileSettingsExample({super.key});

  @override
  State<ExpansionTileSettingsExample> createState() =>
      _ExpansionTileSettingsExampleState();
}

class _ExpansionTileSettingsExampleState
    extends State<ExpansionTileSettingsExample> {
  final _alerts = {'Mentions': true, 'Replies': true, 'New followers': false};
  bool _digest = false;

  @override
  Widget build(BuildContext context) {
    final on = _alerts.values.where((value) => value).length;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: ListSection(
        header: const Text('Account'),
        children: [
          const ListTile(
            leading: PhosphorIcon(PhosphorIconsRegular.user),
            title: Text('Profile'),
            showChevron: true,
          ),
          ExpansionTile(
            leading: const PhosphorIcon(PhosphorIconsRegular.bell),
            title: const Text('Notifications'),
            value: Text('$on on'),
            initiallyOpen: true,
            children: [
              for (final MapEntry(key: name, value: enabled) in _alerts.entries)
                SwitchListTile(
                  title: Text(name),
                  value: enabled,
                  onChanged: (value) => setState(() => _alerts[name] = value),
                ),
            ],
          ),
          ExpansionTile(
            leading: const PhosphorIcon(PhosphorIconsRegular.envelope),
            title: const Text('Email'),
            value: Text(_digest ? 'Weekly' : 'Off'),
            children: [
              CheckboxListTile(
                title: const Text('Weekly digest'),
                subtitle: const Text('Every Monday morning'),
                value: _digest,
                onChanged: (value) => setState(() => _digest = value ?? false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
