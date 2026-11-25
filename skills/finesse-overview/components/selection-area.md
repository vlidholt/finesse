# Selection Area

Makes the text under it selectable as one selection across widgets. A mouse drags and right-clicks for Copy; a touch screen long-presses and gets the handles, the `TextSelectionToolbar` and the `TextMagnifier` that text fields use.

## Default

Every `Text` under the area takes part. On iOS and Android the handles and the toolbar appear on a long press.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SelectionAreaBasicExample extends StatelessWidget {
  const SelectionAreaBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      // One selection runs from the heading through the paragraph: drag
      // with a mouse, or long-press a word on a touch screen.
      child: SelectionArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Release notes', style: theme.textTheme.h4),
            const Gap.sm(),
            Text(
              'Text fields now show selection handles, a toolbar and a '
              'magnifier on a touch screen.',
              style: theme.textTheme.p,
            ),
            const Gap.sm(),
            Text(
              'Everything on this card can be copied in one go.',
              style: theme.textTheme.muted,
            ),
          ],
        ),
      ),
    );
  }
}
```

## Excluding content

`SelectionContainer.disabled` keeps a part out of the selection; `onSelectionChanged` reports what is selected.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SelectionAreaExcludedExample extends StatefulWidget {
  const SelectionAreaExcludedExample({super.key});

  @override
  State<SelectionAreaExcludedExample> createState() =>
      _SelectionAreaExcludedExampleState();
}

class _SelectionAreaExcludedExampleState
    extends State<SelectionAreaExcludedExample> {
  String selected = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectionArea(
            onSelectionChanged: (content) {
              setState(() => selected = content?.plainText ?? '');
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite code',
                  style: theme.textTheme.small,
                ),
                const Gap.xs(),
                Text('FINESSE-2026-TEAL', style: theme.textTheme.large),
                const Gap.sm(),
                // Chrome that should not end up on the clipboard.
                const SelectionContainer.disabled(
                  child: Badge.secondary(child: Text('Expires in 3 days')),
                ),
              ],
            ),
          ),
          const Gap.md(),
          Text(
            selected.isEmpty
                ? 'Nothing selected'
                : '${selected.length} characters selected',
            style: theme.textTheme.caption,
          ),
        ],
      ),
    );
  }
}
```
