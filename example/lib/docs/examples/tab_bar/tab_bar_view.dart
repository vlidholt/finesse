import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A bar in one place and its pages in another, on one `TabsController`:
/// swipe the page and the line under the tabs goes with the finger.
class TabBarViewExample extends StatefulWidget {
  const TabBarViewExample({super.key});

  @override
  State<TabBarViewExample> createState() => _TabBarViewExampleState();
}

class _TabBarViewExampleState extends State<TabBarViewExample> {
  static const _sections = {
    'Posts': ['Shipping the new editor', 'What we learned in beta'],
    'Replies': ['Agreed, and the docs say so', 'Try the nightly build'],
    'Media': ['Launch day', 'The team offsite', 'Whiteboard, week 12'],
  };

  final tabs = TabsController<String>(value: 'Posts');

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A phone-sized frame: swiping is a touch gesture, so try it with a
    // finger or a trackpad.
    return Theme(
      data: theme.withFormFactor(FormFactor.mobile),
      child: Container(
        width: 340,
        height: 420,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: theme.radii.xl2),
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: theme.radii.xl2,
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppBar(title: Text('Ada Okafor')),
              TabBar<String>(
                controller: tabs,
                tabs: [
                  for (final name in _sections.keys)
                    Tab(value: name, child: Text(name)),
                ],
              ),
              Expanded(
                child: TabBarView<String>(
                  controller: tabs,
                  pages: {
                    for (final MapEntry(key: name, value: rows)
                        in _sections.entries)
                      name: (context) => ListView(
                        padding: EdgeInsets.all(
                          theme.layoutTheme.gap(GapSize.md),
                        ),
                        children: [
                          for (final row in rows)
                            ListTile(
                              title: Text(row),
                              subtitle: Text(name),
                            ),
                        ],
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
