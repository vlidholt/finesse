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
