import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class ToastVariantsExample extends StatelessWidget {
  const ToastVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    void show(ToastVariant variant, String title, [String? description]) {
      Toaster.of(context).show(
        Toast(
          variant: variant,
          title: Text(title),
          description: description == null ? null : Text(description),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        Button.outline(
          child: const Text('Neutral'),
          onPressed: () => show(ToastVariant.neutral, 'Link copied'),
        ),
        Button.outline(
          child: const Text('Success'),
          onPressed: () => show(
            ToastVariant.success,
            'Changes saved',
            'Your profile is up to date.',
          ),
        ),
        Button.outline(
          child: const Text('Warning'),
          onPressed: () => show(
            ToastVariant.warning,
            'Storage almost full',
            '2 GB of 50 GB left.',
          ),
        ),
        Button.outline(
          child: const Text('Destructive'),
          onPressed: () => show(
            ToastVariant.destructive,
            'Could not send the message',
            'Check your connection and try again.',
          ),
        ),
      ],
    );
  }
}
