# Glass

A frosted surface: a translucent tint over a blurred, saturated backdrop, with a hairline border. Blur, saturation and opacity come from the style, so `Glass` follows the theme and its brightness.

## Regular and strong

`level` picks how much of the backdrop shows through. Use `GlassLevel.strong` for a surface that carries text.

```dart
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
                'assets/strand/photo_alpine_lake.jpg',
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
```

## A dark scrim

`color` replaces the tint and is used at its own alpha. A dark scrim keeps white labels readable over a photo in both light and dark themes.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Labels over a photo. `color` replaces the theme's tint with a dark scrim,
/// used at its own alpha, so white text stays readable in light and dark.
class GlassScrimExample extends StatelessWidget {
  const GlassScrimExample({super.key});

  static const _scrim = Color(0x52090909);
  static const _onScrim = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget label({required IconData icon, required String text}) {
      return Glass(
        color: _scrim,
        borderRadius: theme.radii.full,
        // No hairline: the scrim is the whole surface.
        border: const Border.fromBorderSide(BorderSide.none),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Icon(icon, size: 16, color: _onScrim),
            Text(
              text,
              style: theme.textTheme.small.copyWith(color: _onScrim),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: theme.radii.xl2,
      child: SizedBox(
        width: 440,
        height: 260,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/strand/photo_alpine_lake.jpg',
              fit: BoxFit.cover,
            ),
            PositionedDirectional(
              top: 12,
              end: 12,
              child: label(icon: PhosphorIconsFill.images, text: '1 / 4'),
            ),
            PositionedDirectional(
              start: 12,
              bottom: 12,
              child: label(
                icon: PhosphorIconsFill.mapPin,
                text: 'Alpine lake',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Floating chrome

Scroll the list beneath the toolbar. `shadows` are painted outside the surface and never show through it. Each `Glass` is a compositing layer: a handful on screen is fine, a long list of them is not.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A toolbar floating over a list. The rows blur as they scroll beneath it,
/// and the shadow is painted outside the glass rather than through it.
class GlassToolbarExample extends StatelessWidget {
  const GlassToolbarExample({super.key});

  static const _files = [
    (PhosphorIconsRegular.filePdf, 'Research summary.pdf', '2.4 MB'),
    (PhosphorIconsRegular.image, 'Onboarding map.jpg', '840 KB'),
    (PhosphorIconsRegular.fileText, 'Interview notes.md', '12 KB'),
    (PhosphorIconsRegular.presentationChart, 'Roadmap review.key', '18 MB'),
    (PhosphorIconsRegular.table, 'Survey results.csv', '96 KB'),
    (PhosphorIconsRegular.fileZip, 'Brand assets.zip', '41 MB'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 360,
      height: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: theme.radii.xl,
      ),
      // Painted over the content, so nothing covers the frame's corners.
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: theme.radii.xl,
      ),
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
            children: [
              for (final (icon, name, size) in _files)
                ListTile(
                  leading: IconTile(icon: Icon(icon)),
                  title: Text(name),
                  subtitle: Text(size),
                ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: Glass(
                borderRadius: theme.radii.full,
                shadows: theme.style.floatingShadow,
                padding: const EdgeInsets.all(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    IconButton.ghost(
                      icon: const Icon(PhosphorIconsRegular.shareNetwork),
                      semanticLabel: 'Share',
                      onPressed: () {},
                    ),
                    IconButton.ghost(
                      icon: const Icon(PhosphorIconsRegular.downloadSimple),
                      semanticLabel: 'Download',
                      onPressed: () {},
                    ),
                    IconButton.ghost(
                      icon: const Icon(PhosphorIconsRegular.trash),
                      semanticLabel: 'Delete',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

