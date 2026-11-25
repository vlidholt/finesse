import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Rows with controls of their own, dragged by their grips only
/// (`longPressToDrag: false`), built on demand in a list that scrolls: hold
/// a row near an edge and the list scrolls under it. A row keeps its state
/// — here, its switch — when it moves.
class ReorderableListViewHandlesExample extends StatefulWidget {
  const ReorderableListViewHandlesExample({super.key});

  @override
  State<ReorderableListViewHandlesExample> createState() =>
      _ReorderableListViewHandlesExampleState();
}

class _ReorderableListViewHandlesExampleState
    extends State<ReorderableListViewHandlesExample> {
  final sections = [
    for (final name in [
      'Summary',
      'Experience',
      'Education',
      'Skills',
      'Projects',
      'Publications',
      'Volunteering',
      'Languages',
      'Recommendations',
      'Interests',
    ])
      (name: name, shown: ValueNotifier(true)),
  ];

  @override
  void dispose() {
    for (final section in sections) {
      section.shown.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 320),
      child: Card(
        style: CardTheme(
          padding: EdgeInsets.zero,
          columnCrossAxisAlignment: CrossAxisAlignment.stretch,
          rowMainAxisSize: MainAxisSize.max,
        ),
        child: ReorderableListView.builder(
          padding: const EdgeInsets.all(8),
          longPressToDrag: false,
          itemCount: sections.length,
          // Which item is at an index, without building its row.
          itemId: (index) => sections[index].name,
          onReorder: (from, to) =>
              setState(() => sections.insert(to, sections.removeAt(from))),
          itemSemanticLabel: (index) => sections[index].name,
          itemBuilder: (context, index) {
            final section = sections[index];
            return ListTile(
              leading: const ReorderableDragHandle(),
              title: Text(section.name),
              trailing: ValueListenableBuilder(
                valueListenable: section.shown,
                builder: (context, shown, _) => Semantics(
                  label: 'Show ${section.name}',
                  child: Switch(
                    value: shown,
                    onChanged: (value) => section.shown.value = value,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
