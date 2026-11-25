import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A menu of actions is a `DropdownMenu` anchored above the button.
class FloatingActionButtonMenuExample extends StatelessWidget {
  const FloatingActionButtonMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    final gap = Theme.of(context).layoutTheme.gap(GapSize.sm);
    return DropdownMenu(
      // The menu's bottom end corner on the button's top end corner.
      anchor: Anchor(
        childAlignment: AlignmentDirectional.topEnd,
        overlayAlignment: AlignmentDirectional.bottomEnd,
        offset: Offset(0, -gap),
      ),
      constraints: const BoxConstraints(minWidth: 200),
      items: const [
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.notePencil),
          child: Text('Post'),
        ),
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.image),
          child: Text('Photo'),
        ),
        MenuItem(
          leading: PhosphorIcon(PhosphorIconsRegular.chartBar),
          child: Text('Poll'),
        ),
      ],
      builder: (context, controller, _) => FloatingActionButton(
        icon: const PhosphorIcon(PhosphorIconsRegular.plus),
        label: const Text('Create'),
        onPressed: controller.toggle,
      ),
    );
  }
}
