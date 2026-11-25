import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/dialog/dialog_alert.dart';
import 'package:example/docs/examples/dialog/dialog_form.dart';

final dialogDoc = ComponentDoc(
  slug: 'dialog',
  title: 'Dialog',
  description:
      'A modal window overlaid on the page, rendering the content underneath '
      'inert.',
  examples: [
    ComponentExample(
      id: 'dialog_form',
      title: 'With a form',
      description:
          'A dialog has no close button of its own. Its actions close it, '
          'as do Escape and a tap outside; pass `showCloseButton: true` '
          'for an x in the corner.',
      builder: (_) => const DialogFormExample(),
    ),
    ComponentExample(
      id: 'dialog_alert',
      title: 'Alert dialog',
      description:
          'Interrupts the user with an important question and explicit '
          'actions.',
      builder: (_) => const DialogAlertExample(),
    ),
  ],
);
