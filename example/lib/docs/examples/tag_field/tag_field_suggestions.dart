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
