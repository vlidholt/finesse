import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToastDestructiveExample extends StatelessWidget {
  const ToastDestructiveExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      child: const Text('Show destructive toast'),
      onPressed: () {
        Toaster.of(context).show(
          const Toast.destructive(
            title: Text('Uh oh! Something went wrong'),
            description: Text('There was a problem with your request'),
          ),
        );
      },
    );
  }
}
