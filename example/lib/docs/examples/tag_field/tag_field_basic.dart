import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TagFieldBasicExample extends StatefulWidget {
  const TagFieldBasicExample({super.key});

  @override
  State<TagFieldBasicExample> createState() => _TagFieldBasicExampleState();
}

class _TagFieldBasicExampleState extends State<TagFieldBasicExample> {
  List<String> topics = ['design', 'motion'];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      // Enter or a comma turns the text into a tag; a pasted list becomes
      // that many. Backspace in the empty input marks the last tag, and
      // again removes it.
      child: TagField<String>(
        values: topics,
        placeholder: const Text('Add a topic'),
        semanticLabel: 'Topics',
        labelBuilder: (context, topic) => Text(topic),
        onChanged: (value) => setState(() => topics = value),
      ),
    );
  }
}
