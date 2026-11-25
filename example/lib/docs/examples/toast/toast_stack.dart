import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToastStackExample extends StatefulWidget {
  const ToastStackExample({super.key});

  @override
  State<ToastStackExample> createState() => _ToastStackExampleState();
}

class _ToastStackExampleState extends State<ToastStackExample> {
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    final toaster = Toaster.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        Button.outline(
          child: const Text('Show a toast'),
          onPressed: () {
            _count++;
            toaster.show(
              Toast(
                title: Text('Message $_count'),
                description: const Text('Point at the stack to open it.'),
              ),
            );
          },
        ),
        Button.outline(
          child: const Text('One that stays'),
          onPressed: () => toaster.show(
            const Toast(
              variant: ToastVariant.warning,
              title: Text('You are offline'),
              description: Text('Changes are kept on this device.'),
              // No clock: it stays until it is dismissed.
              duration: Duration.zero,
            ),
          ),
        ),
        Button.ghost(
          onPressed: toaster.dismissAll,
          child: const Text('Dismiss all'),
        ),
      ],
    );
  }
}
