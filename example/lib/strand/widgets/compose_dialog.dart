import 'package:example/strand/data.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Opens the post composer: what the bottom bar's "Create post" action and
/// the home feed's "Start a post" box lead to.
///
/// The designs stop at the entry points, so the composer is a plain dialog.
Future<void> showComposeDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      title: const Text('Create post'),
      description: const Text('Share an update with your network.'),
      actions: [
        Button.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Button(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Post'),
        ),
      ],
      child: Textarea(
        autofocus: true,
        placeholder: Text('Start a post, ${People.me.firstName}…'),
      ),
    ),
  );
}
