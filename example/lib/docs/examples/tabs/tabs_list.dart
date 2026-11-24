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
