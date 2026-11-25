import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/action_sheet/action_sheet_basic.dart';
import 'package:example/docs/examples/action_sheet/action_sheet_confirm.dart';
import 'package:example/docs/examples/action_sheet/action_sheet_inline.dart';

final actionSheetDoc = ComponentDoc(
  slug: 'action_sheet',
  title: 'Action Sheet',
  description:
      'A short list of choices about the thing just touched. '
      'showActionSheet presents it the way the form factor expects: a sheet '
      'from the bottom on a phone, a menu or a small dialog on a desktop.',
  examples: [
    ComponentExample(
      id: 'action_sheet_basic',
      title: 'From a button',
      description:
          'Pass the rectangle of the control that opened it as anchorRect '
          'and a desktop shows a menu there. A phone ignores it and shows a '
          'sheet with a Cancel row; a drag down, a tap outside and Escape '
          'cancel too.',
      builder: (_) => const ActionSheetBasicExample(),
    ),
    ComponentExample(
      id: 'action_sheet_confirm',
      title: 'A decision',
      description:
          'isDefault makes one action heavier, destructive paints one in '
          'the destructive colour, and cancelLabel renames the way out.',
      builder: (_) => const ActionSheetConfirmExample(),
    ),
    ComponentExample(
      id: 'action_sheet_inline',
      title: 'The list on its own',
      builder: (_) => const ActionSheetInlineExample(),
      minPreviewHeight: 300,
    ),
  ],
);
