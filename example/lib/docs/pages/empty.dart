import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/empty/empty_basic.dart';
import 'package:example/docs/examples/empty/empty_states.dart';

final emptyDoc = ComponentDoc(
  slug: 'empty',
  title: 'Empty',
  description:
      'A placeholder for an empty state: icon, title, description, and '
      'actions.',
  examples: [
    ComponentExample(
      id: 'empty_basic',
      title: 'Default',
      builder: (_) => const EmptyBasicExample(),
    ),
    ComponentExample(
      id: 'empty_states',
      title: 'Loading, failed and empty',
      description:
          'The three states a page shows in place of its content are each '
          'an `Empty`: a `Spinner` as the icon while it loads, a way to try '
          'again when it failed, a way forward when there is nothing yet.',
      builder: (_) => const EmptyStatesExample(),
    ),
  ],
);
