# Menubar

A visually persistent menu, common in desktop applications.

## Default

Each menu takes the rows of any other menu: shortcuts, checkbox rows under View, a radio group under Profiles.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class MenubarBasicExample extends StatefulWidget {
  const MenubarBasicExample({super.key});

  @override
  State<MenubarBasicExample> createState() => _MenubarBasicExampleState();
}

class _MenubarBasicExampleState extends State<MenubarBasicExample> {
  bool bookmarksBar = false;
  bool fullUrls = true;
  String profile = 'benoit';

  @override
  Widget build(BuildContext context) {
    // ⌘ on Apple's platforms, Ctrl everywhere else.
    final apple =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    MenuShortcut keys(LogicalKeyboardKey key, {bool shift = false}) =>
        MenuShortcut(
          SingleActivator(key, meta: apple, control: !apple, shift: shift),
        );
    const more = PhosphorIcon(PhosphorIconsRegular.caretRight);

    return Menubar(
      items: [
        MenubarItem(
          items: [
            ContextMenuItem(
              shortcut: keys(LogicalKeyboardKey.keyT),
              child: const Text('New Tab'),
            ),
            ContextMenuItem(
              shortcut: keys(LogicalKeyboardKey.keyN),
              child: const Text('New Window'),
            ),
            const ContextMenuItem(
              enabled: false,
              child: Text('New Incognito Window'),
            ),
            const MenuDivider(),
            const ContextMenuItem(
              trailing: more,
              items: [
                ContextMenuItem(child: Text('Email Link')),
                ContextMenuItem(child: Text('Messages')),
                ContextMenuItem(child: Text('Notes')),
              ],
              child: Text('Share'),
            ),
            const MenuDivider(),
            ContextMenuItem(
              shortcut: keys(LogicalKeyboardKey.keyP),
              child: const Text('Print...'),
            ),
          ],
          child: const Text('File'),
        ),
        MenubarItem(
          items: [
            ContextMenuItem(
              shortcut: keys(LogicalKeyboardKey.keyZ),
              child: const Text('Undo'),
            ),
            ContextMenuItem(
              shortcut: keys(LogicalKeyboardKey.keyZ, shift: true),
              child: const Text('Redo'),
            ),
            const MenuDivider(),
            const ContextMenuItem(
              trailing: more,
              items: [
                ContextMenuItem(child: Text('Search the Web')),
                MenuDivider(),
                ContextMenuItem(child: Text('Find...')),
                ContextMenuItem(child: Text('Find Next')),
                ContextMenuItem(child: Text('Find Previous')),
              ],
              child: Text('Find'),
            ),
            const MenuDivider(),
            const ContextMenuItem(child: Text('Cut')),
            const ContextMenuItem(child: Text('Copy')),
            const ContextMenuItem(child: Text('Paste')),
          ],
          child: const Text('Edit'),
        ),
        MenubarItem(
          items: [
            MenuCheckboxItem(
              checked: bookmarksBar,
              onChanged: (value) => setState(() => bookmarksBar = value),
              child: const Text('Always Show Bookmarks Bar'),
            ),
            MenuCheckboxItem(
              checked: fullUrls,
              onChanged: (value) => setState(() => fullUrls = value),
              child: const Text('Always Show Full URLs'),
            ),
            const MenuDivider(),
            // Lined up with the rows above without `ContextMenuItem.inset`.
            ContextMenuItem(
              shortcut: keys(LogicalKeyboardKey.keyR),
              child: const Text('Reload'),
            ),
            const ContextMenuItem(child: Text('Toggle Full Screen')),
          ],
          child: const Text('View'),
        ),
        MenubarItem(
          items: [
            MenuRadioGroup<String>(
              value: profile,
              onChanged: (value) => setState(() => profile = value),
              children: const [
                MenuRadioItem(value: 'andy', child: Text('Andy')),
                MenuRadioItem(value: 'benoit', child: Text('Benoit')),
                MenuRadioItem(value: 'luis', child: Text('Luis')),
              ],
            ),
            const MenuDivider(),
            const ContextMenuItem(child: Text('Edit...')),
            const ContextMenuItem(child: Text('Add Profile...')),
          ],
          child: const Text('Profiles'),
        ),
      ],
    );
  }
}
```

