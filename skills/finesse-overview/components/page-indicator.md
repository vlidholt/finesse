# Page Indicator

A row of dots, one per page, with a pill on the current one: where you are in a carousel, an onboarding flow, a gallery.

## Steps of a flow

The pill glides to a new `index` on the theme's snappy spring. With `onSelected` a tap on a dot picks its page, the dots take the keyboard focus and the arrow keys step through the pages.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Dots for the steps of a flow. The pill glides to the new page; a tap on
/// a dot, or the arrow keys while the dots have the focus, picks a page.
class PageIndicatorBasicExample extends StatefulWidget {
  const PageIndicatorBasicExample({super.key});

  @override
  State<PageIndicatorBasicExample> createState() =>
      _PageIndicatorBasicExampleState();
}

class _PageIndicatorBasicExampleState extends State<PageIndicatorBasicExample> {
  static const _steps = ['Welcome', 'Your profile', 'Interests', 'All set'];
  int step = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FinesseColumn(
      gap: GapSize.lg,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_steps[step], style: theme.textTheme.h4),
        PageIndicator(
          count: _steps.length,
          index: step,
          onSelected: (index) => setState(() => step = index),
        ),
        FinesseRow(
          gap: GapSize.sm,
          mainAxisSize: MainAxisSize.min,
          children: [
            Button.outline(
              enabled: step > 0,
              onPressed: () => setState(() => step--),
              child: const Text('Back'),
            ),
            Button(
              enabled: step < _steps.length - 1,
              onPressed: () => setState(() => step++),
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }
}
```

## Following a page view

With the `PageController` of the view it describes, the pill follows a drag as it happens. More pages than `maxVisible` show as a window of dots, smaller at an edge that has more beyond it. `PageIndicatorVariant.overlay` is for dots over a photograph.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Given the controller of the page view it describes, the pill follows
/// the pages under the finger. Twelve pages are more than the seven dots
/// shown at once: the dots become a window, smaller at an edge that has
/// more beyond it. Over a photograph the overlay variant puts white dots on
/// a dark capsule.
class PageIndicatorPageViewExample extends StatefulWidget {
  const PageIndicatorPageViewExample({super.key});

  @override
  State<PageIndicatorPageViewExample> createState() =>
      _PageIndicatorPageViewExampleState();
}

class _PageIndicatorPageViewExampleState
    extends State<PageIndicatorPageViewExample> {
  static const _count = 12;
  final controller = PageController();
  int page = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _show(int index) {
    final spring = Motion.of(context).smooth;
    if (spring.isInstant) return controller.jumpToPage(index);
    controller.animateToPage(
      index,
      duration: spring.settleDuration,
      curve: spring.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: FinesseColumn(
        gap: GapSize.md,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: theme.radii.xl,
            child: SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: controller,
                    itemCount: _count,
                    onPageChanged: (index) => setState(() => page = index),
                    itemBuilder: (context, index) => Image.asset(
                      index.isEven
                          ? 'assets/strand/photo_alpine_lake.jpg'
                          : 'assets/strand/photo_conference_stage.jpg',
                      fit: BoxFit.cover,
                      semanticLabel: 'Photograph ${index + 1}',
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: theme.layoutTheme.gap(GapSize.sm),
                    child: Center(
                      child: PageIndicator(
                        count: _count,
                        index: page,
                        controller: controller,
                        variant: PageIndicatorVariant.overlay,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          PageIndicator(
            count: _count,
            index: page,
            controller: controller,
            onSelected: _show,
          ),
        ],
      ),
    );
  }
}
```

