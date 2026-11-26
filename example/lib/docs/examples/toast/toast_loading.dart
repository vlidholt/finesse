import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class ToastLoadingExample extends StatefulWidget {
  const ToastLoadingExample({super.key});

  @override
  State<ToastLoadingExample> createState() => _ToastLoadingExampleState();
}

class _ToastLoadingExampleState extends State<ToastLoadingExample> {
  Timer? _upload;

  @override
  void dispose() {
    _upload?.cancel();
    super.dispose();
  }

  void _start() {
    final toaster = Toaster.of(context);
    // A loading toast stays until it is replaced or dismissed.
    final id = toaster.show(
      const Toast(
        variant: ToastVariant.loading,
        title: Text('Uploading 3 photos…'),
        dismissible: false,
      ),
    );
    _upload?.cancel();
    _upload = Timer(const Duration(seconds: 2), () {
      // The same toast, where it is, with its result.
      toaster.update(
        id,
        const Toast(
          variant: ToastVariant.success,
          title: Text('3 photos uploaded'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      onPressed: _start,
      child: const Text('Upload'),
    );
  }
}
