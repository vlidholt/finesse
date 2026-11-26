import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class CommandDialogExample extends StatelessWidget {
  const CommandDialogExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      trailing: const Kbd.group(['⌘', 'K']),
      child: const Text('Open command palette'),
      onPressed: () {
        showCommandDialog<String>(
          context: context,
          placeholder: const Text('Type a command or search…'),
          groups: [
            CommandGroup(
              heading: 'Suggestions',
              items: [
                CommandItem(
                  label: 'Calendar',
                  value: 'calendar',
                  leading: const PhosphorIcon(
                    PhosphorIconsRegular.calendarBlank,
                  ),
                  onSelected: () {},
                ),
                CommandItem(
                  label: 'Sign out',
                  value: 'signout',
                  keywords: const ['logout', 'exit'],
                  leading: const PhosphorIcon(PhosphorIconsRegular.signOut),
                  onSelected: () {},
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
