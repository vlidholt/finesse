import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Rows with no grip: the whole row is the handle, as a card is on a
/// board. Drag one with the mouse, or press and hold it with a finger. A
/// click is still a click. With the keyboard, Tab to a row and press Space.
class ReorderableListViewNoHandlesExample extends StatefulWidget {
  const ReorderableListViewNoHandlesExample({super.key});

  @override
  State<ReorderableListViewNoHandlesExample> createState() =>
      _ReorderableListViewNoHandlesExampleState();
}

class _ReorderableListViewNoHandlesExampleState
    extends State<ReorderableListViewNoHandlesExample> {
  final priorities = [
    (PhosphorIconsRegular.rocketLaunch, 'Ship the beta', 'Due Friday'),
    (PhosphorIconsRegular.usersThree, 'Hire a designer', 'Three interviews'),
    (PhosphorIconsRegular.chartLineUp, 'Grow activation', 'Up to 40%'),
    (PhosphorIconsRegular.lifebuoy, 'Halve support tickets', 'This quarter'),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        style: CardTheme(
          padding: const EdgeInsets.all(8),
          columnCrossAxisAlignment: CrossAxisAlignment.stretch,
          rowMainAxisSize: MainAxisSize.max,
        ),
        child: ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (from, to) => setState(
            () => priorities.insert(to, priorities.removeAt(from)),
          ),
          itemSemanticLabel: (index) => priorities[index].$2,
          children: [
            for (final (index, (icon, title, detail)) in priorities.indexed)
              ListTile(
                key: ValueKey(title),
                leading: IconTile(icon: PhosphorIcon(icon)),
                title: Text(title),
                subtitle: Text(detail),
                trailing: Badge.secondary(child: Text('#${index + 1}')),
                onTap: () {},
              ),
          ],
        ),
      ),
    );
  }
}
