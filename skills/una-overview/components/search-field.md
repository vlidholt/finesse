# Search Field

A text field for a search: a magnifier, a clear button while it has text and the keyboard's search action, at the metrics of `TextField`. For suggestions under the field see `Autocomplete`; for a full-screen search, `showSearch`.

## Default

`onChanged` reports the query as it is typed; `onSubmitted` the keyboard's search key. Escape clears a field that has text.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class SearchFieldBasicExample extends StatefulWidget {
  const SearchFieldBasicExample({super.key});

  @override
  State<SearchFieldBasicExample> createState() =>
      _SearchFieldBasicExampleState();
}

class _SearchFieldBasicExampleState extends State<SearchFieldBasicExample> {
  static const fruits = ['Apple', 'Apricot', 'Banana', 'Cherry', 'Peach'];

  String query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matches = [
      for (final fruit in fruits)
        if (fruit.toLowerCase().contains(query.toLowerCase())) fruit,
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The clear button and Escape both empty the field.
          SearchField(
            placeholder: const Text('Search fruit'),
            onChanged: (value) => setState(() => query = value),
          ),
          const Gap.sm(),
          Text(
            matches.isEmpty ? 'No fruit found' : matches.join(', '),
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}
```

## With a shortcut hint

`trailing` takes a hint or an action. `SearchField.shortcutLabel` names the platform's search chord.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class SearchFieldShortcutExample extends StatelessWidget {
  const SearchFieldShortcutExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: SearchField(
        // ⌘K on an Apple platform, Ctrl K elsewhere. Listen for the chord
        // with `SearchField.isSearchShortcut` where the app wants it.
        trailing: Kbd(SearchField.shortcutLabel),
      ),
    );
  }
}
```

## Loading

```dart
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class SearchFieldLoadingExample extends StatefulWidget {
  const SearchFieldLoadingExample({super.key});

  @override
  State<SearchFieldLoadingExample> createState() =>
      _SearchFieldLoadingExampleState();
}

class _SearchFieldLoadingExampleState extends State<SearchFieldLoadingExample> {
  Timer? request;
  String answer = 'Type to search';

  void search(String query) {
    request?.cancel();
    if (query.isEmpty) {
      setState(() {
        request = null;
        answer = 'Type to search';
      });
      return;
    }
    // A stand-in for a request to a server.
    setState(() {
      request = Timer(const Duration(milliseconds: 900), () {
        setState(() {
          request = null;
          answer = '3 results for "$query"';
        });
      });
    });
  }

  @override
  void dispose() {
    request?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchField(
            // The magnifier is a spinner while results are on their way.
            loading: request != null,
            onChanged: search,
          ),
          const Gap.sm(),
          Text(answer, style: theme.textTheme.muted),
        ],
      ),
    );
  }
}
```

## With Cancel

`showCancel` is how a phone's search bar gives the screen back.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class SearchFieldCancelExample extends StatelessWidget {
  const SearchFieldCancelExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      // The phone pattern: focus the field and "Cancel" slides in beside
      // it. It clears the field and puts the keyboard away.
      child: const SearchField(
        placeholder: Text('Search messages'),
        showCancel: true,
      ),
    );
  }
}
```
