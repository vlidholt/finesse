import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class AlertDismissibleExample extends StatefulWidget {
  const AlertDismissibleExample({super.key});

  @override
  State<AlertDismissibleExample> createState() =>
      _AlertDismissibleExampleState();
}

class _AlertDismissibleExampleState extends State<AlertDismissibleExample> {
  var _shown = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: UnaColumn(
        gap: GapSize.md,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_shown)
            Alert(
              variant: AlertVariant.info,
              title: const Text('Scheduled maintenance'),
              description: const Text(
                'Demo will be read-only on Saturday from 02:00 to 03:00.',
              ),
              // Called once the alert has folded away.
              onDismissed: () => setState(() => _shown = false),
            )
          else
            Button.outline(
              onPressed: () => setState(() => _shown = true),
              child: const Text('Show it again'),
            ),
        ],
      ),
    );
  }
}
