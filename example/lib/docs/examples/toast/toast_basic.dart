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
        toaster.show(
          Toast(
            title: const Text('Scheduled: Catch up'),
            description: const Text('Friday, February 10, 2023 at 5:57 PM'),
            action: Button.outline(
              child: const Text('Undo'),
              onPressed: () => toaster.hide(),
            ),
          ),
        );
      },
    );
  }
}
