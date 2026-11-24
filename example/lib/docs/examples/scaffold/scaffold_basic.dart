import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A phone-sized screen. Both bars are laid *over* the list, which insets
/// itself by their heights and scrolls beneath them.
class ScaffoldBasicExample extends StatefulWidget {
  const ScaffoldBasicExample({super.key});

  @override
  State<ScaffoldBasicExample> createState() => _ScaffoldBasicExampleState();
}

class _ScaffoldBasicExampleState extends State<ScaffoldBasicExample> {
  static const _people = [
    ('Omar Rahimi', 'Sent you the workshop notes'),
    ('Mei Tanaka', 'Are we still on for Thursday?'),
    ('Claire Dubois', 'Loved the talk!'),
    ('Julian Reyes', 'Here is the recording'),
    ('Freya Holm', 'Thanks for the intro'),
    ('Rafael Cruz', 'Shared a file with you'),
    ('Elena Petrova', 'Can you review my portfolio?'),
    ('Sara Lindqvist', 'See you at the meetup'),
  ];

  int index = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The frame stands in for a phone: the theme is laid out for one, and the
    // real window's safe area is kept out of it.
    return Theme(
      data: theme.withFormFactor(FormFactor.mobile),
      child: Container(
        width: 340,
        height: 520,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: theme.radii.xl2,
        ),
        // Painted over the content, so nothing covers the frame's corners.
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: theme.radii.xl2,
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Messages'),
              actions: [
                IconButton.ghost(
                  icon: const Icon(PhosphorIconsRegular.notePencil),
                  semanticLabel: 'New message',
                  onPressed: () {},
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => setState(() => index = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(PhosphorIconsRegular.house),
                  selectedIcon: Icon(PhosphorIconsFill.house),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(PhosphorIconsRegular.chatCircleDots),
                  selectedIcon: Icon(PhosphorIconsFill.chatCircleDots),
                  label: 'Messages',
                ),
                NavigationDestination(
                  icon: Icon(PhosphorIconsRegular.user),
                  selectedIcon: Icon(PhosphorIconsFill.user),
                  label: 'Profile',
                ),
              ],
            ),
            // A ListView pads itself with the MediaQuery padding, which the
            // scaffold has grown by the height of each bar.
            body: ListView(
              children: [
                for (final (name, message) in _people)
                  ListTile(
                    leading: Avatar('', fallback: Text(name[0])),
                    title: Text(name),
                    subtitle: Text(message),
                    onTap: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
