import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class AlertDestructiveExample extends StatelessWidget {
  const AlertDestructiveExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 576),
      child: const Alert.destructive(
        icon: Icon(PhosphorIconsRegular.warningCircle),
        title: Text('Error'),
        description: Text('Your session has expired. Please log in again.'),
      ),
    );
  }
}
