import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/select/select_basic.dart';
import 'package:example/docs/examples/select/select_multiple.dart';
import 'package:example/docs/examples/select/select_search.dart';

final selectDoc = ComponentDoc(
  slug: 'select',
  title: 'Select',
  description:
      'Displays a list of options for the user to pick from, triggered by a '
      'button. Give `value` to hold the choice yourself or `initialValue` '
      'to let the select keep it; `Select.multiple` holds `values`. The '
      'searchable and multiple variants open a bottom sheet on a phone. '
      '`SelectFormField` and `SelectMultipleFormField` put a select in a '
      'form.',
  examples: [
    ComponentExample(
      id: 'select_basic',
      title: 'Default',
      description:
          'A `SelectOption` with a `label` needs no child, and the trigger '
          'shows that label for the chosen value. '
          '`selectedOptionBuilder` builds something else there.',
      builder: (_) => const SelectBasicExample(),
    ),
    ComponentExample(
      id: 'select_search',
      title: 'With search',
      description:
          'Filter a long list of Dart frameworks and tools — Serverpod, '
          'Relic, Flutter, and more.',
      builder: (_) => const SelectSearchExample(),
    ),
    ComponentExample(
      id: 'select_multiple',
      title: 'Multiple, in a sheet',
      description:
          '`Select.multipleWithSearch` with `values` and `onChanged`. '
          '`PickerPresentation.auto`, the default, opens the sheet on a '
          'phone and a popover on a desktop; a plain single select stays '
          'a popover everywhere.',
      builder: (_) => const SelectMultipleExample(),
    ),
  ],
);
