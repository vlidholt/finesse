import 'package:example/docs/phone_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// An `Alert` as the scaffold's `banner`. Its close button folds it away,
/// and `onDismissed` takes it out of the scaffold once it has.
class ScaffoldBannerAlertExample extends StatefulWidget {
  const ScaffoldBannerAlertExample({super.key});

  @override
  State<ScaffoldBannerAlertExample> createState() =>
      _ScaffoldBannerAlertExampleState();
}

class _ScaffoldBannerAlertExampleState
    extends State<ScaffoldBannerAlertExample> {
  bool _shown = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      child: Scaffold(
        appBar: const AppBar(title: Text('Payments')),
        banner: _shown
            ? Padding(
                padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
                child: Alert(
                  variant: AlertVariant.warning,
                  icon: const PhosphorIcon(PhosphorIconsRegular.creditCard),
                  title: const Text('Your card expires this month'),
                  description: const Text(
                    'Update it to keep your subscription.',
                  ),
                  onDismissed: () => setState(() => _shown = false),
                ),
              )
            : null,
        body: ListView(
          children: [
            ListTile(
              title: const Text('Show the reminder again'),
              leading: const PhosphorIcon(PhosphorIconsRegular.bell),
              onTap: () => setState(() => _shown = true),
            ),
            for (final (month, amount) in [
              ('November', '€12.00'),
              ('October', '€12.00'),
              ('September', '€12.00'),
              ('August', '€9.00'),
              ('July', '€9.00'),
              ('June', '€9.00'),
            ])
              ListTile(
                title: Text(month),
                subtitle: const Text('Pro plan'),
                trailing: Text(amount, style: theme.textTheme.small),
              ),
          ],
        ),
      ),
    );
  }
}
