import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A page inside a stand-in window. The content takes the theme's page
/// margins, stops growing at `maxWidth` and is centred beyond it.
class PageContainerBasicExample extends StatelessWidget {
  const PageContainerBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 640,
      height: 340,
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
      child: PageContainer(
        scrollable: true,
        // The theme's page width is 1280; narrowed so the cap shows here.
        maxWidth: 440,
        child: UnaColumn(
          gap: GapSize.lg,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Jobs for you', style: theme.textTheme.h4),
            for (final role in const [
              'Senior product designer',
              'Design systems lead',
              'UX researcher',
              'Content designer',
            ])
              Card(
                title: Text(role),
                description: const Text('Copenhagen, hybrid'),
              ),
          ],
        ),
      ),
    );
  }
}
