import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

enum SortOrder { recent, name, size }

/// `ActionSheet` is the list on its own: put it in a card, a popover or a
/// route of yours, and decide in `onSelected` what a choice does there.
class ActionSheetInlineExample extends StatefulWidget {
  const ActionSheetInlineExample({super.key});

  @override
  State<ActionSheetInlineExample> createState() =>
      _ActionSheetInlineExampleState();
}

class _ActionSheetInlineExampleState extends State<ActionSheetInlineExample> {
  var _order = SortOrder.recent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        padding: EdgeInsets.zero,
        child: ActionSheet<SortOrder>(
          title: const Text('Sort files by'),
          showCancel: false,
          // Nothing opens here, so nothing should take the focus.
          autofocus: false,
          onSelected: (action) => setState(() => _order = action.value!),
          actions: [
            for (final order in SortOrder.values)
              ActionSheetAction(
                value: order,
                isDefault: order == _order,
                icon: PhosphorIcon(
                  order == _order
                      ? PhosphorIconsRegular.checkCircle
                      : PhosphorIconsRegular.circle,
                ),
                label: Text(switch (order) {
                  SortOrder.recent => 'Most recent',
                  SortOrder.name => 'Name',
                  SortOrder.size => 'Size',
                }),
              ),
          ],
        ),
      ),
    );
  }
}
