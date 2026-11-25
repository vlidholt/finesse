import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Segments with an icon, on its own or before a label. An icon on its own
/// is named by `semanticLabel` for a screen reader and by `tooltip` for a
/// pointer.
class SegmentedControlIconsExample extends StatefulWidget {
  const SegmentedControlIconsExample({super.key});

  @override
  State<SegmentedControlIconsExample> createState() =>
      _SegmentedControlIconsExampleState();
}

class _SegmentedControlIconsExampleState
    extends State<SegmentedControlIconsExample> {
  String layout = 'list';
  ThemeMode mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.layoutTheme.gap(GapSize.lg),
      children: [
        Semantics(
          label: 'Layout',
          container: true,
          child: SegmentedControl<String>(
            value: layout,
            onChanged: (value) => setState(() => layout = value),
            segments: const [
              Segment(
                value: 'list',
                icon: PhosphorIcon(PhosphorIconsRegular.listBullets),
                semanticLabel: 'List',
                tooltip: 'List',
              ),
              Segment(
                value: 'grid',
                icon: PhosphorIcon(PhosphorIconsRegular.squaresFour),
                semanticLabel: 'Grid',
                tooltip: 'Grid',
              ),
              Segment(
                value: 'board',
                icon: PhosphorIcon(PhosphorIconsRegular.kanban),
                semanticLabel: 'Board',
                tooltip: 'Board',
              ),
            ],
          ),
        ),
        Semantics(
          label: 'Appearance',
          container: true,
          child: SegmentedControl<ThemeMode>(
            value: mode,
            onChanged: (value) => setState(() => mode = value),
            segments: const [
              Segment(
                value: ThemeMode.light,
                icon: PhosphorIcon(PhosphorIconsRegular.sun),
                label: Text('Light'),
              ),
              Segment(
                value: ThemeMode.dark,
                icon: PhosphorIcon(PhosphorIconsRegular.moon),
                label: Text('Dark'),
              ),
              Segment(
                value: ThemeMode.system,
                icon: PhosphorIcon(PhosphorIconsRegular.desktop),
                label: Text('System'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
