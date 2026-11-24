import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/text_field/text_field_basic.dart';
import 'package:example/docs/examples/text_field/text_field_disabled.dart';
import 'package:example/docs/examples/text_field/text_field_password.dart';

final inputDoc = ComponentDoc(
  slug: 'input',
  title: 'Input',
  description: 'Displays a form input field.',
  examples: [
    ComponentExample(
      id: 'input_basic',
      title: 'Default',
      builder: (_) => const InputBasicExample(),
    ),
    ComponentExample(
      id: 'input_password',
      title: 'Password',
      description: 'Leading and trailing slots hold icons and actions.',
      builder: (_) => const InputPasswordExample(),
    ),
    ComponentExample(
      id: 'input_disabled',
      title: 'Disabled',
      builder: (_) => const InputDisabledExample(),
    ),
  ],
);
