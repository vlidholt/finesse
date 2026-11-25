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
