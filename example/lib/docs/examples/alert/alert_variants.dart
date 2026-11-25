import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class AlertVariantsExample extends StatelessWidget {
  const AlertVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: const FinesseColumn(
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
