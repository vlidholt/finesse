import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class DialogAlertExample extends StatelessWidget {
  const DialogAlertExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      child: const Text('Delete account'),
      onPressed: () {
        showDialog<bool>(
          context: context,
          builder: (context) => Dialog.alert(
            title: const Text('Are you absolutely sure?'),
            description: const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'This action cannot be undone. This will permanently delete '
                'your account and remove your data from our servers.',
              ),
            ),
            actions: [
              Button.outline(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Button(
                child: const Text('Continue'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );
      },
    );
  }
}
