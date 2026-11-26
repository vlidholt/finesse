# Dropdown Menu

A menu that opens from a trigger. It flips to stay on screen, scrolls when long, and supports keyboard navigation and type-ahead.

## Default

A label, shortcuts written the way the platform writes them, a submenu and a destructive row.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
        MenuItem(
          leading: const PhosphorIcon(PhosphorIconsRegular.user),
          shortcut: MenuShortcut(keys(LogicalKeyboardKey.keyP, shift: true)),
          child: const Text('Profile'),
        ),
        MenuItem(
          leading: const PhosphorIcon(PhosphorIconsRegular.gear),
          shortcut: MenuShortcut(keys(LogicalKeyboardKey.comma)),
          child: const Text('Settings'),
        ),
        const MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.users),
          trailing: PhosphorIcon(PhosphorIconsRegular.caretRight),
          items: [
            MenuItem(child: Text('Email')),
            MenuItem(child: Text('Message')),
            MenuDivider(),
            MenuItem(
              trailing: PhosphorIcon(PhosphorIconsRegular.caretRight),
              items: [
                MenuItem(child: Text('Slack')),
                MenuItem(child: Text('Discord')),
                MenuItem(child: Text('Copy Invite Link')),
              ],
              child: Text('More...'),
            ),
          ],
          child: Text('Invite users'),
        ),
        const MenuDivider(),
        MenuItem(
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
```

## Checkbox and radio items

Checkable rows are controlled. A click toggles one and closes the menu like any row; Space toggles it and keeps the menu open, so several can be set in one visit. Every row of the menu keeps the column of the check marks free and the labels line up.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

enum _PanelSide { top, bottom, end }

class DropdownMenuCheckableExample extends StatefulWidget {
  const DropdownMenuCheckableExample({super.key});

  @override
  State<DropdownMenuCheckableExample> createState() =>
      _DropdownMenuCheckableExampleState();
}

class _DropdownMenuCheckableExampleState
    extends State<DropdownMenuCheckableExample> {
  bool statusBar = true;
  bool minimap = false;
  bool panel = true;
  _PanelSide side = _PanelSide.bottom;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      constraints: const BoxConstraints(minWidth: 224),
      // The rows are controlled: each reports a change, and the rebuild
      // shows it while the menu is still open.
      items: [
        const MenuLabel(child: Text('Appearance')),
        MenuCheckboxItem(
          checked: statusBar,
          onChanged: (value) => setState(() => statusBar = value),
          child: const Text('Status bar'),
        ),
        MenuCheckboxItem(
          checked: minimap,
          // No callback: the row is shown, and cannot be toggled.
          onChanged: null,
          child: const Text('Minimap'),
        ),
        MenuCheckboxItem(
          checked: panel,
          onChanged: (value) => setState(() => panel = value),
          child: const Text('Panel'),
        ),
        const MenuDivider(),
        const MenuLabel(child: Text('Panel position')),
        MenuRadioGroup<_PanelSide>(
          value: side,
          onChanged: (value) => setState(() => side = value),
          children: const [
            MenuRadioItem(value: _PanelSide.top, child: Text('Top')),
            MenuRadioItem(value: _PanelSide.bottom, child: Text('Bottom')),
            MenuRadioItem(value: _PanelSide.end, child: Text('Right')),
          ],
        ),
        const MenuDivider(),
        // A plain row keeps the column of the check marks free, so its
        // label lines up with the ones above.
        MenuItem(
          onPressed: () => setState(() {
            statusBar = true;
            panel = true;
            side = _PanelSide.bottom;
          }),
          child: const Text('Reset layout'),
        ),
      ],
      builder: (context, controller, _) => Button.outline(
        onPressed: controller.toggle,
        leading: const PhosphorIcon(PhosphorIconsRegular.layout),
        child: const Text('View'),
      ),
    );
  }
}
```
