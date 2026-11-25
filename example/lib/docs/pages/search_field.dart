import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/search_field/search_field_basic.dart';
import 'package:example/docs/examples/search_field/search_field_cancel.dart';
import 'package:example/docs/examples/search_field/search_field_loading.dart';
import 'package:example/docs/examples/search_field/search_field_shortcut.dart';

final searchFieldDoc = ComponentDoc(
  slug: 'search_field',
  title: 'Search Field',
  description:
      'A text field for a search: a magnifier, a clear button while it has '
      'text and the keyboard\'s search action, at the metrics of '
      '`TextField`. For suggestions under the field see `Autocomplete`; '
      'for a full-screen search, `showSearch`.',
  examples: [
    ComponentExample(
      id: 'search_field_basic',
      title: 'Default',
      description:
          '`onChanged` reports the query as it is typed; `onSubmitted` the '
          'keyboard\'s search key. Escape clears a field that has text.',
      builder: (_) => const SearchFieldBasicExample(),
    ),
    ComponentExample(
      id: 'search_field_shortcut',
      title: 'With a shortcut hint',
      description:
          '`trailing` takes a hint or an action. '
          '`SearchField.shortcutLabel` names the platform\'s search chord.',
      builder: (_) => const SearchFieldShortcutExample(),
    ),
    ComponentExample(
      id: 'search_field_loading',
      title: 'Loading',
      builder: (_) => const SearchFieldLoadingExample(),
    ),
    ComponentExample(
      id: 'search_field_cancel',
      title: 'With Cancel',
      description:
          '`showCancel` is how a phone\'s search bar gives the screen back.',
      builder: (_) => const SearchFieldCancelExample(),
    ),
  ],
);
