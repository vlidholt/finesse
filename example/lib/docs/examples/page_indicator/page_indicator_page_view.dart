import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
      child: UnaColumn(
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
                          ? 'assets/images/photo_alpine_lake.jpg'
                          : 'assets/images/photo_conference_stage.jpg',
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
