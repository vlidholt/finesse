import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ContextMenuBasicExample extends StatelessWidget {
  const ContextMenuBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const divider = Divider.horizontal(
      margin: EdgeInsets.symmetric(vertical: 4),
    );
    return ContextMenuRegion(
      constraints: const BoxConstraints(minWidth: 300),
      items: const [
        ContextMenuItem.inset(child: Text('Back')),
        ContextMenuItem.inset(enabled: false, child: Text('Forward')),
        ContextMenuItem.inset(child: Text('Reload')),
        ContextMenuItem.inset(
          trailing: Icon(LucideIcons.chevronRight),
          items: [
            ContextMenuItem(child: Text('Save Page As...')),
            ContextMenuItem(child: Text('Create Shortcut...')),
            divider,
            ContextMenuItem(child: Text('Developer Tools')),
          ],
          child: Text('More Tools'),
        ),
        divider,
        ContextMenuItem(
          leading: Icon(LucideIcons.check),
          child: Text('Show Bookmarks Bar'),
        ),
        ContextMenuItem.inset(child: Text('Show Full URLs')),
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
