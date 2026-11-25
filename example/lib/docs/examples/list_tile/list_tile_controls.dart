import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Rows that are controls: a tap anywhere on the row flips the switch,
/// ticks the box or picks the radio, and a screen reader meets one control
/// named by the row's title.
class ListTileControlsExample extends StatefulWidget {
  const ListTileControlsExample({super.key});

  @override
  State<ListTileControlsExample> createState() =>
      _ListTileControlsExampleState();
}

class _ListTileControlsExampleState extends State<ListTileControlsExample> {
  bool receipts = true;
  final topics = {'Design': true, 'Research': false, 'Hiring': true};
  String density = 'Comfortable';

  /// All, none, or — null — some of the topics.
  bool? get _all {
    final on = topics.values.where((value) => value).length;
    if (on == 0) return false;
    return on == topics.length ? true : null;
  }

  @override
  Widget build(BuildContext context) {
    final overline = Theme.of(context).style.overline;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: FinesseColumn(
        gap: GapSize.lg,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListSection(
            children: [
              SwitchListTile(
                title: const Text('Read receipts'),
                subtitle: const Text(
                  'Let people see when you have read their message',
                ),
                value: receipts,
                onChanged: (value) => setState(() => receipts = value),
              ),
            ],
          ),
          ListSection(
            header: Text(overline.applyCase('Topics')),
            children: [
              CheckboxListTile(
                title: const Text('All topics'),
                tristate: true,
                value: _all,
                controlAffinity: ControlAffinity.leading,
                // A mixed box, like an empty one, selects everything.
                onChanged: (_) => setState(() {
                  final next = _all != true;
                  topics.updateAll((_, _) => next);
                }),
              ),
              for (final topic in topics.keys)
                CheckboxListTile(
                  title: Text(topic),
                  value: topics[topic],
                  controlAffinity: ControlAffinity.leading,
                  onChanged: (value) =>
                      setState(() => topics[topic] = value ?? false),
                ),
            ],
          ),
          ListSection(
            header: Text(overline.applyCase('Density')),
            children: [
              for (final option in ['Compact', 'Comfortable', 'Spacious'])
                RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: density,
                  onChanged: (value) => setState(() => density = value!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
