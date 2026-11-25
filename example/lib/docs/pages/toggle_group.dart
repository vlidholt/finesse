import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/toggle_group/toggle_group_basic.dart';
import 'package:example/docs/examples/toggle_group/toggle_group_multiple.dart';
import 'package:example/docs/examples/toggle_group/toggle_group_outline.dart';

final toggleGroupDoc = ComponentDoc(
  slug: 'toggle_group',
  title: 'Toggle Group',
  description:
      'A set of two-state buttons that can be toggled on or off. '
      '`ToggleGroup` holds one value and `ToggleGroup.multiple` a set. The '
      'group is controlled: it shows `value` (or `values`) and reports a '
      'tap through `onChanged` (or `onValuesChanged`); `initialValue` (or '
      '`initialValues`) instead makes a group that keeps its own '
      'selection, and with no callback it is disabled. With `gap: 0` the '
      'items are joined into one bar, as in a `ButtonGroup`, and '
      '`ToggleGroupFormField` and `ToggleGroupMultipleFormField` put a '
      'group in a `FinesseForm`.',
  examples: [
    ComponentExample(
      id: 'toggle_group_basic',
      title: 'Single',
      description:
          'Selecting one value clears the others; `allowDeselection: '
          'false` keeps the last one selected.',
      builder: (_) => const ToggleGroupBasicExample(),
    ),
    ComponentExample(
      id: 'toggle_group_multiple',
      title: 'Multiple',
      builder: (_) => const ToggleGroupMultipleExample(),
    ),
    ComponentExample(
      id: 'toggle_group_outline',
      title: 'Outline',
      description: 'Every item uses the outline toggle style.',
      builder: (_) => const ToggleGroupOutlineExample(),
    ),
  ],
);
