import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonGroupSplitExample extends StatelessWidget {
  const ButtonGroupSplitExample({super.key});

  @override
  Widget build(BuildContext context) {
    // A split button is a group, not a widget of its own: the action, a
    // separator (these two have no outline to share) and a menu.
    return ButtonGroup(
      children: [
        Button.secondary(onPressed: () {}, child: const Text('Send')),
        const ButtonGroupSeparator(),
        DropdownMenu(
          items: [
            ContextMenuItem(
              leading: const PhosphorIcon(PhosphorIconsRegular.clock),
              onPressed: () {},
              child: const Text('Send later'),
            ),
            ContextMenuItem(
              leading: const PhosphorIcon(PhosphorIconsRegular.floppyDisk),
              onPressed: () {},
              child: const Text('Save as draft'),
            ),
          ],
          builder: (context, controller, _) => IconButton.secondary(
            tooltip: 'More ways to send',
            onPressed: controller.toggle,
            icon: const PhosphorIcon(PhosphorIconsRegular.caretDown),
          ),
        ),
      ],
    );
  }
}
