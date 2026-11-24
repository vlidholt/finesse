import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ContextMenuSubmenusExample extends StatelessWidget {
  const ContextMenuSubmenusExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const divider = Divider.horizontal(
      margin: EdgeInsets.symmetric(vertical: 4),
    );
    const more = Icon(LucideIcons.chevronRight);
    return ContextMenuRegion(
      constraints: const BoxConstraints(minWidth: 220),
      items: const [
        ContextMenuItem(
          leading: Icon(LucideIcons.folderOpen),
          child: Text('Open'),
        ),
        ContextMenuItem(
          leading: Icon(LucideIcons.appWindow),
          trailing: more,
          items: [
            ContextMenuItem(child: Text('Preview')),
            ContextMenuItem(child: Text('Text Editor')),
            ContextMenuItem(child: Text('Code')),
            divider,
            ContextMenuItem(child: Text('Other...')),
          ],
          child: Text('Open With'),
        ),
        ContextMenuItem(
          leading: Icon(LucideIcons.share2),
          trailing: more,
          items: [
            ContextMenuItem(child: Text('Email')),
            ContextMenuItem(child: Text('Messages')),
            ContextMenuItem(child: Text('AirDrop')),
            ContextMenuItem(
              trailing: more,
              items: [
                ContextMenuItem(child: Text('Copy Link')),
                ContextMenuItem(child: Text('Copy Embed Code')),
                ContextMenuItem(child: Text('Copy as Markdown')),
              ],
              child: Text('Copy'),
            ),
          ],
          child: Text('Share'),
        ),
        ContextMenuItem(
          leading: Icon(LucideIcons.folderInput),
          trailing: more,
          items: [
            ContextMenuItem(child: Text('Desktop')),
            ContextMenuItem(child: Text('Documents')),
            ContextMenuItem(child: Text('Downloads')),
            ContextMenuItem(
              trailing: more,
              items: [
                ContextMenuItem(child: Text('Design')),
                ContextMenuItem(child: Text('Engineering')),
                ContextMenuItem(child: Text('Marketing')),
              ],
              child: Text('Projects'),
            ),
          ],
          child: Text('Move To'),
        ),
        ContextMenuItem(
          leading: Icon(LucideIcons.tag),
          trailing: more,
          items: [
            ContextMenuItem(child: Text('Red')),
            ContextMenuItem(child: Text('Orange')),
            ContextMenuItem(child: Text('Green')),
            ContextMenuItem(child: Text('Blue')),
            divider,
            ContextMenuItem(child: Text('Edit Tags...')),
          ],
          child: Text('Tags'),
        ),
        ContextMenuItem(
          leading: Icon(LucideIcons.arrowUpDown),
          trailing: more,
          items: [
            ContextMenuItem(child: Text('Name')),
            ContextMenuItem(child: Text('Date Modified')),
            ContextMenuItem(child: Text('Size')),
            ContextMenuItem(child: Text('Kind')),
          ],
          child: Text('Sort By'),
        ),
        ContextMenuItem(
          leading: Icon(LucideIcons.layoutGrid),
          trailing: more,
          items: [
            ContextMenuItem(child: Text('Icons')),
            ContextMenuItem(child: Text('List')),
            ContextMenuItem(child: Text('Columns')),
            ContextMenuItem(child: Text('Gallery')),
          ],
          child: Text('View As'),
        ),
        ContextMenuItem(
          leading: Icon(LucideIcons.copy),
          trailing: more,
          items: [
            ContextMenuItem(child: Text('Duplicate')),
            ContextMenuItem(child: Text('Copy Path')),
            ContextMenuItem(child: Text('Copy Name')),
          ],
          child: Text('Copy'),
        ),
        ContextMenuItem(
          leading: Icon(LucideIcons.zap),
          trailing: more,
          items: [
            ContextMenuItem(child: Text('Compress')),
            ContextMenuItem(child: Text('Convert Image')),
            ContextMenuItem(child: Text('Remove Background')),
            ContextMenuItem(child: Text('Create PDF')),
          ],
          child: Text('Quick Actions'),
        ),
        divider,
        ContextMenuItem(
          leading: Icon(LucideIcons.trash2),
          destructive: true,
          child: Text('Move to Trash'),
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
