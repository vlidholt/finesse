import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A card interior laid out with `FinesseColumn` spacing and separators.
class LayoutCardSectionsExample extends StatefulWidget {
  const LayoutCardSectionsExample({super.key});

  @override
  State<LayoutCardSectionsExample> createState() =>
      _LayoutCardSectionsExampleState();
}

class _LayoutCardSectionsExampleState extends State<LayoutCardSectionsExample> {
  bool email = true;
  bool push = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Card(
        title: const Text('Notifications'),
        description: const Text('Choose what you want to be notified about'),
        child: FinesseColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Checkbox(
              value: email,
              onChanged: (v) => setState(() => email = v),
              label: const Text('Email'),
            ),
            Checkbox(
              value: push,
              onChanged: (v) => setState(() => push = v),
              label: const Text('Push'),
            ),
            const Divider.horizontal(
              margin: EdgeInsets.symmetric(vertical: 4),
            ),
            Button(onPressed: () {}, child: const Text('Save preferences')),
          ],
        ),
      ),
    );
  }
}
