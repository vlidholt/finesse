import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// With `expand` the segments share the width, as they do across a phone.
/// A segment can be disabled on its own, and the whole control with
/// `enabled: false`.
class SegmentedControlExpandedExample extends StatefulWidget {
  const SegmentedControlExpandedExample({super.key});

  @override
  State<SegmentedControlExpandedExample> createState() =>
      _SegmentedControlExpandedExampleState();
}

class _SegmentedControlExpandedExampleState
    extends State<SegmentedControlExpandedExample> {
  String plan = 'monthly';
  bool locked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: theme.layoutTheme.gap(GapSize.lg),
        children: [
          Semantics(
            label: 'Billing period',
            container: true,
            child: SegmentedControl<String>(
              expand: true,
              enabled: !locked,
              value: plan,
              onChanged: (value) => setState(() => plan = value),
              segments: const [
                Segment(value: 'monthly', label: Text('Monthly')),
                Segment(value: 'yearly', label: Text('Yearly')),
                // Not on offer yet.
                Segment(
                  value: 'lifetime',
                  label: Text('Lifetime'),
                  enabled: false,
                ),
              ],
            ),
          ),
          Switch(
            value: locked,
            onChanged: (value) => setState(() => locked = value),
            label: const Text('Lock the choice'),
          ),
        ],
      ),
    );
  }
}
