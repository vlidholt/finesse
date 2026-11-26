import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// An action can take its time: here Delete asks first, and the row stays
/// open until the answer comes. `fullSwipe: false` makes a long swipe only
/// open the row, so nothing destructive runs without a tap.
class SwipeActionsConfirmExample extends StatefulWidget {
  const SwipeActionsConfirmExample({super.key});

  @override
  State<SwipeActionsConfirmExample> createState() =>
      _SwipeActionsConfirmExampleState();
}

class _SwipeActionsConfirmExampleState
    extends State<SwipeActionsConfirmExample> {
  final files = ['Brand guidelines.pdf', 'Q3 roadmap.key', 'Interview notes'];

  Future<bool> _confirm(String file) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog.alert(
        title: Text('Delete "$file"?'),
        description: const Text(
          'It is removed for everyone it is shared with.',
        ),
        actions: [
          Button.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          Button.destructive(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return sure ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: ListSection(
        variant: ListSectionVariant.plain,
        children: [
          for (final file in files)
            SwipeActions(
              key: ValueKey(file),
              fullSwipe: false,
              trailing: [
                SwipeAction(
                  icon: const PhosphorIcon(PhosphorIconsRegular.trash),
                  label: 'Delete',
                  destructive: true,
                  onPressed: () => _confirm(file),
                ),
                SwipeAction(
                  icon: const PhosphorIcon(PhosphorIconsRegular.shareNetwork),
                  label: 'Share',
                  onPressed: () => false,
                ),
              ],
              onRemoved: () => setState(() => files.remove(file)),
              child: ListTile(
                leading: const IconTile(
                  icon: PhosphorIcon(PhosphorIconsRegular.file),
                ),
                title: Text(file),
                showChevron: true,
                onTap: () {},
              ),
            ),
        ],
      ),
    );
  }
}
