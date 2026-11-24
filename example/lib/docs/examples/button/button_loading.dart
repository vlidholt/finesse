import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonLoadingExample extends StatelessWidget {
  const ButtonLoadingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Button(
      enabled: false,
      leading: const SizedBox.square(
        dimension: 16,
        child: Spinner(),
      ),
      child: const Text('Please wait'),
    );
  }
}
