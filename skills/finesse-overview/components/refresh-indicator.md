# Refresh Indicator

Pull a list down past its top to refresh it. A small circle comes down with the pull, pops when letting go will refresh, and spins until the refresh is done.

## Pull to refresh

Drag the list down with a finger or a trackpad. It follows both kinds of scroll physics: a list that stops at its top and one that bounces. A mouse wheel cannot pull, so the button in the header calls `show()` on the `RefreshIndicatorState`. A list that may be shorter than its viewport takes `AlwaysScrollableScrollPhysics`.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// An inbox that refreshes when pulled down — and, for a mouse, from the
/// button in its header, which calls `show()` on the indicator's state.
class RefreshIndicatorBasicExample extends StatefulWidget {
  const RefreshIndicatorBasicExample({super.key});

  @override
  State<RefreshIndicatorBasicExample> createState() =>
      _RefreshIndicatorBasicExampleState();
}

class _RefreshIndicatorBasicExampleState
    extends State<RefreshIndicatorBasicExample> {
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  final messages = [
    ('Omar Rahimi', 'The research readout moved to Thursday.'),
    ('Mei Tanaka', 'Sent you the interview notes.'),
    ('Claire Dubois', 'Can you review the audit before Friday?'),
    ('Julian Reyes', 'Lunch next week?'),
  ];
  int fetched = 0;

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() {
      fetched++;
      messages.insert(0, ('Demo', 'New message number $fetched'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380, maxHeight: 380),
      child: Card(
        style: CardTheme(
          padding: EdgeInsets.zero,
          columnCrossAxisAlignment: CrossAxisAlignment.stretch,
          rowMainAxisSize: MainAxisSize.max,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: theme.layoutTheme.gap(GapSize.lg),
                end: theme.layoutTheme.gap(GapSize.sm),
                top: theme.layoutTheme.gap(GapSize.sm),
                bottom: theme.layoutTheme.gap(GapSize.sm),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Inbox', style: theme.textTheme.large),
                  ),
                  IconButton.ghost(
                    semanticLabel: 'Refresh',
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.arrowClockwise,
                    ),
                    onPressed: () => refreshKey.currentState?.show(),
                  ),
                ],
              ),
            ),
            const Divider(margin: EdgeInsets.zero),
            Expanded(
              child: RefreshIndicator(
                key: refreshKey,
                onRefresh: _refresh,
                // The card has no status bar above it.
                edgeOffset: 0,
                child: ListView.builder(
                  // A list shorter than its viewport still has to scroll
                  // for a pull to register.
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final (name, text) = messages[index];
                    return ListTile(
                      leading: Avatar('', fallback: Text(name[0])),
                      title: Text(name),
                      subtitle: Text(text),
                      onTap: () {},
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```
