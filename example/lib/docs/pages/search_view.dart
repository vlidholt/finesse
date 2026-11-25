import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/search_view/search_view_basic.dart';

final searchViewDoc = ComponentDoc(
  slug: 'search_view',
  title: 'Search View',
  description:
      '`showSearch` opens a search and returns what was chosen: a page with '
      'a back button and a focused field on a phone, a palette on the '
      'command dialog\'s surface on a desktop. The builder is called with '
      'the query once typing has paused. For a fixed set of actions '
      'filtered in memory, use `Command`.',
  examples: [
    ComponentExample(
      id: 'search_view_basic',
      title: 'Default',
      description:
          'The arrow keys walk from the field into the results, Enter takes '
          'one, and Escape clears the query and then closes the view.',
      builder: (_) => const SearchViewBasicExample(),
    ),
  ],
);
