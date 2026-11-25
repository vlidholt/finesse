import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/selection_area/selection_area_basic.dart';
import 'package:example/docs/examples/selection_area/selection_area_excluded.dart';

final selectionAreaDoc = ComponentDoc(
  slug: 'selection_area',
  title: 'Selection Area',
  description:
      'Makes the text under it selectable as one selection across widgets. '
      'A mouse drags and right-clicks for Copy; a touch screen long-presses '
      'and gets the handles, the `TextSelectionToolbar` and the '
      '`TextMagnifier` that text fields use.',
  examples: [
    ComponentExample(
      id: 'selection_area_basic',
      title: 'Default',
      description:
          'Every `Text` under the area takes part. On iOS and Android the '
          'handles and the toolbar appear on a long press.',
      builder: (_) => const SelectionAreaBasicExample(),
    ),
    ComponentExample(
      id: 'selection_area_excluded',
      title: 'Excluding content',
      description:
          '`SelectionContainer.disabled` keeps a part out of the selection; '
          '`onSelectionChanged` reports what is selected.',
      builder: (_) => const SelectionAreaExcludedExample(),
    ),
  ],
);
