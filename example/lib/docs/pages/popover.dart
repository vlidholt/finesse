import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/popover/popover_arrow.dart';
import 'package:example/docs/examples/popover/popover_basic.dart';

final popoverDoc = ComponentDoc(
  slug: 'popover',
  title: 'Popover',
  description: 'Displays rich content in a portal, triggered by a button.',
  examples: [
    ComponentExample(
      id: 'popover_basic',
      title: 'Default',
      builder: (_) => const PopoverBasicExample(),
    ),
    ComponentExample(
      id: 'popover_arrow',
      title: 'With an arrow',
      description:
          'showArrow adds a tip that points at the trigger. It rides the '
          'edge that faces the trigger — the anchor decides which — and '
          'keeps pointing at it when the popover is pushed in from the edge '
          'of the window.',
      builder: (_) => const PopoverArrowExample(),
      minPreviewHeight: 300,
    ),
  ],
);
