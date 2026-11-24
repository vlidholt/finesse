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
