import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
