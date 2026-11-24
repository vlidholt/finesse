# Tabs

A set of layered sections of content displayed one at a time.

## Default

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TabsBasicExample extends StatelessWidget {
  const TabsBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    // The strip hugs its tabs at the start of the width it is given, so
    // the box around the whole control is what lines it up with its panel.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Tabs<String>(
        value: 'account',
        tabs: [
          Tab(
            value: 'account',
            content: Card(
              title: const Text('Account'),
              description: const Text(
                "Make changes to your account here. Click save when you're "
                'done.',
              ),
              footer: const Button(child: Text('Save changes')),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    label: const Text('Name'),
                    initialValue: 'Ale',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    label: const Text('Username'),
                    initialValue: 'nank1ro',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            child: const Text('Account'),
          ),
          Tab(
            value: 'password',
            content: Card(
              title: const Text('Password'),
              description: const Text(
                "Change your password here. After saving, you'll be logged "
                'out.',
              ),
              footer: const Button(child: Text('Save password')),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    label: const Text('Current password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    label: const Text('New password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            child: const Text('Password'),
          ),
        ],
      ),
    );
  }
}
```

## Tabs list

With no content, only the list renders: a segmented control.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Tabs with no content render only their list: a segmented control that
/// switches something elsewhere on the page.
class TabsListExample extends StatefulWidget {
  const TabsListExample({super.key});

  @override
  State<TabsListExample> createState() => _TabsListExampleState();
}

class _TabsListExampleState extends State<TabsListExample> {
  var range = 'week';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Tabs<String>(
          value: range,
          onChanged: (value) => setState(() => range = value),
          tabs: const [
            Tab(value: 'day', child: Text('Day')),
            Tab(value: 'week', child: Text('Week')),
            Tab(value: 'month', child: Text('Month')),
          ],
        ),
        Text(
          'Showing one $range',
          style: Theme.of(context).textTheme.muted,
        ),
      ],
    );
  }
}
```

