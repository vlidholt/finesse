# Context Menu

Displays a menu at the pointer, triggered by a right click or a long press.

## Default

Checkbox rows, a radio group under a label, dividers and shortcuts. Space toggles a checkable row and keeps the menu open; Enter and a click do what the row is set to do.

```dart
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
```

## Submenus

Eight rows in a row open a submenu, and two of them nest a second level. Sweep the pointer down the list: each submenu closes the moment the next row is reached.

```dart
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
        ContextMenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.folderOpen),
          child: Text('Open'),
        ),
        ContextMenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.appWindow),
          trailing: more,
          items: [
            ContextMenuItem(child: Text('Preview')),
            ContextMenuItem(child: Text('Text Editor')),
            ContextMenuItem(child: Text('Code')),
            MenuDivider(),
            ContextMenuItem(child: Text('Other...')),
          ],
          child: Text('Open With'),
        ),
        ContextMenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.shareNetwork),
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
          leading: PhosphorIcon(PhosphorIconsRegular.folderSimplePlus),
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
          leading: PhosphorIcon(PhosphorIconsRegular.tag),
          trailing: more,
          items: [
            ContextMenuItem(child: Text('Red')),
            ContextMenuItem(child: Text('Orange')),
            ContextMenuItem(child: Text('Green')),
            ContextMenuItem(child: Text('Blue')),
            MenuDivider(),
            ContextMenuItem(child: Text('Edit Tags...')),
          ],
          child: Text('Tags'),
        ),
        ContextMenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.arrowsDownUp),
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
          leading: PhosphorIcon(PhosphorIconsRegular.squaresFour),
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
          leading: PhosphorIcon(PhosphorIconsRegular.copy),
          trailing: more,
          items: [
            ContextMenuItem(child: Text('Duplicate')),
            ContextMenuItem(child: Text('Copy Path')),
            ContextMenuItem(child: Text('Copy Name')),
          ],
          child: Text('Copy'),
        ),
        ContextMenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.lightning),
          trailing: more,
          items: [
            ContextMenuItem(child: Text('Compress')),
            ContextMenuItem(child: Text('Convert Image')),
            ContextMenuItem(child: Text('Remove Background')),
            ContextMenuItem(child: Text('Create PDF')),
          ],
          child: Text('Quick Actions'),
        ),
        MenuDivider(),
        ContextMenuItem(
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
```

## At a point

showMenu opens a menu where there is no widget to anchor it to: at a point of a canvas, or under a rectangle. Its future completes with the value of the row that was chosen.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

enum _CellAction { copy, fill, clear }

class ContextMenuShowMenuExample extends StatefulWidget {
  const ContextMenuShowMenuExample({super.key});

  @override
  State<ContextMenuShowMenuExample> createState() =>
      _ContextMenuShowMenuExampleState();
}

class _ContextMenuShowMenuExampleState
    extends State<ContextMenuShowMenuExample> {
  static const _columns = 4;
  static const _rows = 3;

  final _filled = <int>{1, 6};
  String _last = 'Right click or long press a cell';

  // A grid painted as one widget has no widget per cell to hang a menu on:
  // the menu is shown at the point of the press, and the future says what
  // was chosen.
  Future<void> _openMenu(Offset globalPosition, int cell) async {
    final name = '${'ABCD'[cell % _columns]}${cell ~/ _columns + 1}';
    final action = await showMenu<_CellAction>(
      context: context,
      position: globalPosition,
      items: [
        MenuLabel(child: Text('Cell $name')),
        const ContextMenuItem(
          value: _CellAction.copy,
          leading: PhosphorIcon(PhosphorIconsRegular.copy),
          child: Text('Copy'),
        ),
        const ContextMenuItem(
          value: _CellAction.fill,
          leading: PhosphorIcon(PhosphorIconsRegular.paintBucket),
          child: Text('Fill'),
        ),
        const MenuDivider(),
        ContextMenuItem(
          value: _CellAction.clear,
          enabled: _filled.contains(cell),
          destructive: true,
          leading: const PhosphorIcon(PhosphorIconsRegular.eraser),
          child: const Text('Clear'),
        ),
      ],
    );
    if (!mounted) return;
    setState(() {
      switch (action) {
        case _CellAction.fill:
          _filled.add(cell);
        case _CellAction.clear:
          _filled.remove(cell);
        case _CellAction.copy || null:
          break;
      }
      _last = action == null ? 'Dismissed' : '${action.name} $name';
    });
  }

  int _cellAt(Offset local, Size size) {
    final column = (local.dx / size.width * _columns).floor();
    final row = (local.dy / size.height * _rows).floor();
    return row.clamp(0, _rows - 1) * _columns + column.clamp(0, _columns - 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = Size(320, 168);
    return FinesseColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.sm,
      children: [
        GestureDetector(
          onSecondaryTapDown: (details) => _openMenu(
            details.globalPosition,
            _cellAt(details.localPosition, size),
          ),
          onLongPressStart: (details) => _openMenu(
            details.globalPosition,
            _cellAt(details.localPosition, size),
          ),
          child: CustomPaint(
            size: size,
            painter: _GridPainter(
              columns: _columns,
              rows: _rows,
              filled: Set.of(_filled),
              line: theme.colorScheme.border,
              fill: theme.colorScheme.accent,
              radius: theme.radii.md,
            ),
          ),
        ),
        Text(_last, style: theme.textTheme.muted),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({
    required this.columns,
    required this.rows,
    required this.filled,
    required this.line,
    required this.fill,
    required this.radius,
  });

  final int columns;
  final int rows;
  final Set<int> filled;
  final Color line;
  final Color fill;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = Size(size.width / columns, size.height / rows);
    final outline = radius.toRRect(Offset.zero & size);
    canvas
      ..save()
      ..clipRRect(outline);
    for (final index in filled) {
      final origin = Offset(
        index % columns * cell.width,
        index ~/ columns * cell.height,
      );
      canvas.drawRect(origin & cell, Paint()..color = fill);
    }
    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke;
    for (var column = 1; column < columns; column++) {
      final x = column * cell.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), stroke);
    }
    for (var row = 1; row < rows; row++) {
      final y = row * cell.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), stroke);
    }
    canvas
      ..restore()
      ..drawRRect(outline.deflate(.5), stroke);
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      !_sameCells(filled, oldDelegate.filled) ||
      line != oldDelegate.line ||
      fill != oldDelegate.fill ||
      radius != oldDelegate.radius;

  static bool _sameCells(Set<int> a, Set<int> b) =>
      a.length == b.length && a.containsAll(b);
}
```

