import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/page_indicator/page_indicator_basic.dart';
import 'package:example/docs/examples/page_indicator/page_indicator_page_view.dart';

final pageIndicatorDoc = ComponentDoc(
  slug: 'page_indicator',
  title: 'Page Indicator',
  description:
      'A row of dots, one per page, with a pill on the current one: where '
      'you are in a carousel, an onboarding flow, a gallery.',
  examples: [
    ComponentExample(
      id: 'page_indicator_basic',
      title: 'Steps of a flow',
      description:
          'The pill glides to a new `index` on the theme\'s snappy spring. '
          'With `onSelected` a tap on a dot picks its page, the dots take '
          'the keyboard focus and the arrow keys step through the pages.',
      minPreviewHeight: 220,
      builder: (_) => const PageIndicatorBasicExample(),
    ),
    ComponentExample(
      id: 'page_indicator_page_view',
      title: 'Following a page view',
      description:
          'With the `PageController` of the view it describes, the pill '
          'follows a drag as it happens. More pages than `maxVisible` show '
          'as a window of dots, smaller at an edge that has more beyond '
          'it. `PageIndicatorVariant.overlay` is for dots over a '
          'photograph.',
      minPreviewHeight: 300,
      builder: (_) => const PageIndicatorPageViewExample(),
    ),
  ],
);
