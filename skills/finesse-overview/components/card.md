# Card

Displays a card with title, description, content, and footer.

## With a form

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

const _frameworks = {
  'next': 'Next.js',
  'react': 'React',
  'astro': 'Astro',
  'nuxt': 'Nuxt.js',
};

class CardProjectExample extends StatelessWidget {
  const CardProjectExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      style: CardTheme(width: 350),
      title: const Text('Create project'),
      description: const Text('Deploy your new project in one-click.'),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Button.outline(
            onPressed: () {},
            child: const Text('Cancel'),
          ),
          Button(
            onPressed: () {},
            child: const Text('Deploy'),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Name'),
          const SizedBox(height: 6),
          const TextField(placeholder: Text('Name of your project')),
          const SizedBox(height: 16),
          const Text('Framework'),
          const SizedBox(height: 6),
          Select<String>(
            placeholder: const Text('Select'),
            options: [
              for (final entry in _frameworks.entries)
                SelectOption(value: entry.key, child: Text(entry.value)),
            ],
            selectedOptionBuilder: (context, value) =>
                Text(_frameworks[value]!),
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
```
