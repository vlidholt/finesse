import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class ToastInlineExample extends StatelessWidget {
  const ToastInlineExample({super.key});

  @override
  Widget build(BuildContext context) {
    // A `Toast` is a widget: outside a toaster it is a picture of one.
    return UnaColumn(
      gap: GapSize.md,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Toast(title: Text('Link copied')),
        const Toast(
          variant: ToastVariant.success,
          title: Text('Changes saved'),
          description: Text('Your profile is up to date.'),
        ),
        Toast(
          variant: ToastVariant.destructive,
          title: const Text('Could not send the message'),
          action: Button.outline(
            size: ButtonSize.sm,
            onPressed: () {},
            child: const Text('Retry'),
          ),
        ),
        const Toast(
          variant: ToastVariant.loading,
          title: Text('Uploading 3 photos…'),
        ),
      ],
    );
  }
}
