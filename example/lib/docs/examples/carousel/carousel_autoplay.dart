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
        padding: EdgeInsets.zero,
        columnCrossAxisAlignment: CrossAxisAlignment.stretch,
        rowMainAxisSize: MainAxisSize.max,
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
