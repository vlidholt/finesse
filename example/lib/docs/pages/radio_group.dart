import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/radio_group/radio_group_basic.dart';
import 'package:example/docs/examples/radio_group/radio_group_controlled.dart';

final radioGroupDoc = ComponentDoc(
  slug: 'radio_group',
  title: 'Radio Group',
  description:
      'A set of checkable buttons where only one can be checked at a time.',
  examples: [
    ComponentExample(
      id: 'radio_group_basic',
      title: 'Default',
      builder: (_) => const RadioGroupBasicExample(),
    ),
    ComponentExample(
      id: 'radio_group_controlled',
      title: 'Controlled, with descriptions',
      description:
          'Give `value` and `onChanged` to hold the selection yourself, '
          'or `initialValue` to let the group keep it. '
          '`UnaRadioGroup.maybeOf` lets a widget of your own act as '
          'an option.',
      builder: (_) => const RadioGroupControlledExample(),
    ),
  ],
);
