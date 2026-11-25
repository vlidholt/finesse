import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/tag_field/tag_field_basic.dart';
import 'package:example/docs/examples/tag_field/tag_field_suggestions.dart';

final tagFieldDoc = ComponentDoc(
  slug: 'tag_field',
  title: 'Tag Field',
  description:
      'A field that holds a list of tags: what is typed becomes a tag on '
      'Enter or a separator, and each tag can be removed again. It is '
      'controlled: `values` and `onChanged`.',
  examples: [
    ComponentExample(
      id: 'tag_field_basic',
      title: 'Default',
      description:
          'The field grows as tags wrap. From the keyboard, Backspace and '
          'the arrow keys reach the tags.',
      builder: (_) => const TagFieldBasicExample(),
    ),
    ComponentExample(
      id: 'tag_field_suggestions',
      title: 'With suggestions and a limit',
      description:
          '`optionsBuilder` suggests tags, `parse` decides which texts are '
          'tags at all, and `maxTags` closes the input when the field is '
          'full.',
      minPreviewHeight: 320,
      builder: (_) => const TagFieldSuggestionsExample(),
    ),
  ],
);
