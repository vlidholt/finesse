import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The same bar with `TabBarVariant.segmented`: a filled strip and a raised
/// pill. A tab takes a `leading` and a `trailing` widget, and can be
/// disabled.
class TabBarSegmentedExample extends StatefulWidget {
  const TabBarSegmentedExample({super.key});

  @override
  State<TabBarSegmentedExample> createState() => _TabBarSegmentedExampleState();
}

class _TabBarSegmentedExampleState extends State<TabBarSegmentedExample> {
  String folder = 'inbox';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.layoutTheme.gap(GapSize.lg),
      children: [
        TabBar<String>(
          variant: TabBarVariant.segmented,
          value: folder,
          onChanged: (value) => setState(() => folder = value),
          tabs: const [
            Tab(
              value: 'inbox',
              leading: PhosphorIcon(PhosphorIconsRegular.tray),
              trailing: IndicatorBadge(count: 4),
              child: Text('Inbox'),
            ),
            Tab(
              value: 'drafts',
              leading: PhosphorIcon(PhosphorIconsRegular.notePencil),
              child: Text('Drafts'),
            ),
            Tab(
              value: 'archive',
              leading: PhosphorIcon(PhosphorIconsRegular.archive),
              enabled: false,
              tooltip: 'Nothing archived yet',
              child: Text('Archive'),
            ),
          ],
        ),
        Text('Showing $folder', style: theme.textTheme.muted),
      ],
    );
  }
}
