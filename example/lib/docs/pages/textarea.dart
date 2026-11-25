import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/textarea/textarea_basic.dart';
import 'package:example/docs/examples/textarea/textarea_counter.dart';

final textareaDoc = ComponentDoc(
  slug: 'textarea',
  title: 'Textarea',
  description: 'A multi-line text input, optionally user-resizable.',
  examples: [
    ComponentExample(
      id: 'textarea_basic',
      title: 'Default',
      builder: (_) => const TextareaBasicExample(),
    ),
    ComponentExample(
      id: 'textarea_counter',
      title: 'Character count',
      description:
          '`showCounter` counts what is typed against `maxLength`. On '
          'iOS '
          'and Android a textarea has the same selection handles, toolbar '
          'and magnifier as a text field.',
      builder: (_) => const TextareaCounterExample(),
    ),
  ],
);
