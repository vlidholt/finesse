# Menubar

A visually persistent menu, common in desktop applications.

## Default

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class MenubarBasicExample extends StatelessWidget {
  const MenubarBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    const divider = Divider.horizontal(
      margin: EdgeInsets.symmetric(vertical: 4),
    );
    return Menubar(
      items: const [
        MenubarItem(
          items: [
            ContextMenuItem(child: Text('New Tab')),
            ContextMenuItem(child: Text('New Window')),
            ContextMenuItem(
              enabled: false,
              child: Text('New Incognito Window'),
            ),
            divider,
            ContextMenuItem(
              trailing: PhosphorIcon(PhosphorIconsRegular.caretRight),
              items: [
                ContextMenuItem(child: Text('Email Link')),
                ContextMenuItem(child: Text('Messages')),
                ContextMenuItem(child: Text('Notes')),
              ],
              child: Text('Share'),
            ),
            ContextMenuItem(
              trailing: PhosphorIcon(PhosphorIconsRegular.caretRight),
              items: [
                ContextMenuItem(child: Text('PDF')),
                ContextMenuItem(child: Text('HTML')),
                ContextMenuItem(child: Text('Plain Text')),
              ],
              child: Text('Export As'),
            ),
            divider,
            ContextMenuItem(child: Text('Print...')),
          ],
          child: Text('File'),
        ),
        MenubarItem(
          items: [
            ContextMenuItem(child: Text('Undo')),
            ContextMenuItem(child: Text('Redo')),
            divider,
            ContextMenuItem(
              trailing: PhosphorIcon(PhosphorIconsRegular.caretRight),
              items: [
                ContextMenuItem(child: Text('Search the Web')),
                divider,
                ContextMenuItem(child: Text('Find...')),
                ContextMenuItem(child: Text('Find Next')),
                ContextMenuItem(child: Text('Find Previous')),
              ],
              child: Text('Find'),
            ),
            divider,
            ContextMenuItem(child: Text('Cut')),
            ContextMenuItem(child: Text('Copy')),
            ContextMenuItem(child: Text('Paste')),
          ],
          child: Text('Edit'),
        ),
        MenubarItem(
          items: [
            ContextMenuItem(
              leading: PhosphorIcon(PhosphorIconsRegular.check),
              child: Text('Always Show Full URLs'),
            ),
            ContextMenuItem.inset(child: Text('Reload')),
            ContextMenuItem.inset(child: Text('Toggle Full Screen')),
          ],
          child: Text('View'),
        ),
      ],
    );
  }
}
```

