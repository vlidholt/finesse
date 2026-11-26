import 'package:example/docs/phone_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A search field in `bottom`. It stays under the toolbar when the large
/// title has gone, inside the bar's surface.
class SliverAppBarBottomExample extends StatefulWidget {
  const SliverAppBarBottomExample({super.key});

  @override
  State<SliverAppBarBottomExample> createState() =>
      _SliverAppBarBottomExampleState();
}

class _SliverAppBarBottomExampleState extends State<SliverAppBarBottomExample> {
  static const _people = [
    'Aisha Rahman',
    'Claire Dubois',
    'Elena Petrova',
    'Freya Holm',
    'Irina Volkova',
    'Julian Reyes',
    'Mateo Alvarez',
    'Mei Tanaka',
    'Noor Haddad',
    'Omar Rahimi',
    'Rafael Cruz',
    'Sara Lindqvist',
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final margin = theme.layoutTheme.gap(GapSize.lg);
    final matches = [
      for (final person in _people)
        if (person.toLowerCase().contains(_query.toLowerCase())) person,
    ];
    return PhoneFrame(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Contacts'),
              bottom: Padding(
                padding: EdgeInsets.fromLTRB(
                  margin,
                  0,
                  margin,
                  theme.layoutTheme.gap(GapSize.md),
                ),
                // Cancel slides in beside the field while it has the
                // focus, as in a search bar on iOS.
                child: SearchField(
                  showCancel: true,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            ),
            SliverList.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) => ListTile(
                leading: Avatar('', fallback: Text(matches[index][0])),
                title: Text(matches[index]),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
