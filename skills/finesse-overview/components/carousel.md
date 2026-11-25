# Carousel

Pages to swipe through, one or a few at a time: a post's photographs, a row of cards, an onboarding flow.

## Photographs

One page at a time, looping, with the carousel's own indicator over the photograph. Drag with a finger or a trackpad; where a mouse is connected the previous and next buttons fade in under the pointer. With the focus on the carousel the arrow keys, Page Up and Page Down, Home and End turn the pages.

```dart
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
```

## Cards with the next one showing

`viewportFraction` below 1 lets the neighbours show, a themed gap apart. A `CarouselController` moves the carousel from outside and reports each change of page, which is how the `PageIndicator` under it follows along and takes taps.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A row of cards with the next one peeking in: `viewportFraction` below 1
/// shows the neighbours, and a controller lets a page indicator beside the
/// carousel follow it and drive it.
class CarouselCardsExample extends StatefulWidget {
  const CarouselCardsExample({super.key});

  @override
  State<CarouselCardsExample> createState() => _CarouselCardsExampleState();
}

class _CarouselCardsExampleState extends State<CarouselCardsExample> {
  final controller = CarouselController();

  static const _jobs = [
    ('Staff Product Designer', 'Birchline · Copenhagen'),
    ('Design Systems Lead', 'Lumen Labs · Remote'),
    ('Senior UX Researcher', 'Kestrel Health · Berlin'),
    ('Head of Design', 'Tidewater · Lisbon'),
    ('Interaction Designer', 'Orbital · Stockholm'),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: FinesseColumn(
        gap: GapSize.md,
        mainAxisSize: MainAxisSize.min,
        children: [
          Carousel(
            controller: controller,
            height: 176,
            viewportFraction: .78,
            semanticLabel: 'Recommended jobs',
            children: [
              for (final (title, company) in _jobs)
                Card(
                  title: Text(title, maxLines: 1),
                  description: Text(company, maxLines: 1),
                  footer: Button.outline(
                    size: ButtonSize.sm,
                    onPressed: () {},
                    child: const Text('View'),
                  ),
                ),
            ],
          ),
          // The controller reports each change of page.
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) => PageIndicator(
              count: _jobs.length,
              index: controller.page,
              onSelected: controller.animateToPage,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Moving on by itself

`autoPlay` turns the page every so often. It waits while the pointer is over the carousel, while the focus is in it and while it is touched, and does not run under reduced motion.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A carousel that moves on by itself. It waits while the pointer is over
/// it, while the focus is in it and while it is touched, and stands still
/// when the platform asks for reduced motion.
class CarouselAutoplayExample extends StatefulWidget {
  const CarouselAutoplayExample({super.key});

  @override
  State<CarouselAutoplayExample> createState() =>
      _CarouselAutoplayExampleState();
}

class _CarouselAutoplayExampleState extends State<CarouselAutoplayExample> {
  static const _quotes = [
    ('“Strand is where our team finds its next hire.”', 'Mei Tanaka'),
    ('“The only feed I read to the end.”', 'Omar Rahimi'),
    ('“It feels like it was made by people who listen.”', 'Claire Dubois'),
  ];

  final controller = CarouselController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gap = theme.layoutTheme.gap(GapSize.xl);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        style: CardTheme(
          padding: EdgeInsets.zero,
          columnCrossAxisAlignment: CrossAxisAlignment.stretch,
          rowMainAxisSize: MainAxisSize.max,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Carousel(
              controller: controller,
              height: 132,
              loop: true,
              autoPlay: const Duration(seconds: 4),
              semanticLabel: 'What people say',
              children: [
                for (final (quote, name) in _quotes)
                  Padding(
                    padding: EdgeInsets.fromLTRB(gap, gap, gap, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quote,
                          style: theme.textTheme.large.copyWith(
                            color: theme.colorScheme.foreground,
                          ),
                        ),
                        const Gap.sm(),
                        Text(name, style: theme.textTheme.muted),
                      ],
                    ),
                  ),
              ],
            ),
            // Dots on the card itself are the plain kind; the overlay kind
            // is for photographs.
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) => PageIndicator(
                count: _quotes.length,
                index: controller.page,
                onSelected: controller.animateToPage,
              ),
            ),
            const Gap.md(),
          ],
        ),
      ),
    );
  }
}
```
