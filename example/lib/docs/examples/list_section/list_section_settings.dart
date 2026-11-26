import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A settings page: sections of rows on a card, each with a heading and a
/// line of explanation, hairlines starting at the rows' text.
class ListSectionSettingsExample extends StatefulWidget {
  const ListSectionSettingsExample({super.key});

  @override
  State<ListSectionSettingsExample> createState() =>
      _ListSectionSettingsExampleState();
}

enum _Audience {
  everyone('Everyone'),
  connections('Your connections'),
  nobody('No one');

  const _Audience(this.label);

  final String label;
}

class _ListSectionSettingsExampleState
    extends State<ListSectionSettingsExample> {
  bool push = true;
  bool digest = false;
  _Audience audience = _Audience.connections;

  @override
  Widget build(BuildContext context) {
    // A style may set its overlines in capitals; the header is the caller's
    // text, so the caller applies the case.
    final overline = Theme.of(context).style.overline;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: UnaColumn(
        gap: GapSize.lg,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListSection(
            header: Text(overline.applyCase('Notifications')),
            footer: const Text('Mentions and replies are always delivered.'),
            children: [
              SwitchListTile(
                secondary: const PhosphorIcon(PhosphorIconsRegular.bell),
                title: const Text('Push notifications'),
                value: push,
                onChanged: (value) => setState(() => push = value),
              ),
              SwitchListTile(
                secondary: const PhosphorIcon(
                  PhosphorIconsRegular.envelopeSimple,
                ),
                title: const Text('Weekly digest'),
                subtitle: const Text('Every Monday morning'),
                value: digest,
                onChanged: (value) => setState(() => digest = value),
              ),
              ListTile(
                leading: const PhosphorIcon(PhosphorIconsRegular.speakerHigh),
                title: const Text('Sound'),
                value: const Text('Chime'),
                showChevron: true,
                onTap: () {},
              ),
            ],
          ),
          UnaRadioGroup<_Audience>(
            value: audience,
            onChanged: (value) => setState(() => audience = value),
            child: ListSection(
              header: Text(overline.applyCase('Who can message you')),
              children: [
                for (final option in _Audience.values)
                  RadioListTile<_Audience>(
                    title: Text(option.label),
                    value: option,
                  ),
              ],
            ),
          ),
          ListSection(
            children: [
              ListTile(
                leading: const PhosphorIcon(PhosphorIconsRegular.signOut),
                title: const Text('Sign out'),
                destructive: true,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
