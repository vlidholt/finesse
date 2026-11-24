# Command

A composable command menu with filtering and full keyboard navigation.

## Inline

Arrow keys move the highlight, Enter selects. Keywords let items match terms their label does not contain.

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class CommandInlineExample extends StatelessWidget {
  const CommandInlineExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 450),
      child: Command(
        autofocus: false,
        decoration: const FinesseDecoration(shadows: Shadows.md),
        placeholder: const Text('Type a command or search…'),
        groups: [
          CommandGroup(
            heading: 'Suggestions',
            items: [
              CommandItem(
                label: 'Calendar',
                value: 'calendar',
                leading: const Icon(PhosphorIconsRegular.calendarBlank),
                onSelected: () {},
              ),
              CommandItem(
                label: 'Search Emoji',
                value: 'emoji',
                keywords: const ['smiley', 'face'],
                leading: const Icon(PhosphorIconsRegular.smiley),
                onSelected: () {},
              ),
            ],
          ),
          CommandGroup(
            heading: 'Settings',
            items: [
              CommandItem(
                label: 'Profile',
                value: 'profile',
                leading: const Icon(PhosphorIconsRegular.user),
                trailing: const Kbd.group(['⌘', 'P']),
                onSelected: () {},
              ),
              CommandItem(
                label: 'Billing',
                value: 'billing',
                leading: const Icon(PhosphorIconsRegular.creditCard),
                trailing: const Kbd.group(['⌘', 'B']),
                onSelected: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

## Dialog

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

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
                  leading: const Icon(PhosphorIconsRegular.calendarBlank),
                  onSelected: () {},
                ),
                CommandItem(
                  label: 'Sign out',
                  value: 'signout',
                  keywords: const ['logout', 'exit'],
                  leading: const Icon(PhosphorIconsRegular.signOut),
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
```

