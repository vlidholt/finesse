# Tag Field

A field that holds a list of tags: what is typed becomes a tag on Enter or a separator, and each tag can be removed again. It is controlled: `values` and `onChanged`.

## Default

The field grows as tags wrap. From the keyboard, Backspace and the arrow keys reach the tags.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class TagFieldBasicExample extends StatefulWidget {
  const TagFieldBasicExample({super.key});

  @override
  State<TagFieldBasicExample> createState() => _TagFieldBasicExampleState();
}

class _TagFieldBasicExampleState extends State<TagFieldBasicExample> {
  List<String> topics = ['design', 'motion'];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      // Enter or a comma turns the text into a tag; a pasted list becomes
      // that many. Backspace in the empty input marks the last tag, and
      // again removes it.
      child: TagField<String>(
        values: topics,
        placeholder: const Text('Add a topic'),
        semanticLabel: 'Topics',
        labelBuilder: (context, topic) => Text(topic),
        onChanged: (value) => setState(() => topics = value),
      ),
    );
  }
}
```

## With suggestions and a limit

`optionsBuilder` suggests tags, `parse` decides which texts are tags at all, and `maxTags` closes the input when the field is full.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class TagFieldSuggestionsExample extends StatefulWidget {
  const TagFieldSuggestionsExample({super.key});

  @override
  State<TagFieldSuggestionsExample> createState() =>
      _TagFieldSuggestionsExampleState();
}

class _TagFieldSuggestionsExampleState
    extends State<TagFieldSuggestionsExample> {
  static const skills = [
    'Accessibility',
    'Animation',
    'Dart',
    'Design systems',
    'Flutter',
    'Prototyping',
    'Typography',
  ];

  List<String> chosen = ['Flutter'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TagField<String>(
            values: chosen,
            maxTags: 4,
            semanticLabel: 'Skills',
            labelBuilder: (context, skill) => Text(skill),
            // Suggestions under the field, as an Autocomplete shows them.
            // The ones already chosen are left out.
            optionsBuilder: (value) {
              final query = value.text.trim().toLowerCase();
              if (query.isEmpty) return const [];
              return skills.where(
                (skill) => skill.toLowerCase().contains(query),
              );
            },
            // Only a known skill becomes a tag.
            parse: (text) {
              for (final skill in skills) {
                if (skill.toLowerCase() == text.toLowerCase()) return skill;
              }
              return null;
            },
            onChanged: (value) => setState(() => chosen = value),
          ),
          const Gap.sm(),
          Text('${chosen.length} of 4 skills', style: theme.textTheme.caption),
        ],
      ),
    );
  }
}
```
