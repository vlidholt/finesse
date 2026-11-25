import 'package:finesse/finesse.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ContextMenuBasicExample extends StatefulWidget {
  const ContextMenuBasicExample({super.key});

  @override
  State<ContextMenuBasicExample> createState() =>
      _ContextMenuBasicExampleState();
}

class _ContextMenuBasicExampleState extends State<ContextMenuBasicExample> {
  bool bookmarks = true;
  bool fullUrls = false;
  String person = 'pedro';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apple =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    return ContextMenuRegion(
      constraints: const BoxConstraints(minWidth: 260),
      items: [
        // With a checkable row in the menu, every row keeps the column of
        // the check marks free: no `ContextMenuItem.inset` is needed.
        ContextMenuItem(
          // Different keys per platform, so the text is given as it is.
          shortcut: MenuShortcut.text(apple ? '⌘[' : 'Alt+←'),
          child: const Text('Back'),
        ),
        ContextMenuItem(
          enabled: false,
          shortcut: MenuShortcut.text(apple ? '⌘]' : 'Alt+→'),
          child: const Text('Forward'),
        ),
        ContextMenuItem(
          // The same key with the platform's own modifier.
          shortcut: MenuShortcut(
            SingleActivator(
              LogicalKeyboardKey.keyR,
              meta: apple,
              control: !apple,
            ),
          ),
          child: const Text('Reload'),
        ),
        const ContextMenuItem(
          trailing: PhosphorIcon(PhosphorIconsRegular.caretRight),
          items: [
            ContextMenuItem(child: Text('Save Page As...')),
            ContextMenuItem(child: Text('Create Shortcut...')),
            MenuDivider(),
            ContextMenuItem(child: Text('Developer Tools')),
          ],
          child: Text('More Tools'),
        ),
        const MenuDivider(),
        MenuCheckboxItem(
          checked: bookmarks,
          onChanged: (value) => setState(() => bookmarks = value),
          child: const Text('Show Bookmarks Bar'),
        ),
        MenuCheckboxItem(
          checked: fullUrls,
          onChanged: (value) => setState(() => fullUrls = value),
          child: const Text('Show Full URLs'),
        ),
        const MenuDivider(),
        const MenuLabel(child: Text('People')),
        MenuRadioGroup<String>(
          value: person,
          onChanged: (value) => setState(() => person = value),
          children: const [
            MenuRadioItem(value: 'pedro', child: Text('Pedro Duarte')),
            MenuRadioItem(value: 'colm', child: Text('Colm Tuite')),
          ],
        ),
      ],
      child: Container(
        width: 300,
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: theme.radii.md,
        ),
        child: const Text('Right click here'),
      ),
    );
  }
}
