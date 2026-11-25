import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/autocomplete/autocomplete_async.dart';
import 'package:example/docs/examples/autocomplete/autocomplete_basic.dart';
import 'package:example/docs/examples/autocomplete/autocomplete_custom.dart';

final autocompleteDoc = ComponentDoc(
  slug: 'autocomplete',
  title: 'Autocomplete',
  description:
      'A text field that suggests completions under itself as the user '
      'types. The text stays free; where the value has to be one of a '
      'list, use `Select.withSearch`. The focus never leaves the field: '
      'arrow keys move a highlight, Enter takes it, Escape closes the list.',
  examples: [
    ComponentExample(
      id: 'autocomplete_basic',
      title: 'Default',
      minPreviewHeight: 320,
      builder: (_) => const AutocompleteBasicExample(),
    ),
    ComponentExample(
      id: 'autocomplete_async',
      title: 'Options from a server',
      description:
          '`optionsBuilder` may return a future. `loadingBuilder` and '
          '`emptyBuilder` fill the list meanwhile and when nothing is found.',
      minPreviewHeight: 320,
      builder: (_) => const AutocompleteAsyncExample(),
    ),
    ComponentExample(
      id: 'autocomplete_custom',
      title: 'Options of any type',
      description:
          '`displayStringForOption` and `optionBuilder` for options that '
          'are more than a string; `openOnFocus` to suggest before anything '
          'is typed.',
      minPreviewHeight: 320,
      builder: (_) => const AutocompleteCustomExample(),
    ),
  ],
);
