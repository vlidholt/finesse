import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The plain variant: no card, rows from edge to edge with hairlines that
/// start at the names, whatever the rows lead with.
class ListSectionPlainExample extends StatelessWidget {
  const ListSectionPlainExample({super.key});

  static const _people = [
    ('assets/images/avatar_omar_rahimi.jpg', 'Omar Rahimi', 'Birchline'),
    ('assets/images/avatar_mei_tanaka.jpg', 'Mei Tanaka', 'Lumen Labs'),
    ('assets/images/avatar_claire_dubois.jpg', 'Claire Dubois', 'Collective'),
  ];

  @override
  Widget build(BuildContext context) {
    final overline = Theme.of(context).style.overline;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: ListSection(
        variant: ListSectionVariant.plain,
        header: Text(overline.applyCase('Suggested')),
        children: [
          for (final (photo, name, company) in _people)
            ListTile(
              leading: Avatar(photo, fallback: Text(name[0])),
              title: Text(name),
              subtitle: Text(company),
              showChevron: true,
              onTap: () {},
            ),
        ],
      ),
    );
  }
}
