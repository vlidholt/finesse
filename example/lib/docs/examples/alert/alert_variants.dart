import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class AlertVariantsExample extends StatelessWidget {
  const AlertVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: const UnaColumn(
        gap: GapSize.md,
        mainAxisSize: MainAxisSize.min,
        children: [
          Alert(
            variant: AlertVariant.success,
            title: Text('Payment received'),
            description: Text('A receipt is on its way to your inbox.'),
          ),
          Alert(
            variant: AlertVariant.warning,
            title: Text('Your trial ends in 3 days'),
            description: Text('Add a payment method to keep your projects.'),
          ),
          Alert(
            variant: AlertVariant.info,
            title: Text('A new version is available'),
            description: Text('Reload the page to get the latest changes.'),
          ),
        ],
      ),
    );
  }
}
