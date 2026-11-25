import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/alert/alert_default.dart';
import 'package:example/docs/examples/alert/alert_destructive.dart';
import 'package:example/docs/examples/alert/alert_dismissible.dart';
import 'package:example/docs/examples/alert/alert_variants.dart';

final alertDoc = ComponentDoc(
  slug: 'alert',
  title: 'Alert',
  description: 'Displays a callout for user attention.',
  examples: [
    ComponentExample(
      id: 'alert_default',
      title: 'Default',
      builder: (_) => const AlertDefaultExample(),
    ),
    ComponentExample(
      id: 'alert_destructive',
      title: 'Destructive',
      builder: (_) => const AlertDestructiveExample(),
    ),
    ComponentExample(
      id: 'alert_variants',
      title: 'Success, warning and info',
      description:
          'Three variants tinted with the `success`, `warning` and `tint` '
          'colours of the scheme, each with an icon of its own. `icon` '
          'replaces it.',
      minPreviewHeight: 300,
      builder: (_) => const AlertVariantsExample(),
    ),
    ComponentExample(
      id: 'alert_dismissible',
      title: 'Dismissible',
      description:
          'With `onDismissed` the alert has a close button. Pressing it '
          'folds the alert away and then calls `onDismissed`, where the '
          'parent stops building it.',
      builder: (_) => const AlertDismissibleExample(),
    ),
  ],
);
