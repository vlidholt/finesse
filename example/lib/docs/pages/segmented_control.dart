import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/segmented_control/segmented_control_basic.dart';
import 'package:example/docs/examples/segmented_control/segmented_control_expanded.dart';
import 'package:example/docs/examples/segmented_control/segmented_control_icons.dart';

final segmentedControlDoc = ComponentDoc(
  slug: 'segmented_control',
  title: 'Segmented Control',
  description:
      'Picks one of a few values that are all in view: a filled strip with '
      'a raised thumb on the chosen segment. It is controlled with `value` '
      'and `onChanged`, and announced as a group of radio buttons. To show '
      'one of several views, use `Tabs` or a `TabBar`, which look the same '
      'and mean something else; where none or several can be on, use a '
      '`ToggleGroup`.',
  examples: [
    ComponentExample(
      id: 'segmented_control_basic',
      title: 'Default',
      description:
          'The thumb is one shape that slides to the chosen segment on the '
          "theme's `Motion.snappy`. The control is one stop for the Tab "
          'key; the arrow keys, Home and End change the value. On a touch '
          'screen, drag along the strip and the thumb follows the finger.',
      minPreviewHeight: 180,
      builder: (_) => const SegmentedControlBasicExample(),
    ),
    ComponentExample(
      id: 'segmented_control_icons',
      title: 'Icons',
      description:
          'A `Segment` has a `label`, an `icon` or both. Give an icon on '
          'its own a `semanticLabel` and a `tooltip`.',
      minPreviewHeight: 220,
      builder: (_) => const SegmentedControlIconsExample(),
    ),
    ComponentExample(
      id: 'segmented_control_expanded',
      title: 'Expanded and disabled',
      description:
          'By default the control is as wide as its segments. `expand` '
          'shares the width between them, the usual arrangement on a '
          'phone. A label that does not fit its segment ends in an '
          'ellipsis.',
      minPreviewHeight: 220,
      builder: (_) => const SegmentedControlExpandedExample(),
    ),
  ],
);
