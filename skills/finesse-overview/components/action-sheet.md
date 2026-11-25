# Action Sheet

A short list of choices about the thing just touched. showActionSheet presents it the way the form factor expects: a sheet from the bottom on a phone, a menu or a small dialog on a desktop.

## From a button

Pass the rectangle of the control that opened it as anchorRect and a desktop shows a menu there. A phone ignores it and shows a sheet with a Cancel row; a drag down, a tap outside and Escape cancel too.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

enum PostAction { save, share, copyLink, report }

/// The choices that belong to the thing just touched. On a phone they come
/// up in a sheet; on a desktop, given the rectangle of the button that asked
/// for them, they open as a menu under it.
class ActionSheetBasicExample extends StatefulWidget {
  const ActionSheetBasicExample({super.key});

  @override
  State<ActionSheetBasicExample> createState() =>
      _ActionSheetBasicExampleState();
}

class _ActionSheetBasicExampleState extends State<ActionSheetBasicExample> {
  PostAction? _last;

  Future<void> _open(BuildContext buttonContext) async {
    // Where the button is on screen: the menu's anchor on a desktop.
    final box = buttonContext.findRenderObject()! as RenderBox;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final action = await showActionSheet<PostAction>(
      context: context,
      anchorRect: rect,
      title: const Text('Post by Maya Lindqvist'),
      message: const Text('Shared with your network'),
      actions: const [
        ActionSheetAction(
          value: PostAction.save,
          isDefault: true,
          icon: PhosphorIcon(PhosphorIconsRegular.bookmarkSimple),
          label: Text('Save post'),
        ),
        ActionSheetAction(
          value: PostAction.share,
          icon: PhosphorIcon(PhosphorIconsRegular.export),
          label: Text('Share…'),
        ),
        ActionSheetAction(
          value: PostAction.copyLink,
          icon: PhosphorIcon(PhosphorIconsRegular.link),
          label: Text('Copy link'),
        ),
        ActionSheetAction(
          value: PostAction.report,
          destructive: true,
          icon: PhosphorIcon(PhosphorIconsRegular.flag),
          label: Text('Report post'),
        ),
      ],
    );
    if (mounted && action != null) setState(() => _last = action);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Builder(
          builder: (buttonContext) => IconButton.outline(
            semanticLabel: 'More actions',
            icon: const PhosphorIcon(PhosphorIconsRegular.dotsThree),
            onPressed: () => _open(buttonContext),
          ),
        ),
        Text(
          _last == null ? 'Nothing chosen yet' : 'Chose ${_last!.name}',
          style: Theme.of(context).textTheme.muted,
        ),
      ],
    );
  }
}
```

## A decision

isDefault makes one action heavier, destructive paints one in the destructive colour, and cancelLabel renames the way out.

```dart
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
```

## The list on its own

```dart
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
        style: CardTheme(padding: EdgeInsets.zero),
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
```
