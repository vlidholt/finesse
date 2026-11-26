import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

enum Density { compact, comfortable, spacious }

/// Picks one value of a few. The thumb slides to the chosen segment; on a
/// touch screen a finger dragged along the strip takes it along.
class SegmentedControlBasicExample extends StatefulWidget {
  const SegmentedControlBasicExample({super.key});

  @override
  State<SegmentedControlBasicExample> createState() =>
      _SegmentedControlBasicExampleState();
}

class _SegmentedControlBasicExampleState
    extends State<SegmentedControlBasicExample> {
  Density density = Density.comfortable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.layoutTheme.gap(GapSize.lg),
      children: [
        // The group's name, for a screen reader: the segments are its
        // radio buttons.
        Semantics(
          label: 'Density',
          container: true,
          child: SegmentedControl<Density>(
            value: density,
            onChanged: (value) => setState(() => density = value),
            segments: const [
              Segment(value: Density.compact, label: Text('Compact')),
              Segment(value: Density.comfortable, label: Text('Comfortable')),
              Segment(value: Density.spacious, label: Text('Spacious')),
            ],
          ),
        ),
        Text('Rows are ${density.name}.', style: theme.textTheme.muted),
      ],
    );
  }
}
