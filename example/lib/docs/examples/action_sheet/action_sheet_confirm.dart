import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Without an anchor a desktop shows the choices in a small dialog. Without
/// icons the labels are centred; the destructive one is in the destructive
/// colour and never has the focus when the sheet opens.
class ActionSheetConfirmExample extends StatefulWidget {
  const ActionSheetConfirmExample({super.key});

  @override
  State<ActionSheetConfirmExample> createState() =>
      _ActionSheetConfirmExampleState();
}

class _ActionSheetConfirmExampleState extends State<ActionSheetConfirmExample> {
  String _status = 'Draft kept';

  Future<void> _close() async {
    final discard = await showActionSheet<bool>(
      context: context,
      title: const Text('Discard this draft?'),
      message: const Text('You have written 240 words.'),
      cancelLabel: const Text('Keep writing'),
      actions: const [
        ActionSheetAction(
          value: false,
          isDefault: true,
          label: Text('Save as draft'),
        ),
        ActionSheetAction(
          value: true,
          destructive: true,
          label: Text('Discard'),
        ),
      ],
    );
    if (!mounted || discard == null) return;
    setState(() => _status = discard ? 'Draft discarded' : 'Draft saved');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Button.outline(
          onPressed: _close,
          child: const Text('Close the editor'),
        ),
        Text(_status, style: Theme.of(context).textTheme.muted),
      ],
    );
  }
}
