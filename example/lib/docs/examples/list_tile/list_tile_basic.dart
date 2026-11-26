import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// People to follow: an avatar, a name, a quieter second line and a trailing
/// action. Long text truncates instead of pushing the button out.
class ListTileBasicExample extends StatelessWidget {
  const ListTileBasicExample({super.key});

  static const _people = [
    (
      'assets/images/avatar_omar_rahimi.jpg',
      'Omar Rahimi',
      'Design lead at Birchline',
    ),
    (
      'assets/images/avatar_mei_tanaka.jpg',
      'Mei Tanaka',
      'Staff researcher at Lumen Labs',
    ),
    (
      'assets/images/avatar_claire_dubois.jpg',
      'Claire Dubois',
      'Founder of the Accessibility Collective',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        style: CardTheme(padding: const EdgeInsets.all(8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (photo, name, role) in _people)
              ListTile(
                leading: Avatar(photo, fallback: Text(name[0])),
                title: Text(name),
                subtitle: Text(role),
                trailing: Button.outline(
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Follow'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
