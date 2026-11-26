import 'package:example/docs/phone_frame.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A `TabBar` in the bar's `bottom` and a `TabBarView` as the body, on one
/// `TabsController`: tap a tab or swipe the page, and the other follows.
class AppBarTabsExample extends StatefulWidget {
  const AppBarTabsExample({super.key});

  @override
  State<AppBarTabsExample> createState() => _AppBarTabsExampleState();
}

class _AppBarTabsExampleState extends State<AppBarTabsExample> {
  static const _sections = {
    'Albums': ['Slow Tide', 'Paper Lanterns', 'Northbound', 'Glass Hours'],
    'Artists': ['Nora Vale', 'The Low Suns', 'Harbour', 'Iris Mae'],
    'Songs': ['Afterglow', 'Second Wind', 'Harbour Lights', 'Low Sun'],
  };

  final _tabs = TabsController<String>(value: 'Albums');

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      height: 460,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          bottom: TabBar<String>(
            controller: _tabs,
            // The bar draws the hairline under both rows.
            showBorder: false,
            tabs: [
              for (final name in _sections.keys)
                Tab(value: name, child: Text(name)),
            ],
          ),
        ),
        body: TabBarView<String>(
          controller: _tabs,
          pages: {
            for (final MapEntry(key: name, value: rows) in _sections.entries)
              name: (context) => ListView(
                children: [
                  for (final row in rows)
                    ListTile(title: Text(row), subtitle: Text(name)),
                ],
              ),
          },
        ),
      ),
    );
  }
}
