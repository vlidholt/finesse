import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ContextMenuSubmenusExample extends StatelessWidget {
  const ContextMenuSubmenusExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const more = PhosphorIcon(PhosphorIconsRegular.caretRight);
    return ContextMenuRegion(
      constraints: const BoxConstraints(minWidth: 220),
      items: const [
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.folderOpen),
          child: Text('Open'),
        ),
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.appWindow),
          trailing: more,
          items: [
            MenuItem(child: Text('Preview')),
            MenuItem(child: Text('Text Editor')),
            MenuItem(child: Text('Code')),
            MenuDivider(),
            MenuItem(child: Text('Other...')),
          ],
          child: Text('Open With'),
        ),
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.shareNetwork),
          trailing: more,
          items: [
            MenuItem(child: Text('Email')),
            MenuItem(child: Text('Messages')),
            MenuItem(child: Text('AirDrop')),
            MenuItem(
              trailing: more,
              items: [
                MenuItem(child: Text('Copy Link')),
                MenuItem(child: Text('Copy Embed Code')),
                MenuItem(child: Text('Copy as Markdown')),
              ],
              child: Text('Copy'),
            ),
          ],
          child: Text('Share'),
        ),
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.folderSimplePlus),
          trailing: more,
          items: [
            MenuItem(child: Text('Desktop')),
            MenuItem(child: Text('Documents')),
            MenuItem(child: Text('Downloads')),
            MenuItem(
              trailing: more,
              items: [
                MenuItem(child: Text('Design')),
                MenuItem(child: Text('Engineering')),
                MenuItem(child: Text('Marketing')),
              ],
              child: Text('Projects'),
            ),
          ],
          child: Text('Move To'),
        ),
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.tag),
          trailing: more,
          items: [
            MenuItem(child: Text('Red')),
            MenuItem(child: Text('Orange')),
            MenuItem(child: Text('Green')),
            MenuItem(child: Text('Blue')),
            MenuDivider(),
            MenuItem(child: Text('Edit Tags...')),
          ],
          child: Text('Tags'),
        ),
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.arrowsDownUp),
          trailing: more,
          items: [
            MenuItem(child: Text('Name')),
            MenuItem(child: Text('Date Modified')),
            MenuItem(child: Text('Size')),
            MenuItem(child: Text('Kind')),
          ],
          child: Text('Sort By'),
        ),
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.squaresFour),
          trailing: more,
          items: [
            MenuItem(child: Text('Icons')),
            MenuItem(child: Text('List')),
            MenuItem(child: Text('Columns')),
            MenuItem(child: Text('Gallery')),
          ],
          child: Text('View As'),
        ),
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.copy),
          trailing: more,
          items: [
            MenuItem(child: Text('Duplicate')),
            MenuItem(child: Text('Copy Path')),
            MenuItem(child: Text('Copy Name')),
          ],
          child: Text('Copy'),
        ),
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.lightning),
          trailing: more,
          items: [
            MenuItem(child: Text('Compress')),
            MenuItem(child: Text('Convert Image')),
            MenuItem(child: Text('Remove Background')),
            MenuItem(child: Text('Create PDF')),
          ],
          child: Text('Quick Actions'),
        ),
        MenuDivider(),
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.trash),
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
