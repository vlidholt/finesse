import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/checkbox/checkbox_basic.dart';
import 'package:example/docs/examples/checkbox/checkbox_disabled.dart';
import 'package:example/docs/examples/checkbox/checkbox_tristate.dart';

final checkboxDoc = ComponentDoc(
  slug: 'checkbox',
  title: 'Checkbox',
  description:
      'A control that allows the user to toggle between checked and not '
      'checked.',
  examples: [
    ComponentExample(
      id: 'checkbox_basic',
      title: 'With label',
      builder: (_) => const CheckboxBasicExample(),
    ),
    ComponentExample(
      id: 'checkbox_disabled',
      title: 'Disabled',
      builder: (_) => const CheckboxDisabledExample(),
    ),
    ComponentExample(
      id: 'checkbox_tristate',
      title: 'Mixed',
      description:
          '`tristate` allows a null value, the mixed state, drawn as a '
          'dash and announced as "mixed". `onChanged` still reports a '
          'bool: a tap on a mixed box checks it.',
      builder: (_) => const CheckboxTristateExample(),
    ),
  ],
);
