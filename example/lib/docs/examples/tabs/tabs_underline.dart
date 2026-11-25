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
