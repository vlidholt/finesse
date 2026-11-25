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
            MenuItem(
              shortcut: keys(LogicalKeyboardKey.keyT),
              child: const Text('New Tab'),
            ),
            MenuItem(
              shortcut: keys(LogicalKeyboardKey.keyN),
              child: const Text('New Window'),
            ),
            const MenuItem(
              enabled: false,
              child: Text('New Incognito Window'),
            ),
            const MenuDivider(),
            const MenuItem(
              trailing: more,
              items: [
                MenuItem(child: Text('Email Link')),
                MenuItem(child: Text('Messages')),
                MenuItem(child: Text('Notes')),
              ],
              child: Text('Share'),
            ),
            const MenuDivider(),
            MenuItem(
              shortcut: keys(LogicalKeyboardKey.keyP),
              child: const Text('Print...'),
            ),
          ],
          child: const Text('File'),
        ),
        MenubarItem(
          items: [
            MenuItem(
              shortcut: keys(LogicalKeyboardKey.keyZ),
              child: const Text('Undo'),
            ),
            MenuItem(
              shortcut: keys(LogicalKeyboardKey.keyZ, shift: true),
              child: const Text('Redo'),
            ),
            const MenuDivider(),
            const MenuItem(
              trailing: more,
              items: [
                MenuItem(child: Text('Search the Web')),
                MenuDivider(),
                MenuItem(child: Text('Find...')),
                MenuItem(child: Text('Find Next')),
                MenuItem(child: Text('Find Previous')),
              ],
              child: Text('Find'),
            ),
            const MenuDivider(),
            const MenuItem(child: Text('Cut')),
            const MenuItem(child: Text('Copy')),
            const MenuItem(child: Text('Paste')),
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
            // Lined up with the rows above without `MenuItem.inset`.
            MenuItem(
              shortcut: keys(LogicalKeyboardKey.keyR),
              child: const Text('Reload'),
            ),
            const MenuItem(child: Text('Toggle Full Screen')),
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
            const MenuItem(child: Text('Edit...')),
            const MenuItem(child: Text('Add Profile...')),
          ],
          child: const Text('Profiles'),
        ),
      ],
    );
  }
}
