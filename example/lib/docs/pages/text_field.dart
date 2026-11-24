import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/text_field/text_field_basic.dart';
import 'package:example/docs/examples/text_field/text_field_disabled.dart';
import 'package:example/docs/examples/text_field/text_field_password.dart';

final textFieldDoc = ComponentDoc(
  slug: 'text_field',
  title: 'Text Field',
  description:
      'A single-line text field. `TextField` is the control; '
      '`TextFormField` is the same field inside a `FinesseForm`.',
  examples: [
    ComponentExample(
      id: 'text_field_basic',
      title: 'Default',
      builder: (_) => const TextFieldBasicExample(),
    ),
    ComponentExample(
      id: 'text_field_password',
      title: 'Password',
      description: 'Leading and trailing slots hold icons and actions.',
      builder: (_) => const TextFieldPasswordExample(),
    ),
    ComponentExample(
      id: 'text_field_disabled',
      title: 'Disabled',
      builder: (_) => const TextFieldDisabledExample(),
    ),
  ],
);
