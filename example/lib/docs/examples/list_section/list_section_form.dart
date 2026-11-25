import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A form laid out as a section: each row a `ListTile` with its control as
/// the trailing widget — a text field, a select, a switch.
class ListSectionFormExample extends StatefulWidget {
  const ListSectionFormExample({super.key});

  @override
  State<ListSectionFormExample> createState() => _ListSectionFormExampleState();
}

class _ListSectionFormExampleState extends State<ListSectionFormExample> {
  final name = TextEditingController(text: 'Maya Lindqvist');
  String language = 'English';
  bool public = true;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overline = Theme.of(context).style.overline;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: ListSection(
        header: Text(overline.applyCase('Profile')),
        headerTrailing: Button.link(
          size: ButtonSize.sm,
          onPressed: () {},
          child: const Text('Preview'),
        ),
        footer: const Text('Your name is shown on everything you post.'),
        children: [
          ListTile(
            title: const ExcludeSemantics(child: Text('Name')),
            trailing: SizedBox(
              width: 200,
              child: Semantics(
                label: 'Name',
                child: TextField(controller: name),
              ),
            ),
          ),
          ListTile(
            title: const ExcludeSemantics(child: Text('Language')),
            trailing: Semantics(
              label: 'Language',
              child: Select<String>(
                initialValue: language,
                minWidth: 200,
                options: [
                  for (final option in ['English', 'Svenska', 'Deutsch'])
                    SelectOption(value: option, child: Text(option)),
                ],
                selectedOptionBuilder: (context, value) => Text(value),
                onChanged: (value) {
                  if (value != null) setState(() => language = value);
                },
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Public profile'),
            subtitle: const Text('Anyone on Strand can find you'),
            value: public,
            onChanged: (value) => setState(() => public = value),
          ),
        ],
      ),
    );
  }
}
