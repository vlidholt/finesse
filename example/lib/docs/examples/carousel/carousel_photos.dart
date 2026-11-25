import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A post's photographs: one at a time, swiped with a finger, stepped with
/// the arrow buttons that appear under a mouse, or with the arrow keys once
/// the carousel has the focus. The dots lie over the photograph.
class CarouselPhotosExample extends StatelessWidget {
  const CarouselPhotosExample({super.key});

  static const _photos = [
    ('assets/strand/photo_alpine_lake.jpg', 'A lake between mountains'),
    ('assets/strand/photo_workshop_team.jpg', 'A team at a workshop'),
    ('assets/strand/photo_conference_stage.jpg', 'A conference stage'),
    ('assets/strand/story_mountain_meadow.jpg', 'A mountain meadow'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Carousel(
        height: 240,
        loop: true,
        showIndicator: true,
        borderRadius: theme.radii.xl,
        semanticLabel: 'Photos',
        children: [
          for (final (asset, alt) in _photos)
            Image.asset(asset, fit: BoxFit.cover, semanticLabel: alt),
        ],
      ),
    );
  }
}
