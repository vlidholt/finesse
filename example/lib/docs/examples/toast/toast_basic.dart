import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToastBasicExample extends StatelessWidget {
  const ToastBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      child: const Text('Add to calendar'),
      onPressed: () {
        final toaster = Toaster.of(context);
        // The id is how the action finds its own toast again.
        final id = UniqueKey();
        toaster.show(
          Toast(
            id: id,
            title: const Text('Scheduled: Catch up'),
            description: const Text('Friday at 5:57 PM'),
            action: Button.outline(
              size: ButtonSize.sm,
              child: const Text('Undo'),
              onPressed: () => toaster.dismiss(id),
            ),
          ),
        );
      },
    );
  }
}
