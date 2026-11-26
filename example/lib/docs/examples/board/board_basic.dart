import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A board of three columns. The board reports each move through `onMove`
/// and the example carries it out on its own lists.
class BoardBasicExample extends StatefulWidget {
  const BoardBasicExample({super.key});

  @override
  State<BoardBasicExample> createState() => _BoardBasicExampleState();
}

class _BoardBasicExampleState extends State<BoardBasicExample> {
  final columns = <String, List<String>>{
    'To do': [
      'Write the launch post',
      'Review the pricing page',
      'Book the venue for the offsite',
      'Draft the Q3 roadmap',
    ],
    'In progress': [
      'Design the onboarding flow',
      'Fix the sign-up error on Safari',
    ],
    'Done': ['Set up analytics'],
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // A board fills the height it is given; each column scrolls its own
      // cards.
      height: 420,
      child: Board<String>(
        columns: [
          for (final MapEntry(key: name, value: tasks) in columns.entries)
            BoardColumn(id: name, label: name, items: tasks),
        ],
        itemBuilder: (context, task, details) => Card(child: Text(task)),
        onMove: (move) => setState(() {
          move.apply(columns[move.fromColumn]!, columns[move.toColumn]!);
        }),
      ),
    );
  }
}
