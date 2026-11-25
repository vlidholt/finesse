# Tabs

Sections of content shown one at a time: a `TabBar` with the selected tab's `content` under it. Controlled with `value` and `onChanged`, or by a `TabsController`. On a touch screen the content can be swiped to the next tab's, and the bar's selection follows the finger.

## Default

The segmented strip is as wide as its tabs; `expandTabs` makes them share the width, and `tabBarAlignment` places a strip that is narrower than its content. A tab that is not showing keeps its state unless `maintainState` is false.

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
              footer: Button(
                onPressed: () {},
                child: const Text('Save changes'),
              ),
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
              footer: Button(
                onPressed: () {},
                child: const Text('Save password'),
              ),
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

## Underline

`variant: TabBarVariant.underline` puts the content under a row of text tabs. The content is as tall as the tab showing; set `expandContent` to fill the height left under the bar instead. `swipeable: false` switches the swipe off.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// `Tabs` with the underline bar. The content is as tall as the tab that
/// is showing; swiped to the next tab, it goes from the one height to the
/// other.
class TabsUnderlineExample extends StatefulWidget {
  const TabsUnderlineExample({super.key});

  @override
  State<TabsUnderlineExample> createState() => _TabsUnderlineExampleState();
}

class _TabsUnderlineExampleState extends State<TabsUnderlineExample> {
  String tab = 'overview';

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Tabs<String>(
        variant: TabBarVariant.underline,
        value: tab,
        onChanged: (value) => setState(() => tab = value),
        tabs: const [
          Tab(
            value: 'overview',
            content: Card(
              title: Text('Overview'),
              description: Text(
                'Two releases this month, and the editor left beta.',
              ),
            ),
            child: Text('Overview'),
          ),
          Tab(
            value: 'activity',
            content: Card(
              title: Text('Activity'),
              description: Text(
                'Mei merged the tab bar. Jonas opened four issues. Ada '
                'reviewed the route work, twice, and asked for one more '
                'test of the back swipe in a right-to-left layout.',
              ),
            ),
            child: Text('Activity'),
          ),
          Tab(
            value: 'settings',
            content: Card(
              title: Text('Settings'),
              description: Text('Only owners can change these.'),
            ),
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }
}
```

## Tabs list

With no content, only the bar is shown. To pick a value this way, use a `SegmentedControl`, which a screen reader hears as radio buttons rather than tabs.

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
