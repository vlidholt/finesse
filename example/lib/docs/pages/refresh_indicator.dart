import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/refresh_indicator/refresh_indicator_basic.dart';

final refreshIndicatorDoc = ComponentDoc(
  slug: 'refresh_indicator',
  title: 'Refresh Indicator',
  description:
      'Pull a list down past its top to refresh it. A small circle comes '
      'down with the pull, pops when letting go will refresh, and spins '
      'until the refresh is done.',
  examples: [
    ComponentExample(
      id: 'refresh_indicator_basic',
      title: 'Pull to refresh',
      description:
          'Drag the list down with a finger or a trackpad. It follows both '
          'kinds of scroll physics: a list that stops at its top and one '
          'that bounces. A mouse wheel cannot pull, so the button in the '
          'header calls `show()` on the `RefreshIndicatorState`. A list '
          'that may be shorter than its viewport takes '
          '`AlwaysScrollableScrollPhysics`.',
      minPreviewHeight: 440,
      builder: (_) => const RefreshIndicatorBasicExample(),
    ),
  ],
);
