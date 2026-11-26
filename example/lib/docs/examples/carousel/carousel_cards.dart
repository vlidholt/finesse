import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
      child: UnaColumn(
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
