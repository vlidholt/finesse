import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A controlled group: the parent holds the selection in `value`, so a
/// button outside the group can change it. Each radio has a description.
class RadioGroupControlledExample extends StatefulWidget {
  const RadioGroupControlledExample({super.key});

  @override
  State<RadioGroupControlledExample> createState() =>
      _RadioGroupControlledExampleState();
}

class _RadioGroupControlledExampleState
    extends State<RadioGroupControlledExample> {
  static const _plans = {
    'Free': 'One board, three collaborators.',
    'Team': 'Unlimited boards and guests.',
    'Company': 'Single sign-on and an audit log.',
  };

  String plan = 'Team';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FinesseColumn(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      gap: GapSize.md,
      children: [
        FinesseRadioGroup<String>(
          value: plan,
          onChanged: (value) => setState(() => plan = value),
          spacing: theme.layoutTheme.gap(GapSize.md),
          items: [
            for (final MapEntry(key: name, value: detail) in _plans.entries)
              Radio(
                value: name,
                label: Text(name),
                description: Text(detail),
              ),
          ],
        ),
        Button.link(
          onPressed: () => setState(() => plan = 'Free'),
          child: const Text('Back to Free'),
        ),
      ],
    );
  }
}
