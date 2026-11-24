# Dropdown Menu

A menu that opens from a trigger. It flips to stay on screen, scrolls when long, and supports keyboard navigation and type-ahead.

## Default

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class DropdownMenuBasicExample extends StatelessWidget {
  const DropdownMenuBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      constraints: const BoxConstraints(minWidth: 224),
      items: const [
        ContextMenuItem(
          leading: Icon(PhosphorIconsRegular.user),
          trailing: Text('⇧⌘P'),
          child: Text('Profile'),
        ),
        ContextMenuItem(
          leading: Icon(PhosphorIconsRegular.gear),
          trailing: Text('⌘S'),
          child: Text('Settings'),
        ),
        ContextMenuItem(
          leading: Icon(PhosphorIconsRegular.users),
          trailing: Icon(PhosphorIconsRegular.caretRight),
          items: [
            ContextMenuItem(child: Text('Email')),
            ContextMenuItem(child: Text('Message')),
            Divider.horizontal(
              margin: EdgeInsets.symmetric(vertical: 4),
            ),
            ContextMenuItem(
              trailing: Icon(PhosphorIconsRegular.caretRight),
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
        Divider.horizontal(margin: EdgeInsets.symmetric(vertical: 4)),
        ContextMenuItem(
          leading: Icon(PhosphorIconsRegular.signOut),
          destructive: true,
          child: Text('Log out'),
        ),
      ],
      builder: (context, controller, _) => Button.outline(
        onPressed: controller.toggle,
        child: const Text('Open'),
      ),
    );
  }
}
```

