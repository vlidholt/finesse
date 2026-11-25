import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The two levels over a photograph. `regular` lets the backdrop through;
/// `strong` is the one for a surface that carries text.
class GlassLevelsExample extends StatelessWidget {
  const GlassLevelsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget panel(GlassLevel level, String title, String caption) {
      return Glass(
        level: level,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.large),
            Text(caption, style: theme.textTheme.muted),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: theme.radii.xl2,
      child: SizedBox(
        width: 440,
        child: Stack(
          children: [
            // Something busy behind the glass, so the blur has work to do.
            Positioned.fill(
              child: Image.asset(
                'assets/images/photo_alpine_lake.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 96, 16, 16),
              child: FinesseColumn(
                gap: GapSize.md,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  panel(
                    GlassLevel.regular,
                    'Regular',
                    'A light tint. The photo stays visible.',
                  ),
                  panel(
                    GlassLevel.strong,
                    'Strong',
                    'A heavy tint, for longer text.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
