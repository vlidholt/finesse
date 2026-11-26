import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class CommandInlineExample extends StatelessWidget {
  const CommandInlineExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 450),
      child: Command(
        autofocus: false,
        decoration: const UnaDecoration(shadows: Shadows.md),
        placeholder: const Text('Type a command or search…'),
        groups: [
          CommandGroup(
            heading: 'Suggestions',
            items: [
              CommandItem(
                label: 'Calendar',
                value: 'calendar',
                leading: const PhosphorIcon(PhosphorIconsRegular.calendarBlank),
                onSelected: () {},
              ),
              CommandItem(
                label: 'Search Emoji',
                value: 'emoji',
                keywords: const ['smiley', 'face'],
                leading: const PhosphorIcon(PhosphorIconsRegular.smiley),
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
                leading: const PhosphorIcon(PhosphorIconsRegular.user),
                trailing: const Kbd.group(['⌘', 'P']),
                onSelected: () {},
              ),
              CommandItem(
                label: 'Billing',
                value: 'billing',
                leading: const PhosphorIcon(PhosphorIconsRegular.creditCard),
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
