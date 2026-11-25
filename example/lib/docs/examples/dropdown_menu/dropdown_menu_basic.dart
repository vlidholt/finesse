import 'package:finesse/finesse.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DropdownMenuBasicExample extends StatelessWidget {
  const DropdownMenuBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    // ⌘ on Apple's platforms, Ctrl everywhere else. `MenuShortcut` writes
    // either the way the platform does; binding the keys is the app's job.
    final apple =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    SingleActivator keys(LogicalKeyboardKey key, {bool shift = false}) =>
        SingleActivator(key, meta: apple, control: !apple, shift: shift);

    return DropdownMenu(
      constraints: const BoxConstraints(minWidth: 224),
      items: [
        const MenuLabel(child: Text('My account')),
        ContextMenuItem(
          leading: const PhosphorIcon(PhosphorIconsRegular.user),
          shortcut: MenuShortcut(keys(LogicalKeyboardKey.keyP, shift: true)),
          child: const Text('Profile'),
        ),
        ContextMenuItem(
          leading: const PhosphorIcon(PhosphorIconsRegular.gear),
          shortcut: MenuShortcut(keys(LogicalKeyboardKey.comma)),
          child: const Text('Settings'),
        ),
        const ContextMenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.users),
          trailing: PhosphorIcon(PhosphorIconsRegular.caretRight),
          items: [
            ContextMenuItem(child: Text('Email')),
            ContextMenuItem(child: Text('Message')),
            MenuDivider(),
            ContextMenuItem(
              trailing: PhosphorIcon(PhosphorIconsRegular.caretRight),
              items: [
                ContextMenuItem(child: Text('Slack')),
                ContextMenuItem(child: Text('Discord')),
                ContextMenuItem(child: Text('Copy Invite Link')),
              ],
              child: Text('More...'),
            ),
          ],
          child: Text('Invite users'),
        ),
        const MenuDivider(),
        ContextMenuItem(
          leading: const PhosphorIcon(PhosphorIconsRegular.signOut),
          shortcut: MenuShortcut(keys(LogicalKeyboardKey.keyQ, shift: true)),
          destructive: true,
          child: const Text('Log out'),
        ),
      ],
      builder: (context, controller, _) => Button.outline(
        onPressed: controller.toggle,
        child: const Text('Open'),
      ),
    );
  }
}
