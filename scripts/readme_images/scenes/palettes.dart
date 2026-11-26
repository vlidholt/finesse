import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

import '../frames.dart';
import '../harness.dart';
import 'common.dart';

/// The size of the palette grid.
const palettesSize = Size(2040, 680);

/// The six colour schemes, light over dark.
class PalettesScene extends StatelessWidget {
  /// Creates the grid.
  const PalettesScene({super.key});

  @override
  Widget build(BuildContext context) {
    return _Grid(
      columns: [
        for (final scheme in ColorSchemes.values)
          (
            scheme.label,
            imageTheme(colorScheme: scheme.light),
            imageTheme(
              colorScheme: scheme.dark,
              brightness: Brightness.dark,
            ),
          ),
      ],
      sample: const _PaletteSample(),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.sample});

  final List<(String, ThemeData, ThemeData)> columns;
  final Widget sample;

  @override
  Widget build(BuildContext context) {
    Widget tile(ThemeData theme) => DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          color: theme.colorScheme.foreground.withValues(alpha: .08),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Panel(
          theme: theme,
          child: Padding(padding: const EdgeInsets.all(16), child: sample),
        ),
      ),
    );
    return ColoredBox(
      color: const Color(0xFFF3F5F5),
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, (name, light, dark)) in columns.indexed) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SceneLabel(name),
                    const SizedBox(height: 12),
                    tile(light),
                    const SizedBox(height: 16),
                    tile(dark),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaletteSample extends StatelessWidget {
  const _PaletteSample();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      title: const Text('Upgrade to Pro'),
      description: const Text('Unlimited projects and history.'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('6 of 10 projects', style: theme.textTheme.muted),
              const Spacer(),
              const Badge.secondary(child: Text('Free')),
            ],
          ),
          const Gap.sm(),
          const ProgressBar(value: .6),
          const Gap.lg(),
          Row(
            children: [
              const PersonAvatar(1, size: 32),
              const Gap.sm(),
              Expanded(
                child: Text(people[1].name, style: theme.textTheme.small),
              ),
              Switch(value: true, onChanged: (_) {}),
            ],
          ),
          const Gap.lg(),
          Row(
            children: [
              Expanded(
                child: Button.secondary(
                  onPressed: () {},
                  child: const Text('Later'),
                ),
              ),
              const Gap.sm(),
              Expanded(
                child: Button(onPressed: () {}, child: const Text('Upgrade')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
