# List Detail Layout

A list and the detail of what is chosen in it. On a desktop they are side by side; on a phone the list has the screen and the detail is pushed over it as a page. It follows the 

## Conversations

Give it the `list`, the `detail` of the current choice — or null — and a `placeholder` for the desktop while nothing is chosen. On a phone, setting `detail` pushes it with the page s transition and clearing it pops it; when the user goes "
          
          
          

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// One widget, two arrangements: side by side in the desktop frame, and
/// the detail pushed over the list in the phone frame.
class ListDetailLayoutBasicExample extends StatefulWidget {
  const ListDetailLayoutBasicExample({super.key});

  @override
  State<ListDetailLayoutBasicExample> createState() =>
      _ListDetailLayoutBasicExampleState();
}

class _ListDetailLayoutBasicExampleState
    extends State<ListDetailLayoutBasicExample> {
  static const _people = {
    'Ada Okafor': 'Can you look at the route tests before Friday?',
    'Jonas Lind': 'The rail looks right on the tablet now.',
    'Mei Tanaka': 'Shipping the tab bar this afternoon.',
  };

  /// Null until one is chosen: the frame starts as whatever the app is.
  FormFactor? chosen;
  String? open;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formFactor = chosen ?? theme.formFactor;
    final phone = formFactor == FormFactor.mobile;
    final gap = theme.layoutTheme.gap(GapSize.md);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Semantics(
          label: 'Frame',
          container: true,
          child: SegmentedControl<FormFactor>(
            value: formFactor,
            onChanged: (value) => setState(() => chosen = value),
            segments: const [
              Segment(value: FormFactor.desktop, label: Text('Desktop')),
              Segment(value: FormFactor.mobile, label: Text('Phone')),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: theme.withFormFactor(formFactor),
            child: Container(
              width: phone ? 340 : 680,
              height: 400,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: theme.radii.xl2,
              ),
              foregroundDecoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.border),
                borderRadius: theme.radii.xl2,
              ),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: ListDetailLayout(
                  listWidth: 260,
                  list: ListView(
                    padding: EdgeInsets.all(gap),
                    children: [
                      for (final name in _people.keys)
                        ListTile(
                          title: Text(name),
                          subtitle: Text(
                            _people[name]!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected: name == open,
                          onTap: () => setState(() => open = name),
                        ),
                    ],
                  ),
                  placeholder: Center(
                    child: Text(
                      'Choose a conversation',
                      style: theme.textTheme.muted,
                    ),
                  ),
                  // Keyed by the choice, so each has its own state.
                  detail: open == null
                      ? null
                      : _Conversation(
                          key: ValueKey(open),
                          name: open!,
                          message: _people[open]!,
                        ),
                  // The user went back on a phone: forget the choice.
                  onDetailClosed: () => setState(() => open = null),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Conversation extends StatelessWidget {
  const _Conversation({
    required this.name,
    required this.message,
    super.key,
  });

  final String name;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Over the list, the detail is a page: the bar shows the way back by
    // itself, and going back calls `onDetailClosed`. Beside the list it is
    // a pane, with nowhere to go back to.
    final phone = theme.formFactor == FormFactor.mobile;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: phone,
        title: Text(name),
      ),
      body: PageContainer(
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: Card(description: Text(message)),
        ),
      ),
    );
  }
}
```

