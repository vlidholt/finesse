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
